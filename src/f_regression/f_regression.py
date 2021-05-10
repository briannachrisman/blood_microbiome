import pandas as pd
import numpy as np
from collections import Counter 
import matplotlib.pyplot as plt
import seaborn as sns
import sys
import copy
from tqdm import tqdm
import scipy.stats as stats
import statsmodels.api as sm
from sklearn.preprocessing import StandardScaler
from statsmodels.stats.anova import anova_lm
from statsmodels.formula.api import ols
import scipy.stats as stats
from sklearn.feature_selection import f_regression


COLUMN = sys.argv[1] # Bacteria or virus name.

print(COLUMN)
BLOOD_MICROBIOME_DIR = '/home/groups/dpwall/briannac/blood_microbiome/'
MICROBE_FILE = BLOOD_MICROBIOME_DIR + 'data/kraken_align/microbe_filtered_species.tsv'

BAM_MAPPINGS_FILE = BLOOD_MICROBIOME_DIR + 'data/bam_mappings.csv'
COEFF_OUT_DIR = BLOOD_MICROBIOME_DIR + ('intermediate_files/f_regression/%s.txt' % (COLUMN.replace(' ', '_').replace('/', '_')))

bam_mappings = pd.read_csv(BAM_MAPPINGS_FILE, sep='\t', index_col=1)
bam_mappings['child'] = 1.0*(bam_mappings.relationship=='sibling')
bam_mappings['autism'] = 1.0*(bam_mappings.derived_affected_status=='autism')

df_microbe = pd.read_table(MICROBE_FILE, index_col=0).transpose()



bam_mappings['sample_id'] = bam_mappings.index
exog = pd.get_dummies(bam_mappings.loc[df_microbe.index][['bio_seq_source', 'sex_numeric', 'child', 'autism', 
                                                          'sequencing_plate', 'family', 'sample_id']], drop_first=False, dummy_na=True).astype(float)
exog = exog.drop(['bio_seq_source_LCL', 'sex_numeric_1.0'], axis=1)
exog = exog[exog.columns[exog.sum()!=0]]
exog_scale = pd.DataFrame(StandardScaler().fit(exog).transform(exog))
exog_scale.columns = exog.columns
exog_scale.index = exog.index
exog_scale.columns = exog.columns #[c.replace('.', '_').replace('-', '_') for c in exog_scale.columns]
exog = exog_scale


print(COLUMN)
endog = np.log10(df_microbe[[COLUMN]]+1)
endog = StandardScaler().fit(endog).transform(endog)
min_pval = 0
sig_cols = []
new_exog = exog
new_endog = endog
_, pvals = f_regression(new_exog, new_endog)
cols_left = exog.columns
ols_model = sm.OLS(endog, exog[[cols_left[np.argmin(pvals)]]]).fit()
new_endog = ols_model.resid
min_pval = ols_model.f_pvalue


# Perform F-regression.
while min_pval < (.05/len(df_microbe.columns)):
    sig_cols = sig_cols + [cols_left[np.argmin(pvals)]]
    print(sig_cols[-1])
    old_model = copy.deepcopy(ols_model)
    cols_left = [c for c in exog.columns if c not in sig_cols]
    _, pvals = f_regression(exog[cols_left], new_endog)
    new_exog = exog[sig_cols + [cols_left[np.argmin(pvals)]]]
    try: ols_model = sm.OLS(endog, new_exog).fit()
    except: ols_model = sm.OLS(endog, new_exog[new_exog.columns[::-1]]).fit()
    new_endog = ols_model.resid
    min_pval = anova_lm(old_model, ols_model)['Pr(>F)'][1]
    print(min_pval)
results = [(COLUMN, i,j) for i,j in zip(sig_cols, ols_model.params) if 'sample_id' not in i]
pd.DataFrame(results).to_csv(COEFF_OUT_DIR, header=None)