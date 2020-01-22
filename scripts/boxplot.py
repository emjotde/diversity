import numpy as np
import matplotlib.pyplot as plt
from matplotlib.ticker import FormatStrFormatter
import sys
import math

plt.rc('font', size=12)
plt.rc('axes', titlesize=12)

dataAll = []
human   = []
labels  = []

mtld = False

for path in sys.argv[2:]:
    print(path)
    labels.append(path.split(".")[1])
    if "mtld" in path:
        mtld = True
    with open(path) as file:
        data = []
        for line in file:
            line = line.rstrip("\n")
            (system, score) = line.split(" ")
            if system == "HUMAN":
                human.append(float(score))
            else:
                data.append(float(score))
        dataAll.append(np.array(data))

# plot with various axes scales

cols = int(math.ceil(len(labels) / 2))

fig, axes = plt.subplots(2, cols, figsize=(18, 12), dpi=75, facecolor='w', edgecolor='k', constrained_layout=True)
if len(labels) % 2 == 1:
    axes[-1, -1].axis('off')

for i in range(len(labels)):
    x = int(i / cols)
    y = int(i % cols)
    axes[x, y].boxplot(dataAll[i], whis=10000, widths = 0.6)
    axes[x, y].set_xticklabels([labels[i]])
    axes[x, y].scatter(x=1, y=human[i], c="red", s=100)
    if mtld:
        axes[x, y].yaxis.set_major_formatter(FormatStrFormatter('%.0f'))
    else:
        axes[x, y].yaxis.set_major_formatter(FormatStrFormatter('%.3f'))

fig.savefig(sys.argv[1], bbox_inches='tight')