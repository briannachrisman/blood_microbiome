#!/bin/bash
#SBATCH --job-name=realign_herpes
#SBATCH --partition=owners
#SBATCH --array=1001-1006%300
#SBATCH --output=/scratch/users/briannac/logs/realign_herpes_%a.out
#SBATCH --error=/scratch/users/briannac/logs/realign_herpes_%a.err
#SBATCH --time=10:00:00
#SBATCH --mem=10GB
####SBATCH --cpus-per-task=5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/viral_integration/align_herpes_1kg.sh



unfinished_samples_and_batches=$MY_HOME/blood_microbiome/intermediate_files/1kg_herpes/unfinished_files.tsv
#SAMPLE=06C54347
#BATCH=batch_00016
REF_GENOMES=/home/groups/dpwall/briannac/blood_microbiome/data/reference_genomes/hg38_and_herpes.fa

cd $SCRATCH/tmp
for I_TO_ADD in 0
do
    N=$((SLURM_ARRAY_TASK_ID + I_TO_ADD))
    head -n $N $unfinished_samples_and_batches | tail -n 1 > $SCRATCH/tmp/tmp_realign_herpes_$SLURM_ARRAY_TASK_ID.txt
    while read SAMPLE FILE; do
        
        echo $FILE  $SAMPLE
        # Setup directories.
        intermediate_dir=$MY_HOME/blood_microbiome/intermediate_files/1kg_herpes/${SAMPLE}
        #intermediate_dir=$MY_HOME/blood_microbiome/intermediate_files/herpesvirus/${SAMPLE}
       echo "copying..."       
       aws s3 cp $FILE $SAMPLE.copy.tmp.cram

       echo "Extracting unmapped/mapped reads..."
       samtools view $SAMPLE.copy.tmp.cram -f 4 -F 8 -b > ${intermediate_dir}.to_remap1.tmp.bam
              
       echo "Extracting unmapped/unmapped reads..."
       samtools view $SAMPLE.copy.tmp.cram -f 4 -f 8 -b > ${intermediate_dir}.to_remap2.tmp.bam
       
       echo "Extracting mapped/unmapped reads..."
       samtools view $SAMPLE.copy.tmp.cram -F 4 -f 8  -b > ${intermediate_dir}.to_remap3_with_supp.tmp.bam
       samtools view ${intermediate_dir}.to_remap3_with_supp.tmp.bam -F 2048 -o ${intermediate_dir}.to_remap3.tmp.bam

       echo "Merging..."
       samtools merge -f ${intermediate_dir}.to_remap.tmp.bam ${intermediate_dir}.to_remap1.tmp.bam ${intermediate_dir}.to_remap3.tmp.bam ${intermediate_dir}.to_remap2.tmp.bam 
       samtools sort -n ${intermediate_dir}.to_remap.tmp.bam -o ${intermediate_dir}.sorted.tmp.bam
       
       echo "Converting to fastq..."
       samtools fastq -1 ${intermediate_dir}_1.tmp.fastq -2 ${intermediate_dir}_2.tmp.fastq ${intermediate_dir}.sorted.tmp.bam
     
       echo "bwa mem..."
       bwa mem -o ${intermediate_dir}.realigned.bam $REF_GENOMES ${intermediate_dir}_1.tmp.fastq ${intermediate_dir}_2.tmp.fastq 
    

        \rm *$SAMPLE.*ai
        \rm $SAMPLE.copy.tmp.cram
        \rm ${intermediate_dir}*.tmp.*
    done < $SCRATCH/tmp/tmp_realign_herpes_$SLURM_ARRAY_TASK_ID.txt
    \rm $SCRATCH/tmp/tmp_realign_herpes_$SLURM_ARRAY_TASK_ID.txt
done