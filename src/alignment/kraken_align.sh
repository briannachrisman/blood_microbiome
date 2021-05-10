#!/bin/bash
#SBATCH --job-name=kraken_align
#SBATCH --partition=owners
#SBATCH --array=11-77
#SBATCH --output=/scratch/users/briannac/logs/kraken_align_%a.out
#SBATCH --error=/scratch/users/briannac/logs/kraken_align_%a.err
#SBATCH --time=3:00:00
#SBATCH --mem=54GB
####SBATCH --cpus-per-task=5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/alignment/kraken_align.sh

### SLURM_ARRAY_TASK_ID=1 ### CHANGE WHEN RUNNING BATCH!!!

################
# Note: Before kicking off, run 

#find $MY_HOME//blood_microbiome/intermediate_files/kraken_align/*_all.bracken -size 0 -print -delete

python3.6 $MY_HOME/general_scripts/slurm_and_batch_resources/unfinished_samples.py \
$MY_HOME/blood_microbiome/intermediate_files/kraken_align/ \
_all.report \
$MY_HOME/general_data/samples_and_batches.tsv \
$MY_HOME/blood_microbiome/intermediate_files/kraken_align/sample_and_batch_unfinished.tsv
################


###############################################################################
###### Note $MY_HOME/blood_microbiome/intermediate_files/kraken_align/* #######
###### has been archived in gdrive/sherlock_archive/kraken_align.tar.gz #######
###############################################################################


unfinished_samples_and_batches=$MY_HOME/blood_microbiome/intermediate_files/kraken_align/sample_and_batch_unfinished.tsv
intermediate_file_dir=$MY_HOME/blood_microbiome/intermediate_files/kraken_align
#final_file_dir=$MY_HOME/blood_microbiome/results/kraken_align
cd $SCRATCH/tmp
for I_TO_ADD in 0 
do
    N=$((SLURM_ARRAY_TASK_ID + I_TO_ADD))
    head -n $N $unfinished_samples_and_batches | tail -n 1 > $SCRATCH/tmp/tmp_kraken_align_$SLURM_ARRAY_TASK_ID.txt
    while read SAMPLE BATCH; do
        # Replace 
        echo $SAMPLE $BATCH
            
        if [ ! -f "${intermediate_file_dir}/$SAMPLE.tmp.fastq" ]; then
            echo "FASTQ of single ends..."
            samtools fastq  s3://ihart-ms2/unmapped/$BATCH/${SAMPLE/_LCL/-LCL}/${SAMPLE/_LCL/-LCL}.final.single.aln_all.bam > ${intermediate_file_dir}/$SAMPLE.tmp.fastq
        fi
            
        if [ ! -f "${intermediate_file_dir}/${SAMPLE}_1.tmp.fastq" ]; then
            echo "FASTQ for paired ends..."
            # Paired-end pipeline
            echo "samtools fastq..."
            samtools fastq -N -1 ${intermediate_file_dir}/${SAMPLE}_1.tmp.fastq -2 ${intermediate_file_dir}/${SAMPLE}_2.tmp.fastq \
            s3://ihart-ms2/unmapped/$BATCH/${SAMPLE/_LCL/-LCL}/${SAMPLE/_LCL/-LCL}.final.paired.aln_all.bam
        fi
            
        if [ ! -f "${intermediate_file_dir}/${SAMPLE}_all.report" ]; then
            echo "Running kraken..."
            /oak/stanford/groups/dpwall/computeEnvironments/kraken2/kraken2_installation/kraken2 \
            --db $MY_HOME/blood_microbiome/intermediate_files/kraken_align/kraken2-db/kraken2-db \
            --unclassified-out  ${intermediate_file_dir}/$SAMPLE.unclassified.fastq \
            --classified-out  ${intermediate_file_dir}/$SAMPLE.classified.fastq \
            --use-names --output ${intermediate_file_dir}/${SAMPLE}_all.kraken \
            --report ${intermediate_file_dir}/${SAMPLE}_all.report --report-zero-counts \
            ${intermediate_file_dir}/$SAMPLE.tmp.fastq ${intermediate_file_dir}/${SAMPLE}_1.tmp.fastq ${intermediate_file_dir}/${SAMPLE}_2.tmp.fastq 
        fi
        
       # if [ ! -f "${intermediate_file_dir}/${SAMPLE}.species.bracken" ]; then
       #     python /oak/stanford/groups/dpwall/computeEnvironments/Bracken-2.5/src/est_abundance.py \
       #     -i ${intermediate_file_dir}/${SAMPLE}_all.report \
       #     -k /oak/stanford/groups/dpwall/computeEnvironments/Bracken-2.5/database/database150mers.kmer_distrib \
       #     -o ${intermediate_file_dir}/${SAMPLE}.species.bracken -l S 
       # fi

    \rm ${intermediate_file_dir}/${SAMPLE}*tmp*
    done < $SCRATCH/tmp/tmp_kraken_align_$SLURM_ARRAY_TASK_ID.txt
    \rm $SCRATCH/tmp/tmp_kraken_align_$SLURM_ARRAY_TASK_ID.txt
done


for i in $(ls /home/groups/dpwall/briannac/blood_microbiome/intermediate_files/kraken_align/*_2.tmp.fastq); do
if [[ $(head $i  | grep -e '\/2') ]]; then
donothing=True
else
echo ${i/_2.tmp.fastq}
#3\rm ${i/_2.tmp.fastq/}*
fi
done