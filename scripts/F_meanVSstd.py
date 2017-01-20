#!/usr/bin/python3
# -*- coding: utf-8 -*-
#
# ------------------------------
# Name:     F_meanVSstd.py
# Purpose:  Mean vs std figure of profiles Using ward linkage hyerarchical clustering
#
# @uthor:      acph - dragopoot@gmail.com
#
# Created:     2015
# Copyright:   (c) acph 2015
# Licence:     GNU GENERAL PUBLIC LICENSE, Version 3, 29 June 2007
# ------------------------------
"""Mean vs coefficient of variation figure of profiles and ward linkage hyerarchical clustering. Creates a file for
each cluster that contains the list of profiles that are included."""

import os
import argparse
import numpy as np
import matplotlib.pyplot as plt
import pandas as pd

from sklearn import cluster   # , datasets
from sklearn.neighbors import kneighbors_graph
from sklearn.preprocessing import StandardScaler


def limits(array, percentage=0.01):
    """Computes plot limits to plot the data of an array.

    Parameters
    ----------
    array : 1D array
    percentage : Fraction of the array to add to the limits


    Returns
    -------
    out : Returns a 2 values tuple. First value is low limit and second 
          value is the high limit

    """
    max_ = array.max()
    min_ = array.min()
    ad = (max_ - min_) * percentage
    if max_ == 0.0:
        max_ = 0 + ad
    if min_ == 0.0:
        min_ = 0 - ad
    low = min_ - ad
    high = max_ + ad
    return low, high

# options
epilog = """Example:

$ python3 F_meanVSstd entropies_matrix_entropies.tab -o figure.png"""

parser = argparse.ArgumentParser(description=__doc__, epilog=epilog)
parser.add_argument('filename',
                    help="Input file in tabular format. Rows are pfam families and " +
                    "columns are metagenome fragment (reads) length ")
parser.add_argument(
    '-o', '--out_fig', help='Stores the figure in the specified file (and format).')
parser.add_argument('--dpi', type=int, default=300,
                    help='Resolution for output figure file (default = 300)')
parser.add_argument('-s', '--sigma', action='store_true',
                    help='Plot standard deviation instead of coefficient of variation.')
parser.add_argument('-k', type=int, choices=range(2, 9), default=3,
                    help='Number of k-means clusters (default = 3)')
parser.add_argument('--plot-random', default=None, metavar='DIRECTORY',
                    help='Folder where the *.tab files containing random samples are stored.')
args = parser.parse_args()

# input file
# fname = 'matrices_pfam_entropies.tab'
# fname = 'matrices_curadas_sep_entropies.tab'
fname = args.filename

data = pd.read_table(fname, index_col=0, na_values=['NA', "SIN DATO"],
                     decimal='.')
means = np.array(data.mean(1))
stds = np.array(data.std(1))
mask1 = ~np.isnan(means)
mask2 = ~np.isnan(stds)
mask = mask1 * mask2
data = data.ix[mask]
means = np.array(data.mean(1))
stds = np.array(data.std(1))
cv = stds / means                    # Coefficient of variation
# ID = stds**2 / means                 # Index of dispersion
# cv = ID
# _range = np.array(data).ptp(1)      # Data Range
# cv = _range

##############
# Clustering #
##############
if args.sigma:
    x = np.vstack((means, stds)).T
    y_label = 'Entropy standard deviation'
else:
    x = np.vstack((means, cv)).T
    y_label = 'Entropy variation coefficient'
k = args.k
# noramlize data
X = StandardScaler().fit_transform(x)

# connectivity for ward clustering: search for neighbors for each point
connectivity = kneighbors_graph(X, n_neighbors=10, include_self=False)

# ward clustering
ward = cluster.AgglomerativeClustering(
    n_clusters=k, linkage='ward', connectivity=connectivity)
