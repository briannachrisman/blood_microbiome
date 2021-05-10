#!/bin/bash
#SBATCH --job-name=kmers_from_unmapped_reads
#SBATCH --partition=dpwall
#SBATCH --array=2
#SBATCH --output=/scratch/users/briannac/logs/kmers_from_unmapped_reads_%a.out
#SBATCH --error=/scratch/users/briannac/logs/kmers_from_unmapped_reads_%a.err
#SBATCH --time=04:00:00
#SBATCH --mem=120GB
####SBATCH --cpus-per-task=5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/collect_kmers/kmers_from_y_associated_contigs.sh
SLURM_ARRAY_TASK_ID=2 ### CHANGE FOR BATCH ###

###########
# Note: Before kicking off batch, run 

#find $MY_HOME/blood_microbiome/intermediate_files/y_chrom_association/*jellyfish*fa -size 0 -print -delete

#python3.6 $MY_HOME/general_scripts/slurm_and_batch_resources/unfinished_samples.py $MY_HOME/blood_microbiome/intermediate_files/y_chrom_association/ .jellyfish.sex_microbes.fa $MY_HOME/general_data/samples_and_batches.tsv $MY_HOME/blood_microbiome/intermediate_files/y_chrom_association/kmers_from_unmapped_reads_unfinished.tsv

###########

ml biology
ml jellyfish
unfinished_samples=$MY_HOME/blood_microbiome/intermediate_files/y_chrom_association/kmers_from_unmapped_reads_unfinished.tsv

# Directories of extracted fastq files.
umapped_dir=/home/groups/dpwall/briannac/blood_microbiome/intermediate_files/kraken_align
intermediate_dir=$MY_HOME/blood_microbiome/intermediate_files/y_chrom_association
#sex_hg38_dir=/home/groups/dpwall/briannac/y_chromsome_mismappings/intermediate_files/y_chromsome_seqs

#intermediate_dir=/home/groups/dpwall/briannac/blood_microbiome/intermediate_files/kmers

cd $SCRATCH/tmp
for I_TO_ADD in 0 #1000 2000 3000
do
    N=$((SLURM_ARRAY_TASK_ID + I_TO_ADD))
    head -n $N $unfinished_samples | tail -n 1 > $SCRATCH/tmp/tmp_kmers_from_unmapped_reads_$SLURM_ARRAY_TASK_ID.txt
    while read SAMPLE BATCH; do
        echo $SAMPLE $BATCH
        
        # Kmers in unmapped reads.
        if [ ! -f "$MY_HOME/blood_microbiome/intermediate_files/kmers/$SAMPLE.jellyfish.unmapped_reads.fa" ]; then                        
            # Count kmers (depth >=2)
            depth=2
            echo "Counting kmers..."
            jellyfish count --canonical -m 100 -s 100M -L $depth $umapped_dir/${SAMPLE}.y_associated_seqs.fastq  \
            -o $MY_HOME/blood_microbiome/intermediate_files/kmers/$SAMPLE.jellyfish.sex_microbes.jf
            
            # Dump to fasta file.
            echo "dumping to fasta..."
            jellyfish dump $intermediate_dir/$SAMPLE.jellyfish.sex_microbes.jf > $intermediate_dir/$SAMPLE.jellyfish.sex_microbes.fa
            
            # Reformat to csv file
            echo "reformating file..."            
        fi
        
        # Kmers in sex-associated microbes
        #if [ ! -f "$MY_HOME/blood_microbiome/intermediate_files/kmers/$SAMPLE.jellyfish.sex_microbes.fa" ]; then                        
            # Count kmers (depth >=2)
        #    depth=2
        #    echo "Counting kmers..."
        #    jellyfish count --canonical -m 100 -s 100M -L $depth ${sex_microbes_dir}/${SAMPLE}.y_associated_seqs.fastq  -o $MY_HOME/blood_microbiome/intermediate_files/kmers/$SAMPLE.jellyfish.sex_microbes.jf
            
            # Dump to fasta file.
         #   echo "dumping to fasta..."
         #   jellyfish dump $intermediate_dir/$SAMPLE.jellyfish.sex_microbes.jf > $intermediate_dir/$SAMPLE.jellyfish.sex_microbes.fa
            
            # Reformat to csv file
        #    echo "reformating file..."            
        fi
        
        
        # Kmers in sex-associated hg38
        #if [ ! -f "$MY_HOME/blood_microbiome/intermediate_files/kmers/$SAMPLE.jellyfish.sex_hg38.fa" ]; then                        
        #    # Count kmers (depth >=2)
        #    depth=2
        #    echo "Counting kmers..."
        #    jellyfish count --canonical -m 100 -s 100M -L $depth ${sex_hg38_dir}/${SAMPLE}.fastq  \
        #    -o $MY_HOME/blood_microbiome/intermediate_files/kmers/$SAMPLE.jellyfish.sex_hg38.jf
        #   
        #   # Dump to fasta file.
        #   echo "dumping to fasta..."
        #   jellyfish dump $intermediate_dir/$SAMPLE.jellyfish.sex_hg38.jf > $intermediate_dir/$SAMPLE.jellyfish.sex_hg38.fa
        #    
        #    # Reformat to csv file
        #    echo "reformating file..."            
        #fi
        
        
    done < $SCRATCH/tmp/tmp_kmers_from_unmapped_reads_$SLURM_ARRAY_TASK_ID.txt
    \rm $SCRATCH/tmp/tmp_kmers_from_unmapped_reads_$SLURM_ARRAY_TASK_ID.txt 
done
