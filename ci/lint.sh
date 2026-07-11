#!/bin/bash
# Argon OS — CI lint suite
# Runs shellcheck over every shell script, validates JSON and YAML
# configuration, and sanity-checks the live-build config assembly.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
cd "$REPO_ROOT"
FAIL=0

echo "==> shellcheck"
# All tracked shell scripts: scripts/, ci/, live-build auto/ and hooks
mapfile -t SCRIPTS < <(
    git ls-files 'scripts/*.sh' 'ci/*.sh' 'build/auto/*' 'build/argon-config/**/hooks/**'
)
for f in "${SCRIPTS[@]}"; do
    head -1 "$f" | grep -q '^#!' || continue
    if ! shellcheck -x "$f"; then
        FAIL=1
    fi
done

echo "==> JSON validation"
while IFS= read -r f; do
    if ! python3 -m json.tool "$f" > /dev/null; then
        echo "invalid JSON: $f"
        FAIL=1
    fi
done < <(git ls-files '*.json')

echo "==> YAML validation (Calamares configuration)"
while IFS= read -r f; do
    if ! python3 -c "import sys, yaml; list(yaml.safe_load_all(open(sys.argv[1])))" "$f"; then
        echo "invalid YAML: $f"
        FAIL=1
    fi
done < <(git ls-files 'installer/calamares/*.conf' 'installer/calamares/modules/*.conf' 'installer/calamares/branding/*/branding.desc' '.github/workflows/*.yml')

echo "==> live-build config assembly (dry run)"
if ! ./scripts/build-iso.sh --skip-build --variant xfce --version ci-test; then
    echo "config assembly failed"
    FAIL=1
fi
# The assembled tree must contain the essentials
for path in \
    build/config/package-lists/argon-base.list.chroot \
    build/config/package-lists/argon-desktop.list.chroot \
    build/config/hooks/normal/0100-argon-branding.hook.chroot \
    build/config/includes.chroot/etc/calamares/settings.conf \
    build/config/includes.chroot/usr/share/plymouth/themes/argon/argon.plymouth \
    build/config/includes.chroot/etc/sysctl.d/99-argon-hardening.conf; do
    if [ ! -f "$path" ]; then
        echo "missing from assembled config: $path"
        FAIL=1
    fi
done

if [ "$FAIL" -ne 0 ]; then
    echo "LINT FAILED"
    exit 1
fi
echo "LINT OK"
