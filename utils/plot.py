# python3 plot.py BINGOPREFIX OUTFOLDER TYPE [benchmarks]
import matplotlib.pyplot as plt
import sys,os
import os.path
import itertools
def parseseries(pre):
	print(pre)
	rt=[]
	for i in itertools.count():
		f=pre+str(i)+'.out'
		if not os.path.isfile(f):break
		f=open(f).readlines()[1:]
		t=0
		for x in f:
			x=x.split()
			if x[2]=='TrueGround':
				t+=int(x[0])
		rt.append(t)
	print(rt)
	return rt
BINGOPREFIX,OUTFOLDER,TYPE=sys.argv[1:4]
BENCHMARKS=sys.argv[4:]
ltx=open(f'{OUTFOLDER}/plts.tex','a')
for x in BENCHMARKS:
	print(x)
	print("""\\begin{subfigure}[b]{0.25\\textwidth}
         \centering
         \includegraphics[width=\\textwidth]{images/eval/"""+x+""".png}
         \caption{"""+x+"""}
     \end{subfigure}
     \hfill""",file=ltx)
	plt.clf()
	#plt.title(x)
	plt.rcParams['text.usetex'] = True
	plt.rcParams.update({'font.size': 16})
	plt.plot(parseseries(BINGOPREFIX+x.split('-')[0]+'true-combined'),label=r'$\textsc{DynaBoost}_\textsc{all}$')
	plt.plot(parseseries(f'{os.environ["VANILLA_CI"]}/benchmark/{x}/sparrow-out/{TYPE}/bingo_combined/'),label=r'$\textsc{Bingo}_\textsc{zero}$',linestyle='dashed')
	plt.xlabel('Iteration number',fontsize=16)
	plt.ylabel('Rank of bug',fontsize=16)
	#plt.legend(prop={'size': 16})
	plt.savefig(f'{OUTFOLDER}/{x}.pdf')