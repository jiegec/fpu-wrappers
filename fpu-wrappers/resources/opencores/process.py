import glob
import os

for file in glob.glob('../../../thirdparty/opencores-fpu/verilog/*.v'):
	name = os.path.basename(file)
	with open(file, 'r') as r:
		with open(name, 'w') as w:
			write = True
			for line in r:
				# fpu.v: co -> co_d
				if '// carry output' in line:
					line = line.replace('co', 'co_d')

				# fpu.v: missing fasu_op
				if 'fasu_op_r1, fasu_op_r2' in line:
					w.write('wire\t\tfasu_op;\n')

				# casex -> casez
				line = line.replace('casex(', 'casez(')

				# remove redundant <= #1
				line = line.replace('<= #1 ', '<= ')

				if 'synopsys translate_off' in line:
					write = False
				if write:
					w.write(line)
				if 'synopsys translate_on' in line:
					write = True