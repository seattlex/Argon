# Argon OS documentation

| Document | Contents |
| --- | --- |
| [getting-started.md](getting-started.md) | **New here? Start with this.** Download → USB → install, no terminal |
| [building.md](building.md) | Building the ISO and the Argon packages from source |
| [installation.md](installation.md) | Installing Argon (live session, Calamares, disk encryption) |
| [troubleshooting.md](troubleshooting.md) | Boot and install problems: `(initramfs)` prompt, black screen, USB sticks |
| [applications.md](applications.md) | Argon Software (the app store) and Argon Welcome |
| [wayland.md](wayland.md) | The optional, experimental Wayland session (labwc) |
| [secure-boot.md](secure-boot.md) | Turning on UEFI Secure Boot with a Machine Owner Key (opt-in) |
| [updates.md](updates.md) | Keeping Argon current (automatic security fixes + one-click updates) |
| [snapshots.md](snapshots.md) | Btrfs snapshots + one-step rollback of a bad update |
| [migrating.md](migrating.md) | Upgrading an older install to the current build (no reinstall) |
| [audio-production.md](audio-production.md) | Voicemeeter, FL Studio and VST plugins on Argon (PipeWire) |
| [hardening.md](hardening.md) | Security defaults: what is enabled, why, and how to adjust it |
| [privacy.md](privacy.md) | Privacy defaults: DNS, MAC randomization, browser, time sync |
| [repository.md](repository.md) | Using and operating the Argon APT repository |
| [reproducible-builds.md](reproducible-builds.md) | Reproducibility goals and current status |
| [security-tools.md](security-tools.md) | Installing security tooling from the Kali repositories |
| [roadmap.md](roadmap.md) | What's shipped and what's planned |

## Quick orientation

Argon is a Kali-rolling-based live/installable distribution assembled with
Debian [live-build](https://live-team.pages.debian.net/live-manual/).
The repository is laid out so that every artifact on a shipped image can be
traced back to a file here:

```
build/argon-config/   live-build configuration (package lists, hooks, files)
  common/             applies to every variant
    bootloaders/      Argon-branded GRUB (UEFI) + isolinux (BIOS) menus
  variant-xfce/       XFCE desktop variant overlay (panel, wm, theme)
installer/calamares/  installer sequence, module configs, branding
branding/             logo, plymouth boot theme, boot-menu splash sources
wallpapers/           wallpaper sources (SVG)
packages/             Argon's own Debian packages + APT repo (reprepro)
  argon-apps/         Argon Software (app store) + Argon Welcome (greeter)
  argon-meta/         metapackages
scripts/              build-iso.sh, build-packages.sh, manage-repo.sh, sign-release.sh
ci/                   lint suite run by GitHub Actions
docs/                 you are here
website/              static project page
iso/                  build output (checksums + images, not committed)
```
