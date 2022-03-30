import os

width = {
    'S': 32,
    'D': 64
}

for stage in range(1, 6):
    for format in ['S', 'D']:
        for lane in range(1, 3):
            suffix = f'_{format}{lane}l{stage}s'
            os.system(f"cp FPNewBlackbox.sv FPNewBlackbox{suffix}.sv")
            os.system(f"sed -i 's/__FLEN__/{width[format]*lane}/' FPNewBlackbox{suffix}.sv")
            fp32 = int(format == "S")
            os.system(f"sed -i 's/__FP32__/{fp32}/' FPNewBlackbox{suffix}.sv")
            fp64 = int(format == "D")
            os.system(f"sed -i 's/__FP64__/{fp64}/' FPNewBlackbox{suffix}.sv")
            os.system(f"sed -i 's/__STAGES__/{stage}/' FPNewBlackbox{suffix}.sv")
            os.system(f"make SUFFIX={suffix}")
