# Berkeley-Hardfloat

Language: Chisel -> Verilog

http://www.jhauser.us/arithmetic/HardFloat-1/doc/HardFloat-Verilog.html

float format: 32 bit -> 33 bit

# FPNew

Language: SystemVerilog

# FloPoCo

Language: C++ -> VHDL

float format: 32 bit -> 34 bit

## Installation

### wcpg

```shell
git clone https://scm.gforge.inria.fr/anonscm/git/metalibm/wcpg.git
cd wcpg
sh autogen.sh
./configure --prefix=$HOME/prefix/wcpg
make install -j
```

### scalp

```shell
git clone https://digidev.digi.e-technik.uni-kassel.de/git/scalp.git
cd scalp
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/prefix/scalp -DUSE_LPSOLVE=ON -DLPSOLVE_LIBRARIES=/usr/lib/liblpsolve55_pic.a -DLP_INCLUDE_DIRS=/usr/include
make install -j
```

### pagsuite

```shell
svn co https://digidev.digi.e-technik.uni-kassel.de/home/svn/pagsuite
cd pagsuite/trunk
mkdir build
cd build
cmake .. -DCMAKE_INSTALL_PREFIX=$HOME/prefix/pagsuite -DCMAKE_PREFIX_PATH=$HOME/prefix/scalp
make install -j
```

### flopoco

```shell
git clone https://gitlab.inria.fr/fdupont/flopoco.git
cd flopoco
mkdir build
cd build
cmake .. -DCMAKE_PREFIX_PATH="$HOME/prefix/wcpg;$HOME/prefix/pagsuite;$HOME/prefix/scalp" -DCMAKE_INSTALL_PREFIX=$HOME/prefix/flopoco
make -j
```