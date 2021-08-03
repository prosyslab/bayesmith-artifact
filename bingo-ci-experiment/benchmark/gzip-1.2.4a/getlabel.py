import json
arr=[]
for x in ["gzip.c:515", "gzip.c:1005", "gzip.c:1053", "gzip.c:1056", "gzip.c:1070", "gzip.c:1133", "gzip.c:1434", "gzip.c:1439", "gzip.c:1467", "gzip.c:1502","gzip.c:1504", "gzip.c:1685", "gzip.c:1688"]:
	a,b=x.split(':')
	arr.append({'project':'gzip-1.2.4a','file':a,'line':int(b)})
print(json.dumps(arr))