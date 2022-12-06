#!/usr/bin/env nix-shell
#! nix-shell -i bash -p jq curl

export VERSION=$( curl \
  -H "Accept: application/vnd.github+json" \
  https://api.github.com/repos/GloriousEggroll/proton-ge-custom/releases/latest | jq -r '.tag_name' )

export URL=https://github.com/GloriousEggroll/proton-ge-custom/releases/download/$VERSION/$VERSION.tar.gz
export HASH=$( nix-prefetch-url --unpack $URL )

cd "$(dirname "${BASH_SOURCE[0]}")"

echo $VERSION
echo $URL
echo $HASH

sed -i "s/version = \"\([^\"]*\)\";/version = \"${VERSION}\";/" proton.nix
sed -i "s/sha256 = \"\([a-z0-9]*\)\";/sha256 = \"${HASH}\";/" proton.nix
