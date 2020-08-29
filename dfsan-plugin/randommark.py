# randomly selecting cons
import sys,random
random.seed(0)
DUPaths,work_dir,num=sys.argv[1:]
dupath=open(DUPaths).readlines()
random.shuffle(dupath)
of=open(work_dir+'/feedback.random','w')
oo=open(work_dir+'/observed-queries.random','w')
for i in range(int(num)):
	x=dupath[i].split()
	print(f'DUPath({x[0]},{x[1]})\t0.8',file=oo)
	print(f'O DUPath({x[0]},{x[1]}) true',file=of)
