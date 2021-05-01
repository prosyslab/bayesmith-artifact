# calculate 10% test case coverage and total coverage
# current line coverage. can migrate to block or function coverage
import sys
BENCHMARKS=sys.argv[1:]
for x in BENCHMARKS:
	try:
		f=open('/tmp/'+x+'/cov/covratio.txt').readlines()
		print(x,end=' ')
		for i in range(10):
			print(f[len(f)*i//10].strip(),end=' ')
		print()
	except:
		print(x,'ERROR')
		pass