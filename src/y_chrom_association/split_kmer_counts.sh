#!/bin/sh
#SBATCH --job-name=split_kmer_counts_ychrom
#SBATCH --partition=dpwall
#SBATCH --array=1
#SBATCH --output=/scratch/users/briannac/logs/split_kmer_counts_ychrom_%a.out
#SBATCH --error=/scratch/users/briannac/logs/split_kmer_counts_ychrom_%a.err
#SBATCH --time=10:00:00
#SBATCH --mem=10G
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu

### file at /home/groups/dpwall/briannac/blood_microbiome/src/y_chrom_association/split_kmer_counts.sh


cd /home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association


ml parallel 
split_func() {
    echo $1
    txtfile=$1
    sample=${txtfile/.query_counts.sex_microbes.txt/}
    echo "deleting first line"
    if [ $(sed -n "1{/^$sample/p};q" $txtfile) ]; then
        tail -n +2 "$txtfile" > "$txtfile.tmp" && mv "$txtfile.tmp" "$txtfile" # Remove first line of file (sample name), shouldn't have added this in the first place.
    fi
    echo "splitting file"
    split -l 100000 -d -a 4 --additional-suffix=.txt $txtfile ${txtfile/.txt/.} # Split into many 1M line files.
    
    # Add sample name to start of all files.
    echo "Adding sample name to split files"
    for f in ${sample}.query_counts.sex_microbes.*.txt; do 
        sed  -i "1i $sample" $f
    done
    
    echo "zipping back up to save space"
    gzip $txtfile # Zip back up to save some space.
}

export -f split_func

N=$((SLURM_ARRAY_TASK_ID -1))
N=$(printf "%02g" $N)
#parallel -j $SLURM_CPUS_PER_TASK split_func ::: *$N.query_counts.sex_microbes.txt
#for f in *$N.query_counts.sex_microbes.txt; do
for f in *.query_counts.sex_microbes.txt; do
    split_func $f
done

# Note after all arrays have finished do (for _LCL or _reprep samples): parallel -j 20 split_func ::: *$N.query_counts.sex_microbes.txt
# do ls /home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association/*.query_counts.sex_microbes.txt.gz | wc -l to see how many have completed