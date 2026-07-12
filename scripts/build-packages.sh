#!/bin/bash
# Argon OS — build all Argon source packages under packages/
#
# Builds every directory in packages/ that contains debian/control and
# leaves the resulting .deb / .changes files in packages/dist/.
#
#   ./scripts/build-packages.sh          build unsigned (development)
#   SIGN=1 ./scripts/build-packages.sh   sign with the default GPG key
#
# Requires: build-essential, debhelper, devscripts

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
PKG_ROOT="$REPO_ROOT/packages"
DIST_DIR="$PKG_ROOT/dist"

SIGN_ARGS=(-us -uc)
if [ "${SIGN:-0}" = "1" ]; then
    SIGN_ARGS=()
fi

mkdir -p "$DIST_DIR"
built=0

for dir in "$PKG_ROOT"/*/; do
    [ -f "$dir/debian/control" ] || continue
    name="$(basename "$dir")"
    echo "==> Building $name"
    (cd "$dir" && dpkg-buildpackage -b "${SIGN_ARGS[@]}")
    # dpkg-buildpackage drops artifacts in the parent dir (packages/)
    built=1
done

if [ "$built" -eq 0 ]; then
    echo "No source packages found under $PKG_ROOT" >&2
    exit 1
fi

mv -f "$PKG_ROOT"/*.deb "$PKG_ROOT"/*.changes "$PKG_ROOT"/*.buildinfo "$DIST_DIR"/ 2>/dev/null || true

echo "==> Artifacts in $DIST_DIR:"
ls -1 "$DIST_DIR"
