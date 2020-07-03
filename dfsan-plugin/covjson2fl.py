import sys,json
d=json.load(sys.stdin)
printed=set()
for x in d["point-symbol-info"]:
	filename=x.split('/')[-1]+':'
	for y in d["point-symbol-info"][x]:
		for a,b in d["point-symbol-info"][x][y].items():
			if not b.startswith('0:'):
				toprint=filename+b.split(':')[0]
				if toprint not in printed:
					printed.add(toprint)
					print(toprint)