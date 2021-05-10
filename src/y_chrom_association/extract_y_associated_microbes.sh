#!/bin/bash
#SBATCH --job-name=extract_y_associated_microbes
#SBATCH --partition=dpwall
#SBATCH --array=1
#SBATCH --output=/scratch/users/briannac/logs/extract_y_associated_microbes_%a.out
#SBATCH --error=/scratch/users/briannac/logs/extract_y_associated_microbes_%a.err
#SBATCH --time=1:00:00
#SBATCH --mem=50GB
####SBATCH --cpus-per-task=5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/y_chrom_association/extract_y_associated_microbes.sh

SLURM_ARRAY_TASK_ID=1 ### CHANGE WHEN RUNNING BATCH!!!

#Before kicking off batch, run 

#find $MY_HOME/blood_microbiome/intermediate_files/y_chrom_association/* -size 0 -print -delete


#python3.6 $MY_HOME/general_scripts/slurm_and_batch_resources/unfinished_samples.py $MY_HOME/blood_microbiome/intermediate_files/y_chrom_association/ .y_associated_seqs.fastq $MY_HOME/general_data/samples_and_batches.tsv  $MY_HOME/blood_microbiome/intermediate_files/y_chrom_association/sample_and_batch_unfinished.tsv 



######################################################################################
###### Note $MY_HOME/blood_microbiome/intermediate_files/y_chrom_association/* #######
###### has been archived in gdrive/sherlock_archive/y_chrom_association.tar.gz #######
######################################################################################



unfinished_samples_and_batches=$MY_HOME/blood_microbiome/intermediate_files/y_chrom_association/sample_and_batch_unfinished.tsv
#SAMPLE=06C54347
#BATCH=batch_00016
TAXA_IDS_TO_GREP=/home/groups/dpwall/briannac/blood_microbiome/results/y_chrom_association/tax_ids_to_grep.txt
TAXA_NAMES_TO_GREP=/home/groups/dpwall/briannac/blood_microbiome/results/y_chrom_association/tax_names_to_grep.txt


#final_file_dir=$MY_HOME/blood_microbiome/results/kraken_align
cd $SCRATCH/tmp
for I_TO_ADD in 0
do
    N=$((SLURM_ARRAY_TASK_ID + I_TO_ADD))
    head -n $N $unfinished_samples_and_batches | tail -n 1 > $SCRATCH/tmp/tmp_y_chrom_association_$SLURM_ARRAY_TASK_ID.txt
    while read SAMPLE BATCH; do
        
        echo $SAMPLE  $BATCH
        # Setup directories.
        KRAKEN_OUT_DIR=$MY_HOME/blood_microbiome/intermediate_files/kraken_align/${SAMPLE}
        intermediate_dir=$MY_HOME/blood_microbiome/intermediate_files/y_chrom_association/${SAMPLE}
        
        sed -e 's/taxid|/taxid/' ${KRAKEN_OUT_DIR}.classified.fastq > ${intermediate_dir}.classified.tmp.fastq
                
        # Get fastq of y-associated microbes.
        grep -f $TAXA_IDS_TO_GREP ${intermediate_dir}.classified.tmp.fastq -A 3 | sed  '/--/d' > ${intermediate_dir}.y_associated_seqs.fastq
        
        
        # Format this into table form.
        cat ${intermediate_dir}.y_associated_seqs.fastq | paste - - - - | sort -k1 | cut -f1,2 > ${intermediate_dir}.reads_and_kraken_classes.tmp.tsv
        sed -i "s/^@//" ${intermediate_dir}.reads_and_kraken_classes.tmp.tsv

        wc -l ${intermediate_dir}.reads_and_kraken_classes.tmp.tsv
        echo "lines in reads_and_kraken_classes.tmp.tsv"
        # Format so kraken_id is a column of its own.
        sed -i -e 's/ kraken/\tkraken/' ${intermediate_dir}.reads_and_kraken_classes.tmp.tsv
        grep -f $TAXA_NAMES_TO_GREP ${KRAKEN_OUT_DIR}_all.kraken |cut  -f 2-  | sort -k1 > ${intermediate_dir}.kraken_kmers.tmp.tsv
        wc -l ${intermediate_dir}.kraken_kmers.tmp.tsv
        echo "lines in kraken_kmers.tmp.tsv"
        
        paste ${intermediate_dir}.reads_and_kraken_classes.tmp.tsv ${intermediate_dir}.kraken_kmers.tmp.tsv > ${intermediate_dir}.kraken_classes_pre.tsv
        sed -i "s/^/$SAMPLE\t/" ${intermediate_dir}.kraken_classes_pre.tsv
        sed -i "s/kraken:taxid//" ${intermediate_dir}.kraken_classes_pre.tsv
        mv ${intermediate_dir}.kraken_classes_pre.tsv ${intermediate_dir}.kraken_classes.tsv        
        
        \rm ${intermediate_dir}*.tmp*
    done < $SCRATCH/tmp/tmp_y_chrom_association_$SLURM_ARRAY_TASK_ID.txt
    \rm $SCRATCH/tmp/tmp_y_chrom_association_$SLURM_ARRAY_TASK_ID.txt
done

