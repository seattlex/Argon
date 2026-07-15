# Changelog

All notable changes to Argon OS. Format follows
[Keep a Changelog](https://keepachangelog.com/); versions follow the
release tags.

## [Unreleased]

### Fixed — installer bootloader + wallpaper (second boot pass)
- **Install failed at the end: "bootloader/main.py raised an exception".**
  Calamares' bootloader module reads the GRUB binary names and EFI id
  directly out of its config (`grubInstall`, `efiBootloaderId`, …); with no
  `bootloader.conf` present it raised a `KeyError`. Added a proper
  `bootloader.conf` (BIOS + UEFI, with removable-media fallback) and a
  `grubcfg.conf` that also carries Argon branding and the AppArmor kernel
  command line onto installed systems.
- **Desktop background still black.** The first wallpaper fix only updated
  the generic `monitor0` node; xfdesktop actually renders the output under
  its real RandR connector name (e.g. `Virtual-1`), which stayed unset. The
  login-time script now enumerates the *connected* outputs via `xrandr` and
  sets the wallpaper on each (added `x11-xserver-utils` for `xrandr`). The
  shipped image is unchanged — the Argon mountains scene.

### Fixed — install, desktop, and CI storage
- **Installer could not unpack the system.** Calamares' `unpackfs` step
  failed with "Failed to find unsquashfs". Added `squashfs-tools` (provides
  `unsquashfs`) to the image, plus the GRUB/EFI target packages
  (`grub-common`, `grub2-common`, `grub-pc-bin`, `grub-efi-amd64-bin`,
  `efibootmgr`, `os-prober`) so the installed system is actually bootable on
  both BIOS and UEFI. The `-bin` variants avoid the interactive
  "install GRUB to which disk?" debconf prompt during the chroot build.
- **Black desktop background.** xfdesktop keys the wallpaper per-monitor by
  RandR connector name, so the shipped `monitor0` default was ignored on
  machines whose monitor is named otherwise, leaving the dark solid-colour
  fallback (a near-black screen). A tiny login-time autostart
  (`/usr/libexec/argon/argon-set-wallpaper`) now applies the wallpaper to
  whatever monitors actually exist — live and installed alike.
- **GitHub Actions artifact storage exhausted.** The multi-GB ISO is no
  longer uploaded as a workflow artifact (those count against a small,
  quota-limited store). Downloads now come only from GitHub Releases, which
  use separate, generous storage: `v*` tags publish versioned releases, and
  every other build refreshes a single, always-overwritten `rolling`
  pre-release — so ISO storage stays bounded no matter how often it builds.
  The failure build-log artifact retention dropped to 3 days.

- Live login rebuilt from scratch as a script-free, layered design so it
  works even if nothing runs correctly at boot:
  1. The `argon` user (password `argon`, unlocked, non-expiring, in the
     right groups) is **baked into the image at build time** — so logging
     in is always possible, exactly how Kali bakes its `kali` user.
  2. `live-config` is told **not** to manage users/passwords/sudo
     (`/etc/live/config.conf` `LIVE_CONFIG_NOCOMPONENTS`), and the
     `username=` boot parameters were removed — this is what previously
     recreated and **locked** the account at boot, causing
     "authentication failure".
  3. Autologin and showing the user in the greeter are **static config
     files** (no boot script). If autologin ever doesn't fire, the `argon`
     user is one click away (no more "Other…" / unknown-username prompt).
  4. On install, Calamares `removeuser` deletes the live account and a
     `shellprocess` step removes the live-only autologin/launcher files, so
     installed systems stay login-required with only your account.
  Removed the previous boot-time machinery (a systemd service, a
  live-config component, and runtime-generated drop-ins) that this replaces.

### Fixed (earlier iterations, superseded by the above)
- Detect the real live account by UID instead of assuming `argon`; pass
  `live-config.username=argon` so the account is named `argon`.
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
