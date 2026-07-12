# Changelog

All notable changes to Argon OS. Format follows
[Keep a Changelog](https://keepachangelog.com/); versions follow the
release tags.

## [Unreleased]

### Fixed
- Live session lockout: the autologin live user had no usable password, so
  any authentication prompt (notably the idle screen locker) rejected every
  password. The live user now has a known password (`argon`/`argon`), the
  automatic screen locker no longer starts, and the power manager does not
  lock on suspend — so live users can't get locked out. Installed systems
  are unaffected (you create your own account in the installer).

### Changed
- Official Argon artwork: the real logo (arrowhead "A" with a swoosh base),
  a Nordic-mountains desktop wallpaper, and a starfield login background,
  wired through the app icon (hicolor 48–512 px), Plymouth boot splash,
  Calamares installer, boot menu, desktop and login screen. The branding
  pipeline now ships ready-made PNGs instead of rendering from SVG at build
  time (fewer build dependencies, fully reproducible).
- Welcome screen now shows a clear live-session banner (credentials + "click
  Install to create your own account").

### Added
- Audio production support: Creative & Audio catalog category (LMMS,
  Ardour, Carla, qpwgraph, EasyEffects, Hydrogen, Wine) and
  `argon-virtual-audio`, a helper that creates Voicemeeter-style virtual
  audio cables on PipeWire; audio-production guide covering the Voicemeeter,
  FL Studio (via Wine) and VST-plugin workflows
- Argon Software — first-party GTK software center: curated categories
  (incl. defensive Security & Analysis), search, one-click install/remove
  through a polkit-authenticated helper, package "bundles"; no network
  services, local catalog
- Argon Welcome — first-login greeter: install, get software, review
  privacy defaults, docs; autostart with an off switch
- `argon-apps` Debian package (built and baked into the ISO via
  `packages.chroot`, so images are self-contained)
- Branded boot menu for both firmware types: dark Nordic GRUB (UEFI) and
  isolinux (BIOS) with live / safe-graphics / to-RAM / failsafe entries
- XFCE desktop identity: Argon panel layout and window-manager defaults
- Beginner "Getting Started" guide (download → USB → install, no terminal
  or Kali required) and an applications guide
- live-build ISO pipeline on Kali rolling (XFCE variant, UEFI + BIOS,
  hybrid ISO) with reproducibility measures (`SOURCE_DATE_EPOCH`,
  per-build state stripped)
- Privacy defaults: DNS-over-TLS (Quad9/Mullvad) via systemd-resolved,
  MAC randomization, no DHCP hostname leak, IPv6 privacy addresses,
  hardened Firefox ESR policy (telemetry off, uBlock Origin, HTTPS-only,
  DoH), NTS-authenticated time sync (chrony), mat2
- Security defaults: UFW (deny incoming), AppArmor enforced, fail2ban,
  unattended security upgrades, hardened sysctl baseline, SSH hardened
  and disabled by default, per-machine SSH host keys via first-boot
  service, zero listening services
- Calamares installer: guided erase-disk with LUKS2 + Btrfs default,
  manual partitioning (Btrfs/EXT4), swap options, sudo-only user model,
  Argon branding and slideshow
- Branding: geometric "A" logo, Nordfjell wallpaper, Plymouth boot theme,
  dark Nordic XFCE + LightDM theming, os-release/issue/motd identity
- Packaging: argon-core / argon-desktop-xfce / argon-privacy-tools /
  argon-dev-tools metapackages; reprepro-based signed APT repository
  (suite `argon-rolling`) with management tooling
- CI: lint suite (shellcheck, JSON/YAML, config assembly) and ISO build
  workflow (weekly snapshots, tag-driven draft releases with signed
  checksums)
- Documentation: building, installation, hardening, privacy, repository,
  reproducible builds, security tooling
- Static project website

[Unreleased]: https://github.com/seattlex/argon/commits/main
