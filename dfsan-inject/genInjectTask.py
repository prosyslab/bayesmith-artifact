import json
import sys
sys.stdout=open('/tmp/task.txt','w')
print('task.out.c patch.txt')
troot='../../bingo-ci-experiment/benchmark/'+sys.argv[1]+'/sparrow-out/'
print(troot,file=sys.stderr)
#alarms=open(troot+'taint/datalog/DUEdge.facts')#60k
alarms=open(troot+'taint/datalog/Alarm.facts')
s=open(troot+'node.json','rb').read()
nodes=json.loads(s.decode('utf-8','ignore'))['nodes']
i=0
import random
for _ in alarms:
	#if random.random()>.001:continue
	i+=1
	print(_,end='',file=sys.stderr)
	for n in _.split():
		print(nodes[n]['loc'])
print('number of edges:',i,file=sys.stderr)
