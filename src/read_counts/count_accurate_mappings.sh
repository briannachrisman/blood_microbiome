#!/bin/bash
#SBATCH --job-name=count_accurate_mappings
#SBATCH --partition=owners
#SBATCH --array=1
#SBATCH --output=/scratch/users/briannac/logs/count_accurate_mappings_%a.out
#SBATCH --error=/scratch/users/briannac/logs/count_accurate_mappings_%a.err
#SBATCH --time=2:00:00
#SBATCH --mem=10GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/read_counts/count_accurate_mappings.sh

module load py-numpy/1.14.3_py36
all_samples_and_batches=/oak/stanford/groups/dpwall/users/briannac/general_data/samples_and_batches.tsv
unfinished_samples_and_batches=/scratch/users/briannac/blood_microbiome/intermediate_files/read_counts/samples_and_batches_not_finished.tsv

# Run this before running this script to get samples that have not been finished yet.
# module load py-numpy/1.14.3_py36
# python3 -u /home/groups/dpwall/briannac/blood_microbiome/src/read_counts/unfinished_samples_and_batches.py $MY_SCRATCH/blood_microbiome/intermediate_files/read_counts .alt_hap.txt /scratch/users/briannac/blood_microbiome/intermediate_files/read_counts/samples_and_batches_not_finished.tsv

cd $SCRATCH/tmp
for I_TO_ADD in 0 #1000 2000 3000 4000
do
    N=$((SLURM_ARRAY_TASK_ID + I_TO_ADD))
    head -n $N $unfinished_samples_and_batches | tail -n 1 > $SCRATCH/tmp/tmp_$SLURM_ARRAY_TASK_ID.txt
    while read sample batch; do
        echo $sample $batch
        if [ ! -f "/scratch/users/briannac/blood_microbiome/intermediate_files/read_counts/$sample.alt_hap.txt" ]; then
            python3 -u /home/groups/dpwall/briannac/blood_microbiome/src/read_counts/count_accurate_mappings.py $sample $batch
            \rm $SCRATCH/tmp/tmp_$SLURM_ARRAY_TASK_ID.txt
            \rm $SCRATCH/tmp/$sample*
        fi
    done < $SCRATCH/tmp/tmp_$SLURM_ARRAY_TASK_ID.txt
done