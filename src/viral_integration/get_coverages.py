import pandas as pd
from collections import Counter
import numpy as np
import glob
import sys
from tqdm import tqdm
import os
import pysam
from collections import OrderedDict

BLOOD_MICROBIOME_PATH = '/home/groups/dpwall/briannac/blood_microbiome/'
fig_dir=BLOOD_MICROBIOME_PATH + 'results/abundances/'

sys.path.append('/home/groups/dpwall/briannac/blood_microbiome/src')
bam_mappings_file = '/home/groups/dpwall/briannac/general_data/bam_mappings.csv'

virus_file = BLOOD_MICROBIOME_PATH + 'data/kraken_align/virus_filtered_species.df' 


bam_mappings = pd.read_csv(bam_mappings_file, sep='\t', index_col=1)
df_virus  = pd.read_pickle(virus_file)
df_virus.index = [i[2] for i in df_virus.index]
df_virus = df_virus.transpose()
df_herpesvirus = np.log10(df_virus[[c for c in df_virus.columns if 'herpesvirus' in c]]+1)
df_herpesvirus.drop('09C86428', inplace=True)

herpes_6a_contig = 'kraken:taxid|32603|NC_001664.4'
herpes_6b_contig = 'kraken:taxid|32604|NC_000898.1'
herpes_7_contig = 'kraken:taxid|10372|NC_001716.2'
herpes_contigs = [herpes_6a_contig, herpes_6b_contig, herpes_7_contig]
def GetCoverages(sample_name):
    sample_dir = BLOOD_MICROBIOME_PATH + 'intermediate_files/herpesvirus/%s' % sample_name
    with pysam.AlignmentFile(sample_dir + '.paired_aligned_to_hg38_herpes.sam', 'r') as samfile:
        reads = [r for r in samfile.fetch() if not r.is_supplementary]
    with pysam.AlignmentFile(sample_dir + '.single_aligned_to_hg38_herpes.sam', 'r') as samfile:
        reads =  reads + [r for r in samfile.fetch() if not r.is_supplementary]
    with pysam.AlignmentFile(sample_dir + '.single_original_alignment.sam', 'r') as samfile:
        reads = reads + [r for r in samfile.fetch()  if not r.is_supplementary]
    #return 1
    read_dict = {}
    pair_dict = {}
    for r in reads:
        if r.query_name in read_dict:
            read2 = r
            read1 = read_dict[r.query_name]
            read1_reference_name = read1.reference_name
            read2_reference_name = read2.reference_name
            if (read1_reference_name not in herpes_contigs) and (read2_reference_name not in herpes_contigs): continue
            read1 = read_dict[r.query_name]
            if not read1_reference_name: read1_reference_name = 'unmapped'
            if not read2_reference_name: read2_reference_name = 'unmapped'
            if read1_reference_name < read2_reference_name:
                pair_key = (read1_reference_name, read2_reference_name)
                pair_value = [(read1.positions, read2.positions)]
            else:
                pair_key = (read2_reference_name, read1_reference_name)
                pair_value = [(read2.positions, read1.positions)]
            
            if pair_key in pair_dict:
                pair_dict[pair_key] = pair_dict[pair_key] + pair_value
            else: 
                pair_dict[pair_key] =  pair_value
        else:
            read_dict[r.query_name] = r
    return {k:(Counter(np.concatenate([p[0] for p in pair_dict[k]])),Counter(np.concatenate([p[1] for p in pair_dict[k]])), len(pair_dict[k])) for k in pair_dict}
    
coverages = {}
for i, sample_name in tqdm(enumerate(df_herpesvirus.index)):
    if i==4299: continue # Skip sample with very large HSV count because it is making script unable to finish.
    try: coverages.update({sample_name: GetCoverages(sample_name)})
    except: print(sample_name, 'failed...')
counter_sum = Counter()
for c in [Counter({k:len(c[k][0]) for k in c}) for c in coverages.values()]:
    counter_sum = counter_sum + c
    

np.save(BLOOD_MICROBIOME_PATH + 'results/herpesvirus/coverages.npy', coverages)