# fit
ward.fit(X)
# cluster labels
y_pred = ward.labels_
clusts = np.unique(y_pred)
cs_ = ['b', 'g', 'r', 'y', 'k', 'c', 'm', 'grey']

# figure
fig = plt.figure()
# Ax positions
scat_pos = [0.15, 0.15, 0.7, 0.7]
xbox_pos = [0.15, 0.85, 0.7, 0.1]
ybox_pos = [0.85, 0.15, 0.1, 0.7]

axscatter = fig.add_axes(scat_pos, frameon=True)
axxbox = fig.add_axes(xbox_pos, frameon=False)
axybox = fig.add_axes(ybox_pos, frameon=False)

# plot random
if args.plot_random:
    dataframes = {}
    files = os.listdir(args.plot_random)
    files = [f for f in files if '.tab' in f]
    for f in files:
        path = os.path.join(args.plot_random, f)
        key = f.split('.')[-2]
        df = pd.read_table(path)
        del df[df.columns[0]]
        dataframes[key] = df
    panel = pd.Panel(dataframes)
    r_means = panel.mean(0)
    r_stds = panel.std(0)
    if args.sigma:
        r_variation = r_stds
    else:
        # coefficent of variation
        r_variation = r_stds / r_means
#    import seaborn as sns
#    sns.kdeplot(r_means, r_variation, ax=axscatter)
    axscatter.scatter(r_means, r_variation, color='mistyrose',
                      label='Random samples', alpha=0.8)
# scatter plot
for i in clusts:
    mask = y_pred == i
    data_ = x[mask]
    axscatter.scatter(data_[:, 0], data_[:, 1], alpha=0.5,
                      color=cs_[i], label='Cluster {}'.format(i))

leg = axscatter.legend(fontsize='small')
ylims = limits(x[:, 1])
xlims = limits(x[:, 0])
axscatter.set_ylim(ylims)
axscatter.set_xlim(xlims)


clust2 = x[y_pred == 1]
labels = data.index[y_pred == 1]
for i in range(len(labels)):
    axscatter.annotate(labels[i], clust2[i], alpha=0.5, fontsize='xx-small')


axscatter.set_xlabel("Entropy mean", fontweight='bold')
axscatter.set_ylabel(y_label, fontweight='bold')

# box plots
bpx = axxbox.boxplot(x[:, 0], vert=False)
axxbox.set_xticks([])
axxbox.set_yticks([])
axxbox.set_xlim(xlims)
axxbox.set_ylim(0.9, 1.1)

bpy = axybox.boxplot(x[:, 1], vert=True)
axybox.set_xticks([])
axybox.set_yticks([])
axybox.set_ylim(ylims)
axybox.set_xlim(0.9, 1.1)

plt.setp(bpx['boxes'], color='black', linewidth=1.5)
plt.setp(bpx['whiskers'], color='black', linewidth=1.5)
plt.setp(bpx['caps'], color='black', linewidth=1.5)
plt.setp(bpx['fliers'], color='black')

plt.setp(bpy['boxes'], color='black', linewidth=1.5)
plt.setp(bpy['whiskers'], color='black', linewidth=1.5)
plt.setp(bpy['caps'], color='black', linewidth=1.5)
plt.setp(bpy['fliers'], color='black')


# dataframes = {}
# for f in files:
#     path = os.path.join(fol, f)
#     key = f.split('.')[-2]
#     df = pd.read_table(path)
#     del df[df.columns[0]]
#     dataframes[key] = df


# save clusters
for i in clusts:
    mask = y_pred == i
    dset = data.ix[mask]
    m = dset.mean(1)
    s = dset.std(1)
    _cv = m / s
    df = pd.concat((m, s, _cv), 1, keys=['mean', 'std', 'VC'])
    fname = 'cluster_{}_pfam.tab'.format(i)
    df.to_csv(fname, sep='\t')

if args.out_fig:
    plt.savefig(args.out_fig, dpi=args.dpi)
else:
    plt.show()
