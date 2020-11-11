import json,sys,os
#tab sep alarm, etc file inside datalog/
s=open(os.path.dirname(sys.argv[1])+'/../../node.json','rb').read()
nodes=json.loads(s.decode('utf-8','ignore'))['nodes']
for x in open(sys.argv[1]):
	x=x.split()[1]
	print(nodes[x]) #['loc'])
