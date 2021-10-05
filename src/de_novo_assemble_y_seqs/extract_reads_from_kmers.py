import pandas as pd
import numpy as np
import sys


# Set up file names.
SAMPLE=sys.argv[1]
OUTFILE_MALE='/home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association/denovo/%s.reads_from_male_kmers.fastq' % (SAMPLE)
OUTFILE_FEMALE='/home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association/denovo/%s.reads_from_female_kmers.fastq' % (SAMPLE)
FASTQ_FILE = '/home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association/%s/%s.y_associated_seqs.fastq' % (SAMPLE, SAMPLE)

print('Reading in kmers...')
# Read in k-mers associated with females and males.
kmers_female_set = set(pd.read_table('/home/groups/dpwall/briannac/blood_microbiome/results/y_chrom_association/sig_kmers_female.txt', usecols=[0], header=None)[0].values)
kmers_male_set = set(pd.read_table('/home/groups/dpwall/briannac/blood_microbiome/results/y_chrom_association/sig_kmers_male.txt', usecols=[0], header=None)[0].values)

# Extract reads with-male associated k-mers.
print('Extracting male reads...')
with open(OUTFILE_MALE, 'w') as outfile:
    with open(FASTQ_FILE) as infile:
        for i, line in enumerate(infile.readlines()):
            if i%4==0:  read_idx=line
            elif i%4==1:  seq=line
            elif i%4==2:  plus=line
            elif i%4==3: 
                qual=line
                kmers = set([seq[i:i+100] for i in range(50)])
                if len(kmers_male_set.intersection(kmers)):
                    outfile.write(read_idx)
                    outfile.write(seq)
                    outfile.write(plus)
                    outfile.write(line)
                    
                    
# Extract reads with female associated k-mers.
print('Extracting female reads...')
with open(OUTFILE_FEMALE, 'w') as outfile:
    with open(FASTQ_FILE) as infile:
        for i, line in enumerate(infile.readlines()):
            if i%4==0:  read_idx=line
            elif i%4==1:  seq=line
            elif i%4==2:  plus=line
            elif i%4==3: 
                qual=line
                kmers = set([seq[i:i+100] for i in range(50)])
                if len(kmers_female_set.intersection(kmers)):
                    outfile.write(read_idx)
                    outfile.write(seq)
                    outfile.write(plus)
                    outfile.write(line)