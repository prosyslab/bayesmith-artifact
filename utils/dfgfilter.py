#appliable for grep,sed,sort,readelf
import sys,os
from pathlib import Path
WORKDIR=sys.argv[1]+'/'
KEYWORD=sys.argv[2]
Path(WORKDIR+'dfg/bak').mkdir(parents=True, exist_ok=True)
for x in os.listdir(WORKDIR+'/dfg'):
	if not os.path.isfile(WORKDIR+'/dfg/'+x):continue
	if x.endswith('run.log'):
		xx=open(WORKDIR+'/dfg/'+x,'rb').readlines()
		exe=str(xx[1]) if len(xx)>1 else ''
		id=x[:-7]
		if KEYWORD not in exe:
			print('rename',id,x)
			try:
				os.rename(WORKDIR+'dfg/'+x,WORKDIR+'/dfg/bak/'+x)
			except:
				pass
			try:
				os.rename(WORKDIR+'dfg/'+id+'dfg.txt',WORKDIR+'/dfg/bak/'+id+'dfg.txt')
			except:
				pass
			try:
				os.rename(WORKDIR+'dfg/'+id+'san.log',WORKDIR+'/dfg/bak/'+id+'san.log')
			except:
				pass