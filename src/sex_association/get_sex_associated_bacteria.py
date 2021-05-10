import pandas as pd
import numpy as np
import glob

import multiprocessing as mp
final_tables = glob.glob('/scratch/users/chloehe/unmapped_reads/bam/*/*/*.final_alignment_table.csv')

def getFusoAndMollicutesCounts(filename):
    print(filename)
    sample_idx = filename.split('/')[-1].replace('.final_alignment_table.csv', '')
    df = pd.read_csv(filename)
    fuso_count = sum(df.R1_ref=='BACT_577|gi|224473368|ref|NZ_ACDH01000101.1|') + sum(df.R2_ref=='BACT_577|gi|224473368|ref|NZ_ACDH01000101.1|')
    mollicutes_count = sum(df.R1_ref=='BACT_769|gi|223714005|gb|ACDT01000210.1|') + sum(df.R2_ref=='BACT_769|gi|223714005|gb|ACDT01000210.1|')
    return sample_idx, fuso_count, mollicutes_count

pool = mp.Pool(mp.cpu_count())


fuso_mollicutes_count = [pool.apply(getFusoAndMollicutesCounts, args=[filename]) for filename in final_tables]
pool.close()    
pd.DataFrame(fuso_mollicutes_count).to_csv('/scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/results/sex_associated_microbes_count/tsv_files/sex_associated_counts.tsv', sep='\t')
