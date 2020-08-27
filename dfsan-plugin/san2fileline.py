import sys,os
import json
from collections import defaultdict,Counter
from pathlib import Path
import traceback
sys.setrecursionlimit(int(1e7))
workdir=sys.argv[1]+'/'
init=len(sys.argv)>2 and sys.argv[2]=='init' #init confidence
fileline={}
log=open(workdir+Path(__file__).stem+'.log','w')
fo=open(workdir+'/sanfl.txt','w')
fileline['_SaN_bad00000']=':-1'
for x in open(workdir+'/loc_vars.txt'):
	a,b=x.split()
	fileline[b]=a

instrumented=set(open(workdir+"visited_edges.txt").read().splitlines())
pos=defaultdict(int) #positive edges
neg=Counter() #negative
touched=set()

#dfg[node]=(childA,childB,label)
def load_dfgraph(pid):
	try:
		fdfg=open(workdir+'dfg/'+pid+'dfg.txt')
		global dfg
		dfg=[]
		dfg.append(0)
		a=fdfg.readlines()
		assert a[0].split()==['DFGRAPH',pid]
		assert a[-1]=='END\n'
		t=0
		for x in a[1:-1]:
			ln=x.split()
			assert int(ln[0])==t+1
			t=int(ln[0])
			if len(ln)==3:ln.append('') #no desc
			dfg.append((int(ln[1]),int(ln[2]),ln[3]))
		return True
	except Exception as e:
		print('error file:',workdir+'dfg/'+pid+'dfg.txt')
		print(e)
		return None

def load_sanlog(pid):
	try:
		a=open(workdir+'dfg/'+pid+'san.log').readlines()
		assert a[0].split()[:2]==['start',pid]
		assert a[-1].split()[:2]==['end',pid]
		rt=[]
		t=0
		for x in a[1:-1]:
			x=x.split()
			t+=1
			assert x[0].split('.')==[pid,str(t)]
			assert len(x)==5+1 or len(x)==2+1
			rt.append(x[1:])
		return rt
	except Exception as e:
		print('error file:',workdir+'dfg/'+pid+'san.log')
		print(e)
		return None
def find_all_srcs_of_label(lbl):
	rt=[]
	vis=defaultdict(lambda:0)
	def dfs(i):
		nonlocal vis
		if vis[i]:return
		vis[i]=1
		if i==0:return
		nonlocal rt
		if i>=len(dfg):return
		n=dfg[i]
		if len(n[2]):rt.append(n[2])
		else:
			dfs(n[0]);dfs(n[1])
	dfs(lbl)
	return rt

total_runs=0
def process(insid):
	global total_runs
	pos=set()
	neg=Counter() #negative
	if load_dfgraph(insid)==None:
		print('failed dfg',insid)
		return
	sanlog=load_sanlog(insid)
	if sanlog is None:
		print('failed slg',insid)
		return
	total_runs+=1
	src=set()
	print('run loaded',insid)
	for x in sanlog:
		if len(x)==2:#src
			src.add(x[0])
			continue
		#sanlog
		a,b,lsink,lsrc,p=x
		touched.add(a+' '+b)
		if lsink!='0': #has label
			z=find_all_srcs_of_label(int(lsink))
			for i in z:
				pos.add(fileline[a]+' '+fileline[i])
				#newedges.add(a+' '+i)
		if p=='1' or b in src:
			if p=='1':
				pos.add(fileline[a]+' '+fileline[b])
			else:
				neg[fileline[a]+' '+fileline[b]]+=1
	return pos,neg

processed=set()
for filename in os.listdir(workdir+'dfg'):
	i=filename[:-7]
	if i not in processed:
		_=process(i)
		if _ is not None:
			ppos,pneg=_
			for x in ppos:pos[x]+=1
			for x in pneg:neg[x]+=1
		processed.add(i)
print('total_runs',total_runs)

def positive_confidence(x):
	if init:return .999
	return pos[x]/total_runs
def negative_confidence(x):
	if init:return .999
	return neg[x] # actural times passed

for x in pos:
	print(x,1,positive_confidence(x),file=fo)
for x in neg:
	if x in pos:continue
	print(x,0,negative_confidence(x),file=fo)

print('coverage',len(touched&instrumented),len(instrumented),file=log)
