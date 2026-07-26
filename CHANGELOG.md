# Changelog

All notable changes to Argon OS. Format follows
[Keep a Changelog](https://keepachangelog.com/); versions follow the
release tags.

## [Unreleased]

### Added — Pulsemeeter (graphical Voicemeeter alternative)
- Ships **Pulsemeeter**, a Voicemeeter-style graphical audio mixer/router
  for PipeWire, as a menu entry (Sound & Video). It's a PyPI app (not in
  apt or Flathub), so `argon-pulsemeeter` installs it per-user with pipx on
  first launch — isolated, no root, `--system-site-packages` so it uses the
  system GTK — in a visible terminal, then just launches it thereafter.
  Runtime prerequisites (`pipx`, `python3-venv`, `pulseaudio-utils` for
  `pactl`) are on the image. The `argon-virtual-audio` CLI stays for a
  scripted/no-GUI setup; audio-production.md now leads with Pulsemeeter.

### Added — Flathub in Argon Software
- Argon Software now has a **Flathub** category. Catalog entries can carry a
  `flatpak` app-id instead of apt `packages`; those install as **per-user
  Flatpaks** (no root, sandboxed) with the same one-click Install/Remove and
  live log. Ships `flatpak` + the desktop portals; a first-boot service
  (`argon-flathub-setup`, once the network is up) registers the Flathub
  remote — it installs nothing and does nothing until you pick an app.
- Seeded the category with Flatseal, Bottles, OBS Studio, Signal and GIMP.
  apt remains preferred where an app is packaged (smaller, shared libs);
  Flathub is there for latest releases and un-packaged apps.

### Added — no-reinstall migration for older installs
- `scripts/argon-migrate.sh`: brings an Argon system installed *before* the
  updater/snapshots/audio fixes up to the current build without reinstalling
  and without touching `/home`. Snapshots first (if Btrfs), installs the
  packages newer images ship (including `dbus-user-session` and
  `plymouth-label` — the audio and LUKS-prompt fixes), pulls Argon's system
  integration from the repo tarball (single source of truth), installs the
  latest `argon-apps` from the rolling release, then rebuilds the initramfs
  and enables the services. Idempotent and best-effort throughout.
- CI now publishes the `argon-apps_*.deb` on the rolling release so the
  migration script (and manual installs) can fetch it. See
  [migrating.md](docs/migrating.md).

### Added — automatic Btrfs snapshots + one-step rollback
- On a Btrfs install (the default), Argon now snapshots the root subvolume
  **before every package change** via an apt `Pre-Invoke` hook, so a bad
  upgrade can be undone. Built on the standard **snapper + grub-btrfs**
  stack rather than hand-rolled: a first-boot service (`argon-snapshots-
  setup`, installed systems only) configures snapper for `/`, and
  grub-btrfs adds the snapshots to the boot menu so you can boot one
  read-only to preview before committing.
- No background timer — snapshots happen around `apt`, and the last 12 are
  kept and auto-pruned. `/home` (a separate subvolume) is never part of a
  snapshot, so rolling back never touches personal files. The whole thing
  self-skips on ext4 and in the live session.
- `argon-snapshot` CLI (`status` / `list` / `create` / `rollback`) and a
  [snapshots guide](docs/snapshots.md). Rollback delegates to snapper's
  tested `rollback` (which snapshots the current state first, so it's
  itself undoable).

### Added — Argon Update (one-click updates for existing installs)
- New **Argon Update** app (menu → System, and a button on Argon Welcome):
  **Check for updates** then **Update now**, with apt's progress streaming
  live in the window. No terminal. It runs
  `apt-get update && apt-get full-upgrade` through the *same*
  polkit-authenticated helper Argon Software already uses — the helper
  gained an `upgrade` action (no package arguments), so there is still one
  audited privilege boundary. Security fixes keep installing themselves via
  unattended-upgrades; this covers the feature/app updates that are held
  back so the system never changes mid-session.
- New [updates guide](docs/updates.md) explaining the rolling model,
  the one-click flow, and the `apt full-upgrade` terminal equivalent.

