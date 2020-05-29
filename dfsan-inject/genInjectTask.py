import json
import sys
sys.stdout=open(sys.argv[2]+'/task.txt','w')
troot='../../bingo-ci-experiment/benchmark/'+sys.argv[1]+'/sparrow-out/'
batchnum=int(sys.argv[3])
batchid=int(sys.argv[4])
print(sys.argv,file=sys.stderr)
print(troot,file=sys.stderr)
alarms=open(troot+'taint/datalog/DUEdge.facts').readlines()
#alarms=open(troot+'taint/datalog/Alarm.facts')
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
for _ in alarms[batchsize*batchid:batchsize*(batchid+1)]:
	a,b=nodes[_.split()[0]],nodes[_.split()[1]]
	i+=1

	print(' '.join(nodes[n]['loc'] for n in _.split()))
print('number of edges:',i,file=sys.stderr)
