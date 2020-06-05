import sys
import os
from collections import defaultdict
rules=sys.argv[1]

From=defaultdict(list)

for x in open(rules):
	left=[]
	while 'NOT' in x:
		left.append(x[x.find("NOT"):x.find(')')+1][4:])
		x=x[x.find(')')+1:]
	x=x[2:].strip()
	From[x].append(left)

def dfs(x,level=0):
	print('  '*level,x,len(From[x]))
	for y in From[x]:
		for z in y:
			dfs(z,level+1)
		if len(From[x])>1:print('  '*level,'-------')
for x in sys.stdin:
	dfs(x.strip())
