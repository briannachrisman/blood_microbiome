#!/bin/bash
#SBATCH --job-name=query_kmers
#SBATCH --partition=dpwall
#SBATCH --array=1
#SBATCH --output=/scratch/users/briannac/logs/query_kmers_%a.out
#SBATCH --error=/scratch/users/briannac/logs/query_kmers_%a.err
#SBATCH --time=02:00:00
#SBATCH --mem=1GB
####SBATCH --cpus-per-task=5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/y_chrom_association/query_kmers.sh
###  SLURM_ARRAY_TASK_ID=1 ### CHANGE FOR BATCH ###
ml biology
ml jellyfish


# Before kicking off, run:
# python3.6 $MY_HOME/general_scripts/slurm_and_batch_resources/unfinished_samples.py $MY_HOME/blood_microbiome/intermediate_files/y_chrom_association/ .query_counts.sex_microbes.done $MY_HOME/general_data/samples_and_batches.tsv $MY_HOME/blood_microbiome/intermediate_files/y_chrom_association/query_kmers_unfinished.tsv


unfinished_samples=$MY_HOME/blood_microbiome/intermediate_files/y_chrom_association/query_kmers_unfinished.tsv

intermediate_dir=/home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association
### SLURM_ARRAY_TASK_ID=1
#SAMPLE=HI0203

cd $SCRATCH/tmp
for I_TO_ADD in 0
do
    N=$((SLURM_ARRAY_TASK_ID + I_TO_ADD))
    head -n $N $unfinished_samples | tail -n 1 > $SCRATCH/tmp/tmp_query_kmers_sex_microbes_$SLURM_ARRAY_TASK_ID.txt
    while read SAMPLE BATCH; do

        echo $SAMPLE
        # Put header (SAMPLE_ID) onto file.
        echo $SAMPLE > $intermediate_dir/$SAMPLE.query_counts.sex_microbes.txt
            
        # For each 'shared' k-mer, query number of kmers in sample's .jf file.
        xargs jellyfish query $intermediate_dir/$SAMPLE.jellyfish.sex_microbes.jf <$intermediate_dir/kmers.sex_microbes.list \
        | awk  '{print $2}'  >> $intermediate_dir/$SAMPLE.query_counts.sex_microbes.txt

        echo "done" > $intermediate_dir/$SAMPLE.query_counts.sex_microbes.done


    done < $SCRATCH/tmp/tmp_query_kmers_sex_microbes_$SLURM_ARRAY_TASK_ID.txt
done
