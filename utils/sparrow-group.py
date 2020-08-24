import sys
from collections import Counter
g=Counter()
for x in open(sys.argv[1]):
	x=x.split()[1].split('-')[0]
	g[x]+=1
print(g)