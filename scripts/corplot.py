import numpy as np
import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter
import sys
import math
from scipy import stats

plt.rc('font', size=12)
plt.rc('axes', titlesize=12)

dataAll = []
human   = []
labels  = []

mtld = False
ref = dict()
for i, path in enumerate(sys.argv[2:]):
    labels.append(path.split(".")[1])
    print(path)
    if "mtld" in path:
        mtld = True
    with open(path) as file:
        x = []
        y = []
        for line in file:
            line = line.rstrip("\n")
            (label, ld, he) = line.split(" ")
            x.append(float(he))
            y.append(float(ld))
            if "HUMAN" in label:
                ref[i] = [float(he), float(ld)]
        dataAll.append([x, y])

# plot with various axes scales
rows = 4
cols = int(math.ceil(len(labels) / rows))
fig, axes = plt.subplots(rows, cols, figsize=(16, 16), dpi=75, facecolor='w', edgecolor='k', constrained_layout=True)

missing = rows * cols - len(labels)
for i in range(1, missing + 1):
    axes[-1, -i].axis('off')

for i in range(len(labels)):
    x = int(i / cols)
    y = int(i % cols)
    axes[x, y].scatter(x=dataAll[i][0], y=dataAll[i][1], c="green")

    gradient, intercept, r_value, p_value, std_err = stats.linregress(dataAll[i][0], dataAll[i][1])
    mn=np.min(dataAll[i][0])
    mx=np.max(dataAll[i][0])
    x1=np.linspace(mn,mx,500)
    y1=gradient*x1+intercept

    axes[x, y].plot(x1,y1,'-r', c="blue")

    if i in ref:
        axes[x, y].scatter(x=[ref[i][0]], y=[ref[i][1]], c="red")

    axes[x, y].set_xlabel(labels[i])
    if mtld:
        axes[x, y].yaxis.set_major_formatter(FormatStrFormatter('%.0f'))
    else:
        axes[x, y].yaxis.set_major_formatter(FormatStrFormatter('%.3f'))
    

fig.savefig(sys.argv[1], bbox_inches='tight')