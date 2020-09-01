BENCHMARKS=['bc-1.06','cflow-1.5','grep-2.19','gzip-1.2.4a','libtasn1-4.3','patch-2.7.1','readelf-2.24','sed-4.3','sort-7.2','tar-1.28']
for b in BENCHMARKS:
	print(b)
	print(len(open('/tmp/'+b+'/feedback.txt').readlines()))