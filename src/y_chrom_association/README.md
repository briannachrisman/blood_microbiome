# Y Chrom Association

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
    - ***Outputs***: ```../intermediate_files/kmers/<SAMPLE>.jellyfish.sex_microbes.jf```, ```../intermediate_files/kmers/<SAMPLE>.jellyfish.sex_microbes.fa```

3. ✓ ```shared_kmers.sh```: Compute list of non-unique k-mers. Note: 23,038,807 kmers.
    - ***Inputs***: ```../intermediate_files/kmers/<SAMPLE>.jellyfish.sex_microbes.fa```
    - ***Outputs***: ```../intermediate_files/kmers/kmers.sex_microbes.list```

4. ✓ ```query_kmers.sh```: Query each sample for count of each non-unique kmers (Can use get_unfinished_samples.ipynb to update finished/unfinished samples)
    - ***Inputs***: ```../intermediate_files/kmers/kmers.sex_microbes.list```, ```../intermediate_files/kmers/<SAMPLE>.jellyfish.sex_microbes.jf```
    - ***Outputs***: ```../intermediate_files/kmers/<SAMPLE>.query_counts.sex_microbes.txt```

5. ✓ ```split_kmer_counts.sh```: Compute count matrix of kmer x sample.   
    - ***Inputs***:  ```../intermediate_files/kmers/<SAMPLE>.query_counts.kmers.unmapped_reads.list.txt```
    - ***Outputs***: ```../results/kmers/kmer_counts.kmers.unmapped_reads.list.tsv```    

6. ```concat_kmer_counts.sh```: Compute count matrix of kmer x sample.   ***TODO: Currently Running***
    - ***Inputs***:  ```../intermediate_files/kmers/<SAMPLE>.query_counts.kmers.unmapped_reads.list.txt```
    - ***Outputs***: ```../results/kmers/kmer_counts.kmers.unmapped_reads.list.tsv```