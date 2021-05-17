#!/bin/sh
#SBATCH --job-name=concat_kmer_counts
#SBATCH --partition=dpwall
#SBATCH --array=1-232%10
#SBATCH --output=/scratch/users/briannac/logs/concat_kmer_counts_%a.out
#SBATCH --error=/scratch/users/briannac/logs/concat_kmer_counts_%a.err
#SBATCH --time=2:00:00
#SBATCH --mem=50G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/y_chrom_association/concat_kmer_counts.sh

N=$((SLURM_ARRAY_TASK_ID-1))
N=$(printf "%04g" $N)
if [ ! -f $MY_HOME/blood_microbiome/results/y_chrom_association/query_counts.sex_microbes/query_counts.sex_microbes.$N.tsv.gz ]; then
    mkdir $MY_SCRATCH/tmp/y_chrom_association/$N
    while read SAMPLE BATCH; do
        file=/home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association/$SAMPLE/$SAMPLE.query_counts.sex_microbes.$N.txt
        sed  '/[*]/d' $file > $MY_SCRATCH/tmp/y_chrom_association/$N/$SAMPLE.query_counts.sex_microbes.$N.txt
        echo 'cleaned up' $file
    done < $MY_HOME/general_data/samples_and_batches.tsv
    echo "pasting..."
    paste $MY_SCRATCH/tmp/y_chrom_association/$N/*.txt > $MY_SCRATCH/tmp/y_chrom_association/$N/query_counts.sex_microbes.$N.tsv
    gzip $MY_SCRATCH/tmp/y_chrom_association/$N/query_counts.sex_microbes.$N.tsv
    mv $MY_SCRATCH/tmp/y_chrom_association/$N/query_counts.sex_microbes.$N.tsv.gz $MY_HOME/blood_microbiome/results/y_chrom_association/query_counts.sex_microbes/query_counts.sex_microbes.$N.tsv.gz
    \rm $MY_SCRATCH/tmp/y_chrom_association/$N -r
fi


