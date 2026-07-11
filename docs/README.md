# Argon OS documentation

| Document | Contents |
| --- | --- |
| [building.md](building.md) | Building the ISO and the Argon packages from source |
| [installation.md](installation.md) | Installing Argon (live session, Calamares, disk encryption) |
| [hardening.md](hardening.md) | Security defaults: what is enabled, why, and how to adjust it |
| [privacy.md](privacy.md) | Privacy defaults: DNS, MAC randomization, browser, time sync |
| [repository.md](repository.md) | Using and operating the Argon APT repository |
| [reproducible-builds.md](reproducible-builds.md) | Reproducibility goals and current status |
| [security-tools.md](security-tools.md) | Installing security tooling from the Kali repositories |

## Quick orientation

Argon is a Kali-rolling-based live/installable distribution assembled with
Debian [live-build](https://live-team.pages.debian.net/live-manual/).
The repository is laid out so that every artifact on a shipped image can be
traced back to a file here:

```
build/argon-config/   live-build configuration (package lists, hooks, files)
  common/             applies to every variant
  variant-xfce/       XFCE desktop variant overlay
installer/calamares/  installer sequence, module configs, branding
branding/             logo and plymouth boot theme sources
wallpapers/           wallpaper sources (SVG)
packages/             Argon's own Debian packages + APT repo (reprepro)
scripts/              build-iso.sh, build-packages.sh, manage-repo.sh, sign-release.sh
ci/                   lint suite run by GitHub Actions
docs/                 you are here
website/              static project page
iso/                  build output (checksums + images, not committed)
```
