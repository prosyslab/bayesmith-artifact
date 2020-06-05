import sys
feedback,tree=sys.argv[1:]
used=set()
for x in open(tree):
	y=x.split()
	if len(y)==2:
		if '_G_-ENTRY' not in y[0]:
			print(y[0])
			used.add(y[0])
for x in open(feedback):
	y=x.split()[1]
	print(y,(y in used))