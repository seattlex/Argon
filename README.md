<p align="center">
  <img src="branding/logo/argon-icon.png" alt="Argon OS" width="128"/>
</p>

<h1 align="center">Argon OS</h1>

<p align="center">
  A privacy-first, security-hardened Linux distribution built on Kali rolling.<br/>
  Developed in Norway. Free software, forever.
</p>

---

**Argon** is for people who want a hardened system without doing the
hardening themselves: developers, security engineers, journalists,
researchers, and anyone who thinks an OS should answer to its user and
no one else.

## What you get out of the box

| | Default |
| --- | --- |
| Telemetry | **None.** Nothing in Argon phones home |
| Firewall | UFW enabled, deny incoming / allow outgoing |
| MAC address | Randomized while scanning, per-network stable when connected |
| DNS | DNS-over-TLS (Quad9/Mullvad), DNSSEC, no mDNS/LLMNR |
| Browser | Firefox ESR: telemetry off, tracking protection strict, HTTPS-only, uBlock Origin |
| Mandatory access control | AppArmor enforced |
| Updates | Security updates applied automatically, reboots never forced |
| Brute-force protection | fail2ban (sshd jail) |
| Time | chrony with authenticated NTS |
| Network services | Zero listening; ssh/tor/cups installed but opt-in |
| Kernel | Hardened sysctl baseline (commented, auditable) |
| Disk encryption | LUKS2 full-disk encryption in the guided installer |
| Desktop | XFCE, low memory footprint |

Argon tracks **Kali rolling**, so the entire Kali package ecosystem is
available via `apt` but none of it is preinstalled and nothing listens
by default. See [docs/security-tools.md](docs/security-tools.md).

## First-party experience

Argon isn't a re-skin, it has its own applications:

* **Argon Software** has a graphical app store. Browse curated categories
  or search, then install/remove with one click and a password prompt.
  No terminal, ever.
* **Argon Welcome** is a first-login greeter: install the system, get
  software, review your privacy defaults, find the docs.
* **Argon boot menu** is a branded GRUB (UEFI) and isolinux (BIOS) menus.
* **Argon desktop** has a dark XFCE layout, not stock XFCE.

More in [docs/applications.md](docs/applications.md).

## Get Argon

**New to this?** The [Getting Started guide](docs/getting-started.md)
walks you from download to a running desktop with no prior Linux
experience — you don't need Kali or a terminal.

Grab an ISO from the releases page (weekly rolling snapshots + versioned
releases), verify it, write it to USB with
[balenaEtcher](https://etcher.balena.io/), and boot:

* [Getting started (beginners)](docs/getting-started.md)
* [Installation guide (detailed)](docs/installation.md)
* [Verifying downloads](docs/reproducible-builds.md#verifying-a-release-current-state)

## Build it yourself

Everything on a shipped image is generated from this repository:

```sh
# on Kali rolling (or a privileged kalilinux/kali-rolling container)
sudo apt install live-build git
sudo ./scripts/build-iso.sh --variant xfce --version dev
```

Full instructions: [docs/building.md](docs/building.md).

## Repository map

```
build/       live-build configuration (the OS is defined here)
             └ bootloaders/  branded GRUB (UEFI) + isolinux (BIOS) menus
installer/   Calamares installer configuration and branding
packages/    Argon apps (Software + Welcome) + metapackages + APT repo
branding/    logo, plymouth boot theme, boot-menu splash
wallpapers/  wallpaper sources
scripts/     build, sign, and repo-management entry points
docs/        documentation
ci/          lint suite
website/     static project page
```

## Principles

1. **Privacy first**, data minimization in every default.
2. **Security by default**, hardened without user intervention.
3. **Freedom**, FOSS-first, GPL-3.0, no lock and key.
4. **Transparency**, public scripts, reproducible builds, signed releases.

The full product vision lives in the
[PRD / project documentation](docs/README.md).

## Contributing

Argon is young and contributions shape it — see
[CONTRIBUTING.md](CONTRIBUTING.md). Security issues: please read
[SECURITY.md](SECURITY.md) first.

## License

GPL-3.0-or-later. See [LICENSE](LICENSE).
