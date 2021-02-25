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
#ax1.set_title(name)
ax1.boxplot(data,positions=range(10,100,10),widths=5,showmeans=False)
plt.rcParams['text.usetex'] = True
plt.rcParams['text.latex.preview'] = True
plt.rcParams.update({'font.size': 16})
ax1.plot([0],[testfree],'o',label=r'$\textsc{DynaBoost}_\textsc{zero}$')
ax1.plot([100],[dyna],'r*',label=r'$\textsc{DynaBoost}_\textsc{all}$')
#ax1.hlines(undiff,0,100,label='Undifferentiated')
ax1.hlines(bingo,0,100,linestyles='dotted',label=r'$\textsc{Bingo}_\textsc{zero}$')
ax1.set_ylim(ymin=0)
plt.xlabel('Fraction of test cases (%)',fontsize=16)
plt.ylabel('Number of iterations',fontsize=16)
plt.legend()
plt.savefig('/tmp/sampleplots/'+name+'.pdf')