import os
import glob
import collections

data = collections.defaultdict(lambda :{})

for file_name in glob.glob('*/*_report_area.txt'):
	parts = file_name.split('/')
	key = parts[0]
	with open(file_name) as f:
		for line in f:
			line = line.strip()
			if line.startswith('Combinational area:'):
				area = line.split(' ')[-1]
				data[key]['comb_area'] = float(area)
			if line.startswith('Total area:'):
				area = line.split(' ')[-1]
				data[key]['area'] = float(area)
			if line.startswith('Number of cells:'):
				cells = line.split(' ')[-1]
				data[key]['cells'] = int(cells)

for file_name in glob.glob('*/*_report_timing_setup.txt'):
	parts = file_name.split('/')
	key = parts[0]
	with open(file_name) as f:
		for line in f:
			line = line.strip()
			if 'data arrival time' in line:
				time = line.split(' ')[-1]
				data[key]['max_comb_delay'] = float(time)
				break

keys = data.keys()
for key in sorted(keys):
	value = data[key]
	print('{}:'.format(key))
	print('  Cells: {}'.format(value['cells']))
	print('  Area: {}'.format(value['area']))
	print('  Comb Area: {}'.format(value['comb_area']))
	print('  Max Freq: {:.0f} MHz ({:.2f} ns)'.format(1000.0 / value['max_comb_delay'], value['max_comb_delay']))