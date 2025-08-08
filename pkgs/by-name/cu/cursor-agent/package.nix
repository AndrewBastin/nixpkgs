{
  lib,
  fetchurl,
  stdenv,
  autoPatchelfHook,
  makeWrapper,
}:

let
  inherit (stdenv) hostPlatform;
  version = "2025.08.08-f57cb59";

  sources = {
    x86_64-linux = fetchurl {
      url = "https://downloads.cursor.com/lab/${version}/linux/x64/agent-cli-package.tar.gz";
      hash = "sha256-AwwfNJU4+ndvO5DAY7cfpKBVqQz7QiCB4IPY57Ri2iQ=";
    };
    aarch64-linux = fetchurl {
      url = "https://downloads.cursor.com/lab/${version}/linux/arm64/agent-cli-package.tar.gz";
      hash = "sha256-ikoxUvpLMngDOlHawq7i69mOcPGkV8q1capDU83QMWs=";
    };
    x86_64-darwin = fetchurl {
      url = "https://downloads.cursor.com/lab/${version}/darwin/x64/agent-cli-package.tar.gz";
      hash = "sha256-c3OEfW++DPuYnC4frnrytJKSuuPtJ5zXCw/+yeTYb8w=";
    };
    aarch64-darwin = fetchurl {
      url = "https://downloads.cursor.com/lab/${version}/darwin/arm64/agent-cli-package.tar.gz";
      hash = "sha256-jq037h5yBfKIcxDRLsAAlWFZ3WU+fwyTxRMkNitgh/c=";
    };
  };
in
stdenv.mkDerivation {
  pname = "cursor-agent";
  inherit version;

  src = sources.${hostPlatform.system};

  nativeBuildInputs = lib.optionals hostPlatform.isLinux [ autoPatchelfHook ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin $out/share/cursor-agent
    cp -r * $out/share/cursor-agent/
    ln -s $out/share/cursor-agent/cursor-agent $out/bin/cursor-agent

    runHook postInstall
  '';

  passthru.updateScript = ./update.sh;

  meta = {
    description = "Cursor CLI";
    homepage = "https://cursor.com/cli";
    license = lib.licenses.unfree;
    maintainers = with lib.maintainers; [ sudosubin ];
    platforms = builtins.attrNames sources;
    mainProgram = "cursor-agent";
  };
}
