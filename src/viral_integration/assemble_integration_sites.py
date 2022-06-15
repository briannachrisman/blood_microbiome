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

herpes_6a_contig = 'kraken:taxid|32603|NC_001664.4'
herpes_6b_contig = 'kraken:taxid|32604|NC_000898.1'
herpes_7_contig = 'kraken:taxid|10372|NC_001716.2'
decoy_contig = 'chrUn_JTFH01000690v1_decoy'

bam_mappings = pd.read_csv(bam_mappings_file, sep='\t', index_col=1)
df_virus  = pd.read_pickle(virus_file)
df_virus.index = [i[2] for i in df_virus.index]
df_herpesvirus = df_virus.transpose()
df_herpesvirus.drop(['09C86428', '03C16028'], inplace=True)

OUT_DIR = BLOOD_MICROBIOME_PATH + 'intermediate_files/assemble_integration_sites/'
def GetCoverages(sample_name, contig, hhv, flank):
    print(sample_name, hhv, flank)
    herpes_contigs = [contig]
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
    print(len(reads))
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
                pair_value = [(read1, read2)]
            else:
                pair_key = (read2_reference_name, read1_reference_name)
                pair_value = [(read2, read1)]
            
            if pair_key in pair_dict:
                pair_dict[pair_key] = pair_dict[pair_key] + pair_value
            else: 
                pair_dict[pair_key] =  pair_value
        else:
            read_dict[r.query_name] = r
    if flank=='start':
        seqs = {k:[p[0] for p in pair_dict[k] if (('NC_' not in k[0]) & (min([60e3] + list(p[1].get_reference_positions()))<50e3))] + [
            p[1] for p in pair_dict[k] if (('NC_' not in k[1]) & (min([60e3] + list(p[0].get_reference_positions()))<50e3))] for k in pair_dict}
    else: 
        seqs = {k:[p[0] for p in pair_dict[k] if (('NC_' not in k[0]) & (max([60e3] + list(p[1].get_reference_positions()))>100e3))] + [
            p[1] for p in pair_dict[k] if (('NC_' not in k[1]) & (max([60e3] + list(p[0].get_reference_positions()))>100e3))] for k in pair_dict}
    seqs= {k:seqs[k] for k in seqs if len(seqs[k])>0}
    seqs = [v for vv in seqs.values() for v in vv]    
    if len(seqs)>0:
        print("Writing seqs...")
        with pysam.AlignmentFile(sample_dir + '.paired_aligned_to_hg38_herpes.sam', 'r') as samfile: 
            outfile = pysam.AlignmentFile("%s/%s_%s_%s.bam" % (OUT_DIR, sample_name, hhv, flank), "wb", template=samfile)
            for s in seqs: outfile.write(s)

#for SAMPLE in df_herpesvirus[df_herpesvirus['Human betaherpesvirus 6A']>0].index: GetCoverages(SAMPLE, herpes_6a_contig, 'hhv6A', 'start')
#for SAMPLE in df_herpesvirus[df_herpesvirus['Human betaherpesvirus 6B']>0].index: GetCoverages(SAMPLE, herpes_6b_contig, 'hhv6B', 'start')
#for SAMPLE in df_herpesvirus[df_herpesvirus['Human betaherpesvirus 7']>0].index: GetCoverages(SAMPLE, herpes_7_contig, 'hhv7', 'start')

for SAMPLE in df_herpesvirus[df_herpesvirus['Human betaherpesvirus 6A']>0].index: GetCoverages(SAMPLE, herpes_6a_contig, 'hhv6A', 'end')
for SAMPLE in df_herpesvirus[df_herpesvirus['Human betaherpesvirus 6B']>0].index: GetCoverages(SAMPLE, herpes_6b_contig, 'hhv6B', 'end')
for SAMPLE in df_herpesvirus[df_herpesvirus['Human betaherpesvirus 7']>0].index: GetCoverages(SAMPLE, herpes_7_contig, 'hhv7', 'end')