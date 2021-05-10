import pandas as pd
import sys
import os
import glob
from collections import defaultdict, OrderedDict
import pysam
from matplotlib import pyplot as plt
import math

def set_pandas_display_options() -> None:
    """Set pandas display options."""
    # Ref: https://stackoverflow.com/a/52432757/
    display = pd.options.display

    display.max_columns = 1000
    display.max_rows = 1000
    display.max_colwidth = 199
    display.width = None
    # display.precision = 2  # set as needed

    
def plot_unmapped_reads(folder, ylim, window = 10000000):
    
    # read final_alignment_table.csv into memory
    dtype = {'R1_ref': object, 'R1_start': object, 'R1_MAPQ': 'float64', 'R1_is_reverse': 'boolean',
             'R2_ref': object, 'R2_start': object, 'R2_MAPQ': 'float64', 'R2_is_reverse': 'boolean',
             'is_proper_pair': bool}
    file = glob.glob(os.path.join(folder, '*alignment_table.csv'))[0]
    table = pd.read_csv(file, dtype=dtype, index_col=0)
    
    
    # filter for reads that contain chromosomal and unmapped alignments in order to make the next
    # counting step more efficient
    table_chr = table[table['R1_ref'].str.startswith('chr') | table['R2_ref'].str.startswith('chr')]
    table_chr = table_chr[(table_chr['R1_ref'] == 'unmapped') | (table_chr['R2_ref'] == 'unmapped')]

    # iterate through table by row and count unmapped reads
    counter = defaultdict(int)
    counter.clear()
    for row in table.itertuples():
        if row.R2_ref in index and row.R1_ref == 'unmapped':
            quotient = math.floor(int(row.R2_start)/window)
            key = row.R2_ref + ':' + str(quotient*window+1) + '-' + str(min((quotient+1)*window, reference_dict[row.R2_ref]))
            counter[key] += 1
        elif row.R1_ref in index and row.R2_ref == 'unmapped':
            quotient = math.floor(int(row.R1_start)/window)
            key = row.R1_ref + ':' + str(quotient*window+1) + '-' + str(min((quotient+1)*window, reference_dict[row.R1_ref]))
            counter[key] += 1

    # normalize counts
    normalized_counter = defaultdict(int)
    normalized_counter.clear()
    for key, value in counter.items():
        normalized_counter[key] = counter[key] / label_dict[key]

    # plot
    print(os.path.basename(folder))
    fig = plt.figure(figsize=(20,10))
    ax = fig.add_axes([0.1,0.1,0.8,0.8])
    y = [normalized_counter[i] for i in list(label_dict)]
    plt.plot(y)
    plt.ylim(ylim)
    every_nth = 10
    plt.xticks(range(len(label_dict)), list(label_dict), size='medium', rotation='vertical')
    for n, label in enumerate(ax.xaxis.get_ticklabels()):
        if n % every_nth != 0:
            label.set_visible(False)
    plt.show()
    
    
