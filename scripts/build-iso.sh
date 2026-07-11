#!/bin/bash
# Argon OS — ISO build orchestrator
#
# Assembles the live-build configuration from the pieces kept in this
# repository (build/argon-config, branding/, wallpapers/, installer/) and
# runs the build. Must run as root on Kali rolling (native or container)
# with live-build installed:
#
#   sudo apt install live-build
#   sudo ./scripts/build-iso.sh [--variant xfce] [--version 0.1.0]
#
# The finished ISO and its SHA256SUMS land in iso/.

set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BUILD_DIR="$REPO_ROOT/build"
OUT_DIR="$REPO_ROOT/iso"

VARIANT="xfce"
VERSION="rolling"

usage() {
    echo "Usage: $0 [--variant xfce] [--version <string>] [--skip-build]"
    echo "  --variant     desktop variant (default: xfce)"
    echo "  --version     version string for image name and os-release"
    echo "  --skip-build  assemble config only, do not run lb build"
    exit "${1:-0}"
}

SKIP_BUILD=0
while [ $# -gt 0 ]; do
    case "$1" in
        --variant) VARIANT="$2"; shift 2 ;;
        --version) VERSION="$2"; shift 2 ;;
        --skip-build) SKIP_BUILD=1; shift ;;
        -h|--help) usage ;;
        *) echo "Unknown argument: $1" >&2; usage 1 ;;
    esac
done

VARIANT_DIR="$BUILD_DIR/argon-config/variant-$VARIANT"
if [ ! -d "$VARIANT_DIR" ]; then
    echo "ERROR: unknown variant '$VARIANT' (no $VARIANT_DIR)" >&2
    exit 1
fi

if [ "$SKIP_BUILD" -eq 0 ]; then
    if [ "$(id -u)" -ne 0 ]; then
        echo "ERROR: building an image requires root (chroot creation)." >&2
        exit 1
    fi
    if ! command -v lb >/dev/null 2>&1; then
        echo "ERROR: live-build is not installed (apt install live-build)." >&2
        exit 1
    fi
fi

echo "==> Assembling live-build config (variant: $VARIANT, version: $VERSION)"

# Start from a clean config/ so removed files don't linger between builds
rm -rf "$BUILD_DIR/config"
mkdir -p "$BUILD_DIR/config"

# Layer 1: common configuration
cp -a "$BUILD_DIR/argon-config/common/." "$BUILD_DIR/config/"

# Layer 2: variant overlay (may override common files)
cp -a "$VARIANT_DIR/." "$BUILD_DIR/config/"

CHROOT_INC="$BUILD_DIR/config/includes.chroot"

# Branding: plymouth theme, logo, wallpapers
mkdir -p "$CHROOT_INC/usr/share/plymouth/themes"
cp -a "$REPO_ROOT/branding/plymouth/argon" "$CHROOT_INC/usr/share/plymouth/themes/"
mkdir -p "$CHROOT_INC/usr/share/backgrounds/argon" "$CHROOT_INC/usr/share/icons/argon"
cp -a "$REPO_ROOT/wallpapers/." "$CHROOT_INC/usr/share/backgrounds/argon/"
cp -a "$REPO_ROOT/branding/logo/." "$CHROOT_INC/usr/share/icons/argon/"

# Installer: Calamares configuration and branding
mkdir -p "$CHROOT_INC/etc/calamares"
cp -a "$REPO_ROOT/installer/calamares/." "$CHROOT_INC/etc/calamares/"

