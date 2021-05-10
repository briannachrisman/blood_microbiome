#!/bin/bash
#SBATCH --job-name=unmapped_reads_distribution
#SBATCH --array=1-47
#SBATCH --partition=owners
#SBATCH --output=/scratch/users/briannac/logs/unmapped_reads_distribution_%a.out
#SBATCH --error=/scratch/users/briannac/logs/unmapped_reads_distribution_%a.err
#SBATCH --time=01:00:00
#SBATCH --mem=5G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at $MY_HOME/blood_microbiome/src/read_counts/unmapped_reads_distribution.sh

# Run this before running this script to get samples that have not been finished yet.
# module load py-numpy/1.14.3_py36
# python3 -u /home/groups/dpwall/briannac/blood_microbiome/src/read_counts/unfinished_samples_and_batches.py $MY_SCRATCH/blood_microbiome/intermediate_files/read_counts .unmapped.txt /scratch/users/briannac/blood_microbiome/intermediate_files/read_counts/samples_and_batches_not_finished.tsv

samples_and_batches=/scratch/users/briannac/blood_microbiome/intermediate_files/read_counts/samples_and_batches_not_finished.tsv
cd $MY_SCRATCH/tmp
for TO_ADD in 0; do
    N=$((SLURM_ARRAY_TASK_ID+TO_ADD))
    head -n $N $samples_and_batches | tail -n 1 > tmp.$N
    while read -r sample batch; do 
        echo $sample
        sample_replace="${sample/_LCL/-LCL}" 
        if [ ! -f "$MY_HOME/blood_microbiome/intermediate_files/read_counts/$sample.unmapped.txt" ]; then
            echo 'unmapped'
            n_unmapped_pre=$(aws s3 cp s3://ihart-ms2/unmapped/$batch/$sample_replace/$sample_replace.final_alignment_table.csv - | grep -o unmapped | wc -l) # Number of ultimately unmapped reads
            n_unmapped=$((n_unmapped_pre/2)) # Divide by 2 because we set read_start_pos='unmapped' if read is unmapped.
            echo $sample $n_unmapped > $MY_HOME/blood_microbiome/intermediate_files/read_counts/$sample.unmapped.txt
        fi
    done < tmp.$N
    \rm $sample_replace*.bai
done
\rm tmp.$N
