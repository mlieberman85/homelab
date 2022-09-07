{ lib
, buildGoModule
, rustPlatform
, fetchFromGitHub
, makeWrapper
, symlinkJoin
, CoreFoundation
, openssl
, pkg-config
, protobuf
, Security
, stdenv
, xdg-utils
, nixosTests

, withRdpClient ? false
}:
let
  # This repo has a private submodule "e" which fetchgit cannot handle without failing.
  src = fetchFromGitHub {
    owner = "gravitational";
    repo = "teleport";
    rev = "v${version}";
    sha256 = "sha256-3/aq4ZKEdFoF82lTgdJH1C/Az54CIrWUe7raU6qdUcI=";
  };
  version = "10.1.9";

  rdpClient = rustPlatform.buildRustPackage rec {
    name = "teleport-rdpclient";
    cargoSha256 = "sha256-/roAxkpvcJ7GsTxKifDFwI50zlwjj5LMmgbx7r+VCUI=";
    inherit version src;

    buildAndTestSubdir = "lib/srv/desktop/rdp/rdpclient";

    buildInputs = [ openssl ]
      ++ lib.optionals stdenv.isDarwin [ CoreFoundation Security ];
    nativeBuildInputs = [ pkg-config ];

    # https://github.com/NixOS/nixpkgs/issues/161570 ,
    # buildRustPackage sets strictDeps = true;
    checkInputs = buildInputs;

    OPENSSL_NO_VENDOR = "1";

    postInstall = ''
      cp -r target $out
    '';
  };

  webassets = fetchFromGitHub {
    owner = "gravitational";
    repo = "webassets";
    rev = "67e608db77300d8a6cb17709be67f12c1d3271c3";
    sha256 = "sha256-o4qjXGaNi5XDSUQrUuU+G77EdRnvJ1WUPWrryZU1CUE=";
  };
in
buildGoModule rec {
  pname = "teleport";

  inherit src version;
  vendorSha256 = "sha256-F+UTuD4YIsBnyYd0HI9QwYowlJBff2OO71pZBCf018U=";

  subPackages = [ "tool/tbot" "tool/tctl" "tool/teleport" "tool/tsh" ];
  tags = [ "webassets_embed" ]
    ++ lib.optional withRdpClient "desktop_access_rdp";

  buildInputs = [ openssl ]
    ++ lib.optionals (stdenv.isDarwin && withRdpClient) [ CoreFoundation Security ];
  nativeBuildInputs = [ makeWrapper ];

  patches = [
    # https://github.com/NixOS/nixpkgs/issues/120738
    ./tsh.patch
    # https://github.com/NixOS/nixpkgs/issues/132652
    ./test.patch
    ./0001-fix-add-nix-path-to-exec-env.patch
    ./rdpclient.patch
  ];

  # Reduce closure size for client machines
  outputs = [ "out" "client" ];

  preBuild =
    let rustDeps = symlinkJoin {
      name = "teleport-rust-deps";
      paths = lib.optional withRdpClient rdpClient;
    };
    in
    ''
      mkdir -p build
      echo "making webassets"
      cp -r ${webassets}/* webassets/
      make lib/web/build/webassets

      cp -r ${rustDeps}/. .
    '';

  # Multiple tests fail in the build sandbox
  # due to trying to spawn nixbld's shell (/noshell), etc.
  doCheck = false;

  postInstall = ''
    install -Dm755 -t $client/bin $out/bin/tsh
    # make xdg-open overrideable at runtime
    wrapProgram $client/bin/tsh --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
    wrapProgram $out/bin/tsh --suffix PATH : ${lib.makeBinPath [ xdg-utils ]}
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    $out/bin/tsh version | grep ${version} > /dev/null
    $client/bin/tsh version | grep ${version} > /dev/null
    $out/bin/tbot version | grep ${version} > /dev/null
    $out/bin/tctl version | grep ${version} > /dev/null
    $out/bin/teleport version | grep ${version} > /dev/null
  '';

  passthru.tests = nixosTests.teleport;

  meta = with lib; {
    description = "Certificate authority and access plane for SSH, Kubernetes, web applications, and databases";
    homepage = "https://goteleport.com/";
    license = licenses.asl20;
    maintainers = with maintainers; [ sigma tomberek freezeboy ];
    platforms = platforms.unix;
  };
}
