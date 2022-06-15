#!/bin/bash
#SBATCH --job-name=realign_herpes
#SBATCH --partition=dpwall
#SBATCH --array=1-24
#SBATCH --output=/scratch/users/briannac/logs/realign_herpes_%a.out
#SBATCH --error=/scratch/users/briannac/logs/realign_herpes_%a.err
#SBATCH --time=10:00:00
#SBATCH --mem=30GB
####SBATCH --cpus-per-task=5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/viral_integration/realign_herpes.sh

### SLURM_ARRAY_TASK_ID=1 ### CHANGE WHEN RUNNING BATCH!!!



#Before kicking off batch, run 

#find $MY_HOME/blood_microbiome/intermediate_files/herpesvirus/*.paired_aligned_to_hg38_herpes.sam -size 0 -print -delete

#python3.6 $MY_HOME/general_scripts/slurm_and_batch_resources/unfinished_samples.py $MY_HOME/blood_microbiome/intermediate_files/herpesvirus/ .paired_aligned_to_hg38_herpes.sam $MY_HOME/general_data/samples_and_batches.tsv  $MY_HOME/blood_microbiome/intermediate_files/herpesvirus/sample_and_batch_unfinished.tsv 




###############################################################################
###### Note $MY_HOME/blood_microbiome/intermediate_files/herpesvirus/* #######
###### has been archived in gdrive/sherlock_archive/herpesvirus.tar.gz #######
###############################################################################


unfinished_samples_and_batches=$MY_HOME/blood_microbiome/intermediate_files/herpesvirus/sample_and_batch_unfinished.tsv
#SAMPLE=06C54347
#BATCH=batch_00016
REF_GENOMES=/home/groups/dpwall/briannac/blood_microbiome/data/reference_genomes/hg38_and_herpes.fa


