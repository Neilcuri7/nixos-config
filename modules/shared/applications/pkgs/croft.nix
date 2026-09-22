{ lib, rustPlatform, fetchFromGitHub, pkg-config, openssl }:

rustPlatform.buildRustPackage rec {
  pname = "croft";
  version = "0.1.942";

  src = fetchFromGitHub {
    owner = "vitali87";
    repo = "croft";
    rev = "v${version}";
    sha256 = "sha256-CEf7Kfu4B0R7xdO3K7t0KflbqAbUaNmTFMVPMpoVODU=";
  };

  cargoHash = "sha256-H4j7W8zvMa3o2MR7RKvZz2aMUFFPN9RFI9UeDFgtHJ0=";

  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ openssl ];

  meta = with lib; {
    description = "A VSCode-style TUI text editor written in Rust";
    homepage = "https://croft.software";
    license = licenses.mit;
    mainProgram = "croft";
  };
}
