#!/bin/bash
#SBATCH --job-name=shared_kmers
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/shared_kmers.out
#SBATCH --error=/scratch/users/briannac/logs/shared_kmers.err
#SBATCH --time=01:00:00
#SBATCH --mem=50GB   
#SBATCH --cpus-per-task=16
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu


### Note: Took 36 min and 24 GB of mem last time.

### file at /home/groups/dpwall/briannac/blood_microbiome/src/y_chrom_association/shared_kmers.sh

module load biology
module load jellyfish

intermediate_dir=$MY_HOME/blood_microbiome/intermediate_files/y_chrom_association


#### UNMAPPED READS

# Get list of kmers that were in at least 2 samples.
echo "jellyfish count..."
jellyfish count -t $SLURM_CPUS_PER_TASK -m 100 -L 2 -s 1000M -o $intermediate_dir/kmers.sex_microbes.jf $intermediate_dir/*.jellyfish.sex_microbes.fa

# Dump kmer count .jf to .fasta.
echo "jellyfish dump..."
jellyfish dump $intermediate_dir/kmers.sex_microbes.jf  > $intermediate_dir/kmers.sex_microbes.fasta

# Print all sequences to a list (take away >___ header)
echo "print to list..."
awk 'NR % 2 == 0' $intermediate_dir/kmers.sex_microbes.fasta > $intermediate_dir/kmers.sex_microbes.list


### Note: This resulted in 23,038,807 shared kmers.
