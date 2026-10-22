{ pkgs ? (
    let
      # Fallback seguro si no hay canal de nixpkgs disponible
      lock = builtins.fromJSON (builtins.readFile ../../flake.lock);
      nixpkgsSrc = fetchTarball {
        url = "https://github.com/nixos/nixpkgs/archive/${lock.nodes.nixpkgs.locked.rev}.tar.gz";
        sha256 = lock.nodes.nixpkgs.locked.narHash;
      };
    in import nixpkgsSrc {}
  ) }:

pkgs.buildFHSEnv {
  name = "docling-fhs-env";
  targetPkgs = pkgs: (with pkgs; [
    python311
    python311Packages.pip
    python311Packages.virtualenv

    # Dependencias C/C++ del sistema para PyTorch, OpenCV, OCR y visualización
    stdenv.cc.cc.lib
    zlib
    glib
    libGL
    libGLU
    fontconfig
    freetype
    libjpeg
    openjpeg
    libpng
    poppler-utils
    tesseract
    pandoc
  ]);
  runScript = "bash";
}
