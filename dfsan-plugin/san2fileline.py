import sys,os
import json
from collections import defaultdict,Counter
from pathlib import Path
import traceback

workdir=sys.argv[1]+'/'
fileline={}
log=open(workdir+Path(__file__).stem+'.log','a')
fo=open(workdir+'/sanfl.txt','a')
for x in open(workdir+'/loc_vars.txt'):
	a,b=x.split()
	fileline[b]=a

instrumented=set(open(workdir+"visited_edges.txt").read().splitlines())
pos=set() #positive edges
neg=Counter() #negative
touched=set()

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
	except:
		print('error file:',workdir+'dfg/'+pid+'dfg.txt')
		#traceback.print_exc()
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
	except:
		print('error file:',workdir+'dfg/'+pid+'san.log')
		print(x[0].split('.'),[pid,str(t)])
		#traceback.print_exc()
		return None
def find_all_srcs_of_label(lbl):
	rt=[]
	def dfs(i):
		if i==0:return
		nonlocal rt
		if i>=len(dfg):return
		n=dfg[i]
		if len(n[2]):rt.append(n[2])
		else:
			dfs(n[0]);dfs(n[1])
	dfs(lbl)
	return rt

def process(insid):
	if load_dfgraph(insid)==None:
		print('failed dfg',insid)
		return
	sanlog=load_sanlog(insid)
	if sanlog is None:
		print('failed slg',insid)
		return
	src=set()
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

processed=set()
for filename in os.listdir(workdir+'dfg'):
	i=filename[:-7]
	if i not in processed:
		process(i)
		processed.add(i)

for x in pos:
	print(x,'1',file=fo)
for x in neg:
	if x in pos:continue
	print(x,max(0.1, .5**neg[x]),file=fo)
print('coverage',len(touched&instrumented),len(instrumented),file=log)
