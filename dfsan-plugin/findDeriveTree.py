import sys
import os
from collections import defaultdict
rules=sys.argv[1]

From=defaultdict(list)
to=defaultdict(list)

for x in open(rules):
	left=[]
	while 'NOT' in x:
		left.append(x[x.find("NOT"):x.find(')')+1][4:])
		x=x[x.find(  ')')+1:]
	x=x[2:].strip()
	# left==>x

	From[x].append(left)
	for y in left:
		to[y].append(x)

def dfs(x,level=0,silent=False):
	global visited
	if x in visited:return
	visited.add(x)
	if not silent:print('  '*level,x,len(From[x]))
	for y in From[x]:
		for z in y:
			dfs(z,level+1,silent)
		if not silent and len(From[x])>1:print('  '*level,'-------')
def dfsa(x,level=0):
	global visited
	if x in visited:return
	visited.add(x)
	print('  ',x,len(to[x]))
	for y in to[x]:
		dfsa(y,level+1)
sys.setrecursionlimit(1000000)
for x in sys.stdin:
	if len(x.split())>1:
		root,q=x.split()
		visited=set()
		dfs(root,silent=True)
		print(f'{root} depends on {q}: {q in visited}, vis: {len(visited)}')
	else:
		print('===from===')
		visited=set()
		dfs(x.strip())
		#print('===to===')
		#visited=set()
		#dfsa(x.strip())
