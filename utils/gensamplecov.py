import sys,os
from glob import glob
app=sys.argv[1]
workdir=sys.argv[2]+'/'
typ=sys.argv[3]
f=open(workdir+'cov/covratio.txt').readlines()
total=len(f)
assert total==len(glob(workdir+'cov/*.praw'))
p=0
for x in range(1,total+1):
	if f[x-1][:-2]!=p:
		p=f[x-1][:-2]
		print(f'export TEST_SAMPLE_RATIO={x/total}')
		PREFIX=f'0113CO{p}_{app}'
		print(f'echo $TEST_SAMPLE_RATIO;./runbingo.sh $1 /tmp/$1/ {typ} {PREFIX} >/dev/null 2>/dev/null')