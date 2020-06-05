import sys
pruned,feedback=sys.argv[1:]
pruned=open(pruned).read()
accept,ignore=0,0
for x in open(feedback):
	e=x.split()[1]
	if e in pruned:
		print(x,end='')
		accept+=1
	else:
		ignore+=1
print('ac/ig',accept,ignore,file=sys.stderr)