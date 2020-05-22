import sys
import os
os.chdir(sys.argv[1])
visited=set([x.strip() for x in open('visited.txt').readlines()])
interested=set()
for x in open('task.txt').readlines()[1:]:
	for y in x.split():interested.add(y.strip())
missed=interested-visited
print(len(missed))
for x in list(missed)[:10]:
	print(x)
#[line[2:] for line in subprocess.check_output("find . -name {}".split(''), shell=True).splitlines()]
