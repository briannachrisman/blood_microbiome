#!/bin/bash
#SBATCH --job-name=concat_alignments
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/concat_alignments.out
#SBATCH --error=/scratch/users/briannac/logs/concat_alignments.err
#SBATCH --time=01:00:00
#SBATCH --mem=5GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at $MY_HOME/blood_microbiome/src/alignment/concat_alignments.sh

# Print abundances (mapped to given tax level & mapped to given tax level + children)
# of each sample to file.
echo "Extracting abundances..."
cd $MY_HOME/blood_microbiome/intermediate_files/kraken_align/
for f in *_all.report; do
    #echo $f
    echo $f > $f.abundances_exact
    echo $f > $f.abundances_children
    sort -k5,5n $f | awk  '{print $3}' >> $f.abundances_exact
    sort -k5,5n $f | awk  '{print $2}' >> $f.abundances_children
done

# Concatenate together abundances from every sample. 
echo "Concatenating abundances exact..."
echo -e 'tax_level\ttax_id\tname' > tax_info.txt
sort -k5,5n $f | cut -f 4-6  >> tax_info.txt

echo "Concatenating abundances exact..."
paste tax_info.txt $f.abundances_exact $MY_HOME/blood_microbiome/intermediate_files/kraken_align/*_all.report.abundances_exact >  $MY_HOME/blood_microbiome/data/kraken_align/abundances_exact_all.tsv
sed -e 's/\_all.report//g' -i $MY_HOME/blood_microbiome/data/kraken_align/abundances_exact_all.tsv

echo "Concatenating abundances children..."
paste tax_info.txt $MY_HOME/blood_microbiome/intermediate_files/kraken_align/*_all.report.abundances_children >  $MY_HOME/blood_microbiome/data/kraken_align/abundances_children_all.tsv
sed -e 's/\_all.report//g' -i $MY_HOME/blood_microbiome/data/kraken_align/abundances_children_all.tsv



#paste $MY_HOME/blood_microbiome/intermediate_files/kraken_align/*_single.report.abundances_exact >  $MY_HOME/blood_microbiome/data/kraken_align/abundances_exact_single.tsv
#sed -e 's/\_single.report//g' -i $MY_HOME/blood_microbiome/data/kraken_align/abundances_exact_single.tsv

#paste $MY_HOME/blood_microbiome/intermediate_files/kraken_align/*_paired.report.abundances_exact >  $MY_HOME/blood_microbiome/data/kraken_align/abundances_exact_paired.tsv
#sed -e 's/\_paired.report//g' -i $MY_HOME/blood_microbiome/data/kraken_align/abundances_exact_paired.tsv

#paste $MY_HOME/blood_microbiome/intermediate_files/kraken_align/*_single.report.abundances_children >  $MY_HOME/blood_microbiome/data/kraken_align/abundances_children_single.tsv
#sed -e 's/\_single.report//g' -i $MY_HOME/blood_microbiome/data/kraken_align/abundances_children_single.tsv

#paste $MY_HOME/blood_microbiome/intermediate_files/kraken_align/*_paired.report.abundances_children >  $MY_HOME/blood_microbiome/data/kraken_align/abundances_children_paired.tsv
#sed -e 's/\_paired.report//g' -i $MY_HOME/blood_microbiome/data/kraken_align/abundances_children_paired.tsv


