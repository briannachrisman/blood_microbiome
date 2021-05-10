#!/bin/bash
#SBATCH --job-name=f_regression
#SBATCH --array=1-504%100
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/f_regression_%a.out
#SBATCH --error=/scratch/users/briannac/logs/f_regression_%a.err
#SBATCH --time=00:10:00
#SBATCH --mem=2G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at $MY_HOME/blood_microbiome/src/f_regression/f_regression.sh

# Run this get_unfinished_microbes to get samples that have not been finished yet.

ml python/3.6.1
ml py-scikit-learn/0.19.1_py36

# Before running, run:
# python3.6 $MY_HOME/blood_microbiome/src/f_regression/get_unfinished_microbes.py

BLOOD_MICROBIOME_DIR=/home/groups/dpwall/briannac/blood_microbiome/
UNFINISHED=$BLOOD_MICROBIOME_DIR/intermediate_files/f_regression/unfinished_microbes.tsv


COLUMN=$(tail -n $SLURM_ARRAY_TASK_ID $UNFINISHED | head -n 1)
echo $COLUMN
python3 -u $BLOOD_MICROBIOME_DIR/src/f_regression/f_regression.py "$COLUMN"