from glob import glob
import os
a=set()
for x in glob(os.path.expandvars('$BINGO/0113CO*_')+"*.txt"):
	a.add(x.split('_')[1].split('true')[0])
print(a)