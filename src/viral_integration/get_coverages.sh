#!/bin/bash
#SBATCH --job-name=get_coverages
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/get_coverages.out
#SBATCH --error=/scratch/users/briannac/logs/get_coverages.err
#SBATCH --time=10:00:00
#SBATCH --mem=200GB
####SBATCH --cpus-per-task=5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/viral_integration/get_coverages.sh

ml python/3.6.1
ml py-scikit-learn/0.19.1_py36

python3.6 -u $MY_HOME/blood_microbiome/src/viral_integration/get_coverages.py