# Bootloaders: Argon-branded GRUB (UEFI) and isolinux (BIOS) menus.
# live-build reads customizations from config/bootloaders/.
if [ -d "$BUILD_DIR/config/bootloaders" ]; then
    # Render the boot splash to PNG for both bootloaders (best effort).
    if command -v rsvg-convert >/dev/null 2>&1; then
        rsvg-convert -w 960 -h 720 \
            -o "$BUILD_DIR/config/bootloaders/isolinux/splash.png" \
            "$REPO_ROOT/branding/boot-splash.svg" 2>/dev/null || true
        rsvg-convert -w 960 -h 720 \
            -o "$BUILD_DIR/config/bootloaders/grub-pc/argon-splash.png" \
            "$REPO_ROOT/branding/boot-splash.svg" 2>/dev/null || true
        if [ -d "$BUILD_DIR/config/bootloaders/grub-pc/theme" ]; then
            cp "$BUILD_DIR/config/bootloaders/grub-pc/argon-splash.png" \
               "$BUILD_DIR/config/bootloaders/grub-pc/theme/" 2>/dev/null || true
        fi
    else
        echo "    (rsvg-convert missing: boot menu will use its background colour)"
    fi
fi

# Version marker read by the branding hook
echo "$VERSION" > "$CHROOT_INC/etc/argon_version"

# Make sure hooks are executable (git does not always preserve this)
find "$BUILD_DIR/config/hooks" -type f -name '*.chroot' -exec chmod +x {} +

if [ "$SKIP_BUILD" -eq 1 ]; then
    echo "==> Config assembled at $BUILD_DIR/config (build skipped)"
    exit 0
fi

# Argon's own applications: build the debs and bake them into the image
# (live-build installs everything in config/packages.chroot/). This keeps
# the ISO self-contained — no hosted Argon repository required. Only needed
# for a real build, so it runs after the --skip-build early exit above.
find_apps_deb() {
    find "$REPO_ROOT/packages/dist" -maxdepth 1 -name 'argon-apps_*_all.deb' \
        2>/dev/null | sort -V | tail -n1
}
APPS_DEB="$(find_apps_deb)"
if [ -z "$APPS_DEB" ]; then
    if command -v dpkg-buildpackage >/dev/null 2>&1; then
        "$REPO_ROOT/scripts/build-packages.sh"
        APPS_DEB="$(find_apps_deb)"
    else
        echo "ERROR: packages/dist/argon-apps_*.deb missing and dpkg-buildpackage" >&2
        echo "       is not installed. Run: apt install build-essential debhelper" >&2
        exit 1
    fi
fi
if [ -z "$APPS_DEB" ]; then
    echo "ERROR: argon-apps package did not build" >&2
    exit 1
fi
mkdir -p "$BUILD_DIR/config/packages.chroot"
cp "$APPS_DEB" "$BUILD_DIR/config/packages.chroot/"

# Reproducibility: derive timestamps from the last git commit
if [ -z "${SOURCE_DATE_EPOCH:-}" ]; then
    SOURCE_DATE_EPOCH="$(git -C "$REPO_ROOT" log -1 --format=%ct 2>/dev/null || date +%s)"
    export SOURCE_DATE_EPOCH
fi
echo "==> SOURCE_DATE_EPOCH=$SOURCE_DATE_EPOCH"

cd "$BUILD_DIR"

echo "==> lb clean"
lb clean --purge || true

echo "==> lb config"
ARGON_VARIANT="$VARIANT" ARGON_VERSION="$VERSION" lb config

echo "==> lb build (this takes a while)"
lb build

ISO_FILE="$(find "$BUILD_DIR" -maxdepth 1 -name 'argon-*.iso' | sort | head -n1)"
if [ -z "$ISO_FILE" ]; then
    # live-build names images live-image-* if --image-name was not honoured
    ISO_FILE="$(find "$BUILD_DIR" -maxdepth 1 -name 'live-image-*.iso' | sort | head -n1)"
fi
if [ -z "$ISO_FILE" ]; then
    echo "ERROR: build finished but no ISO was produced — check build/build.log" >&2
    exit 1
fi

mkdir -p "$OUT_DIR"
DEST="$OUT_DIR/argon-$VERSION-$VARIANT-amd64.iso"
mv "$ISO_FILE" "$DEST"

echo "==> Generating checksums"
(cd "$OUT_DIR" && sha256sum "$(basename "$DEST")" > "$(basename "$DEST").sha256")

echo "==> Done: $DEST"
echo "    Sign the release with: ./scripts/sign-release.sh $DEST"
