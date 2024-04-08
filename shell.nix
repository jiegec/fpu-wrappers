{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/e42377bbe5ef06ffec13eebf7949d72793ed66f9.tar.gz") {}
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    circt # 1.59.0
    mill
    boost
    verilog # iverilog
    verilator
  ];
}
