# shuffle the feedback to generate a guess baseline
import sys,random
e=[]
fb=[]
for x in open(sys.argv[1]+'/feedback.txt'):
	x=x.split()
	e.append(x[1])
	fb.append(x[2])
random.seed(0)
random.shuffle(fb)
ff=open(sys.argv[1]+'/feedback.txt.disturb','w')
for x in range(len(e)):
	print('O',e[x],fb[x],file=ff)
