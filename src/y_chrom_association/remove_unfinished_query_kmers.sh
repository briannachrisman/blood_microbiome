#!/bin/bash
#SBATCH --job-name=remove_unfinished_query_kmers
#SBATCH --partition=dpwall
#SBATCH --output=/scratch/users/briannac/logs/remove_unfinished_query_kmers.out
#SBATCH --error=/scratch/users/briannac/logs/remove_unfinished_query_kmers.err
#SBATCH --time=30:00:00
#SBATCH --mem=128GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu
#SBATCH -c 20



### file at /home/groups/dpwall/briannac/blood_microbiome/src/y_chrom_association/remove_unfinished_query_kmers.sh

ml parallel

check_length() {
    if [[ $(zgrep -Ec "$" $1) == 23038808 ]]; then
        #echo "do1ne "> ${file/.unmapped.txt/.done}
        echo $1 finished
    else
        #\rm ${1/txt/done}
        #\rm $file
        echo $1 not finished
    fi
}

export -f check_length
parallel -j 20 check_length ::: $MY_HOME/blood_microbiome/intermediate_files/y_chrom_association/*.query_counts.sex_microbes.txt