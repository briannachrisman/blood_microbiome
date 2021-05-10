#!/bin/bash
#SBATCH --job-name=get_sex_associated_bacteria
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/groups/dpwall/personal/briannac/logs/get_sex_associated_bacteria.out
#SBATCH --error=/scratch/groups/dpwall/personal/briannac/logs/get_sex_associated_bacteria.err
#SBATCH --time=10:00:00
#SBATCH --mem=10GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/src/get_sex_associated_bacteria.sh

module load py-numpy/1.14.3_py36
module load py-scipy/1.1.0_py36

out_file=/scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/results/sex_associated_microbes_count/tsv_files/sex_associated_counts.tsv
\rm $out_file

realpath /scratch/users/chloehe/unmapped_reads/bam/*/*/*.final_alignment_table.csv  | while read filename; do 
echo $filename
fuso_counts=$(grep -o 'BACT_577|gi|224473368|ref|NZ_ACDH01000101.1|' $filename | wc -l)
mollicutes_counts=$(grep -o 'BACT_769|gi|223714005|gb|ACDT01000210.1|' $filename | wc -l)
echo $filename $fuso_counts $mollicutes_counts >> $out_file
done
