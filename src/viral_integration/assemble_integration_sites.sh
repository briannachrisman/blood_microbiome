#!/bin/bash
#SBATCH --job-name=assemble_integration_sites
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/assemble_integration_sites.out
#SBATCH --error=/scratch/users/briannac/logs/assemble_integration_sites.err
#SBATCH --time=20:00:00
#SBATCH --mem=50GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

## FILE IN sbatch $MY_HOME/blood_microbiome/src/viral_integration/assemble_integration_sites.sh

ml python/3.6.1

python3 -u $MY_HOME/blood_microbiome/src/viral_integration/assemble_integration_sites.py

cd $MY_HOME/blood_microbiome/intermediate_files/assemble_integration_sites

for FILE in *_end.bam; do
    echo $FILE
    SAMPLE="${FILE/.bam/}"   
    samtools fastq $SAMPLE.bam -o $SAMPLE.fastq
    \rm -r ${SAMPLE}_assembled
    megahit -r $SAMPLE.fastq -o ${SAMPLE}_assembled
    sed -i "s/>/>${SAMPLE}__/" ${SAMPLE}_assembled/final.contigs.fa
done


#cat *_hhv6A_start_assembled/final.contigs.fa > hhv6a_start_assembled.fa
/oak/stanford/groups/dpwall/computeEnvironments/mafft-7.453-without-extensions/bin/mafft --adjustdirection hhv6a_start_assembled.fa > hhv_6a_start_aligned.fa

#cat *_hhv6B_start_assembled/final.contigs.fa > hhv6b_start_assembled.fa
/oak/stanford/groups/dpwall/computeEnvironments/mafft-7.453-without-extensions/bin/mafft --adjustdirection hhv6b_start_assembled.fa > hhv_6b_start_aligned.fa

#cat *_hhv7_start_assembled/final.contigs.fa > hhv7_start_assembled.fa
/oak/stanford/groups/dpwall/computeEnvironments/mafft-7.453-without-extensions/bin/mafft --adjustdirection hhv7_start_assembled.fa > hhv_7_start_aligned.fa

#cat *_hhv6A_end_assembled/final.contigs.fa > hhv6a_end_assembled.fa
/oak/stanford/groups/dpwall/computeEnvironments/mafft-7.453-without-extensions/bin/mafft --adjustdirection hhv6a_end_assembled.fa > hhv_6a_end_aligned.fa

#cat *_hhv6B_end_assembled/final.contigs.fa > hhv6b_end_assembled.fa
/oak/stanford/groups/dpwall/computeEnvironments/mafft-7.453-without-extensions/bin/mafft --adjustdirection hhv6b_end_assembled.fa > hhv_6b_end_aligned.fa

#cat *_hhv7_end_assembled/final.contigs.fa > hhv7_end_assembled.fa
/oak/stanford/groups/dpwall/computeEnvironments/mafft-7.453-without-extensions/bin/mafft --adjustdirection hhv7_end_assembled.fa > hhv_7_end_aligned.fa


 cp *aligned.fa /home/groups/dpwall/briannac/blood_microbiome/results/herpesvirus/