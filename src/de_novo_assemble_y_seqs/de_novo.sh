#!/bin/bash
#SBATCH --job-name=de_novo_microbe_sex_reads
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/de_novo_microbe_sex_reads.out
#SBATCH --error=/scratch/users/briannac/logs/de_novo_microbe_sex_reads.err
#SBATCH --time=10:00:00
#SBATCH --mem=10GB
####SBATCH --cpus-per-task=5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/de_novo_assemble_y_seqs/de_novo.sh



cd /home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association/denovo


# Concat all reads together.
cat 07C69752.reads_from_male_kmers.fastq > reads_from_male_kmers.fastq
cat 07C69752.reads_from_female_kmers.fastq > reads_from_female_kmers.fastq

# De novo assemble.
\rm reads_from_female_kmers_denovo -r
\rm reads_from_male_kmers_denovo -r
megahit -r reads_from_female_kmers.fastq -o  reads_from_female_kmers_denovo
megahit -r reads_from_male_kmers.fastq -o  reads_from_male_kmers_denovo