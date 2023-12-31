#!/usr/bin/env nix-shell
#!nix-shell -i bash -p curl gnused nix coreutils nix-prefetch

set -euo pipefail

DOCKER=$(curl -s https://raw.githubusercontent.com/odoo/docker/master/16.0/Dockerfile)

get_var() {
  echo "$DOCKER" | grep -E "^[A-Z][A-Z][A-Z] ODOO_$1" | sed -r "s|^[A-Z]{3} ODOO_$1.||g"
}

VERSION=$(get_var VERSION)
RELEASE=$(get_var RELEASE)

latestVersion="$VERSION.$RELEASE"
currentVersion=$(nix-instantiate --eval -E "with import ./. {}; odoo.version or (lib.getVersion odoo)" | tr -d '"')

if [[ "$currentVersion" == "$latestVersion" ]]; then
  echo "odoo is up-to-date: $currentVersion"
  exit 0
fi

cd "$(dirname "${BASH_SOURCE[0]}")"

sed -ri "s| hash.+ # odoo| hash = \"$(nix-prefetch -q fetchzip --url "https://nightly.odoo.com/${VERSION}/nightly/src/odoo_${latestVersion}.zip")\"; # odoo|g" default.nix
sed -ri "s| odoo_version.+| odoo_version = \"$VERSION\";|" default.nix
sed -ri "s| odoo_release.+| odoo_release = \"$RELEASE\";|" default.nix
