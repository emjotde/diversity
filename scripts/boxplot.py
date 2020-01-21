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
for path in sys.argv[1:]:
    labels.append(path.split(".")[1])
    with open(path) as file:
        data = []
        for line in file:
            line = line.rstrip("\n")
            (sys, score) = line.split(" ")
            if sys == "HUMAN":
                human.append(float(score))
            else:
                data.append(float(score))
        dataAll.append(np.array(data))

print(dataAll)

# plot with various axes scales

cols = int(math.ceil(len(labels) / 2))

fig, axes = plt.subplots(2, cols, figsize=(18, 12), dpi=75, facecolor='w', edgecolor='k', constrained_layout=True)
if len(labels) % 2 == 1:
    axes[-1, -1].axis('off')


print(cols)
print(labels)
for i in range(len(labels)):
    x = int(i / cols)
    y = int(i % cols)
    print(i, x,y)
    axes[x, y].boxplot(dataAll[i], whis=10000, widths = 0.6)
    axes[x, y].set_xticklabels([labels[i]])
    axes[x, y].scatter(x=1, y=human[i], c="red", s=100)
    axes[x, y].yaxis.set_major_formatter(FormatStrFormatter('%.3f'))

fig.savefig('fig1.png', bbox_inches='tight')