#!/bin/bash
cd /scratch/users/briannac/blood_microbiome/intermediate_files/read_counts
grep '>' /oak/stanford/groups/dpwall/unmapped_reads/reference_genomes/combined.fa > contig_names.txt
python3 /home/groups/dpwall/briannac/blood_microbiome/src/read_counts/contig_names.py