### Fixed — Security Edition CI build ran the runner out of disk
- The Security Edition build kept dying with **"No space left on device"**
  (confirmed from the runner's own crash trace). A GitHub-hosted runner
  only leaves ~21 GB free on `/`, and `kali-linux-default`'s live-build
  needs more. The job ran *inside* a Kali `container:`, so it couldn't
  reach the host's ~30 GB of preinstalled toolchains to delete them. The
  build now runs on the host (freeing Android SDK, .NET, GHC, the
  hosted-tool cache, etc. first) and launches Kali via `docker run
  --privileged` itself — same build, ~30 GB more scratch space. Root-owned
  build outputs are chowned back so the release/publish steps still work.

### Fixed — no audio at all (missing `dbus-user-session`)
- **The machine was silent.** PipeWire and WirePlumber were installed and
  their user services were enabled — but `wireplumber.service` died at
  start with *"Failed to connect to session bus"*, so no audio nodes were
  ever created. The cause was a missing **`dbus-user-session`**: PipeWire
  and WirePlumber run under the systemd `--user` manager and reach each
  other over the per-user session bus at `$XDG_RUNTIME_DIR/bus`, which
  `logind`/`pam_systemd` only set up when that package is installed. Argon
  shipped the legacy **`dbus-x11`** instead (recommends are off, so the
  desktop task's `dbus-user-session` never came in), which starts an ad-hoc
  bus per X display and leaves the `--user` services unreachable. This is
  Debian bug #998167 / #1032351 exactly. Replaced `dbus-x11` with
  `dbus-user-session` (what Debian's own XFCE task ships).
- Added the audio-stack pieces that `--apt-recommends false` also dropped:
  `rtkit` (glitch-free realtime scheduling) and `libspa-0.2-bluetooth` —
  without which a paired Bluetooth headset connects but plays nothing.
  (`pipewire-alsa` turned out to already be pulled in; listing it is
  harmless and explicit.)
- Belt-and-suspenders `systemctl --global enable` of the PipeWire user
  units in the service hook. The packages already ship them enabled, so
  this is normally a no-op; it guards against a future packaging change.
- **Bluetooth was enabled and then immediately disabled** in the same hook
  (the new `enable` line met a pre-existing `disable` line left from when
  Bluetooth wasn't installed), so it shipped off. Removed the stale
  disable; Bluetooth is a local radio, not a network-advertised service.

### Fixed — encrypted installs looked like a hung boot (invisible passphrase prompt)
- **The LUKS passphrase prompt rendered invisibly.** Every text element in
  Argon's plymouth splash goes through the theme's `Image.Text()`, which
  needs plymouth's *label* plugin — a separate package
  (`plymouth-label`) that is only a Recommends, and recommends are
  globally off. The splash showed the logo but no text at all, so an
  encrypted install booted into an *invisible* password prompt and sat
  there — read as "encryption is incompatible / boot fails", while
  unencrypted installs (which never prompt) booted fine. Added
  `plymouth-label` (+ `fonts-dejavu-core` for the font the initramfs hook
  copies in). The Calamares module chain itself was verified against the
  upstream source and is correct for the unencrypted-`/boot` layout
  (root's crypttab entry gets `none` → initramfs prompts).
- Troubleshooting guide now covers encrypted boots: the passphrase screen
  is expected at every boot, type-blind + Enter works, and **Esc** always
  reveals the text prompt beneath the splash.

### Fixed — Secure Boot failure now named and documented
- **"Verification failed: (0x1A) Security Violation"** when booting the
  USB on UEFI machines is Secure Boot rejecting Argon's (Kali-derived,
  unsigned) boot chain — it reads like a corrupt ISO and isn't. The exact
  message is now in the README, install guide and troubleshooting guide
  with per-vendor firmware steps (incl. MSI) and the BitLocker caveat for
  dual-booters. A signed shim stays on the roadmap.

### Fixed — Security Edition build exhausting runner disk
- The first Security Edition CI build died silently partway through (~8 min
  in, vs. the usual ~17; the "Build ISO" step never reached a terminal
  state and no log was ever committed — the signature of the runner
  process itself being killed, not a normal script failure). Root cause:
  live-build's package cache (`--cache-packages`, on by default) keeps a
  *second* copy of every downloaded `.deb` on disk purely so a later build
  can skip re-downloading — but `build-iso.sh` runs `lb clean --purge`
  before every single build, local or CI, so that reuse never happens and
  the cache was pure duplication. Harmless normally; with
  `kali-linux-default`'s much larger package set, likely enough to tip a
  GitHub-hosted runner's disk over the edge. Disabled via
  `--cache-packages false` in `auto/config`, for every variant.

### Added — Argon Security Edition (build variant)
- New `security` build variant: the identical privacy-hardened OS plus
  Kali's standard tool selection (`kali-linux-default`) preinstalled,
  unmodified from the same Kali repositories. Argon's no-listening-services
  rule still applies — tools are installed, nothing starts or listens.
- Build variants can now layer on a parent (`variant-security/parent` →
  `xfce`), so editions share the desktop instead of duplicating it; lint
  assembles the security config to keep the layering honest.
- CI publishes each edition under its own rolling asset name, and splits
  images over GitHub's 2 GiB release-asset cap into `.part*` files with
  reassembly instructions in the release notes.

### Changed — minimal panel + QOL
- The four coloured lock/logout/restart/shutdown buttons in the panel are
  now a single neutral session button (its dialog and the Whisker menu
  carry the same actions) — the loudest element of the default desktop,
  gone.
- Bluetooth finally works out of the box: `bluez` + `blueman` (tray UI),
  service enabled; local radio only, no network listener.
- `fastfetch` ships for a pretty terminal system summary.

### Fixed — live boot dropping to a BusyBox `(initramfs)` prompt
- **The splash ran halfway, then the machine landed in a BusyBox shell.**
  `live-boot` scans for `/live/filesystem.squashfs` for 60 seconds and then
  panics into `(initramfs)`; it never found the medium. This reproduced on
  physical USB boots while working every time in a VM, because a VM's disk
  uses drivers that are present in any initramfs — the USB path needs
  drivers that were not guaranteed to be there.
- The image now **pins `MODULES=most` and forces an explicit boot-media
  driver set into the initramfs** (`xhci`/`ehci`/`ohci`/`uhci`,
  `usb-storage`, `uas`, `sd_mod`, `sr_mod`/`isofs`, `squashfs`, `loop`,
  `overlay`, `vfat` + NLS codepages, `ahci`, `nvme`, virtio). `uas` and the
  `vfat`/NLS set are the load-bearing additions: most USB 3 sticks bind to
  `uas` rather than `usb-storage`, and a stick written by Rufus in "ISO
  mode" holds the live files on FAT32, which is visible but unmountable
  without them.
- **The config alone would have done nothing**, which is the actual trap
  here: live-build installs the kernel (generating the initramfs) *before*
  it copies `includes.chroot` in, so the new settings landed on disk after
  the initrd that ships in the image was already built. A new chroot hook
  regenerates the initramfs after the includes are in place.
- A second hook **verifies the shipped initrd and fails the build** if
  `usb-storage`, `uas`, `xhci_pci`, `squashfs`, `overlay` or `vfat` are
  missing — this class of bug is invisible until someone boots a physical
  stick, so it is now caught in CI instead of by a user. It runs at `9999`
  rather than next to the rebuild, because live-build injects its own hooks
  into the same directory (`1010-enable-cryptsetup` regenerates the
  initramfs, and the built-ins run up to `9020`): checking any earlier
  validates an initrd that is then replaced before the image is assembled.
- Added a **"verbose — troubleshoot boot"** entry to both the BIOS and UEFI
  menus (`debug=1`, no `quiet splash`). The default entry hid the panic
  message behind Plymouth, which is why the failure looked like a silent
  crash with nothing to report.
- New [troubleshooting guide](docs/troubleshooting.md): how to read the
  `(initramfs)` prompt, and correct USB-writing guidance (Etcher, or Rufus
  in **DD mode** — ISO mode rebuilds the boot menu and cannot hold files
  over 4 GB).

### Fixed — bootloader made robust across the whole install matrix
- **`grub-install --target=i386-pc … returned error code 1`.** The erase-disk
  layout now creates a separate **unencrypted 1 GiB ext4 `/boot`**
  (`partitionLayout` + `noEncrypt`, verified against the Calamares source)
  ahead of the root filesystem. GRUB therefore never has to read an
  encrypted or btrfs volume, which makes the bootloader step behave the
  same on BIOS and UEFI, plain and LUKS installs — and it is the only
  layout under which encrypted installs can boot at all (GRUB cannot
  unlock LUKS2/argon2id, so an encrypted `/boot` is unbootable even when
  the install succeeds).
- **Encrypted installs could never unlock at boot**: added
  `cryptsetup-initramfs` (only a Recommends of cryptsetup, and recommends
  are globally off) so the initramfs can actually open the LUKS root.
- Ship an explicit Calamares `mount.conf` (upstream defaults plus
  `/dev/pts`) so the target chroot that runs `grub-install`,
  `grub-mkconfig` and `update-initramfs` never depends on
  package-shipped defaults.
- Documented that UEFI Secure Boot must be disabled (Kali kernels are
  unsigned); noted the unencrypted-`/boot` scheme in the install guide.

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
