import glob,sys
import os.path
import itertools
#~/bingo/1108sorttrue-combined
prefix=sys.argv[1]
if not os.path.isfile(prefix+'0.out'):
	print('run not found')
	sys.exit(1)
totalinc=0
event=0
prev=sys.maxsize
for i in itertools.count(start=0):
	f=f'{prefix}{i}.out'
	if not os.path.isfile(f):
		break
	rank=sum(map(lambda x:int(x.split()[0]),filter(lambda x:'TrueGround' in x,open(f).readlines())))
	if rank>prev+5 and rank>prev*1.1:
		event+=1
		totalinc+=rank-prev
	prev=rank
print(totalinc,event)