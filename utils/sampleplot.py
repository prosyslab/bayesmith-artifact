import matplotlib.pyplot as plt
import sys
data=[]
name=sys.argv[1]
for x in sys.stdin.readlines():
	if len(data)==0 or len(data[-1])==10:
		data.append([])
	data[-1].append(int(x))
fig1, ax1 = plt.subplots()
ax1.set_title(name)
ax1.boxplot(data,positions=range(10,100,10),widths=5,showmeans=True)
#ax1.set_ylim(ymin=0)
plt.xlabel('sample ratio (%)')
plt.ylabel('iterations')
plt.legend()
plt.savefig('/tmp/sampleplots/'+name+'.png')