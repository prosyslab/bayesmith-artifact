import sys,os
from glob import glob
import matplotlib.pyplot as plt
X=[]
y=[]
app=sys.argv[1]
for x in glob(os.path.expandvars('$BINGO/0113CO*_')+app+"*.txt"):
	X.append(float(x.split('/')[-1][6:].split('_')[0]))
	y.append(len(open(x).readlines())-1)
fig1, ax1 = plt.subplots()
ax1.set_title(app)
ax1.scatter(X,y)
#ax1.set_ylim(ymin=0)
plt.xlabel('sample ratio (%)')
plt.ylabel('iterations')
plt.legend()
plt.savefig('/tmp/sampleplots/cov'+app+'.png')