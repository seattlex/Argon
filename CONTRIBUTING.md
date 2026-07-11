# Contributing to Argon OS

Thanks for helping build a privacy-first OS. This document is short on
ceremony — the important parts are the design rules.

## Design rules (non-negotiable defaults)

Any change to the image or packages must respect these; PRs that don't
will be asked to change:

1. **No telemetry, no phoning home.** Nothing may transmit data about
   the user or system without an explicit user action.
2. **No listening services by default.** Installing a package must not
   open a port. Services that listen ship disabled.
3. **FOSS only in the default install.** Non-free firmware for hardware
   support is the single exception.
4. **Defaults must be overridable.** Ship drop-in config (sysctl.d,
   conf.d, policies) that admins can override with later-sorting files —
   never edit files owned by other packages.
5. **Everything traceable.** Every file on the image must come from a
   Kali package or from this repository — no blobs, no "fetched at build
   time" artifacts beyond the package archives.

## Getting started

```sh
git clone https://github.com/seattlex/argon && cd argon
./ci/lint.sh                                  # what CI runs
sudo ./scripts/build-iso.sh --skip-build ...  # assemble config without building
```

A full image build needs Kali rolling — see [docs/building.md](docs/building.md).

## Pull requests

* Branch from `main`; keep PRs focused on one change.
* `./ci/lint.sh` must pass (shellcheck, JSON/YAML validation, config
  assembly).
* Explain *why* in the PR description — especially for anything touching
  defaults, since defaults are the product.
* Changes to hardening/privacy defaults need a matching update to
  `docs/hardening.md` or `docs/privacy.md`. Undocumented defaults don't
  exist.

## Where help is wanted

* Testing ISO builds on varied hardware (UEFI/BIOS, Wi-Fi chipsets)
* KDE Plasma / GNOME variants (`build/argon-config/variant-*`)
* Translations for installer branding
* Reproducible-builds work (snapshot mirrors, diffoscope CI)

## Conduct

Be excellent to each other. Harassment, gatekeeping, or hostility have
no place here; maintainers will act on reports sent to the addresses in
[SECURITY.md](SECURITY.md).
