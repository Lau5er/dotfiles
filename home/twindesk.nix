{ pkgs, ... }:

let
  twindesk-src = pkgs.fetchFromGitHub {
    owner = "InukaAsith";
    repo = "TwinDesk";
    rev = "main";
    sha256 = "5RJyUa3hfJydjaNnqr4vK/ayskHMn/CVMzrWK5V0VtA=";
  };

  ws = pkgs.fetchurl {
    url = "https://registry.npmjs.org/ws/-/ws-8.22.0.tgz";
    hash = "sha512-Ydggc987+RO0AnWtZ/7Wq9FtNvcrL1b/RO0ud9mWjUPgDrsAAwQSF51sm2hm1XofbU/4jkpGEsLFsZZxU+1DOg==";
  };

  helper-build-deps = with pkgs; [
    gcc
    pkg-config
    libx11
    libxi
    libxtst
    libxrandr
    libxfixes
  ];

  app-deps = with pkgs; [
    nodejs_24
  ];

  twindesk = pkgs.stdenv.mkDerivation {
    pname = "twindesk";
    version = "2.0.0";
    src = twindesk-src;

    nativeBuildInputs = helper-build-deps ++ app-deps ++ [
      pkgs.electron
      pkgs.makeWrapper
    ];

    buildPhase = ''
      runHook preBuild

      cd linux-helper
      bash ./build.sh

      cd ../linux
      mkdir -p node_modules/ws
      tar -xzf ${ws} --strip-components=1 -C node_modules/ws

      runHook postBuild
    '';

    installPhase = ''
      runHook preInstall

      mkdir -p $out/bin
      mkdir -p $out/share/twindesk/linux
      cp -r . $out/share/twindesk/linux
      cp -r ../shared ../linux-helper $out/share/twindesk/

      makeWrapper ${pkgs.electron}/bin/electron $out/bin/twindesk \
        --chdir $out/share/twindesk/linux \
        --add-flags $out/share/twindesk/linux/main.js

      runHook postInstall
    '';

    meta = with pkgs.lib; {
      description = "Use two computers as one desk: share screens, mouse, keyboard, clipboard, files, sound";
      homepage = "https://twin-desk.vercel.app";
      license = licenses.gpl3Plus;
      mainProgram = "twindesk";
    };
  };
in
twindesk

