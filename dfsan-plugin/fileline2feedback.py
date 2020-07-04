import sys,os.path
import json
from collections import defaultdict
from collections import deque
workdir=sys.argv[1]
nodefile=sys.argv[2]
datalog=sys.argv[3]
s=open(nodefile,'rb').read()
nodes=json.loads(s.decode('utf-8','ignore'))['nodes']
fileLine2node=defaultdict(list)
sys.stdout=open(workdir+'/feedback.txt','w')
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
dupaths=open(datalog+'DUPath.csv').readlines()
dupathe=defaultdict(list)
for _ in dupaths:
	a,b=_.split()
	dupathe[a].append(b)

# merge edges to larger paths
def dfs0(x):
	global reachable
	reachable.append(x)
	if x not in edge:return
	for y in edge[x]:
		if y not in reachable:
			dfs0(y)
for x in edge:
	reachable=[]
	dfs0(x)
	#print(len(edge[x]),len(list(set(edge[x])|set(reachable))),file=sys.stderr)
	edge[x]=list(set(edge[x])|set(reachable))

# infer smaller paths from edges, requires path unique
path=[]
def dfs1(x):
	global reachcnt,path
	path.append(x)
	print(len(path),x,file=sys.stderr)
	if x==dst:
		reachcnt+=1
		return
	if x in dupathe:
		for y in dupathe[x]:
			if y not in path:
				dfs1(y)
	path.pop()
for src in edge:
	for dst in edge[src]:
		reachcnt=0
		dfs1(src)
		print(src,dst,reachcnt,file=sys.stderr)

for x in dupaths:
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
