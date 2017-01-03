# -*- coding: utf-8 -*-

from sys import argv
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

if __name__ == '__main__':
    fname = argv[1]
    # Use . as decimal indicator
    data = pd.read_table(fname, index_col=0, na_values=['NA', "SIN DATO"], decimal='.')
    # sort data by 'real' column

    # plot boxplot of profiles
    plt.figure(figsize=(7,15))
    data.T.boxplot(grid=False, vert=False )
    plt.axvline(0, alpha=0.5)
    plt.yticks(size='xx-small')
    plt.xlabel('Entropy (bits)')
    #plt.tight_layout()
    plt.savefig(argv[1]+"_prof_box.png")
    plt.close()
    
    # Plot scatter plot
    means = data.mean(1)
    stds = data.std(1)
    df = pd.DataFrame([means, stds], index=['mean', 'std'])
    df = df.T
    df.plot(x='mean', y = 'std', kind='scatter')
    plt.tight_layout()
    plt.savefig(argv[1]+"_scatter.png")
    plt.close()
    
    
    


