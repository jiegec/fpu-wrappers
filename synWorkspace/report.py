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
			if line.startswith('Buf/Inv area:'):
				area = line.split(' ')[-1]
				data[key]['buf_area'] = float(area)
			if line.startswith('Noncombinational area:'):
				area = line.split(' ')[-1]
				data[key]['non_comb_area'] = float(area)
			if line.startswith('Macro/Black Box area:'):
				area = line.split(' ')[-1]
				data[key]['macro_area'] = float(area)
			if line.startswith('Total area:'):
				area = line.split(' ')[-1]
				data[key]['total_area'] = float(area)
			if line.startswith('Number of cells:'):
				cells = line.split(' ')[-1]
				data[key]['cells'] = int(cells)

for file_name in glob.glob('*/*_report_power.txt'):
	parts = file_name.split('/')
	key = parts[0]
	with open(file_name) as f:
		for line in f:
			line = line.strip()
			if '100.0' in line:
				parts = list(filter(lambda s: len(s) > 0, line.split(' ')))
				total_power = parts[-2]
				data[key]['total_power'] = float(total_power)
				leakage_power = parts[-3]
				data[key]['leakage_power'] = float(leakage_power)
				internal_power = parts[-4]
				data[key]['internal_power'] = float(internal_power)
				switch_power = parts[-5]
				data[key]['switch_power'] = float(switch_power)

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
	print('  Area: Comb={:.0f} Buf={:.0f} NonComb={:.0f} Macro={:.0f} Total={:.0f}'.format(value['comb_area'], value['buf_area'], value['non_comb_area'], value['macro_area'], value['total_area']))
	print('  Power:', end='')
	if 'switch_power' in value:
		print(' Switch({:.3f} mW)'.format(value['switch_power']), end='')
	if 'internal_power' in value:
		print(' Internal({:.3f} mW)'.format(value['internal_power']), end='')
	if 'leakage_power' in value:
		print(' Leakage({:.3f} mW)'.format(value['leakage_power'] / 1000), end='')
	if 'total_power' in value:
		print(' Total({:.3f} mW)'.format(value['total_power']), end='')
	print()
	print('  Max Freq: {:.0f} MHz ({:.2f} ns)'.format(1000.0 / value['max_comb_delay'], value['max_comb_delay']))