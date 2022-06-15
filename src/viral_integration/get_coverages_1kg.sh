#!/bin/bash
#SBATCH --job-name=get_coverages_1kg
#SBATCH --partition=owners
#SBATCH --output=/scratch/users/briannac/logs/get_coverages_1kg.out
#SBATCH --error=/scratch/users/briannac/logs/get_coverages_1kg.err
#SBATCH --time=20:00:00
#SBATCH --mem=200GB
####SBATCH --cpus-per-task=5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/viral_integration/get_coverages_1kg.sh

ml python/3.6.1
ml py-scikit-learn/0.19.1_py36

python3.6 -u $MY_HOME/blood_microbiome/src/viral_integration/get_coverages_1kg.py

