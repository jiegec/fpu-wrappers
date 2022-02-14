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

def gen_fma(frequency, task):
    # generate vhdl
    out = subprocess.check_output(
        [flopoco, "IEEEFMA", f"wE={task['exp']}", f"wF={task['frac']}",
            f"name=IEEEFMA_{task['type']}", f"frequency={frequency}"],
        stderr=subprocess.STDOUT).decode('utf-8')

    # parse stages from output
    stages = 0
    for line in out.splitlines():
        if 'Pipeline depth' in line:
            stages = int(line.split(' ')[-1])

    # save vhdl
    name = f"IEEEFMA_{task['type']}{stages}s"
    file = f"{name}.vhdl"
    file_vhdl08 = f"{name}_vhdl08.vhdl"
    os.rename('flopoco.vhdl', file)

    # vhdl08
    os.system(f"sed -e 's/std_logic_arith/numeric_std/g' -e 's/std_logic_unsigned/numeric_std_unsigned/g' {file} > {file_vhdl08}")

    # synthesize to verilog
    os.system(f"sudo docker run -it --rm -t -v $PWD:/src -w /src hdlc/ghdl:yosys yosys -m ghdl -p 'ghdl --std=08 {name}_vhdl08.vhdl -e IEEEFMA_{task['type']}; write_verilog {name}.v'")

def gen_exp(frequency, task):
    # generate vhdl
    out = subprocess.check_output(
        [flopoco, "FPExp", f"wE={task['exp']}", f"wF={task['frac']}",
            f"name=FPCFExp_{task['type']}", f"plainVHDL=1", f"frequency={frequency}"],
        stderr=subprocess.STDOUT).decode('utf-8')

    # parse stages from output
    stages = 0
    for line in out.splitlines():
        if 'Pipeline depth' in line:
            stages = int(line.split(' ')[-1])

    # save vhdl
    name = f"FPCFExp_{task['type']}{stages}s"
    file = f"{name}.vhdl"
    os.rename('flopoco.vhdl', file)

    # synthesize to verilog
    os.system(f"sudo docker run -it --rm -t -v $PWD:/src -w /src hdlc/ghdl:yosys yosys -m ghdl -p 'ghdl -fsynopsys -fexplicit {name}.vhdl -e FPCFExp_{task['type']}; write_verilog {name}.v'")

for task in tasks:
    for frequency in [100, 150, 200, 250, 300]:
        gen_fma(frequency, task)
        gen_exp(frequency, task)
