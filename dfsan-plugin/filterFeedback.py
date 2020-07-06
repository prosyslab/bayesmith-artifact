import sys
pruned,workdir=sys.argv[1:]
pruned=open(pruned).read()
feedback=workdir+'/feedback.txt'
conf=workdir+'/observed-queries.txt'
fconf=open(workdir+'/observed-queries.txt.filtered','w')
ffeedback=open(workdir+'/feedback.txt.filtered','w')
accept,ignore=0,0
for x,y in zip(open(feedback),open(conf)):
	e=x.split()[1]
	if e in pruned:
		print(x,end='',file=ffeedback)
		print(y,end='',file=fconf)
		accept+=1
	else:
		ignore+=1
print('ac/ig',accept,ignore,file=sys.stderr)