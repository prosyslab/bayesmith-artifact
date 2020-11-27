import json
import sys
import random
sys.stdout=open(sys.argv[2]+'/task.txt','w')
troot='../../bingo-ci-experiment/benchmark/'+sys.argv[1]+'/sparrow-out/'
batchnum=int(sys.argv[3])
batchid=int(sys.argv[4])
print(sys.argv,file=sys.stderr)
print(troot,file=sys.stderr)
if 'urjtag' in sys.argv[1] or 'shntool' in sys.argv[1] or 'latex2rtf' in sys.argv[1] or 'optipng' in sys.argv[1] \
or 'sdop-0.61' in sys.argv:
	alarms=open(troot+'taint/datalog/DUPath.csv').readlines()
	duedges=open(troot+'taint/datalog/DUEdge.facts').readlines()
else:
	alarms=open(troot+'interval/datalog/DUPath.csv').readlines()
	duedges=open(troot+'interval/datalog/DUEdge.facts').readlines()

s=open(troot+'node.json','rb').read()
nodes=json.loads(s.decode('utf-8','ignore'))['nodes']
i=0
from collections import Counter
c=Counter()
def inin(x):
	for y in x:
		if 'tmp' in y or '___' in y:return True
	return False
for x in nodes:
	c[nodes[x]['cmd'][0]]+=1

batchsize=-(-len(alarms)//batchnum)
random.seed(0)
random.shuffle(alarms)
err=0
def isEntityNode(x):
	#return x['cmd'][0]!='skip'
	return x['cmd'][0] in ['set','alloc','call']
for _ in alarms[batchsize*batchid:batchsize*(batchid+1)]:
	try:
		a,b=nodes[_.split()[0]],nodes[_.split()[1]]
		if isEntityNode(a) and isEntityNode(b):
			i+=1
			print(' '.join(nodes[n]['loc'] for n in _.split()))
		elif 'ENTRY' in _.split()[0]:
			#special ENTRY src and sink, 6/12
			assert a['cmd'][0]=='skip'
			assert b['cmd'][0]!='skip'
			if _ in duedges:
				print(b['loc'],'E:-1')
			else:
				print('E:-1',b['loc'])
		else:err+=1
	except:
		err+=1
print('err',err,file=sys.stderr)
print('number of edges:',i,file=sys.stderr)
