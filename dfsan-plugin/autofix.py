import sys
f=open('makeerr.txt','r')
log=open('autofix.log','w')
log.write('autofix called\n')
changes=False
for x in f:
	if 'undefined reference to' in x:
		y=x.split(': undefined reference to')[0]
		if y[-1].isdigit():
			print(x)
			a,b=y.split(':')
			ff=open(a,'r').readlines()
			print('removing',ff[int(b)-1],end='')
			print('removing',ff[int(b)-1],end='',file=log)
			ff[int(b)-1]='\n'
			changes=True
			open(a,'w').write(''.join(ff))
if not changes:
	sys.exit(1)
