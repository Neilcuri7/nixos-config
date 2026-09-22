{ lib, stdenv, fetchurl, autoPatchelfHook }:

stdenv.mkDerivation rec {
  pname = "croft";
  version = "0.1.1";

  src = fetchurl {
    url = "https://github.com/nsrosenqvist/croft/releases/download/v${version}/croft-x86_64-unknown-linux-gnu.tar.gz";
    sha256 = "sha256-/LIIiK5GKS6L07catUknFALK0v8HOuYIF3d3X02LEUw=";
  };

  nativeBuildInputs = [ autoPatchelfHook ];
  buildInputs = [ stdenv.cc.cc.lib ];

  sourceRoot = ".";

  installPhase = ''
    install -m755 -D croft $out/bin/croft
  '';

  meta = with lib; {
    description = "A dev-environment wrapper with embedded TUI and Docker Compose orchestration";
    homepage = "https://github.com/nsrosenqvist/croft";
    license = licenses.mit;
    platforms = [ "x86_64-linux" ];
    mainProgram = "croft";
  };
}
