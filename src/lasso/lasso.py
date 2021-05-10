import pandas as pd
import sys
import numpy as np
from tqdm import tqdm
from sklearn import linear_model
import multiprocessing
from joblib import Parallel, delayed
import glob 

num_cores = multiprocessing.cpu_count()

COLUMN = sys.argv[1] # Bacteria or virus name.
N_BOOTS = int(sys.argv[2]) # Number of bootstraps to run.
MICROBE_TYPE = sys.argv[3] # Types of microbes.

print(COLUMN)

BLOOD_MICROBIOME_DIR = '/home/groups/dpwall/briannac/blood_microbiome/'s
MICROBE_FILE = BLOOD_MICROBIOME_DIR + 'data/%s_filtered.csv' % MICROBE_TYPE
BAM_MAPPINGS_FILE = BLOOD_MICROBIOME_DIR + 'data/bam_mappings.csv'

bam_mappings = pd.read_csv(BAM_MAPPINGS_FILE, sep='\t', index_col=1)
df_microbe = pd.read_csv(MICROBE_FILE, index_col=0)

COEFF_OUT_DIR = BLOOD_MICROBIOME_DIR + ('intermediate_files/lasso/%s_%s.txt' % (MICROBE_TYPE,
    COLUMN.replace(' ', '_').replace('/', '_')))

# Write to exog directory if not written (should be written after first run)
#exog = pd.get_dummies(bam_mappings.loc[df_microbe.index][['sequencing_plate', 'bio_seq_source', 'family', 'sex_numeric', 'derived_affected_status', 'relationship']], drop_first=False).astype(float)
#EXOG_DIR = BLOOD_MICROBIOME_DIR + 'intermediate_files/lasso/exog.csv'
if len(glob.glob(EXOG_DIR))==0:
    exog.to_csv(EXOG_DIR, index=None)
# Write to exog directory if not written (should be written after first run)
exog = pd.get_dummies(bam_mappings.loc[df_microbe.index][['sequencing_plate', 'bio_seq_source', 'sex_numeric', 'derived_affected_status', 'relationship', 'family']], drop_first=False).astype(float)
exog['derived_affected_status_autism'] = exog['derived_affected_status_autism'] + exog['derived_affected_status_asd']
exog['relationship_parent'] = 1-exog['relationship_sibling']
exog = exog.drop(['derived_affected_status_broad-spectrum', 'derived_affected_status_not-met', 'derived_affected_status_nqa','derived_affected_status_asd','relationship_mother', 'relationship_father'], axis=1) #, 'sex_numeric_1.0', 'bio_seq_source_LCL'], axis=1)
exog['derived_affected_status_nt'] = ((exog['relationship_sibling']==1) & (exog['derived_affected_status_autism']==0))*1.0
    
print('Cross-validation for alpha...')
np.random.seed(np.cumsum([ord(i) for i in COLUMN])[-1])
endog = np.log(df_microbe[COLUMN]+1)
lm = linear_model.LassoCV(positive=True, fit_intercept=True, cv=10)
lm.fit(exog, endog)
alpha = lm.alpha_

def ComputeCoefficients(i):
    np.random.seed(i)
    new_idx = [np.random.randint(0,len(exog)) for i in endog]
    exog_new = exog.iloc[new_idx]
    endog_new = endog[new_idx]
    lm = linear_model.Lasso(positive=True, fit_intercept=True, alpha=alpha)
    lm.fit(exog_new, endog_new)
    return lm.coef_

print('running bootstrap')
inputs = tqdm([i for i in range(N_BOOTS)])
coeffs = Parallel(n_jobs=num_cores)(delayed(ComputeCoefficients)(i) for i in inputs)
print('Computing p values...')
pvals = [sum([c[i]==0 for c in coeffs])/N_BOOTS for i in range(len(coeffs[0]))]
print('Writing to file...')
with open(COEFF_OUT_DIR, 'w') as f:
    f.write(','.join([COLUMN] + [str(p) for p in list(pvals)]) + '\n')