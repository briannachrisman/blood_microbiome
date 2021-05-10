#!/bin/bash
#SBATCH --job-name=f_regression
#SBATCH --array=1-1000%100
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/f_regression_%a.out
#SBATCH --error=/scratch/users/briannac/logs/f_regression_%a.err
#SBATCH --time=00:10:00
#SBATCH --mem=2G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at $MY_HOME/blood_microbiome/src/f_regression/f_regression.sh

# Run this get_unfinished_microbes to get samples that have not been finished yet.

cat $MY_HOME/blood_microbiome/intermediate_files/f_regression/*.txt > $MY_HOME/blood_microbiome/results/f_regression/f_regression_results.csv