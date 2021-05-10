#!/bin/bash
#SBATCH --job-name=aggregate_contig_counts
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/aggregate_contig_counts.out
#SBATCH --error=/scratch/users/briannac/logs/aggregate_contig_counts.err
#SBATCH --time=0:10:00
#SBATCH --mem=120GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/read_counts/aggregate_contig_counts.sh

ml py-numpy/1.18.1_py36

python3 -u /home/groups/dpwall/briannac/blood_microbiome/src/read_counts/aggregate_contig_counts.py
