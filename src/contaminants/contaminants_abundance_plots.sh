#!/bin/bash
#SBATCH --job-name=contaminants_abundance_plots
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/contaminants_abundance_plots.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/contaminants_abundance_plots.err
#SBATCH --time=10:00:00
#SBATCH --mem=120G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/src/contaminants_abundance_plots.sh

ml py-numpy/1.18.1_py36

python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/src/contaminants_abundance_plots.py