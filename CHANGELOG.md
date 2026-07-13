# Changelog

All notable changes to Argon OS. Format follows
[Keep a Changelog](https://keepachangelog.com/); versions follow the
release tags.

## [Unreleased]

### Fixed
- Live session now autologs in (root cause of the "password incorrect"
  reports): the live image was landing on the LightDM login screen, and the
  real live account was not necessarily named `argon` — live-config could
  create it as `user`, so the password and autologin (which targeted a
  hard-coded `argon`) applied to a user that did not exist. The live-config
  component now **detects the actual live account by UID** (the first
  regular user, whatever its name), and sets its password, autologin groups,
  and a live-only LightDM autologin drop-in against that real user — so the
  session boots straight to the desktop like Kali/Mint regardless of the
  username. The boot options also now pass `live-config.username=argon` so
  the account is named `argon`. Fallbacks: known password (`argon`) and the
  greeter shows the user (not hidden) if autologin ever fails. Installed
  systems are unaffected — they require login and create their own account.
- Live desktop now has an "Install Argon OS" launcher (on the desktop and
  in the menu, live session only) that starts the Calamares installer.
- Screen-lock lockout (hardened): both possible lockers (light-locker and
  xfce4-screensaver) and lock-on-suspend are disabled, so idle can't trap
  the user either.

### Added — project presentation
- Professional README overhaul: screenshots gallery, a "Why Argon?"
  section, a Kali/Ubuntu/Argon comparison table, a "Built by Argon" list of
  original components, a four-step install flow, an architecture diagram,
  a roadmap summary, and status badges.
- Real screenshots of Argon Welcome and Argon Software (plus login and
  desktop backgrounds) under `docs/screenshots/`.
- Public roadmap (`docs/roadmap.md`) and GitHub issue templates
  (bug report, feature request) with a Discussions/Security contact config.

### Added — quality of life
- Media & codecs: FFmpeg + GStreamer good/bad/ugly/libav/VAAPI so common
  audio/video plays out of the box, file-manager thumbnails (tumbler,
  ffmpegthumbnailer), the Parole video player, and emoji/Liberation/DejaVu
  fonts.
- Desktop polish: clipboard-history manager (clipman) and a night-light /
  blue-light filter (redshift, manual location for privacy — no network
  geolocation).
- Faster & lighter: zram compressed-RAM swap and earlyoom OOM protection
  for low-memory machines; NetworkManager-wait-online and ModemManager
  disabled and the boot-menu timeout cut to 5 s for a quicker boot.
- More default apps: calculator (galculator), disk-usage viewer (baobab)
  and PDF reader (atril).

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
- Branding: Plymouth boot theme, dark Nordic XFCE + LightDM theming,
  os-release/issue/motd identity (the logo and wallpapers are covered under
  "Official Argon artwork" above)
- Packaging: argon-core / argon-desktop-xfce / argon-privacy-tools /
  argon-dev-tools metapackages; reprepro-based signed APT repository
  (suite `argon-rolling`) with management tooling
- CI: lint suite (shellcheck, Python syntax, JSON/YAML, config assembly)
  and ISO build workflow (weekly snapshots, manual dispatch, and tag-driven
  auto-published releases with checksums + optional GPG signing)
- Documentation: building, installation, hardening, privacy, repository,
  reproducible builds, security tooling
- Static project website

[Unreleased]: https://github.com/seattlex/argon/commits/main
