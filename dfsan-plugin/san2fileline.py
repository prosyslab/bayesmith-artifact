import sys
import json
from collections import defaultdict,Counter
from pathlib import Path
workdir=sys.argv[1]+'/'
fileline={}
log=open(workdir+Path(__file__).stem+'.log','a')
src=set()
fo=open(workdir+'/sanfl.txt','a')
for x in open(workdir+'/loc_vars.txt'):
	a,b=x.split()
	fileline[b]=a
pos=set()
neg=Counter()
discarded=0
instrumented=set(open(workdir+"visited_edges.txt").read().splitlines())
touched=set()
for x in open(workdir+'/san.log'):
	if len(x.split())==1:
		#start
		src.clear()
		continue
	if len(x.split())!=3:
		src.add(x.split()[0])
		continue
	a,b,p=x.split()
	touched.add(a+' '+b)
	if p=='1' and b not in src:
		pass
		#print('src_violation',a,b,file=sys.stderr)

	if p=='1' or b in src:
		if p=='1':
			pos.add(fileline[a]+' '+fileline[b])
		else:
			neg[fileline[a]+' '+fileline[b]]+=1
	else:
		discarded+=1
print('discarded '+str(discarded),file=log)
for x in pos:
	print(x,'1',file=fo)
for x in neg:
	if x in pos:continue
	print(x,.5**neg[x],file=fo)
print('coverage',len(touched&instrumented),len(instrumented),file=log)
