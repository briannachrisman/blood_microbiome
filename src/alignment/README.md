# CovWAS
Performs a genome-wide association test on coverage at each loci vs sex.

## Storage
- **Intermediate files**: ```MY_HOME/y_chromsome_mismappings/intermediate_files/coverages``` and ```MY_HOME/y_chromsome_mismappings/intermediate_files/covWAS```
- **Archived**: ```../intermediate_files/coverages``` and ```../intermediate_files/covWAS``` archived in gdrive.
- **Final data/results**: ```MY_HOME/y_chromsome_mismappings/results/covWAS```


## Prereqs: 
0.1 ```get_chromosome_line_numbers.ipynb```: Creates a table of chromsome/contig, corresponding start line #, and corresponding end line #. 
    - **Inputs**: sample AWS ihart bam.
    - **Outputs**: ```intermediate_files/coverages/chrom_start_ends.tsv```

## Workflow.

For all, improper:

1. ✓ ```sample_coverages.sh```: Computes a vector of genome-wide read depths for every sample in iHART. (used ```zip_sample_coverages.sh``` to zip files before adding zipping features to ```sample_coverages.sh```) 
    - **Inputs**: AWS ihart bams.
    - **Outputs**: ```intermediate_files/coverages/<SAMPLE>/<SAMPLE>.<IMPROPER|NONPROPER|ALL>.txt.gz>```

2. For all, improper: ***TODO: Currently Running concat_coverages on 'all' -- 2150/3217 finished.***

   2.1.  ```split_coverages.sh```: Splits each coverage file into smaller coverage samples so they can be concatenated.
   - **Inputs**: ```intermediate_files/coverages/<SAMPLE>/<SAMPLE>.<IMPROPER|NONPROPER|ALL>.txt.gz>```
   - **Outputs**: ```intermediate_files/coverages/<SAMPLE>/<SAMPLE>.<IMPROPER|NONPROPER|ALL>.<REGIONS>.txt```

   2.2. ```concat_coverages.sh```: Concatenates together the coverages of all samples for each region of chromosome.
   - **Inputs**: ```intermediate_files/coverages/<SAMPLE>/<SAMPLE>.<IMPROPER|NONPROPER|ALL>.<REGION>.txt```
   - **Outputs**: ```intermediate_files/coverages/<IMPROPER|NONPROPER|ALL>.<REGION>.tsv.gz```


For nonproper:
1. ✓ ```sample_and_split_nonproper.sh```: Computes a vector of genome-wide read depths for every sample in iHART. (used ```zip_sample_coverages.sh``` to zip files before adding zipping features to ```sample_coverages.sh```) 
    - **Inputs**: AWS ihart bams.
    - **Outputs**: ```intermediate_files/coverages/<SAMPLE>/<SAMPLE>.<IMPROPER|NONPROPER|ALL>.txt.gz>```

2. ```concat_coverages.sh```: Concatenates together the coverages of all samples for each region of chromosome. **June 1, 2020 Running -- 1200 done**
   - **Inputs**: ```intermediate_files/coverages/<SAMPLE>/<SAMPLE>.<IMPROPER|NONPROPER|ALL>.<REGION>.txt```
   - **Outputs**: ```intermediate_files/coverages/<IMPROPER|NONPROPER|ALL>.<REGION>.tsv.gz```



4.  ```covWAS.sh```: Runs a genome-wide (batched by chromsome) association between each loci & sex. Returns p-values and p-value related graphs.
    - **Inputs**: ```intermediate_files/coverages/<REGION>.<IMPROPER|NONPROPER|ALL>.tsv.gz>```
    - **Outputs**:  ```intermediate_files/coverages/<IMPROPER|NONPROPER|ALL>.pvals.txt>```, ```results/covWAS/<CHROMOSOME>.<IMPROPER|NONPROPER|ALL>.pvals_hist.svg>```, ```results/covWAS/<CHROMOSOME>.<IMPROPER|NONPROPER|ALL>.pvals_manhattan.svg>```
    
    
5. ```move_to_results.sh```: Move to permanent results directory.
    - ***Inputs***: ```intermediate_files/coverages/<IMPROPER|NONPROPER|ALL>.pvals.txt>```
    - ***Outputs***: ```results/coverages/<CHROMOSOME>.<IMPROPER|NONPROPER|ALL>.pvals.txt>```
    
Note: Ran ``organize_directories.sh``` to reorganize file structure a bit to make linux commands run faster.  Ran ```rename_with_correct_flags``` to fix the flagging bug in samtools depth.


# Instructions for running alignment

1. ✓ ```build_kraken.sh```: Build kraken database.
    - **Outputs**:  ```/oak/stanford/groups/dpwall/computeEnvironments/Bracken-2.5/database/*``


2. ```build_taxonomies.sh``` to build taxonomy tables.
    - **Outputs**:  ```./data/kraken_align/taxonomies.tsv```, ```./data/kraken_align/taxonomies_mpa.tsv```
    
3. ```kraken_align.sh``` batch script for all samples.  Can check which samples still need to run with get_unfinished_samples script. ✓
    - **Inputs**: ```s3://ihart-ms2/unmapped/<BATCH>/<SAMPLE>/<SAMPLE>.final.single.aln_all.bam```
    - **Outputs**:  ```intermediate_files/kraken_align/<SAMPLE>_all.report```, ```intermediate_files/kraken_align/<SAMPLE>_all.kraken```, ```intermediate_files/kraken_align/<SAMPLE>_all_abundances_exact.tsv```,```intermediate_files/kraken_align/<SAMPLE>_all_abundances_chidren.tsv```
    
4. ```concat alignments.sh```: concatenates alignments for all samples.
    - **Inputs**: ```intermediate_files/kraken_align/<SAMPLE>_all_abundances_exact.tsv```,```intermediate_files/kraken_align/<SAMPLE>_all_abundances_chidren.tsv```
    - **Outputs**: ```data/kraken_align/abundances_children_all.tsv```, ```data/kraken_align/abundances_exact_all.tsv```
    
5. ```setup_abundances.py``` Constructs final tables for abundances.
    - **Inputs**: ``data/kraken_align/abundances_children_all.tsv```, ```data/kraken_align/abundances_exact_all.tsv```
    - **Outputs**:  ``data/kraken_align/abundances_children.tsv```, ```data/kraken_align/abundances_exact.tsv```
    
6. ```examine_alignment_and_filter.ipynb``` filters bacteria & viruses.
    - **Inputs**: ```data/kraken_align/abundances_children.tsv```, ```data/kraken_align/abundances_exact.tsv```
    - **Outputs**:  ``data/kraken_align/bacteria_filtered_species.df```, ```data/kraken_align/virus_filtered_species.df```
    