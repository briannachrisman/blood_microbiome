import pandas as pd
import sys
import numpy as np
from Bio import SeqIO
import csv

PARENT_DIR = '/home/groups/dpwall/briannac/blood_microbiome/'

# IN FILES
bacteria_file_in = PARENT_DIR + 'intermediate_files/read_counts/bacteria.all.csv'
virus_file_in = PARENT_DIR + 'intermediate_files/read_counts/virus.all.csv'
alt_hap_file_in = PARENT_DIR + 'intermediate_files/read_counts/alt_hap.all.csv'

contig_names_file = PARENT_DIR + 'intermediate_files/read_counts/contig_names.txt'

# OUT FILES
bacteria_agg_species_file_out =  PARENT_DIR + 'data/bacteria_agg_species.csv'
bacteria_agg_strain_file_out = PARENT_DIR + 'data/bacteria_agg_strain.csv'
bacteria_no_agg_file_out = PARENT_DIR + 'data/bacteria_no_agg.csv'
virus_no_agg_file_out = PARENT_DIR + 'data/virus_no_agg.csv'
alt_hap_no_agg_file_out = PARENT_DIR + 'data/alt_hap_no_agg.csv'

# Get contig dictionary.
print("getting contig dict.")
with open(contig_names_file) as file:
    contig_names = file.readlines()
contig_dict = {c.split(' ')[0].replace('>',''):' '.join(c.split(' ')[1:]).replace('\n', '') for c in contig_names}

# Read in bacteria abundance file and remove all columns that are all zeros.
print('reading in bacteria abundance...')
with open(bacteria_file_in, newline='') as csvfile:
    data = list(csv.reader(csvfile))
non_zeros = [sum([int(d[i]) for d in data[1:]])>0 for i in range(1,len(data[1]))]
idx_to_keep = np.where(np.array(non_zeros))[0]
new_data = [[int(d[i+1]) for i in idx_to_keep] for d in data[1:]]
col_names = np.array(data[0][1:])
row_names = [d[0] for d in data[1:]]
df_bacteria = pd.DataFrame(new_data)
df_bacteria.columns = col_names[idx_to_keep]
df_bacteria.index = row_names
df_bacteria.columns = [contig_dict[c] if c in contig_dict else c for c in df_bacteria.columns]
df_bacteria.to_csv(bacteria_no_agg_file_out)


# Read in virus abundance file and remove all columns that are all zeros.
print('reading in virus abundance...')
df_virus = pd.read_csv(virus_file_in, index_col=0)
df_virus = df_virus[df_virus.columns[df_virus.sum()>0]]
df_virus.columns = [' '.join(contig_dict[c].split(' ')[:3]).replace(',', '').replace('|', '') if c in contig_dict else c for c in df_virus.columns]
df_virus.to_csv(virus_no_agg_file_out)

# Read in alt haplotype abundance file and remove all columns that are all zeros.
print('Reading in alt hap abundance...')
df_alt_hap = pd.read_csv(alt_hap_file_in, index_col=0)
df_alt_hap = df_alt_hap[df_alt_hap.columns[df_alt_hap.sum()>0]]
df_alt_hap.columns = [contig_dict[c] if c in contig_dict else c for c in df_alt_hap.columns]
df_alt_hap.to_csv(alt_hap_no_agg_file_out)


# Aggregate bacteria dataframe.
print('transposing bacteria...')
df_bacteria.head()
df_bacteria = df_bacteria.fillna(0)
df_bacteria_transpose = df_bacteria.transpose()

cleaned_names = [(f+'.').split(' ctg')[0].split(' cont')[0].split(' chr')[0].split('contig')[0].split(
    ' NZ')[0].split(' ATCC')[0].split(' plasmi')[0].split(' genom')[0].split(' Cont')[0].split(' segment')[0].split(
    ' gcontig')[0].split('con.')[0].split('co.')[0].split('gcont.')[0].split(' g.')[0].split(' isolate')[0].split(
    ' B_')[0].split('C_')[0].split('M_')[0].split(' R_')[0].split(' supercont')[0].split(' single')[0].split(' s_')[0].split(
    ' scaffold')[0].split(' .')[0].split('-.')[0].split(' clone')[0].split('Cont.')[0].split(
    '.Contig')[0].split('Co.')[0].split(' Scfld')[0].split('FA.')[0].split('_Co')[0].split(' g ')[0].replace(
    'sp.', '').replace('str.', '').replace('Magn01_', '').replace('DSM ', 'DSM_').replace(' MS ', ' MS_').replace(' NCIB ', ' NCIB_').replace(
    'oral taxon ', ' ').replace('Murine ', 'Murine_').replace(' sub ', '') for f in df_bacteria_transpose.index]
cleaned_names = [f.split('.')[0].split(',')[0] for f in cleaned_names]
for i,c in enumerate(cleaned_names):
    try: 
        a=int(c.split(' ')[-1])
        cleaned_names[i] = ' '.join(c.split(' ')[:-1])
    except:
        cleaned_names[i] = c
    if (c.split(' ')[-1]=='g') or (c.split(' ')[-1]=='str') or (c.split(' ')[-1]=='sp'):
        cleaned_names[i] = ' '.join(c.split(' ')[:-1])
cleaned_names = [c.replace('  ', ' ')  for c in cleaned_names]
strain = [' '.join(f.split(' ')[:3]) for f in cleaned_names]
species = [' '.join(f.split(' ')[:2]) for f in cleaned_names]


# Aggregate by species & save.
print('aggregating bacteria...')
df_bacteria_transpose['cleaned_names'] = species
df_bacteria_agg = df_bacteria_transpose.iloc[1:].groupby('cleaned_names').aggregate(sum).transpose()
df_bacteria_agg.to_csv(bacteria_agg_species_file_out)


# Aggregate by strain & save.
df_bacteria_transpose['cleaned_names'] = strain
df_bacteria_agg = df_bacteria_transpose.iloc[1:].groupby('cleaned_names').aggregate(sum).transpose()
df_bacteria_agg.to_csv(bacteria_agg_strain_file_out)

