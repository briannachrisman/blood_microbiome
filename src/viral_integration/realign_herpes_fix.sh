#!/bin/bash
#SBATCH --job-name=realign_herpes_fix
#SBATCH --partition=owners
#SBATCH --array=1-971
#SBATCH --output=/scratch/users/briannac/logs/realign_herpes_fix_%a.out
#SBATCH --error=/scratch/users/briannac/logs/realign_herpes_fix_%a.err
#SBATCH --time=0:10:00
#SBATCH --mem=10GB
####SBATCH --cpus-per-task=5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/viral_integration/realign_herpes_fix.sh

## #SLURM_ARRAY_TASK_ID=1 ### CHANGE WHEN RUNNING BATCH!!!



#Before kicking off batch, run 

#find $MY_HOME/blood_microbiome/intermediate_files/herpesvirus/*.single_aligned_to_hg38_herpes.sam -size 0 -print -delete

#python3.6 $MY_HOME/general_scripts/slurm_and_batch_resources/unfinished_samples.py $MY_HOME/blood_microbiome/intermediate_files/herpesvirus/ .single_aligned_to_hg38_herpes.sam $MY_HOME/general_data/samples_and_batches.tsv  $MY_HOME/blood_microbiome/intermediate_files/herpesvirus/sample_and_batch_unfinished_fixed.tsv 


unfinished_samples_and_batches=$MY_HOME/blood_microbiome/intermediate_files/herpesvirus/sample_and_batch_unfinished_fixed.tsv
REF_GENOMES=/home/groups/dpwall/briannac/blood_microbiome/data/reference_genomes/hg38_and_herpes.fa


#final_file_dir=$MY_HOME/blood_microbiome/results/kraken_align
cd $SCRATCH/tmp
for I_TO_ADD in 0
do
    N=$((SLURM_ARRAY_TASK_ID + I_TO_ADD))
    head -n $N $unfinished_samples_and_batches | tail -n 1 > $SCRATCH/tmp/tmp_realign_herpes_fix_$SLURM_ARRAY_TASK_ID.txt
    while read SAMPLE BATCH; do
        
        echo $SAMPLE  $BATCH
        # Setup directories.
        KRAKEN_OUT_DIR=$MY_HOME/blood_microbiome/intermediate_files/kraken_align/${SAMPLE}
        intermediate_dir=$MY_HOME/blood_microbiome/intermediate_files/herpesvirus/${SAMPLE}
        
        # Get read IDS for KRAKEN reads mapping to herpes + their mates.
        grep "herpesvirus" ${KRAKEN_OUT_DIR}_all.kraken | cut -f2  > ${intermediate_dir}.read_ids.tmp.out
        grep -v "/" ${intermediate_dir}.read_ids.tmp.out > ${intermediate_dir}.read_single_ids.tmp.out
        echo "single: " $(wc -l ${intermediate_dir}.read_single_ids.tmp.out)

        # Concat read1 and read2 ids, and add '@' to front to help out grep.
        sed -e 's/^/@/' ${intermediate_dir}.read_single_ids.tmp.out> ${intermediate_dir}.read_single_ids.to_realign.tmp.out 

        grep -F -f ${intermediate_dir}.read_single_ids.to_realign.tmp.out -A 3 ${KRAKEN_OUT_DIR}.tmp.fastq  | sed  '/--/d' > ${intermediate_dir}.reads.tmp.fastq # Single reads.

        bwa mem $REF_GENOMES ${intermediate_dir}.reads.tmp.fastq > ${intermediate_dir}.single_aligned_to_hg38_herpes.sam # Single reads


        #\rm ${intermediate_dir}*.tmp*
    done < $SCRATCH/tmp/tmp_realign_herpes_fix_$SLURM_ARRAY_TASK_ID.txt
    \rm $SCRATCH/tmp/tmp_realign_herpes_fix_$SLURM_ARRAY_TASK_ID.txt
done



