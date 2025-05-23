{
  cargo,
  fetchFromGitHub,
  makeWrapper,
  pkg-config,
  rustPlatform,
  lib,
  stdenv,
  gcc,
  cmake,
  libiconv,
}:

rustPlatform.buildRustPackage rec {
  pname = "evcxr";
  version = "0.17.0";

  src = fetchFromGitHub {
    owner = "google";
    repo = "evcxr";
    rev = "v${version}";
    sha256 = "sha256-6gSJJ3ptqpYydjg+xf5Pz3iTk0D+bkC6N79OeiKxPHY=";
  };

  useFetchCargoVendor = true;
  cargoHash = "sha256-U2LBesQNOa/E/NkVeLulb8JUtGsHgMne0MgY0RT9lqI=";

  RUST_SRC_PATH = "${rustPlatform.rustLibSrc}";

  nativeBuildInputs = [
    pkg-config
    makeWrapper
    cmake
  ];
  buildInputs = lib.optionals stdenv.hostPlatform.isDarwin [
    libiconv
  ];

  checkFlags = [
    # test broken with rust 1.69:
    # * https://github.com/evcxr/evcxr/issues/294
    # * https://github.com/NixOS/nixpkgs/issues/229524
    "--skip=check_for_errors"
  ];

  postInstall =
    let
      wrap = exe: ''
        wrapProgram $out/bin/${exe} \
          --prefix PATH : ${
            lib.makeBinPath [
              cargo
              gcc
            ]
          } \
          --set-default RUST_SRC_PATH "$RUST_SRC_PATH"
      '';
    in
    ''
      ${wrap "evcxr"}
      ${wrap "evcxr_jupyter"}
      rm $out/bin/testing_runtime
    '';

  meta = with lib; {
    description = "Evaluation context for Rust";
    homepage = "https://github.com/google/evcxr";
    license = licenses.asl20;
    maintainers = with maintainers; [
      protoben
      ma27
    ];
    mainProgram = "evcxr";
  };
}
