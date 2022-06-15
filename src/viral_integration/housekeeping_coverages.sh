#!/bin/bash
#SBATCH --job-name=housekeeping_coverages
#SBATCH --partition=owners
#SBATCH --array=1-100
#SBATCH --output=/scratch/users/briannac/logs/housekeeping_coverages_%a.out
#SBATCH --error=/scratch/users/briannac/logs/housekeeping_coverages_%a.err
#SBATCH --time=0:10:00
#SBATCH --mem=1G
####SBATCH --cpus-per-task=5
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/viral_integration/housekeeping_coverages.sh

## SLURM_ARRAY_TASK_ID=1
unfinished_samples_and_batches=$MY_HOME/general_data/samples_and_batches.tsv

cd $MY_HOME/blood_microbiome/intermediate_files/housekeeping_coverages

for I_TO_ADD in 0 100 200 300 400 500 600 700 800 900 1000 1100 1200 1300 1400 1500 1600 1700 1800 1900 2000 2100 2200 2300 2400 2500 2600 2700 2800 2900 3000 3100 3200 3300 3400 3500 3600 3700 3800 3900 4000 4100 4200 4300 4400 4500
do
    N=$((SLURM_ARRAY_TASK_ID + I_TO_ADD))
    head -n $N $unfinished_samples_and_batches | tail -n 1 > $SCRATCH/tmp/tmp_housekeeping_$SLURM_ARRAY_TASK_ID.txt
    while read SAMPLE _; do
#    for SAMPLE in 03C21394_LCL 02C11452 03C15873  04C24821 07C62578 07C66619 09C80191_LCL 09C80192 10C102326_LCL 10C102516_LCL 10C104029_LCL 10C104575_LCL 10C110450_LCL 10C110759_LCL 10C111713_LCL 10C112859_LCL 10C115869_LCL 11C120729_LCL 11C123778_LCL 11C125633_LCL 11C125695_LCL 11C125879_LCL MH0131365_LCL MH0134528_LCL MH0138042_LCL ; do
        if [ ! -f $SAMPLE.txt ]; then 
            SAMPLE_LCL="${SAMPLE/_LCL/-LCL}"
            echo $SAMPLE_LCL
            EDAR="$(samtools view s3://ihart-hg38/cram/${SAMPLE_LCL}.final.cram chr2:108894471-108989220 -c )"
            GBB="$(samtools view s3://ihart-hg38/cram/${SAMPLE_LCL}.final.cram chr11:5225464-5227197 -c )"
            echo $SAMPLE $EDAR $GBB > $SAMPLE.txt
            #\rm ${intermediate_dir}*.tmp*
            \rm ${SAMPLE_LCL}*crai
        fi
    #done
    done < $SCRATCH/tmp/tmp_housekeeping_$SLURM_ARRAY_TASK_ID.txt
    \rm $SCRATCH/tmp/tmp_housekeeping_$SLURM_ARRAY_TASK_ID.txt
done

