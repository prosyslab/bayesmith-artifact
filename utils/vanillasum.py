import glob,sys
import os.path
import itertools
#~/bingo/1108sorttrue-combined
prefix=sys.argv[1]
if not os.path.isfile(prefix+'0.out'):
	print('run not found')
	sys.exit(1)
f=prefix+'0.out'
rank=list(map(lambda x:int(x.split()[0]),filter(lambda x:'TrueGround' in x,open(f).readlines())))
rank=sum(rank)/len(rank)
print(rank)