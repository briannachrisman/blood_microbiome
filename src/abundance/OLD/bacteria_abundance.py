import pandas as pd
import matplotlib.pyplot as plt
import seaborn as sns
import numpy as np


a=np.concatenate([[tuple(i) for i in sns.color_palette("husl", 34)[n::5]] for n in range(5)])
a = [tuple(i) for i in a]
palette = ['#%02x%02x%02x' % (int(i[0]*255), int(i[1]*255), int(i[2]*255)) for i in a]
fig_dir='/scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/paper/abundances/'

df_melt = pd.read_csv('/scratch/groups/dpwall/personal/briannac/unmapped_reads/microbes/results/df_bacteria_abundances.csv')

sns.set_palette(['#858585'] + palette)
plt.figure(figsize=(10,50))
print('making plot')
sns.stripplot(data=df_melt, y='variable', x='value', hue='color', jitter=.1)
plt.xscale('log')
plt.ylabel('')
plt.xlabel('')
ax = plt.gca()
ax.tick_params(axis='y', which='major', labelsize=10)
plt.box(on=None)
plt.legend().remove()
plt.tight_layout()
print('saving plot')
plt.savefig(fig_dir + 'bacteria_abundance.png', transparent=True, bbox_inches='tight', format='png', dpi=300)
