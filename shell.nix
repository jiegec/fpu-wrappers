{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/8072d692ed0b32bf169e1391f12488b47406baaa.tar.gz") {}
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    circt # 1.40.0
    mill
  ];
}
