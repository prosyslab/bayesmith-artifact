import matplotlib.pyplot as plt
import sys
data=[]
name=sys.argv[1]
for x in open('benchmark.csv').readlines():
	if name.split('-')[0] not in x:continue
	x=x.split(',')
	dyna=float(x[2])
	testfree=float(x[4])
	undiff=float(x[6])
	bingo=float(x[8])
	print(x)
for x in sys.stdin.readlines():
	if len(data)==0 or len(data[-1])==10:
		data.append([])
	data[-1].append(int(x))
print(len(data))
assert len(data)==9
fig1, ax1 = plt.subplots()
ax1.set_title(name)
ax1.boxplot(data,positions=range(10,100,10),widths=5,showmeans=True)
ax1.plot([0],[testfree],'o',label='Test-free')
ax1.plot([100],[dyna],'r*',label='DynaBoost')
#ax1.hlines(undiff,0,100,label='Undifferentiated')
ax1.hlines(bingo,0,100,linestyles='dotted',label='Bingo')
ax1.set_ylim(ymin=0)
plt.xlabel('sample ratio (%)')
plt.ylabel('iterations')
plt.legend()
plt.savefig('/tmp/sampleplots/'+name+'.png')