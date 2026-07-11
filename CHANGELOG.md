# Changelog

All notable changes to Argon OS. Format follows
[Keep a Changelog](https://keepachangelog.com/); versions follow the
release tags.

## [Unreleased]

### Added
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
