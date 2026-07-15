# Argon OS roadmap

This is a direction, not a promise of dates. Priorities shift with
contributor time and community feedback — see
[Discussions](https://github.com/seattlex/argon/discussions).

## Shipped

- ✔ **Build pipeline** — scripted live-build ISO (UEFI + BIOS, hybrid) on
  Kali rolling, with reproducibility measures and CI.
- ✔ **Argon Welcome** — first-login greeter.
- ✔ **Argon Software** — graphical software center with one-click,
  polkit-authenticated installs.
- ✔ **Argon Virtual Audio** — Voicemeeter-style virtual audio cables on
  PipeWire.
- ✔ **Installer** — Calamares with LUKS2 + Btrfs guided default, sudo-only
  user model, Argon branding.
- ✔ **Branding** — logo, wallpapers, Plymouth theme, branded boot menu.
- ✔ **Privacy & security defaults** — encrypted DNS, MAC randomization,
  UFW, AppArmor, fail2ban, automatic security updates, hardened sysctl.
- ✔ **Packaging** — `argon-*` metapackages + signed APT repository.
- ✔ **Quality of life** — media codecs, thumbnails, clipboard manager,
  night-light, zram + earlyoom, extra default apps.

## Near term (0.x)

- ◻ **Automatic Btrfs snapshots** — snapshot before updates so a bad
  upgrade can be rolled back in one step.
- ◻ **Flatpak integration** — Flathub apps alongside system packages,
  surfaced in Argon Software.
- ◻ **Reproducible builds, verified** — build against a snapshot mirror,
  publish the package manifest, and diff two independent builds
  (`diffoscope`) before release.
- ◻ **Installer polish** — "install alongside" (dual-boot) guidance, more
  locale/keyboard defaults.

## Medium term (1.0)

- ◻ **Secure Boot** — signed shim + kernel for out-of-the-box UEFI Secure
  Boot.
- ◻ **Sandboxed applications** — tighter AppArmor/bubblewrap confinement
  for browsers and risky apps.
- ◻ **Wayland session** — an optional Wayland desktop.
- ◻ **Signed releases by default** — published signing key + verified
  release artifacts as the norm.

## Longer term

- ◻ **Additional editions** — KDE Plasma, GNOME, and a minimal edition.
- ◻ **ARM support** — images for ARM64 devices.
- ◻ **Live USB persistence** — encrypted persistent storage on the USB.
- ◻ **Immutable variant** — an image-based, atomically-updated edition.
- ◻ **Supply-chain security** — Sigstore-style signing across the pipeline.

## How to influence it

Open a [Discussion](https://github.com/seattlex/argon/discussions) or an
[issue](https://github.com/seattlex/argon/issues/new/choose). Concrete
proposals and pull requests move items up the list faster than anything
else.
