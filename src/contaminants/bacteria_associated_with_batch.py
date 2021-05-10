import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np


df_melt = pd.read_csv('/scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/results/df_melt_bacteria_batch_associated.csv')
plt.figure(figsize=(10,30))
df_melt = df_melt.sort_values('microbe')
sns.stripplot(data=df_melt[df_melt.in_batch=='0'], x='read counts', y='microbe', color='#D3D3D3', jitter=.2)
sns.stripplot(data=df_melt[df_melt.in_batch!='0'], x='read counts', y='microbe', hue='in_batch', 
              hue_order = sorted(list(np.unique(df_melt[df_melt.in_batch!='0'].in_batch.values))), jitter=.2)
plt.xscale("log")
plt.legend().remove()
plt.tight_layout()
plt.xlim(0,max(df_melt['read counts'])*2)
plt.box(on=None)
plt.savefig('/scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/paper/contaminants/bacteria_associated_with_batch.png', 
            transparent=True, bbox_inches='tight', format='png', dpi=500)