# randomly selecting cons
import sys,random
def get_sample_seed():
	try:
		return int(os.environ['FEEDBACK_SAMPLE_SEED'])
	except:
		return 0
random.seed(get_sample_seed())
DUPaths,work_dir,num=sys.argv[1:]
dupath=open(DUPaths).readlines()
random.shuffle(dupath)
of=open(work_dir+'/feedback.random','w')
oo=open(work_dir+'/observed-queries.random','w')
for i in range(int(num)):
	x=dupath[i].split()
	print(f'DUPath({x[0]},{x[1]})\t0.8',file=oo)
	print(f'O DUPath({x[0]},{x[1]}) true',file=of)
