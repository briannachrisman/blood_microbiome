import pandas as pd
from glob import glob
files = glob('/home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association/*.done')
files = [f.split('/')[-1].replace('.kmers.done', '') for f in files]

starts_all = pd.read_table('/home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association/kmer_intervals.tsv', index_col=0)
unfinished = starts_all.loc[[i for i in starts_all.index if i not in files]]
print(len(unfinished), ' unfinished samples')
unfinished.to_csv(
    '/home/groups/dpwall/briannac/blood_microbiome/intermediate_files/y_chrom_association/kmer_intervals_unfinished.tsv',
    sep='\t')