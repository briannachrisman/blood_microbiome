#!/bin/bash
#SBATCH --job-name=bacteria_associated_with_batch
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/bacteria_associated_with_batch.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/bacteria_associated_with_batch.err
#SBATCH --time=5:00:00
#SBATCH --mem=120G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/src/bacteria_associated_with_batch.sh

module load py-numpy/1.18.1_py36

# Create "hits" data frame for chromsome.
python3 -u /scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/src/bacteria_associated_with_batch.py