import sys
import os
from collections import Counter
import subprocess
os.chdir(sys.argv[1])
visited=set([x.strip() for x in open('visited.txt').readlines()])
interested=Counter()
for x in open('task.txt').readlines()[1:]:
	a,b=x.split()
	interested[a]|=1
	interested[b]|=2
missed=interested.keys()-visited
missed=sorted(list(missed))
cache=None
fc=[]#file content
for x in missed:
	file,ln=x.split(':')
	if file=='css.c':continue
	ln=int(ln)
	if cache!=file:
		fl=[line[2:] for line in subprocess.check_output("find . -name {}".format(file), shell=True).splitlines()]
		if len(fl)>1:
			fc=[]
		else:
			fc=open(fl[0]).readlines()
		cache=file
	i=0
	for ii in fc:
		i+=1
		if ii.strip()=='#line 1':
			i=0
		if i==ln:
			app=''
			app+='src ' if interested[x]&1 else '    '
			app+='dst' if interested[x]&2 else '   '
			print(app,x,ii,end='')
			break
