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

samples = pd.read_table('/home/groups/dpwall/briannac/blood_microbiome/intermediate_files/1kg_herpes/unfinished_files.tsv', header=None,index_col=0).index.values


herpes_6a_contig = 'kraken:taxid|32603|NC_001664.4'
herpes_6b_contig = 'kraken:taxid|32604|NC_000898.1'
herpes_7_contig = 'kraken:taxid|10372|NC_001716.2'
herpes_4_contig = 'kraken:taxid|10376|NC_007605.1'
herpes_contigs = [herpes_6a_contig, herpes_6b_contig, herpes_7_contig, herpes_4_contig]

def GetCoverages(sample_name):
    sample_dir = BLOOD_MICROBIOME_PATH + 'intermediate_files/1kg_herpes/%s' % sample_name
    with pysam.AlignmentFile(sample_dir + '.realigned.bam', 'r') as samfile:
        reads = [r for r in samfile.fetch() if not r.is_supplementary]
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
    print(sample_name, "SUCCEEDED")
    return {k:(Counter(np.concatenate([p[0] for p in pair_dict[k]])),Counter(np.concatenate([p[1] for p in pair_dict[k]])), len(pair_dict[k])) for k in pair_dict}
    
coverages = {}
for i, sample_name in tqdm(enumerate(samples)):
    try: coverages.update({sample_name: GetCoverages(sample_name)})
    except: print(sample_name, 'failed...')
counter_sum = Counter()
for c in [Counter({k:len(c[k][0]) for k in c}) for c in coverages.values()]:
    counter_sum = counter_sum + c
    

np.save(BLOOD_MICROBIOME_PATH + 'results/herpesvirus/coverages_1kg.npy', coverages)