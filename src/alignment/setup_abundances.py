import pandas as pd
from glob import glob
from collections import Counter
import matplotlib.pyplot as plt
import numpy as np
from scipy.stats import mannwhitneyu
import sys

BLOOD_MICROBIOME_DIR = '/home/groups/dpwall/briannac/blood_microbiome/'
BAM_MAPPINGS_FILE = '/home/groups/dpwall/briannac/general_data/bam_mappings.csv'
CONC_FILE= BLOOD_MICROBIOME_DIR + '/data/decontam/concentrations.csv'
ABUNDANCE_FILE_EXACT_PAIRED=BLOOD_MICROBIOME_DIR + 'data/kraken_align/abundances_exact_paired.tsv'
ABUNDANCE_FILE_EXACT_SINGLE=BLOOD_MICROBIOME_DIR + 'data/kraken_align/abundances_exact_single.tsv'
ABUNDANCE_FILE_EXACT_ALL=BLOOD_MICROBIOME_DIR + 'data/kraken_align/abundances_exact_all.tsv'

ABUNDANCE_FILE_CHILDREN_PAIRED=BLOOD_MICROBIOME_DIR + 'data/kraken_align/abundances_children_paired.tsv'
ABUNDANCE_FILE_CHILDREN_SINGLE=BLOOD_MICROBIOME_DIR + 'data/kraken_align/abundances_children_single.tsv'
ABUNDANCE_FILE_CHILDREN_ALL=BLOOD_MICROBIOME_DIR + 'data/kraken_align/abundances_children_all.tsv'
TAXONOMY_FILE = '/home/groups/dpwall/briannac/blood_microbiome/data/kraken_align/taxonomies.tsv'
TAXONOMY_MPA_FILE = '/home/groups/dpwall/briannac/blood_microbiome/data/kraken_align/taxonomies_mpa.tsv'

DATA_OUT_FILE='/home/groups/dpwall/briannac/blood_microbiome/data/kraken_align/'

bam_mappings = pd.read_table(BAM_MAPPINGS_FILE, index_col=1)


abundances_exact = pd.read_table(ABUNDANCE_FILE_EXACT_ALL, index_col=2) #abundances_exact_paired + abundances_exact_single
abundances_exact = abundances_exact.iloc[np.argsort(abundances_exact.drop(['tax_level', 'tax_id'], axis=1).sum(axis=1)).values[::-1]]

abundances_children = pd.read_table(ABUNDANCE_FILE_CHILDREN_ALL, index_col=2) #abundances_exact_paired + abundances_exact_single
abundances_children = abundances_children.iloc[np.argsort(abundances_children.drop(['tax_level', 'tax_id'], axis=1).sum(axis=1)).values[::-1]]

abundances_exact = abundances_exact[abundances_exact.drop(['tax_level', 'tax_id'], axis=1).sum(axis=1)>0]
abundances_children = abundances_children[abundances_children.drop(['tax_level', 'tax_id'], axis=1).sum(axis=1)>0]

# Save final files.
abundances_exact.to_csv(DATA_OUT_FILE + '/abundances_exact.csv')
abundances_children.to_csv(DATA_OUT_FILE + '/abundances_children.csv')