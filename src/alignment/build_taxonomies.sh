#!/bin/bash
#SBATCH --job-name=build_taxonomies
#SBATCH --partition=owners
#SBATCH --output=/scratch/users/briannac/logs/build_taxonomies.out
#SBATCH --error=/scratch/users/briannac/logs/build_taxonomies.err
#SBATCH --time=00:10:00
#SBATCH --mem=54GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at $MY_HOME/blood_microbiome/src/alignment/build_taxonomies.sh

# Run this get_unfinished_microbes to get samples that have not been finished yet.

echo "Building taxonomies..."
/oak/stanford/groups/dpwall/computeEnvironments/kraken2/kraken2_installation/kraken2-inspect --report-zero-counts \
--db  /oak/stanford/groups/dpwall/computeEnvironments/kraken2/kraken2-db > $MY_HOME/blood_microbiome/data/kraken_align/taxonomies.tsv

/oak/stanford/groups/dpwall/computeEnvironments/kraken2/kraken2_installation/kraken2-inspect --use-mpa-style --report-zero-counts \
--db  /oak/stanford/groups/dpwall/computeEnvironments/kraken2/kraken2-db > $MY_HOME/blood_microbiome/data/kraken_align/taxonomies_mpa.tsv