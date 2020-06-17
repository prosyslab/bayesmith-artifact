import sys
import json
from collections import defaultdict
from pathlib import Path
workdir=sys.argv[1]+'/'
fileline={}
log=open(workdir+Path(__file__).stem+'.log','a')
src=set()
fo=open(workdir+'/sanfl.txt','a')
for x in open(workdir+'/loc_vars.txt'):
	a,b=x.split()
	fileline[b]=a
res=set()
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
		res.add(fileline[a]+' '+fileline[b]+' '+p)
	else:
		discarded+=1
print('discarded '+str(discarded),file=log)
print('res',len(res))
for x in res:
	print(x,file=fo)

print('coverage',len(touched&instrumented),len(instrumented),file=log)
