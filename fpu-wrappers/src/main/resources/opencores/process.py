import glob
import os

for file in glob.glob('../../../../../thirdparty/opencores-fpu/verilog/*.v'):
	name = os.path.basename(file)
	with open(file, 'r') as r:
		with open(name, 'w') as w:
			write = True
			for line in r:
				if 'synopsys translate_off' in line:
					write = False
				if write:
					w.write(line)
				if 'synopsys translate_on' in line:
					write = True