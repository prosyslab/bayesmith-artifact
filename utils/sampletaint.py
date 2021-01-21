import sys,os
import random
from glob import glob
from collections import defaultdict
os.chdir(sys.argv[1]+'/dfg')
c=defaultdict(lambda:[])
for x in glob('*run.log'):
	c[hash(open(x).read())].append(x)
a=[]
for x in c:
	a.append(c[x])
random.seed(int(os.environ['TEST_SAMPLE_SEED']))
random.shuffle(a)
a=a[:(1-int(float(os.environ['TEST_SAMPLE_RATIO']))*len(a))]
def mv(a,b):
	try:
		os.rename(a,b)
	except:
		pass
for x in a:
	for y in x:
		mv(y[:-7]+'run.log','disabled/'+y[:-7]+'run.log')
		mv(y[:-7]+'san.log','disabled/'+y[:-7]+'san.log')
		mv(y[:-7]+'dfg.txt','disabled/'+y[:-7]+'dfg.txt')