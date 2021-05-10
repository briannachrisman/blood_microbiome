import pandas as pd
import glob 
import sys

prefix = sys.argv[1]
suffix = sys.argv[2]
out_file = sys.argv[3]

samples_and_batches = pd.read_csv('/oak/stanford/groups/dpwall/users/briannac/general_data/samples_and_batches.tsv', sep='\t', header=None, index_col=0)
samples_finished = [s.split('/')[-1].replace(suffix, '') for s in glob.glob(prefix + '/*' + suffix)]
print(4569 - len(samples_finished), ' not finished yet.')
print(len(samples_and_batches) - len(samples_finished), ' rows in samples_unfinished.')

samples_and_batches[[i not in samples_finished for i in samples_and_batches.index]].to_csv(out_file, sep='\t', header=None)