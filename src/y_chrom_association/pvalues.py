import pandas as pd
import numpy as np
import sys
from tqdm import tqdm
import scipy.stats as stats

N = int(sys.argv[1])

BLOOD_MICROBIOME_DIR = '/home/groups/dpwall/briannac/blood_microbiome/'

OUT_DIR = BLOOD_MICROBIOME_DIR + 'intermediate_files/query_counts.sex_microbes.pvals/pvals.%04d.txt' % N 

BAM_MAPPINGS_FILE = '/home/groups/dpwall/briannac/general_data/bam_mappings.csv'
bam_mappings = pd.read_csv(BAM_MAPPINGS_FILE, sep='\t', index_col=1)
bam_mappings = bam_mappings[bam_mappings.status=='Passed_QC_analysis_ready']

file = BLOOD_MICROBIOME_DIR + 'intermediate_files/query_counts.sex_microbes/query_counts.sex_microbes.%04d.tsv.gz' % N

total_covs = np.loadtxt('/home/groups/dpwall/briannac/y_chromosome_mismappings/results/coverages/all/total_coverages.tsv')

covs = pd.read_table(file, nrows=10)
samples = covs.columns

# Get pairings.
affected_pairs = []
unaffected_pairs = []
for f in set(bam_mappings.family):
    fam = bam_mappings[(bam_mappings.family==f) & (bam_mappings.relationship=='sibling')]
    affected_females = fam[(fam.sex_numeric=='2.0') & (fam.derived_affected_status=='autism')]
    affected_males = fam[(fam.sex_numeric=='1.0') & (fam.derived_affected_status=='autism')]
    unaffected_females = fam[(fam.sex_numeric=='2.0') & (pd.isna(fam.derived_affected_status))]
    unaffected_males = fam[(fam.sex_numeric=='1.0') & (pd.isna(fam.derived_affected_status))]
    affected_pairs = affected_pairs + [(i,j) for i in affected_females.index for j in affected_males.index if ((i in samples) and (j in samples))]
    unaffected_pairs = unaffected_pairs + [(i,j) for i in unaffected_females.index for j in unaffected_males.index if ((i in samples) and (j in samples))]
males = [m for f,m in (affected_pairs + unaffected_pairs)]
females = [f for f,m in (affected_pairs + unaffected_pairs)]    



pvals = np.zeros(100000) + np.nan
effect_size = np.zeros(100000) + np.nan

mult = 1#.0159 #p.median(covs[males].values.flatten())/np.median(covs[females].values.flatten())
eps = 1e-20
for covs in pd.read_table(file, chunksize=10000):
    print(covs.index[0])
    covs_norm = covs[abs(covs[males].values-covs[females].values).sum(axis=1)>0]
    pvals[covs_norm.index] = [stats.wilcoxon(q[1][males], mult*q[1][females], alternative='greater', zero_method='wilcox').pvalue for q in covs_norm.iterrows()]
    effect_size[covs_norm.index] = [np.mean(q[1][males].values>=q[1][females].values)/np.mean(q[1][males].values<=q[1][females].values) for q in covs_norm.iterrows()]
pvals = pvals[:(covs.index[-1]+1)]
effect_size = effect_size[:(covs.index[-1]+1)]

# Make into dataframe for saving.
df_pvals = pd.DataFrame([pvals, effect_size]).transpose()
df_pvals = df_pvals[~pd.isna(df_pvals[0])]
df_pvals.index = N*100000 + df_pvals.index
df_pvals.to_csv(OUT_DIR, sep='\t', header=None)
