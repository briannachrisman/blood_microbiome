import pandas as pd
from glob import glob 
BLOOD_MICROBIOME_DIR = '/home/groups/dpwall/briannac/blood_microbiome/'
UNFINISHED_FILE=BLOOD_MICROBIOME_DIR + 'intermediate_files/f_regression/unfinished_microbes.tsv'

MICROBE_ALL_FILE = BLOOD_MICROBIOME_DIR + 'data/kraken_align/microbe_filtered_species.tsv'
df_microbe = pd.read_table(MICROBE_ALL_FILE, index_col=0)

finished_microbes = [g.split('f_regression/')[-1].replace('.txt', '') for g in glob(BLOOD_MICROBIOME_DIR + 'intermediate_files/f_regression/*.txt')]
df_unfinished= df_microbe[[i.replace(' ', '_').replace('/', '_') not in finished_microbes for i in df_microbe.index]]
df_unfinished[[]].to_csv(UNFINISHED_FILE, sep='\t', header=None)
print(len(df_unfinished), 'unfinished')