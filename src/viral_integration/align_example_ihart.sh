#!/bin/bash
#SBATCH --job-name=align_example_ihart
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/align_example_ihart.out
#SBATCH --error=/scratch/users/briannac/logs/align_example_ihart.err
#SBATCH --time=10:00:00
#SBATCH --mem=10GB
####SBATCH --cpus-per-task=5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/viral_integration/align_example_ihart.sh

REF_GENOMES=/home/groups/dpwall/briannac/blood_microbiome/data/reference_genomes/hg38_and_herpes.fa

cd $SCRATCH/tmp
        SAMPLE=07C66849
        FILE=s3://ihart-hg38/cram/07C66849.final.cram
        
        echo $FILE  $SAMPLE
        # Setup directories.
        intermediate_dir=$MY_HOME/blood_microbiome/intermediate_files/example_ihart/${SAMPLE}
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
