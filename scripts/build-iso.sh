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

# Branding: plymouth theme (with its logo.png) and desktop/login wallpapers.
# The app icon ships in the argon-apps package; source logo art stays in the
# repo and is not copied raw into the image.
mkdir -p "$CHROOT_INC/usr/share/plymouth/themes"
cp -a "$REPO_ROOT/branding/plymouth/argon" "$CHROOT_INC/usr/share/plymouth/themes/"
mkdir -p "$CHROOT_INC/usr/share/backgrounds/argon"
cp -a "$REPO_ROOT/wallpapers/." "$CHROOT_INC/usr/share/backgrounds/argon/"

# Installer: Calamares configuration and branding
mkdir -p "$CHROOT_INC/etc/calamares"
cp -a "$REPO_ROOT/installer/calamares/." "$CHROOT_INC/etc/calamares/"

# Bootloaders: Argon-branded GRUB (UEFI) and isolinux (BIOS) menus.
# live-build reads customizations from config/bootloaders/. The splash
# images are pre-made PNGs (branding/boot-splash-*.png) — no rendering.
if [ -d "$BUILD_DIR/config/bootloaders" ]; then
    cp "$REPO_ROOT/branding/boot-splash-isolinux.png" \
       "$BUILD_DIR/config/bootloaders/isolinux/splash.png"
    cp "$REPO_ROOT/branding/boot-splash-grub.png" \
       "$BUILD_DIR/config/bootloaders/grub-pc/argon-splash.png"
    if [ -d "$BUILD_DIR/config/bootloaders/grub-pc/theme" ]; then
        cp "$REPO_ROOT/branding/boot-splash-grub.png" \
           "$BUILD_DIR/config/bootloaders/grub-pc/theme/argon-splash.png"
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
    # packages/dist does not exist on a fresh checkout; find would fail and,
    # under pipefail, silently abort the whole script.
    [ -d "$REPO_ROOT/packages/dist" ] || return 0
    find "$REPO_ROOT/packages/dist" -maxdepth 1 -name 'argon-apps_*_all.deb' \
        | sort -V | tail -n1
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

# Verify the initramfs that actually ships.
#
# This cannot be done from a chroot hook. live-build regenerates the
# initramfs in `lb chroot_hacks`, a build *stage* that runs after every
# config/hooks/* hook has finished — so the in-chroot check (hook 9999)
# inspects an initrd that is subsequently rebuilt. The file live-build
# copies into binary/live/ is the one users boot, and it is the only
# meaningful thing to assert on.
#
# What is being guarded: without USB/vfat/squashfs drivers, live-boot
# scans for /live/filesystem.squashfs for 60 seconds and then panics into
# a BusyBox "(initramfs)" prompt. That is invisible in a VM and only shows
# up when someone boots a physical stick.
echo "==> Verifying the shipped initramfs"
SHIPPED_INITRD="$(find "$BUILD_DIR/binary" -maxdepth 2 -name 'initrd*' -type f 2>/dev/null | sort | head -n1 || true)"
if [ -z "$SHIPPED_INITRD" ]; then
    echo "ERROR: no initramfs found under $BUILD_DIR/binary — the image would" >&2
    echo "       not be bootable at all" >&2
    exit 1
fi
if command -v lsinitramfs >/dev/null 2>&1; then
    # Reading the initramfs needs the matching decompressor (zstd by
    # default on Debian/Kali). It is only a Recommends of
    # initramfs-tools-core, so on a minimal build host lsinitramfs fails
    # with a bare "unmkinitramfs: zstd failed" — surface something the
    # reader can act on instead.
    if ! INITRD_CONTENTS="$(lsinitramfs "$SHIPPED_INITRD" 2>&1)"; then
        echo "ERROR: could not read $SHIPPED_INITRD" >&2
        echo "       lsinitramfs said: $INITRD_CONTENTS" >&2
        echo "       Install the decompressor it needs (zstd, xz-utils, gzip)" >&2
        echo "       on the build host and re-run." >&2
        exit 1
    fi
    # Feed grep with a here-string, never a pipe.
    #
    # `printf '%s\n' "$list" | grep -q PATTERN` is actively wrong under
    # `set -o pipefail`, which this script uses: grep -q exits the moment it
    # matches, printf is killed by SIGPIPE (exit 141) partway through the
    # ~3700-line listing, and pipefail then reports 141 as the pipeline's
    # status. `if ! pipeline` therefore reads a *successful match* as a
    # miss. That is not hypothetical — it made an earlier revision of this
    # check report all six modules missing from an initramfs that in fact
    # contained 986 of them. It also hides in testing, because a short
    # listing fits in the pipe buffer and printf finishes before grep exits.
    MISSING_MODULES=""
    for mod in usb-storage uas xhci_pci squashfs overlay vfat; do
        # modprobe knows xhci_pci; the file on disk is xhci-pci.ko. Match
        # either separator, and any compression suffix (.ko.xz, .ko.zst).
        pattern="$(printf '%s' "$mod" | sed 's/[-_]/[-_]/g')"
        if ! grep -qE "/${pattern}\.ko(\.[a-z0-9]+)?$" <<<"$INITRD_CONTENTS"
        then
            MISSING_MODULES="$MISSING_MODULES $mod"
        fi
    done
    if [ -n "$MISSING_MODULES" ]; then
        echo "ERROR: the shipped initramfs ($SHIPPED_INITRD) is missing:" >&2
        echo "      $MISSING_MODULES" >&2
        echo "       This image would drop to a BusyBox (initramfs) prompt when" >&2
        echo "       booted from USB. Refusing to publish it." >&2
        # Evidence, so a future failure can be told apart from a bug in this
        # check. grep -m stops after N matches instead of piping into head,
        # which would reintroduce exactly the SIGPIPE problem described above.
        echo "       evidence:" >&2
        printf '         entries listed:       %s\n' \
            "$(wc -l <<<"$INITRD_CONTENTS")" >&2
        printf '         entries matching .ko: %s\n' \
            "$(grep -c '\.ko' <<<"$INITRD_CONTENTS" || true)" >&2
        echo "         sample module paths:" >&2
        grep -m5 '/modules/' <<<"$INITRD_CONTENTS" \
            | sed 's/^/           /' >&2 || true
        exit 1
    fi
    echo "    verified: usb-storage uas xhci_pci squashfs overlay vfat"
else
    echo "    WARNING: lsinitramfs not found, so the shipped initramfs could" >&2
    echo "    NOT be verified. Install initramfs-tools to enable this check." >&2
fi

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
