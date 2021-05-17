#!/bin/sh
#SBATCH --job-name=organize_directories_y_chrom_mb
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/organize_directories_y_chrom_mb.out
#SBATCH --error=/scratch/users/briannac/logs/organize_directories_y_chrom_mb.err
#SBATCH --time=20:00:00
#SBATCH --mem=1G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/y_chrom_association/organize_directories.sh

cd /home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association
while read SAMPLE _; do
    if [ -f "$SAMPLE.query_counts.sex_microbes.0230.txt" ]; then
        echo "running" $SAMPLE
        mkdir $SAMPLE
        mv $SAMPLE.query_counts.sex_microbes.txt.gz $SAMPLE/$SAMPLE.query_counts.sex_microbes.txt.gz
        mv $SAMPLE.query_counts.sex_microbes.txt $SAMPLE/$SAMPLE.query_counts.sex_microbes.txt
        mv $SAMPLE.jellyfish.sex_microbes.jf $SAMPLE/$SAMPLE.jellyfish.sex_microbes.jf
        mv $SAMPLE.jellyfish.sex_microbes.fa $SAMPLE/$SAMPLE.jellyfish.sex_microbes.fa
        mv $SAMPLE.query_counts.sex_microbes.done $SAMPLE/$SAMPLE.query_counts.sex_microbes.done
        mv $SAMPLE.kraken_classes.tsv $SAMPLE/$SAMPLE.kraken_classes.tsv
        mv $SAMPLE.y_associated_seqs.fastq $SAMPLE/$SAMPLE.y_associated_seqs.fastq
        for i in {0..230}; do
            N=$(printf "%04g" $i)
            mv $SAMPLE.query_counts.sex_microbes.$N.txt $SAMPLE/$SAMPLE.query_counts.sex_microbes.$N.txt
        done
     fi
done < $MY_HOME/general_data/samples_and_batches.tsv
