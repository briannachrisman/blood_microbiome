#!/bin/bash
#SBATCH --job-name=lasso_virus
#SBATCH --array=1-84
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/lasso_virus%a.out
#SBATCH --error=/scratch/users/briannac/logs/lasso_virus%a.err
#SBATCH --time=00:10:00
#SBATCH --mem=10G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at $MY_HOME/blood_microbiome/src/lasso/lasso_virus.sh

# Run this get_unfinished_microbes to get samples that have not been finished yet.
ml python/3.6.1
ml py-scikit-learn/0.19.1_py36
SLURM_ARRAY_TASK_ID=1
BLOOD_MICROBIOME_DIR=/home/groups/dpwall/briannac/blood_microbiome/
UNFINISHED=$BLOOD_MICROBIOME_DIR/intermediate_files/lasso/unfinished_virus.txt

COLUMN=$(tail -n $SLURM_ARRAY_TASK_ID $UNFINISHED | head -n 1)
python3 -u $BLOOD_MICROBIOME_DIR/src/lasso/lasso.py "$COLUMN" 100 virus