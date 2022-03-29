import os

stages = range(1, 6)
for stage in stages:
	suffix = f'_{stage}s'
	os.system(f"cp FPNewBlackbox.sv FPNewBlackbox{suffix}.sv")
	os.system(f"sed -i 's/__STAGES__/{stage}/' FPNewBlackbox{suffix}.sv")
	os.system(f"make SUFFIX={suffix}")