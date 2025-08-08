#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl coreutils common-updater-scripts
set -eu -o pipefail

currentVersion=$(nix-instantiate --eval -E "with import ./. {}; cursor-agent.version or (lib.getVersion cursor-agent)" | tr -d '"')
nextVersion=$(curl -s https://cursor.com/install | grep -oP "lab/\K[^/]+")
if [[ "$nextVersion" == "$currentVersion" ]]; then
  exit 0
fi

declare -A platforms=( [x86_64-linux]="linux/x64" [aarch64-linux]="linux/arm64" [x86_64-darwin]="darwin/x64" [aarch64-darwin]="darwin/arm64" )

for platform in "${!platforms[@]}"; do
  url="https://downloads.cursor.com/lab/$nextVersion/${platforms[$platform]}/agent-cli-package.tar.gz"
  source=$(nix-prefetch-url "$url" --name "cursor-agent-$nextVersion")
  hash=$(nix-hash --to-sri --type sha256 "$source")
  update-source-version cursor-agent "$nextVersion" "$hash" "$url" --system="$platform" --ignore-same-version --source-key="sources.$platform"
done
