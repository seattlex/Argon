# Argon's first-party applications

Argon ships two of its own desktop applications (packaged as
`argon-apps`, source in `packages/argon-apps/`). Both are written in
Python + GTK 3 and neither talks to any network service.

## Argon Software

A curated software center — the graphical way to add and remove programs,
so newcomers never need `apt` or a terminal.

* **Catalog** — a local JSON file (`/usr/share/argon/software-catalog.json`)
  grouped into categories: Featured, Internet, Privacy & Security,
  Security & Analysis, Development, Multimedia, Office & Graphics, System
  Tools. Each entry maps a friendly name to one or more Debian packages,
  so a single click can install a whole toolchain ("bundles").
* **Search** filters across every category by name, description and
  package.
* **Install / Remove** run through a small privileged helper
  (`/usr/libexec/argon/argon-pkg-helper`) launched via `pkexec`. The user
  authenticates once with the polkit dialog (action
  `org.argon.pkg-helper`); the helper strictly validates package names
  and shells out to `apt-get`. Live output streams into a log pane.

Editing the catalog is all it takes to change what's offered — no code
changes. Set `ARGON_CATALOG=/path` to test an alternate catalog, or
`ARGON_SOFTWARE_SIMULATE=1` to exercise the UI with `apt-get -s` (no real
changes).

### About security tooling

Argon is Kali-based, so the entire Kali archive is reachable with `apt`.
The *Security & Analysis* category surfaces **defensive and analysis**
tools (network inspection, system auditing, malware scanning, forensics
and data recovery). Argon deliberately does not present a one-click
installer for offensive/exploitation frameworks; those remain available
through the documented `apt install` route
([security-tools.md](security-tools.md)) for users who need them.

## Argon Welcome

The first-login greeter (autostarted once via
`/etc/xdg/autostart/argon-welcome.desktop`, with a checkbox to disable
it). It offers the handful of things a new user actually wants:

* **Install Argon OS** — shown only in the live session, launches the
  Calamares installer.
* **Get Software** — opens Argon Software.
* **Your Privacy Defaults** — a plain-language list of what's already
  protecting the user (firewall, encrypted DNS, MAC randomization, …).
* **Documentation** and **Community & Source Code** links.

Run `argon-welcome` any time to reopen it; `--autostart` makes it exit
silently if the user turned it off.

## Argon Virtual Audio

`argon-virtual-audio` is a small command-line tool that creates
Voicemeeter-style virtual audio cables on top of PipeWire
(`enable [N]` / `disable` / `status`). Each cable is both an output apps
can play into and an input others can record from, which — combined with
qpwgraph for routing and EasyEffects for processing — replaces a
Voicemeeter setup. It writes a per-user PipeWire drop-in and needs no
root. Full workflow, plus FL Studio and VST guidance, is in
[audio-production.md](audio-production.md).

## Boot menu

Argon ships its own branded boot menu for both firmware types
(`build/argon-config/common/bootloaders/`):

* **GRUB** for UEFI machines, with a dark Nordic theme;
* **isolinux** for older BIOS machines.

Both offer the same entries — *live*, *safe graphics*, *load to RAM*, and
*failsafe* — with kernel parameters matching the hardened defaults from
`build/auto/config`. A bootloader only starts the kernel; it doesn't
install anything, so software is added later from Argon Software.
