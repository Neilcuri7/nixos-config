{ pkgs ? import <nixpkgs> {} }:

(pkgs.buildFHSEnv {
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
}).env
