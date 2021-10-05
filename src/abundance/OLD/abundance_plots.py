from matplotlib.ticker import Locator
import matplotlib.pyplot as plt
import numpy as np

class MinorSymLogLocator(Locator):
    """
    Dynamically find minor tick positions based on the positions of
    major ticks for a symlog scaling.
    """
    def __init__(self, linthresh):
        """
        Ticks will be placed between the major ticks.
        The placement is linear for x between -linthresh and linthresh,
        otherwise its logarithmically
        """
        self.linthresh = linthresh

    def __call__(self):
        'Return the locations of the ticks'
        majorlocs = self.axis.get_majorticklocs()

        # iterate through minor locs
        minorlocs = []

        # handle the lowest part
        for i in range(1, len(majorlocs)):
            majorstep = majorlocs[i] - majorlocs[i-1]
            if abs(majorlocs[i-1] + majorstep/2) < self.linthresh:
                ndivs = 10
            else:
                ndivs = 9
            minorstep = majorstep / ndivs
            locs = np.arange(majorlocs[i-1], majorlocs[i], minorstep)[1:]
            minorlocs.extend(locs)

        return self.raise_if_exceeds(np.array(minorlocs))

    def tick_values(self, vmin, vmax):
        raise NotImplementedError('Cannot get tick locations for a '
                                  '%s type.' % type(self))

def AbundancePlotSettingsAndSave(file_name):
    plt.legend().remove()
    plt.xscale("symlog", linthresh=100)
    plt.xlim(0,1e7)
    xaxis = plt.gca().xaxis
    xaxis.set_minor_locator(MinorSymLogLocator(100))
    plt.title(file_name)
    plt.tight_layout()
    plt.savefig(file_name, transparent=True, bbox_inches='tight', format='png', dpi=500)
    plt.yticks([])
    plt.ylabel('')
    plt.tight_layout()
    plt.savefig(file_name.replace('.png', '_nolabels.png'), transparent=True, bbox_inches='tight', format='png', dpi=500)
    
def abundance_plot_settings():
    plt.xscale("symlog", linthresh=10)
    plt.xlim(0,)
    plt.legend().remove()
    plt.tight_layout()
    plt.box(on=None)