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
fw   = True
yy = 15

for path in sys.argv[2:]:
    print(path)
    labels.append("WMT" + str(yy))
    yy += 1
    if "mtld" in path:
        mtld = True
    if "bw" in path:
        fw = False
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

cols = len(labels)

fig, ax = plt.subplots(figsize=(18, 6), dpi=75, facecolor='w', edgecolor='k', constrained_layout=True)

ax.boxplot(dataAll, whis=10000, widths = 0.6)
ax.set_xticklabels(labels)
ax.scatter(x=range(1,len(labels) + 1), y=human, c="red", s=100)

if mtld:
    ax.yaxis.set_major_formatter(FormatStrFormatter('%.0f'))
else:
    ax.yaxis.set_major_formatter(FormatStrFormatter('%.3f'))

if mtld:
    ld = "MTLD"
else:
    ld = "TTR"

if fw:
    direction = "correct"
else:
    direction = "inverse"

fig.suptitle("Lexical diversity of WMT systems measured with %s over time (%s direction)" % (ld, direction), y=1.02)

fig.savefig(sys.argv[1], bbox_inches='tight')