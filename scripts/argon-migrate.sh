#!/bin/sh
# Argon OS - bring an already-installed Argon system up to the current build
# WITHOUT reinstalling and WITHOUT touching your data.
#
# Older Argon installs (from before the built-in updater, snapshots, the
# audio fix, etc.) are missing pieces that ship in the image rather than in
# a package: extra packages, a few system files, some enabled services. This
# script installs exactly those, idempotently. It never removes packages and
# never touches /home - the worst case is that a step is skipped.
#
# Run it once:
#     curl -fsSL https://raw.githubusercontent.com/seattlex/argon/main/scripts/argon-migrate.sh | sudo sh
# or, from a clone:  sudo ./scripts/argon-migrate.sh
#
# After it finishes you'll have Argon Update (one-click updates), Btrfs
# snapshots, working audio/Bluetooth, Flathub, and the current defaults -
# and future updates come from Argon Update itself.
#
# Env:
#   ARGON_MIGRATE_REF   git ref to pull system files from (default: main)

set -eu

REF="${ARGON_MIGRATE_REF:-main}"
TARBALL="https://github.com/seattlex/argon/archive/refs/heads/${REF}.tar.gz"
RELEASE_API="https://api.github.com/repos/seattlex/argon/releases/tags/rolling"

say()  { echo; echo "==> $*"; }
warn() { echo "    ! $*" >&2; }

if [ "$(id -u)" -ne 0 ]; then
    echo "Please run with sudo:  sudo $0" >&2
    exit 1
fi
if ! command -v apt-get >/dev/null 2>&1; then
    echo "This doesn't look like a Debian/Kali/Argon system (no apt-get)." >&2
    exit 1
fi

WORK="$(mktemp -d)"
cleanup() { rm -rf "$WORK"; }
trap cleanup EXIT INT TERM

# ---------------------------------------------------------------------------
say "Taking a safety snapshot (if this is a Btrfs system)"
# If snapper is already here and configured, snapshot; otherwise just note it.
if command -v snapper >/dev/null 2>&1 &&
   snapper list-configs 2>/dev/null | grep -qw root; then
    if snapper -c root create -t single -c number \
            -d "before argon-migrate" -u "argon=migrate" 2>/dev/null; then
        echo "    snapshot taken - this whole migration is undoable"
    else
        warn "could not take a snapshot; continuing"
    fi
else
    echo "    (snapshots get configured below; nothing to snapshot yet)"
fi

# ---------------------------------------------------------------------------
say "Installing packages the current build ships (already-present ones skip)"
export DEBIAN_FRONTEND=noninteractive
apt-get update -q || warn "apt update had problems; continuing with cached lists"
# Curated catch-up set. --no-install-recommends matches how the image is
# built; missing individual packages must not abort the whole run.
CATCHUP="dbus-user-session plymouth-label fonts-dejavu-core \
  cryptsetup-initramfs snapper grub-btrfs inotify-tools \
  flatpak pipx python3-venv \
  bluez blueman pipewire-alsa rtkit libspa-0.2-bluetooth \
  papirus-icon-theme fastfetch"
# shellcheck disable=SC2086
apt-get install -y -q --no-install-recommends $CATCHUP \
    || warn "some catch-up packages failed; re-run after fixing apt"

# ---------------------------------------------------------------------------
say "Installing Argon's system integration files"
# Pull them straight from the repo so there is one source of truth. These are
# additive (snapshot hook + service + tooling); none overwrites a user config.
if command -v curl >/dev/null 2>&1; then
    curl -fsSL "$TARBALL" -o "$WORK/argon.tgz" || warn "download failed"
elif command -v wget >/dev/null 2>&1; then
    wget -qO "$WORK/argon.tgz" "$TARBALL" || warn "download failed"
else
    warn "neither curl nor wget present; skipping system files"
fi

if [ -f "$WORK/argon.tgz" ]; then
    tar -xzf "$WORK/argon.tgz" -C "$WORK" 2>/dev/null || warn "extract failed"
    SRC="$(find "$WORK" -maxdepth 1 -type d -name 'argon-*' | head -n1)"
    INC="${SRC}/build/argon-config/common/includes.chroot"
    if [ -n "$SRC" ] && [ -d "$INC" ]; then
        install_file() {  # src-rel  mode
            s="${INC}/$1"; d="/$1"
            [ -f "$s" ] || { warn "missing in repo: $1"; return; }
            mkdir -p "$(dirname "$d")"
            install -m "$2" "$s" "$d"
            echo "    + $d"
        }
        install_file etc/apt/apt.conf.d/80argon-snapshot 0644
        install_file etc/systemd/system/argon-snapshots-setup.service 0644
        install_file usr/libexec/argon/argon-snapshots-setup 0755
        install_file usr/libexec/argon/argon-snapshot-apt 0755
        install_file usr/bin/argon-snapshot 0755
        # Flathub remote setup (present once that feature lands)
        install_file usr/libexec/argon/argon-flathub-setup 0755 2>/dev/null || true
        install_file etc/systemd/system/argon-flathub-setup.service 0644 2>/dev/null || true
    else
        warn "unexpected tarball layout; skipping system files"
    fi
fi

# ---------------------------------------------------------------------------
say "Installing the latest Argon apps (Update, Software, Welcome, ...)"
# Fetch the argon-apps .deb published on the rolling release.
DEB_URL=""
if command -v curl >/dev/null 2>&1; then
    DEB_URL="$(curl -fsSL "$RELEASE_API" 2>/dev/null \
        | grep -o 'https://[^"]*argon-apps[^"]*\.deb' | head -n1 || true)"
fi
if [ -n "$DEB_URL" ]; then
    if curl -fsSL "$DEB_URL" -o "$WORK/argon-apps.deb"; then
        apt-get install -y -q "$WORK/argon-apps.deb" \
            || warn "argon-apps install failed"
    fi
else
    warn "could not find the argon-apps .deb on the rolling release."
    warn "Argon Update etc. can be installed later; core migration is done."
fi

# ---------------------------------------------------------------------------
say "Enabling services and applying the fixes"
# plymouth-label was likely just installed - rebuild the initramfs so the
# (previously invisible) LUKS passphrase prompt renders.
if command -v update-initramfs >/dev/null 2>&1; then
    update-initramfs -u 2>/dev/null || warn "update-initramfs failed"
fi
# Enable PipeWire user services for every user (harmless if already on).
systemctl --global enable pipewire.socket pipewire-pulse.socket \
    wireplumber.service 2>/dev/null || true
systemctl enable bluetooth.service 2>/dev/null || true
# Configure snapshots now instead of waiting for a reboot.
if [ -x /usr/libexec/argon/argon-snapshots-setup ]; then
    /usr/libexec/argon/argon-snapshots-setup || true
else
    systemctl enable argon-snapshots-setup.service 2>/dev/null || true
fi
# Flathub remote, if that piece is present.
if [ -x /usr/libexec/argon/argon-flathub-setup ]; then
    /usr/libexec/argon/argon-flathub-setup || true
fi

echo
echo "======================================================================"
echo " Argon migration complete."
echo
echo " * Open \"Update Argon\" (menu -> System) for one-click updates from now on."
echo " * Btrfs installs now snapshot before every update - see \`argon-snapshot\`."
echo " * Audio, Bluetooth and Flathub are set up."
echo
echo " A reboot is recommended so every change takes effect:  sudo reboot"
echo "======================================================================"
