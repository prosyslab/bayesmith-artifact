import sys
import json
from collections import defaultdict
from collections import deque
workdir=sys.argv[1]
nodefile=sys.argv[2]
datalog=sys.argv[3]
s=open(nodefile,'rb').read()
nodes=json.loads(s.decode('utf-8','ignore'))['nodes']
fileLine2node=defaultdict(list)
for x in nodes:
	fileLine2node[nodes[x]['loc']].append(x)
edge=defaultdict(list)
edgen=defaultdict(list)
negative_confidence={}
for x in open(workdir+'/sanfl.txt'):
	a,b,p=x.split()
	a=fileLine2node[a]
	b=fileLine2node[b] 
	for x in b:
		if p=='1':
			edge[x].extend(a)
		else:
			edgen[x].extend(a)
			for y in a:
				negative_confidence[(x,y)]=min(.75,1-float(p))
duedges=set(open(datalog+'DUEdge.facts').readlines())

confid=open(workdir+'/observed-queries.txt','w')
for x in open(datalog+'DUPath.csv').readlines():
	a,b=x.split()
	if b in edge[a]:
		if x in duedges:
			print('O DUEdge({},{}) true'.format(a,b))
			print(f'DUEdge({a},{b})\t0.9',file=confid)
		else:
			print('O DUPath({},{}) true'.format(a,b))
			print(f'DUPath({a},{b})\t0.9',file=confid)
	elif b in edgen[a]:
		if x in duedges:
			print('O DUEdge({},{}) false'.format(a,b))
			print(f'DUEdge({a},{b})\t{negative_confidence[(a,b)]}',file=confid)
		else:
			print('O DUPath({},{}) false'.format(a,b))
			print(f'DUPath({a},{b})\t{negative_confidence[(a,b)]}',file=confid)
