import sys,os.path
import json,random
from collections import defaultdict
from collections import deque
workdir=sys.argv[1]+'/'
nodefile=sys.argv[2]
datalog=sys.argv[3]
prunedname_cons=sys.argv[4]
named_cons_all=open(sys.argv[5]).read()
init='INIT' in os.environ
s=open(nodefile,'rb').read()
nodes=json.loads(s.decode('utf-8','ignore'))['nodes']
fileLine2node=defaultdict(list)
sys.stdout=open(workdir+'/feedback.txt','w')
for x in nodes:
	if 'G_-ENTRY' in x or nodes[x]['cmd'][0]!='skip':
		fileLine2node[nodes[x]['loc']].append(x)
edge=defaultdict(list)
edgen=defaultdict(list)
confidence=defaultdict(lambda:.5)
posconfidence=defaultdict(lambda:.8)
#read positive and negative edges from sanfl
for x in open(workdir+'/sanfl.txt'):
	a,b,p,prob=x.split()
	a=fileLine2node[a]
	b=fileLine2node[b] 
	for x in b:
		if p=='1':
			edge[x].extend(a)
			for y in a:
				posconfidence[(x,y)]=float(prob)
		else:
			edgen[x].extend(a)
			for y in a:
				confidence[(x,y)]=float(prob)
duedges=set(open(datalog+'DUEdge.facts').readlines())

confid=open(workdir+'/observed-queries.txt','w')
dupaths=open(datalog+'DUPath.csv').readlines()

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
	edge[x]=list(set(edge[x])|set(reachable))
 
# infer smaller paths from edges, requires path unique

prunedname_cons=open(prunedname_cons).read()

#graph corresponding to the pruned network
print('graph corresponding to the pruned network',file=sys.stderr)
edgep=defaultdict(list)
edgep_r=defaultdict(list)

for x in dupaths:
	a,b=x.split()
	#the path is alive after pruing, check if we can infer the (small) path form large path discovered
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
				if low[x]>visited[n]:bridges.append((n,x))
			elif x!=parent[n]:
				low[n]=min(low[n],visited[x])# non tree edge
	dfs1(x)
	return bridges

provided=set()

feedbacks=[]
confids=[]
default_confidence=defaultdict(lambda:.9)
# read default confidence
for x in open(workdir+'PT.txt'):
	x=x.split()
	if 'Rank'==x[0]:continue
	default_confidence[x[-1]]=float(x[1])

def positive_feedback(a,b):
	global provided
	if (a,b) in provided:
		return
	provided.add((a,b))
	#if x in duedges:
	#	print('O DUEdge({},{}) true'.format(a,b))
	#	print(f'DUEdge({a},{b})\t0.8',file=confid)
	#else:
	feedbacks.append(f'O DUPath({a},{b}) true')
	c=default_confidence[f'DUPath({a},{b})']**(1/3)
	#print('dcin',f'DUPath({a},{b})',(f'DUPath({a},{b})' in default_confidence),('xacacac' in default_confidence),default_confidence[f'DUPath({a},{b})'],file=sys.stderr)
	confids.append(f'DUPath({a},{b})\t{posconfidence[(a,b)]}')

#additional feedback

for _ in range(2):
	toadd=defaultdict(set)
	for src in edge:
		for dst in edge[src]:
			reachcnt=0
			all_reachable_nodes_in_reversed_pruned=set()
			_all_reachable_nodes_in_reversed_pruned(dst)
			bridges=find_all_bridges_on_discovered_path(src)
			for x in bridges:
				if x[0]+','+x[1] in named_cons_all:
					toadd[x[0]].add(x[1])
					positive_feedback(*x)
					print(f'additional feedback{_}:',x[0]+','+x[1],file=sys.stderr)
	print(len(provided),file=sys.stderr)

	for x in toadd:edge[x]=list(set(edge[x])|toadd[x])

	for x in edge:
		reachable=[]
		dfs0(x)
		edge[x]=list(set(edge[x])|set(reachable))

#dump remaining graph and negative feedback
for x in dupaths:
	a,b=x.split()
	if (a,b) in provided:continue
	if b in edge[a]:
		positive_feedback(a,b)
	elif b in edgen[a]:
		#if NEG_LIMIT==0:continue
		if f'DUPath({a},{b})' not in default_confidence:
			print('not in ' if f'DUEdge({a},{b})' not in default_confidence else 'in' ,f'DUPath({a},{b})',file=sys.stderr)
			pass
		#if x in duedges:      
		#	print('O DUEdge({},{}) false'.format(a,b))
		#	print(f'DUEdge({a},{b})\t{negative_confidence[(a,b)]}',file=conf id)
		#else:
		if init:
			conf=confidence[(a,b)]
		else:
			cnt=confidence[(a,b)]
			p=min(.98,default_confidence[f'DUPath({a},{b})'])
			print(p,cnt,file=sys.stderr)
			conf=(1-p)/(1-p+p*(1-p)**cnt)
		assert 0<=conf<=1,'confidence'
		feedbacks.append(f'O DUPath({a},{b}) false')
		confids.append(f'DUPath({a},{b})\t{conf}')
def get_sample_ratio():
	try:
		return float(os.environ['FEEDBACK_SAMPLE_RATIO'])
	except:
		return 1
#FEEDBACKCAP=int(len(dupaths)*1)+1
FEEDBACKCAP=int(get_sample_ratio()*len(feedbacks))+1
def get_sample_seed():
	try:
		return int(os.environ['FEEDBACK_SAMPLE_SEED'])
	except:
		return 233
random.seed(get_sample_seed())
random.shuffle(feedbacks)
random.seed(get_sample_seed())
random.shuffle(confids)
print('edge size',len(edge),file=sys.stderr)
print('feedback available:',len(feedbacks),file=sys.stderr)
for i in range(min(FEEDBACKCAP,len(feedbacks))):
	print(feedbacks[i])
	print(confids[i],file=confid)
