# python3 plot.py BINGOPREFIX OUTFOLDER TYPE [benchmarks]
import matplotlib.pyplot as plt
import sys,os
import os.path
import itertools
def parseseries(pre):
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
	plt.title(x)
	plt.plot(parseseries(BINGOPREFIX+x.split('-')[0]+'true-combined'),label='DynaBoost')
	plt.plot(parseseries(f'{os.environ["VANILLA_CI"]}/benchmark/{x}/sparrow-out/{TYPE}/bingo_combined/'),label='Bingo',linestyle='dashed')
	plt.xlabel('iterations')
	plt.ylabel('rank of the bug')
	plt.legend()
	plt.savefig(f'{OUTFOLDER}/{x}.png')