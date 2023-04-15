{ pkgs ? import (fetchTarball "https://github.com/NixOS/nixpkgs/archive/9e5e77806a692277da477ca1879e24789350911.tar.gz") {}
}:

pkgs.mkShell {
  buildInputs = with pkgs; [
    circt # 1.34.0
  ];
}