#final_file_dir=$MY_HOME/blood_microbiome/results/kraken_align
cd $SCRATCH/tmp
for I_TO_ADD in 0
do
    N=$((SLURM_ARRAY_TASK_ID + I_TO_ADD))
    head -n $N $unfinished_samples_and_batches | tail -n 1 > $SCRATCH/tmp/tmp_realign_herpes_$SLURM_ARRAY_TASK_ID.txt
    while read SAMPLE BATCH; do
        
        echo $SAMPLE  $BATCH
        # Setup directories.
        KRAKEN_OUT_DIR=$MY_HOME/blood_microbiome/intermediate_files/kraken_align/${SAMPLE}
        intermediate_dir=$MY_HOME/blood_microbiome/intermediate_files/herpesvirus/${SAMPLE}
        
        # Get read IDS for KRAKEN reads mapping to herpes + their mates.
        grep "herpesvirus" ${KRAKEN_OUT_DIR}_all.kraken | cut -f2  > ${intermediate_dir}.read_ids.tmp.out
        echo "total reads: " $(wc -l ${intermediate_dir}.read_ids.tmp.out)
        grep "/1" ${intermediate_dir}.read_ids.tmp.out > ${intermediate_dir}.read_1_ids.tmp.out
        echo "r1: " $(wc -l ${intermediate_dir}.read_1_ids.tmp.out)
        grep "/2" ${intermediate_dir}.read_ids.tmp.out > ${intermediate_dir}.read_2_ids.tmp.out
        echo "r2: " $(wc -l ${intermediate_dir}.read_2_ids.tmp.out)

        # Concat read1 and read2 ids, and add '@' to front to help out grep.
        cat ${intermediate_dir}.read_1_ids.tmp.out ${intermediate_dir}.read_2_ids.tmp.out   > ${intermediate_dir}.paired_reads.tmp.out
        sed -i -e 's/^/@/' ${intermediate_dir}.paired_reads.tmp.out
        sed -i -e 's/\/1//' ${intermediate_dir}.paired_reads.tmp.out 
        sed -i -e 's/\/2//' ${intermediate_dir}.paired_reads.tmp.out 
        uniq ${intermediate_dir}.paired_reads.tmp.out  | sort > ${intermediate_dir}.paired_reads.unique.tmp.out
        mv ${intermediate_dir}.paired_reads.unique.tmp.out ${intermediate_dir}.paired_reads.tmp.out
        
        # Extract corresponding paired reads & bwa align.
        grep -F -f ${intermediate_dir}.paired_reads.tmp.out -A 3 ${KRAKEN_OUT_DIR}.classified.fastq  | sed  '/--/d' | grep '/1' -A 3  | sed  '/--/d' | sed -e 's/\/1//'  > ${intermediate_dir}.reads1.tmp.fastq # Paired reads, read1.
        grep -F -f ${intermediate_dir}.paired_reads.tmp.out -A 3 ${KRAKEN_OUT_DIR}.unclassified.fastq  | sed  '/--/d' | grep '/1' -A 3  | sed  '/--/d' | sed -e 's/\/1//'  >> ${intermediate_dir}.reads1.tmp.fastq # Paired reads, read1.
        
        cat ${intermediate_dir}.reads1.tmp.fastq | paste - - - - | sort -k1,1 -t " " | tr "\t" "\n" > ${intermediate_dir}.reads1.tmp.sorted.fastq
        
        grep -F -f ${intermediate_dir}.paired_reads.tmp.out -A 3 ${KRAKEN_OUT_DIR}.classified.fastq  | sed  '/--/d' | grep '/2' -A 3  | sed  '/--/d' | sed -e 's/\/2//'  > ${intermediate_dir}.reads2.tmp.fastq # Paired reads, read1.
        grep -F -f ${intermediate_dir}.paired_reads.tmp.out -A 3 ${KRAKEN_OUT_DIR}.unclassified.fastq  | sed  '/--/d' | grep '/2' -A 3  | sed  '/--/d' | sed -e 's/\/2//'  >> ${intermediate_dir}.reads2.tmp.fastq # Paired reads, read1.
        
        cat ${intermediate_dir}.reads2.tmp.fastq | paste - - - - | sort -k1,1 -t " " | tr "\t" "\n" > ${intermediate_dir}.reads2.tmp.sorted.fastq
        
        # BWA align reads to human+herpesviruses genomes to get mapping position.
        bwa mem $REF_GENOMES ${intermediate_dir}.reads1.tmp.sorted.fastq ${intermediate_dir}.reads2.tmp.sorted.fastq > ${intermediate_dir}.paired_aligned_to_hg38_herpes.sam # Paired reads.
        
        samtools view -F 0x800  -h  ${intermediate_dir}.paired_aligned_to_hg38_herpes.sam -o  ${intermediate_dir}.paired_aligned_to_hg38_herpes.primary.sam
        mv ${intermediate_dir}.paired_aligned_to_hg38_herpes.primary.sam ${intermediate_dir}.paired_aligned_to_hg38_herpes.sam

        
     
        # Extract single reads & bwa align.
        grep -v "/" ${intermediate_dir}.read_ids.tmp.out > ${intermediate_dir}.read_single_ids.tmp.out
        echo "single: " $(wc -l ${intermediate_dir}.read_single_ids.tmp.out)
        # Concat read1 and read2 ids, and add '@' to front to help out grep.
        sed -e 's/^/@/' ${intermediate_dir}.read_single_ids.tmp.out> ${intermediate_dir}.read_single_ids.to_realign.tmp.out 
        grep -F -f ${intermediate_dir}.read_single_ids.to_realign.tmp.out -A 3 ${KRAKEN_OUT_DIR}.classified.fastq  | sed  '/--/d' > ${intermediate_dir}.reads.tmp.fastq # Single reads.
        
        
        bwa mem $REF_GENOMES ${intermediate_dir}.reads.tmp.fastq > ${intermediate_dir}.single_aligned_to_hg38_herpes.sam # Single reads

        samtools view -F 0x800 -h ${intermediate_dir}.single_aligned_to_hg38_herpes.sam -o  ${intermediate_dir}.single_aligned_to_hg38_herpes.primary.sam
        mv ${intermediate_dir}.single_aligned_to_hg38_herpes.primary.sam ${intermediate_dir}.single_aligned_to_hg38_herpes.sam
        
        # Look up mappings for previously-bwa-aligned reads.
        grep -v "/" ${intermediate_dir}.read_ids.tmp.out > ${intermediate_dir}.read_single_ids.tmp.out
        samtools view s3://ihart-ms2/unmapped/$BATCH/${SAMPLE/_LCL/-LCL}/${SAMPLE/_LCL/-LCL}.final.map_unmap.bam -H > ${intermediate_dir}.single_original_alignment.sam
        samtools view s3://ihart-ms2/unmapped/$BATCH/${SAMPLE/_LCL/-LCL}/${SAMPLE/_LCL/-LCL}.final.map_unmap.bam | grep -F -w -f ${intermediate_dir}.read_single_ids.tmp.out >> ${intermediate_dir}.single_original_alignment.sam
        samtools view s3://ihart-ms2/unmapped/$BATCH/${SAMPLE/_LCL/-LCL}/${SAMPLE/_LCL/-LCL}.final.improper_highq.bam | grep -F -w -f ${intermediate_dir}.read_single_ids.tmp.out >> ${intermediate_dir}.single_original_alignment.sam
        
        
        \rm ${intermediate_dir}*.tmp*
    done < $SCRATCH/tmp/tmp_realign_herpes_$SLURM_ARRAY_TASK_ID.txt
    \rm $SCRATCH/tmp/tmp_realign_herpes_$SLURM_ARRAY_TASK_ID.txt
done




#for f in $MY_HOME/blood_microbiome/intermediate_files/herpesvirus/*.single_aligned_to_hg38_herpes.sam; do
#    echo $f
#    samtools view -F 0x800  -h  $f -o  ${f}.primary
#    mv ${f}.primary $f
#done


#i=0
#for f in $MY_HOME/blood_microbiome/intermediate_files/herpesvirus/*.paired_aligned_to_hg38_herpes.sam; do
#    (( i++ ))
#    echo $f $i
#    samtools view -F 