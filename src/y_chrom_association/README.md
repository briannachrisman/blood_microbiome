# Microbial Y Chrom Association
Extracting k-mers and counts associated with y-chromosome.


## Storage
- **Intermediate files**: ```HOME/blood_microbiome/intermediate_results/y_chrom_association```
- **Final results**: ```HOME/blood_microbiome/results/y_chrom_association```

## Prerequisites

0.1.  Kraken pipeline: Relaign reads from iHART that did not align/aligned poorly to hg38 to a database of archaea, human, bacteria, and viral sequences.  Compile sample vs microbe matrix.

0.2. F-regression pipeline.

## Pipeline

1. ✓ ```y_associated_contigs.ipynb```: Make a list of sex-associated contigs.
    - ***Inputs***: ```
    - ***Outputs***:

2.  ✓ ```kmers_from_y_associated_contigs.sh```: Extract kmers from ultimately unmapped reads. (PS: can use get_unfinished_samples.ipynb to update finished/unfinished samples)
    - ***Inputs***: ``../blood_microbiome/intermediate_files/kraken_align/<SAMPLE>.unclassified.fastq```
    - ***Outputs***: ```../intermediate_files/kmers/<SAMPLE>/<SAMPLE>.jellyfish.sex_microbes.jf```, ```../intermediate_files/kmers/<SAMPLE>.jellyfish.sex_microbes.fa```

3. ✓ ```shared_kmers.sh```: Compute list of non-unique k-mers. Note: 23,038,807 kmers.
    - ***Inputs***: ```../intermediate_files/y_chrom_association/<SAMPLE>/<SAMPLE>.jellyfish.sex_microbes.fa```
    - ***Outputs***: ```../intermediate_files/y_chrom_association/kmers.sex_microbes.list```

4. ✓ ```query_kmers.sh```: Query each sample for count of each non-unique kmers (Can use get_unfinished_samples.ipynb to update finished/unfinished samples)
    - ***Inputs***: ```../intermediate_files/y_chrom_association/kmers.sex_microbes.list```, ```../intermediate_files/kmers/<SAMPLE>.jellyfish.sex_microbes.jf```
    - ***Outputs***: ```../intermediate_files/y_chrom_association/<SAMPLE>/<SAMPLE>.query_counts.sex_microbes.txt```

5. ✓ ```split_kmer_counts.sh```: Splits each sample kmer counts into many different files/kmer sets for concatenation.
    - ***Inputs***:  ```../intermediate_files/y_chrom_association/<SAMPLE>/<SAMPLE>.query_counts.sex_microbes.txt```
    - ***Outputs***: ```../intermediate_files/y_chrom_association/<SAMPLE>/<SAMPLE>.query_counts.sex_microbes.<KMER_REGION>.txt```    

6. ```concat_kmer_counts.sh```: Concatenates sample kmer counts for each region.
    - ***Inputs***:  ```../intermediate_files/y_chrom_association/<SAMPLE>/<SAMPLE>.query_counts.kmers.sex_microbes.list.txt```
    - ***Outputs***: ```../intermediate_files/y_chrom_association/query_counts.sex_microbes.<KMER_REGION>.tsv```
     ***Currently Running: 60/231 finished as of 5/12/2021***
     
7. ```move_to_results.sh```: Move to permanent results directory.
    - ***Inputs***: ```../intermediate_files/kmers/query_counts.sex_microbes.<KMER_REGION>.tsv```
    - ***Outputs***: ```../results/kmers/query_counts.sex_microbes.<KMER_REGION>.tsv.gz```
    
Note: Ran ``organize_directories.sh``` to reorganize file structure a bit to make linux commands run faster.