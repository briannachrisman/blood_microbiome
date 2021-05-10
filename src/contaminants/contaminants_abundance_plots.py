import pandas as pd
import seaborn as sns
import matplotlib.pyplot as plt
import sys
import numpy as np
import math
from scipy.stats import chi2_contingency
from scipy.stats import f_oneway
from Bio import SeqIO


sys.path.append('/scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/src')
from abundance_plots import AbundancePlotSettingsAndSave

# Set custom color palette
colors = ["#8687d1", "#ff9900",  "#3b5c36"]
sns.set_palette(sns.color_palette(colors))


fig_dir='/scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/paper/contaminants'

### Read in aggregated bacteria dataframe ###

df_bacteria = pd.read_csv('/scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/results/bacteria_abundance_data_agg.csv', index_col=0, sep='\t')
column_labels = {x: x.split(', ')[0] for x in df_bacteria.columns}
df_bacteria.rename(columns=column_labels, inplace=True)

type_col = [x.split(' - ')[1] for x in list(df_bacteria.index)]
df_bacteria['type'] = type_col
df_bacteria = df_bacteria.fillna(0)
max_abundance_df_bacteria = df_bacteria.drop(['batch', 'type'], axis=1).apply(lambda x: (np.nanmax(x)))
df_bacteria.head()
df_bacteria = df_bacteria[list(max_abundance_df_bacteria[max_abundance_df_bacteria>=5].keys()) + ['batch', 'type']]


########### Small (for paper) ###########

fs_df = pd.read_csv('/scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/results/bacteria_contaminant_pvals.csv', index_col=0)

type_contaminants = list(fs_df.index[fs_df.WB<1e-5])
batch_contaminants = list(fs_df.drop('WB', axis=1)[fs_df.drop('WB', axis=1).apply(np.min, axis=1).values<1e-6].index)
min_df = fs_df.apply(min, axis=1)

batch_only = sorted(list(set(batch_contaminants).difference(type_contaminants)))
batch_only_small = sorted(list(pd.DataFrame(min_df[batch_only]).sort_values([0]).index[:50]))
df_batch_contaminants = df_bacteria[batch_only_small + ['type','batch']]
print(len(batch_only_small), ' batch_only_small')

type_only = sorted(list(set(type_contaminants).difference(batch_contaminants)))
df_type_contaminants = df_bacteria[type_only + ['type','batch']]
print(len(type_only), ' type_only')

both = sorted(list(set(type_contaminants).intersection(batch_contaminants)))
both_small = sorted(list(pd.DataFrame(min_df[both]).sort_values([0]).index[:50]))
df_both_contaminants = df_bacteria[both_small + ['type','batch']]
print(len(both_small), ' both_small')


## Associated with batch only

print("Association with batch")
df_melt = pd.melt(df_batch_contaminants.reset_index(), id_vars=['index', 'batch', 'type'])
df_melt.rename(columns={'variable': 'Bacteria', 'value': 'read counts'}, inplace=True)
plt.subplots(figsize=(10,1+len(np.unique(df_melt.Bacteria.values))/3))
sns.stripplot(data=df_melt, x='read counts', y='Bacteria', hue='batch', orient='h', alpha=.5,
                      size=5, jitter=.3)
AbundancePlotSettingsAndSave('%s/bacteria_abundance_batch_associated_small.png' % fig_dir)


## Associated with both

print("Association with both type and batch")
df_melt = pd.melt(df_both_contaminants.reset_index(), id_vars=['index', 'batch', 'type'])
df_melt.rename(columns={'variable': 'Bacteria', 'value': 'read counts'}, inplace=True)
plt.subplots(figsize=(10,1+len(np.unique(df_melt.Bacteria.values))/3))
sns.stripplot(data=df_melt, x='read counts', y='Bacteria', hue='batch', orient='h', alpha=.5,
                      size=5, jitter=.3)
AbundancePlotSettingsAndSave('%s/bacteria_abundance_batch_and_type_associated_batch_colored_small.png' % fig_dir)


df_melt = pd.melt(df_both_contaminants.reset_index(), id_vars=['index', 'batch', 'type'])
df_melt.rename(columns={'variable': 'Bacteria', 'value': 'read counts'}, inplace=True)
plt.subplots(figsize=(10,1+len(np.unique(df_melt.Bacteria.values))/3))
sns.stripplot(data=df_melt, x='read counts', y='Bacteria', hue='type', orient='h', alpha=.5,
                      size=5, jitter=.3)
AbundancePlotSettingsAndSave('%s/bacteria_abundance_batch_and_type_associated_type_colored_small.png' % fig_dir)


######################## Full (for supplement) #####################

df_both_contaminants = pd.read_csv('/scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/results/df_both_contaminants.csv', index_col=0)
df_batch_contaminants= pd.read_csv('/scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/results/df_batch_contaminants.csv', index_col=0)
df_type_contaminants= pd.read_csv('/scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/results/df_type_contaminants.csv', index_col=0)

## Associated with type

print("Association with type")
df_melt = pd.melt(df_type_contaminants.reset_index(), id_vars=['index', 'batch', 'type'])
df_melt.rename(columns={'variable': 'Bacteria', 'value': 'read counts'}, inplace=True)
plt.subplots(figsize=(10,1+len(np.unique(df_melt.Bacteria.values))/3))
sns.stripplot(data=df_melt, x='read counts', y='Bacteria', hue='type', orient='h', alpha=.5,
                      size=5, jitter=.3)
AbundancePlotSettingsAndSave('%s/bacteria_abundance_type_associated.png' % fig_dir)


# Associated with both 

print("Association with both type and batch")
df_melt = pd.melt(df_both_contaminants.reset_index(), id_vars=['index', 'batch', 'type'])
df_melt.rename(columns={'variable': 'Bacteria', 'value': 'read counts'}, inplace=True)
plt.subplots(figsize=(10,1+len(np.unique(df_melt.Bacteria.values))/3))
sns.stripplot(data=df_melt, x='read counts', y='Bacteria', hue='batch', orient='h', alpha=.5,
                      size=5, jitter=.3)
AbundancePlotSettingsAndSave('%s/bacteria_abundance_batch_and_type_associated_batch_colored.png' % fig_dir)


df_melt = pd.melt(df_both_contaminants.reset_index(), id_vars=['index', 'batch', 'type'])
df_melt.rename(columns={'variable': 'Bacteria', 'value': 'read counts'}, inplace=True)
plt.subplots(figsize=(10,1+len(np.unique(df_melt.Bacteria.values))/3))
sns.stripplot(data=df_melt, x='read counts', y='Bacteria', hue='type', orient='h', alpha=.5,
                      size=5, jitter=.3)
AbundancePlotSettingsAndSave('%s/bacteria_abundance_batch_and_type_associated_type_colored.png' % fig_dir)

# Associated with batch only

print("Association with batch")
df_melt = pd.melt(df_batch_contaminants.reset_index(), id_vars=['index', 'batch', 'type'])
df_melt.rename(columns={'variable': 'Bacteria', 'value': 'read counts'}, inplace=True)
plt.subplots(figsize=(10,1+len(np.unique(df_melt.Bacteria.values))/3))
sns.stripplot(data=df_melt, x='read counts', y='Bacteria', hue='batch', orient='h', alpha=.5,
                      size=5, jitter=.3)
AbundancePlotSettingsAndSave('%s/bacteria_abundance_batch_associated.png' % fig_dir)

