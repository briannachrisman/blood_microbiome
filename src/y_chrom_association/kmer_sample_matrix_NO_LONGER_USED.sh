#!/bin/sh
#SBATCH --job-name=kmer_sample_matrix
#SBATCH --partition=dpwall
#SBATCH --array=1
#SBATCH --output=/scratch/users/briannac/logs/kmer_sample_matrix_%a.out
#SBATCH --error=/scratch/users/briannac/logs/kmer_sample_matrix_%a.err
#SBATCH --time=3:00:00
#SBATCH --mem=1GB
#SBATCH --mail-type=ALL
#SBATCH --mail-user=briannac@stanford.edu


### file at /home/groups/dpwall/briannac/blood_microbiome/src/y_chrom_association/kmer_sample_matrix.sh


### Before running, do: python3.6 /home/groups/dpwall/briannac/blood_microbiome/src/y_chrom_association/get_unfinished_kmers.py

ml parallel 
for i in 0 1000 2000
do
    N=$((SLURM_ARRAY_TASK_ID+i))
    head -n $((N+1)) /home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association/kmer_intervals_unfinished.tsv | tail -n 1  > $SCRATCH/tmp/tmp_kmers_from_sex_microbes_$SLURM_ARRAY_TASK_ID.txt

    while read KMERID START STOP; do

        export start=$((START+2))
        export stop=$((STOP+2))
        export stop2=$((stop+1))
        export kmerid=$KMERID
        echo $kmerid $start $stop

        select_regions() { 
            head -n 1 $1 > /home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association/${1/query_counts.sex_microbes/kmers.${kmerid}}
            sed  -n "$start,${stop}p;${stop2}q" $1 >> /home/groups/dpwall/briannac/blood_microbiome/intermediate_files/kmers/${1/query_counts.sex_microbes/kmers.${kmerid}}
        }

        export -f select_regions
        
        echo "Unmapped..."
        cd /home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association
        parallel -j 20 select_regions ::: *.query_counts..txt
        cd /home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association
        paste *11.kmers.${kmerid}.txt > kmers.${kmerid}.tsv
        gzip -f kmers.${kmerid}.tsv
        \rm *.kmers.${kmerid}.txt
        #echo "done" > ${kmerid}.kmers.done

    done < $SCRATCH/tmp/tmp_kmers_from_sex_microbes_$SLURM_ARRAY_TASK_ID.txt
    \rm $SCRATCH/tmp/tmp_kmers_from_sex_microbes_$SLURM_ARRAY_TASK_ID.txt
done



