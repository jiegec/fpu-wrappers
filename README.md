# fpu-wrappers

This repo intends to create wrappers for open source FPU hardware implementations currently including:

1. [berkeley-hardfloat](https://github.com/ucb-bar/berkeley-hardfloat)
2. [fpnew](https://github.com/pulp-platform/fpnew)
3. [flopoco](http://flopoco.gforge.inria.fr/)
4. [CNRV-FPU](https://github.com/cnrv/CNRV-FPU)
5. [opencores-fpu](https://github.com/jiegec/opencores-fpu)
6. [fudian](https://github.com/OpenXiangShan/fudian)
7. [vfloat](https://github.com/jiegec/vfloat)

| op     | berkeley-hardfloat | fpnew | flopoco | CNRV-FPU | opencores-fpu | fudian | vfloat |
| ------ | ------------------ | ----- | ------- | -------- | ------------- | ------ | ------ |
| add    | Y                  | Y     | Y       | Y        | Y             | Y      | Y      |
| mul    | Y                  | Y     | Y       | Y        | Y             | Y      | Y      |
| fma    | Y                  | Y     | Y       | Y        |               | Y      | Y      |
| cmp    | Y                  | Y     |         |          |               | Y      |        |
| div    | Y                  | Y     | Y       | Y        | Y             | Y      | Y      |
| sqrt   | Y                  | Y     | Y       | Y        |               | Y      | Y      |
| fp2int | Y                  | Y     | Y       | Y        | Y             | Y      | Y      |
| int2fp | Y                  | Y     | Y       | Y        | Y             | Y      | Y      |
| fp2fp  | Y                  | Y     | Y       |          |               | Y      |        |
| pow    |                    |       | Y       |          |               |        |        |
| log    |                    |       | Y       |          |               |        |        |
| exp    |                    |       | Y       |          |               |        |        |
| custom | Y                  |       | Y       |          |               |        |        |

`custom` means custom floating point format.

And make performance comparison.

Module naming convection:

1. Type 1: Floating point format + operator(FAdd/FMA/FExp)
2. Type 2: Floating point format `To` Floating point format
3. Type 3: Floating point format + FPU(many operations)

Possible floating point formats:

1. HF: berkeley-hardfloat +1 bits
2. IEEE: IEEE 754
3. FPC: flopoco +2 bits