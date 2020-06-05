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
for x in open(workdir+'/sanfl.txt'):
	a,b,p=x.split()
	a=fileLine2node[a]
	b=fileLine2node[b] 
	for x in b:
		if p=='1':
			edge[x].extend(a)
		else:
			edgen[x].extend(a)
duedges=set(open(datalog+'DUEdge.facts').readlines())
for x in open(datalog+'DUPath.csv').readlines():
	a,b=x.split()
	if b in edge[a]:
		if x in duedges:
			print('O DUEdge({},{}) true'.format(a,b))
		else:
			print('O DUPath({},{}) true'.format(a,b))
	elif b in edgen[a]:
		if x in duedges:
			print('O DUEdge({},{}) false'.format(a,b))
		else:
			print('O DUPath({},{}) false'.format(a,b))
