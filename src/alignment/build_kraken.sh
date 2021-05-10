#!/bin/bash
#SBATCH --job-name=build_kraken
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/build_kraken.out
#SBATCH --error=/scratch/users/briannac/logs/build_kraken.err
#SBATCH --time=10:00:00
#SBATCH --mem=120GB
#SBATCH --cpus-per-task=8
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at $MY_HOME/blood_microbiome/src/alignment/build_kraken.sh

echo "kraken2 build..."
#/oak/stanford/groups/dpwall/computeEnvironments/kraken2/kraken2_installation/kraken2-build \
#--build --db /oak/stanford/groups/dpwall/computeEnvironments/kraken2/kraken2-db --threads $SLURM_CPUS_PER_TASK


KRAKEN2_DB=/oak/stanford/groups/dpwall/computeEnvironments/kraken2/kraken2-db
READ_LEN=150
KMER_LEN=35
THREADS=$SLURM_CPUS_PER_TASK

cd /oak/stanford/groups/dpwall/computeEnvironments/Bracken-2.5/database


echo "bracken build..."
/oak/stanford/groups/dpwall/computeEnvironments/Bracken-2.5/bracken-build -d ${KRAKEN2_DB}  -k 35 -l 150  -t $THREADS  

echo "kraken2..."
/oak/stanford/groups/dpwall/computeEnvironments/kraken2/kraken2_installation/kraken2 --db=${KRAKEN2_DB} --threads=$THREADS <( find -L ${KRAKEN2_DB}/library \( -name "*.fna" -o -name "*.fasta" -o -name "*.fa" \) -exec cat {} + ) > database.kraken

echo "kmer2read_distr"
/oak/stanford/groups/dpwall/computeEnvironments/Bracken-2.5/src/kmer2read_distr --seqid2taxid ${KRAKEN2_DB}/seqid2taxid.map --taxonomy ${KRAKEN2_DB}/taxonomy --kraken database.kraken --output database${READ_LEN}mers.kraken -k ${KMER_LEN} -l ${READ_LEN} -t ${THREADS}

echo "generate_kmer_distribution"
python /oak/stanford/groups/dpwall/computeEnvironments/Bracken-2.5/src/generate_kmer_distribution.py -i database${READ_LEN}mers.kraken -o database${READ_LEN}mers.kmer_distrib





