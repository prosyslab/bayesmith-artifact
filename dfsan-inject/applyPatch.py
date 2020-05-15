import copy
import os
import sys
srcroot=sys.argv[1]
realpath={}
for root,dirs,paths in os.walk(srcroot):
	for p in paths:
		if p.endswith('.c') or p.endswith('.h'):
			if p in realpath:#duplicate file
				while True:
					print('replace:',realpath[p][0],'with',root+'/'+p,'?(y/n)')
					i='N'#input()
					if i=='y' or i=='Y' or i=='N' or i=='n':break
				if i=='n' or i=='N':continue
			realpath[p]=(root+'/'+p,list(open(root+'/'+p,'r')))
block=''
oldcode=copy.deepcopy(realpath)
for x in open('/tmp/patch.txt'):
	if x.startswith('before ') or x.startswith('after') or x.startswith('aftersemi '):
		fl=x.split(' ')[1]
		f,l=fl.split(':')
		if f not in realpath: #  or f=='connect.c':
			block=''
			continue
		print(x.strip(),len(realpath[f][1]))
		if f not in realpath:
			print('warning:',f,' not patched')
			block=''
			continue
		if l[0]=='I':#after include
			last_include=0
			depth=0
			for i in range(len(realpath[f][1])):
				if '#include' in realpath[f][1][i]:
					last_include=i
			print('last include',last_include)
			for i in range(len(realpath[f][1])):
				if '#if' in realpath[f][1][i]:
					depth+=1
				elif '#endif' in realpath[f][1][i]:
					depth-=1
				if depth==0 and i>=last_include:
					realpath[f][1][i]+='\n'+block+'\n'
					break
			block=''
			continue
		l=int(l)-1
		if x.startswith('before'):
			realpath[f][1][l]=block+'\n'+realpath[f][1][l]
		elif x.startswith('aftersemi '):
			while ';' not in oldcode[f][1][l]:l+=1
			realpath[f][1][l]=realpath[f][1][l]+'\n'+block
		else:
			realpath[f][1][l]=realpath[f][1][l]+'\n'+block
		block=''
	else:
		block+=x
for f in realpath:
	rp,content=realpath[f]
	with open(rp,'w') as out:
		out.write(''.join(content))
