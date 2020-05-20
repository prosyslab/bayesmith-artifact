import copy
import os
import sys
realpath={}
for root,dirs,paths in os.walk('.'):
	for p in paths:
		if p.endswith('.dfsan'):
			os.replace(root+'/'+p,root+'/'+p[:-6])
