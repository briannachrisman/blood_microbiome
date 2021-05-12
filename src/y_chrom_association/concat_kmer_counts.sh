#!/bin/sh
#SBATCH --job-name=concat_kmer_counts
#SBATCH --partition=dpwall
#SBATCH --array=6-231%30
#SBATCH --output=/scratch/users/briannac/logs/concat_kmer_counts_%a.out
#SBATCH --error=/scratch/users/briannac/logs/concat_kmer_counts_%a.err
#SBATCH --time=10:00:00
#SBATCH --mem=1G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/y_chrom_association/concat_kmer_counts.sh

for i in 0; do # NOTE: 231 regions to process 
    N=$((SLURM_ARRAY_TASK_ID+i))
    N=$(printf "%04g" $N)
    echo "pasting..."
    for file in /home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association/*.query_counts.sex_microbes.$N.txt; do
        sed '/[*]/d' -i $file
        echo 'cleaned up' $file
    done
    
    paste /home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association/*.query_counts.sex_microbes.$N.txt > /home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association/query_counts.sex_microbes.$N.tsv
done