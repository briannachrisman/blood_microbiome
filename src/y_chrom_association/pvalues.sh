#!/bin/sh
#SBATCH --job-name=microbes_ychrom_association
#SBATCH --partition=owners
#SBATCH --array=65
#SBATCH --output=/scratch/users/briannac/logs/microbes_ychrom_association_%a.out
#SBATCH --error=/scratch/users/briannac/logs/microbes_ychrom_association_%a.err
#SBATCH --time=1:00:00
#SBATCH --mem=5GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at $MY_HOME/blood_microbiome/src/y_chrom_association/pvalues.sh
# 232 files to parse.
ml python/3.6.1
# SLURM_ARRAY_TASK_ID=1
N=$((SLURM_ARRAY_TASK_ID-1))
echo $N
python3.6 -u $MY_HOME/blood_microbiome/src/y_chrom_association/pvalues.py $N
