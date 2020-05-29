import sys
import json
from collections import defaultdict
from collections import deque
workdir=sys.argv[1]
nodefile=sys.argv[2]
dupaths=sys.argv[3]
s=open(nodefile,'rb').read()
nodes=json.loads(s.decode('utf-8','ignore'))['nodes']
fileLine2node=defaultdict(list)
for x in nodes:
	fileLine2node[nodes[x]['loc']].append(x)
edge=defaultdict(list)
for x in open(workdir+'/sanfl.txt'):
	a,b=x.split()
	a=fileLine2node[a]
	b=fileLine2node[b]
	for x in b:
		edge[x].extend(a)
for x in open(dupaths).readlines():
	q=deque()
	vis=set()
	a,b=x.split()
	q.append(a)
	while len(q) and b not in vis:
		nx=q.popleft()
		for y in edge[nx]:
			if y not in vis:
				q.append(y)
				vis.add(y)
	if b in vis:
		print('O DUPath({},{}) true'.format(a,b))