def count_alignment(directory):
    MAPQ_THRESH=55
    folders = [folder for folder in os.listdir(directory) if os.path.isdir(os.path.join(directory, folder))]
    folders = sorted(folders)
    
    virus_family_tallied = []
    # virus_family_counts = []
    bacteria_family_tallied = []
    # bacteria_family_counts = []
    viral_hg38_tallied = []
    
    for folder in folders:
        print(folder + '..')
        
        # read final_alignment_table.csv into memory
        dtype = {'R1_ref': object, 'R1_start': object, 'R1_MAPQ': 'float64', 'R1_is_reverse': 'boolean',
                 'R2_ref': object, 'R2_start': object, 'R2_MAPQ': 'float64', 'R2_is_reverse': 'boolean',
                 'is_proper_pair': bool}
        file = glob.glob(os.path.join(directory, folder, '*alignment_table.csv'))[0]
        table = pd.read_csv(file, dtype=dtype, index_col=0)
        table['R1_MAPQ'] = [0 if np.isnan(i) else i for i in table.R1_MAPQ]
        table['R2_MAPQ'] = [0 if np.isnan(i) else i for i in table.R2_MAPQ]
        
        viral_counts = defaultdict(lambda: defaultdict(int))    # all reads mapped to viruses
        bacterial_counts = defaultdict(lambda: defaultdict(int))    # all reads mapped to bacteria
        viral_hg38_counts = defaultdict(lambda: defaultdict(int))    # reads with one end mapped to virus and the other end mapped to hg38+decoy
        
        # iterate by row
        for row in table.itertuples():
            # count all viral reads
            if row.R1_ref.startswith('NC') or row.R1_ref.startswith('VIRL'):
                if (row.R1_ref>=MAPQ_THRESH) or ((row.R2_ref>=MAPQ_THRESH) and (row.R2_ref==row.R1_ref)):
                    viral_counts[row.R1_ref][row.R2_ref] += 1
                
                # count viral/hg38 read pairs
                if row.R2_ref.startswith('chr') or row.R2_ref.startswith('HLA'):
                    viral_hg38_counts[row.R1_ref][row.R2_ref] += 1
                
            if row.R2_ref.startswith('NC') or row.R2_ref.startswith('VIRL'):
                if (row.R2_ref>=MAPQ_THRESH) or ((row.R1_ref>=MAPQ_THRESH) and (row.R1_ref==row.R2_ref)):
                    viral_counts[row.R2_ref][row.R1_ref] += 1
                
                if row.R1_ref.startswith('chr') or row.R1_ref.startswith('HLA'):
                    viral_hg38_counts[row.R2_ref][row.R1_ref] += 1
                
            # count all bacterial reads
            if row.R1_ref.startswith('BACT') or row.R1_ref.startswith('ARCH') or row.R1_ref.startswith('EUKY'):
                if (row.R1_ref>=MAPQ_THRESH) or ((row.R2_ref>=MAPQ_THRESH) and (row.R2_ref==row.R1_ref)):
                    bacterial_counts[row.R1_ref][row.R2_ref] += 1
            if row.R2_ref.startswith('BACT') or row.R2_ref.startswith('ARCH') or row.R2_ref.startswith('EUKY'):
                if (row.R2_ref>=MAPQ_THRESH) or ((row.R1_ref>=MAPQ_THRESH) and (row.R1_ref==row.R2_ref)):
                    bacterial_counts[row.R2_ref][row.R1_ref] += 1
        
        # make dictionary for viral read counts
        viral_total = defaultdict(int)
        for key in viral_counts:
            viral_total[key] = sum(viral_counts[key].values())
            viral_counts[key] = OrderedDict(sorted(viral_counts[key].items(), key=lambda x: x[1], reverse=True))
        viral_total = OrderedDict(sorted(viral_total.items(), key=lambda x: x[1], reverse=True))

        viral_counts_sorted = OrderedDict()
        for key in list(viral_total):
            viral_counts_sorted[key] = viral_counts[key]
            
        virus_family_tallied.append(viral_total)
        # virus_family_counts.append(viral_counts_sorted)
        
        # make dictionary for bacterial read counts
        bacterial_total = defaultdict(int)
        for key in bacterial_counts:
            bacterial_total[key] = sum(bacterial_counts[key].values())
            bacterial_counts[key] = OrderedDict(sorted(bacterial_counts[key].items(), key=lambda x: x[1], reverse=True))
        bacterial_total = OrderedDict(sorted(bacterial_total.items(), key=lambda x: x[1], reverse=True))
        
        bacterial_counts_sorted = OrderedDict()
        for key in list(bacterial_total):
            bacterial_counts_sorted[key] = bacterial_counts[key]
            
        bacteria_family_tallied.append(bacterial_total)
        # bacteria_family_counts.append(bacterial_counts_sorted)
        
        viral_hg38_df = pd.DataFrame.from_dict(viral_hg38_counts)
        viral_hg38_df.fillna(0, inplace=True)
        viral_hg38_df['sampleID'] = folder
        viral_hg38_tallied.append(viral_hg38_df)
        
    return virus_family_tallied, bacteria_family_tallied, viral_hg38_tallied


def make_combined_table(directory):
    
    folders = sorted([os.path.join(directory, folder) for folder in os.listdir(directory) if os.path.isdir(os.path.join(directory, folder))])
    
    virus_tallied, bacteria_tallied, viral_hg38_tallied = count_alignment(directory)
    
    # make virus table
    virus_df = []
    for i, t in enumerate(virus_tallied):
        virus_df.append(pd.DataFrame.from_dict(t, orient='index', columns=[os.path.basename(folders[i])]))
    virus_df = pd.concat(virus_df, axis=1)
    virus_df = virus_df.fillna(0)
    # virus_df = virus_df[virus_df.ge(threshold).any(axis=1)]
    
    virus_df.insert(0, 'pop_average', virus_df.mean(numeric_only=True, axis=1))
    virus_df = virus_df.sort_values('pop_average', ascending=False)
    
    # make bacteria table
    bacteria_df = []
    for i, t in enumerate(bacteria_tallied):
        bacteria_df.append(pd.DataFrame.from_dict(t, orient='index', columns=[os.path.basename(folders[i])]))
    bacteria_df = pd.concat(bacteria_df, axis=1)
    bacteria_df = bacteria_df.fillna(0)
    # bacteria_df = bacteria_df[bacteria_df.ge(threshold).any(axis=1)]
    
    bacteria_df.insert(0, 'pop_average', bacteria_df.mean(numeric_only=True, axis=1))
    bacteria_df = bacteria_df.sort_values('pop_average', ascending=False)
    
    # get metadata
    bam_mappings = pd.read_csv('/scratch/groups/dpwall/personal/chloehe/unmapped_reads/aws/bam_mappings.csv', sep='\t')
    bam_mappings = bam_mappings[['family', 'participant_id', 'sample_id', 'relationship', 'sex_numeric', 'status',
                  'batch_name', 'sequencing_plate', 'bio_seq_source',]]
    seq_source = {}
    family = {}
    relationship = {}
    for folder in folders:
        row = bam_mappings[bam_mappings['sample_id']==os.path.basename(folder)]
        seq_source[os.path.basename(folder)] = row['bio_seq_source'].values[0]
        family[os.path.basename(folder)] = row['family'].values[0]
        relationship[os.path.basename(folder)] = row['relationship'].values[0]

    virus_df = pd.concat([pd.DataFrame(seq_source, index=['seq_source']), 
                    pd.DataFrame(family, index=['family']), 
                    pd.DataFrame(relationship, index=['relationship']), 
                    virus_df])
    bacteria_df = pd.concat([pd.DataFrame(seq_source, index=['seq_source']), 
                    pd.DataFrame(family, index=['family']), 
                    pd.DataFrame(relationship, index=['relationship']), 
                    bacteria_df])
    
    viral_hg38_df = pd.concat(viral_hg38_tallied, axis=0).fillna(0)
    
    return virus_df, bacteria_df, viral_hg38_df