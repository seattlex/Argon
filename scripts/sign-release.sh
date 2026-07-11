#!/bin/bash
# Argon OS — sign release artifacts
#
# Produces, next to each given file:
#   <file>.sha256      SHA-256 checksum
#   <file>.sha256.sig  detached GPG signature over the checksum file
#
# Usage:
#   ./scripts/sign-release.sh iso/argon-0.1.0-xfce-amd64.iso [more files...]
#
# The signing key is selected with ARGON_SIGNING_KEY (fingerprint or key ID);
# otherwise gpg's default key is used. Verify a download with:
#   gpg --verify file.sha256.sig file.sha256 && sha256sum -c file.sha256

set -euo pipefail

if [ $# -lt 1 ]; then
    echo "Usage: $0 <artifact> [artifact...]" >&2
    exit 1
fi

GPG_ARGS=()
if [ -n "${ARGON_SIGNING_KEY:-}" ]; then
    GPG_ARGS+=(--local-user "$ARGON_SIGNING_KEY")
fi

for artifact in "$@"; do
    if [ ! -f "$artifact" ]; then
        echo "ERROR: no such file: $artifact" >&2
        exit 1
    fi
    dir="$(dirname "$artifact")"
    base="$(basename "$artifact")"

    echo "==> Checksumming $base"
    (cd "$dir" && sha256sum "$base" > "$base.sha256")

    echo "==> Signing $base.sha256"
    gpg "${GPG_ARGS[@]}" --armor --detach-sign \
        --output "$artifact.sha256.sig" "$artifact.sha256"

    echo "==> Wrote $artifact.sha256 and $artifact.sha256.sig"
done
