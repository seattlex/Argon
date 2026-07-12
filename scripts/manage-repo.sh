#!/bin/bash
# Argon OS — APT repository management (reprepro wrapper)
#
# The repository lives in packages/repo/ (conf/ is versioned; the pool and
# indices it generates are not). Requires: reprepro, gnupg with the Argon
# archive signing key.
#
# Usage:
#   ./scripts/manage-repo.sh add <package.deb>...   include binary packages
#   ./scripts/manage-repo.sh add-src <package.dsc>  include a source package
#   ./scripts/manage-repo.sh remove <name>          remove a package
#   ./scripts/manage-repo.sh list                   list repository contents
#   ./scripts/manage-repo.sh export                 re-export + re-sign indices
#
# Clients consume the repo with (after importing the signing key):
#   deb [signed-by=/usr/share/keyrings/argon-archive-keyring.gpg] \
#       https://<host>/argon argon-rolling main

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
REPO_DIR="$REPO_ROOT/packages/repo"
CODENAME="argon-rolling"

command -v reprepro >/dev/null 2>&1 || {
    echo "ERROR: reprepro is not installed (apt install reprepro)" >&2
    exit 1
}

cmd="${1:-}"
shift || true

case "$cmd" in
    add)
        [ $# -ge 1 ] || { echo "Usage: $0 add <package.deb>..." >&2; exit 1; }
        for deb in "$@"; do
            reprepro -b "$REPO_DIR" includedeb "$CODENAME" "$deb"
        done
        ;;
    add-src)
        [ $# -eq 1 ] || { echo "Usage: $0 add-src <package.dsc>" >&2; exit 1; }
        reprepro -b "$REPO_DIR" includedsc "$CODENAME" "$1"
        ;;
    remove)
        [ $# -ge 1 ] || { echo "Usage: $0 remove <name>..." >&2; exit 1; }
        for name in "$@"; do
            reprepro -b "$REPO_DIR" remove "$CODENAME" "$name"
        done
        ;;
    list)
        reprepro -b "$REPO_DIR" list "$CODENAME"
        ;;
    export)
        reprepro -b "$REPO_DIR" export "$CODENAME"
        ;;
    *)
        echo "Usage: $0 {add|add-src|remove|list|export}" >&2
        exit 1
        ;;
esac
