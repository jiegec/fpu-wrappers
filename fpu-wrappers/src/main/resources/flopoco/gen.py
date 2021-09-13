import subprocess
import os

tasks = [{
    'type': 'H',
    'exp': 5,
    'frac': 10
}, {
    'type': 'S',
    'exp': 8,
    'frac': 23
}, {
    'type': 'D',
    'exp': 11,
    'frac': 52
}]

home = os.getenv('HOME')
flopoco = home + "/flopoco/build/flopoco"

for frequency in [100, 150, 200, 250]:
    for task in tasks:
        out = subprocess.check_output(
            [flopoco, "IEEEFMA", f"wE={task['exp']}", f"wF={task['frac']}",
             f"name=FMA_{task['type']}", f"frequency={frequency}"],
            stderr=subprocess.STDOUT).decode('utf-8')
        stages = 0
        for line in out.splitlines():
            if 'Pipeline depth' in line:
                stages = int(line.split(' ')[-1])
        file = f"FMA_{task['type']}{stages}s.vhdl"
        file_vhdl08 = f"FMA_{task['type']}{stages}s_vhdl08.vhdl"
        os.rename('flopoco.vhdl', file)
        os.system(f"sed -e 's/std_logic_arith/numeric_std/g' -e 's/std_logic_unsigned/numeric_std_unsigned/g' {file} > {file_vhdl08}")
