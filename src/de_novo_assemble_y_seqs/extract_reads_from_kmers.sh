#!/bin/bash
#SBATCH --job-name=kmers_from_unmapped_reads
#SBATCH --partition=owners
#SBATCH --array=1-100
#SBATCH --output=/scratch/users/briannac/logs/extract_reads_from_kmers_%a.out
#SBATCH --error=/scratch/users/briannac/logs/extract_reads_from_kmers_%a.err
#SBATCH --time=00:02:00
#SBATCH --mem=1GB
####SBATCH --cpus-per-task=5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/de_novo_assemble_y_seqs/extract_reads_from_kmers.sh

###########
# Note: Before kicking off batch, run 

#python3.6 $MY_HOME/general_scripts/slurm_and_batch_resources/unfinished_samples.py $MY_HOME/blood_microbiome/intermediate_files/y_chrom_association/denovo/ .reads_from_female_kmers.fastq $MY_HOME/general_data/samples_and_batches.tsv $MY_SCRATCH/tmp/extract_reads.tsv

###########


ml python/3.6.1

# Directories of extracted fastq files.
unfinished_samples=$MY_SCRATCH/tmp/extract_reads.tsv

cd $SCRATCH/tmp
for I_TO_ADD in 0 1000 2000 3000
do
    N=$((SLURM_ARRAY_TASK_ID + I_TO_ADD))
    head -n $N $unfinished_samples | tail -n 1 > $SCRATCH/tmp/tmp_extract_reads.$SLURM_ARRAY_TASK_ID.txt
    while read SAMPLE BATCH; do
        echo $SAMPLE $BATCH
        python3 -u $MY_HOME/blood_microbiome/src/de_novo_assemble_y_seqs/extract_reads_from_kmers.py $SAMPLE
        
        
    done < $SCRATCH/tmp/tmp_extract_reads.$SLURM_ARRAY_TASK_ID.txt
    \rm $SCRATCH/tmp/tmp_extract_reads.$SLURM_ARRAY_TASK_ID.txt
done

