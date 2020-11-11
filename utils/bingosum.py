import sys,os
from collections import defaultdict
prefix=sys.argv[1]
RTYPES=['full','true','random','nofeedback']
def parsesname(x):
	for y in RTYPES:
		if y in x:
			return x.split(y)[0],y
	assert 0
data={}
for x in sorted(os.listdir(os.environ['BINGO'])):
	if 'stats' in x and x.startswith(prefix):
		a,b=parsesname(x)
		if a not in data:data[a]=defaultdict(lambda:'null,null')
		try:
			c0=open(os.environ['BINGO']+'/'+a+b+'-combined0.out').readlines()
			c0=map(lambda x:int(x.split()[0]),filter(lambda x:'TrueGround' in x,c0))
			c0=list(c0)
			avginit=sum(c0)/len(c0) if len(c0)>1 else c0[0]
			y=open(os.environ['BINGO']+'/'+x).readlines()
			inv=y[1].split()[-3]
			#print(inv)
			iters=len(y)-1
			if int(y[-1].split()[3])==0: #bug not found
				iters='>'+str(iters)
			#print(iters)
			data[a][b]=f'{str(round(avginit, 2))},{iters}'
		except:
			pass
print('Summary,',','.join([x+'avirank,'+x+'iters' for x in RTYPES]))
for x in data:
	print(x,end='')
	for y in RTYPES:
		print('',data[x][y],sep=',',end='')
	print('')
	