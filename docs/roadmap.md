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
- ✔ **Argon Update** — one-click system updates for existing installs, and a
  no-reinstall migration path for older ones.
- ✔ **Automatic Btrfs snapshots** — snapshot before every update
  (snapper + grub-btrfs), one-step rollback.
- ✔ **Flatpak integration** — Flathub apps surfaced in Argon Software.
- ✔ **Pulsemeeter** — graphical Voicemeeter-style audio mixer.
- ✔ **Installer polish** — install-alongside/dual-boot guidance, locale/
  keyboard defaults, geoip-off.
- ✔ **Signed releases by default** — CI signs checksums (tags + rolling)
  whenever a key is configured.
- ✔ **Secure Boot (opt-in)** — Machine Owner Key path (`argon-secureboot-
  setup`); signed shim + kernel out-of-the-box still to come.
- ✔ **Wayland session (experimental)** — optional labwc session.

## Near term (0.x)

- ◻ **Reproducible builds, verified** — build against a snapshot mirror,
  publish the package manifest, and diff two independent builds
  (`diffoscope`) before release.
- ◻ **Secure Boot, out of the box** — a distro-signed (or Microsoft-signed)
  boot chain so Secure Boot needs no MOK enrolment.

## Medium term (1.0)

- ◻ **Sandboxed applications** — tighter AppArmor/bubblewrap confinement
  for browsers and risky apps.
- ◻ **Wayland session, first-class** — promote the experimental session, or
  an XFCE/other Wayland desktop, to supported.

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
