import sys,os.path
import json
from collections import defaultdict
from collections import deque
workdir=sys.argv[1]
nodefile=sys.argv[2]
datalog=sys.argv[3]
prunedname_cons=sys.argv[4]
named_cons_all=open(sys.argv[5]).read()
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

prunedname_cons=open(prunedname_cons).read()

#graph corresponding to the pruned network
print('graph corresponding to the pruned network',file=sys.stderr)
edgep=defaultdict(list)
edgep_r=defaultdict(list)

for x in dupaths:
	a,b=x.split()
	#alive after pruing, check if we can infer the (small) path form large path discovered
	if a+','+b in prunedname_cons:
		edgep[a].append(b)
		edgep_r[b].append(a)

def _all_reachable_nodes_in_reversed_pruned(b):
	global all_reachable_nodes_in_reversed_pruned
	all_reachable_nodes_in_reversed_pruned.add(b)
	if b not in edgep_r:return
	for x in edgep_r[b]:
		if x not in all_reachable_nodes_in_reversed_pruned:
			_all_reachable_nodes_in_reversed_pruned(x)

def find_all_bridges_on_discovered_path(x):
	t=0
	visited={}
	low=defaultdict(lambda: 1e9)
	parent={}
	parent[x]=x
	bridges=[]
	def dfs1(n):
		nonlocal visited,low,parent,t
		t+=1
		low[n]=visited[n]=t
		if n not in edgep:return
		for x in edgep[n]:
			if x not in all_reachable_nodes_in_reversed_pruned:continue
			if x not in visited:
				parent[x]=n
				dfs1(x)
				low[n]=min(low[n],low[x])
				if low[x]>visited[n] or 1:bridges.append((n,x))
			elif x!=parent[n]:
				low[n]=min(low[n],visited[x])# non tree edge
	dfs1(x)
	return bridges

provided=set()
def positive_feedback(a,b):
	global provided
	if (a,b) in provided:
		return
	provided.add((a,b))
	if x in duedges:
		print('O DUEdge({},{}) true'.format(a,b))
		print(f'DUEdge({a},{b})\t0.99',file=confid)
	else:
		print('O DUPath({},{}) true'.format(a,b))
		print(f'DUPath({a},{b})\t0.99',file=confid)
for src in edge:
	for dst in edge[src]:
		reachcnt=0
		all_reachable_nodes_in_reversed_pruned=set()
		_all_reachable_nodes_in_reversed_pruned(dst)
		bridges=find_all_bridges_on_discovered_path(src)
		for x in bridges:
			if x[0]+','+x[1] in named_cons_all:
				positive_feedback(*x)
				print('additional feedback:',x[0]+','+x[1],file=sys.stderr)
print(len(provided),file=sys.stderr)
for x in dupaths:
	a,b=x.split()
	if b in edge[a]:
		positive_feedback(a,b)
	elif b in edgen[a]:
		if x in duedges:
			print('O DUEdge({},{}) false'.format(a,b))
			print(f'DUEdge({a},{b})\t{negative_confidence[(a,b)]}',file=confid)
		else:
			print('O DUPath({},{}) false'.format(a,b))
			print(f'DUPath({a},{b})\t{negative_confidence[(a,b)]}',file=confid)
  