import sys
import json
from collections import defaultdict
workdir=sys.argv[1]
fileline={}
fo=open(workdir+'/sanfl.txt','a')
for x in open(workdir+'/loc_vars.txt'):
	a,b=x.split()
	fileline[b]=a
res=set()
for x in open(workdir+'/san.log'):
	a,b,_=x.split()
	res.add(fileline[a]+' '+fileline[b])
for x in res:
	print(x,file=fo)
