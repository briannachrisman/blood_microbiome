#!/bin/sh
#SBATCH --job-name=concat_pvalues_microbes_ychrom_association
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/concat_microbes_pvalues_ychrom_association.out
#SBATCH --error=/scratch/users/briannac/logs/concat_microbes_pvalues_ychrom_association.err
#SBATCH --time=10:00:00
#SBATCH --mem=5GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at $MY_HOME/blood_microbiome/src/y_chrom_association/concat_pvalues.sh
ml python/3.6.1

cat $MY_HOME/blood_microbiome/intermediate_files/query_counts.sex_microbes.pvals/pvals.*.txt > $MY_HOME/blood_microbiome/intermediate_files/query_counts.sex_microbes.pvals/pvals.txt

cp $MY_HOME/blood_microbiome/intermediate_files/query_counts.sex_microbes.pvals/pvals.txt /home/groups/dpwall/briannac/blood_microbiome/results/y_chrom_association/pvals.txt