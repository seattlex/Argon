# Building Argon OS

## Requirements

Images must be built on **Kali rolling** (bare metal, VM, or container),
because Argon uses Kali's patched `live-build`, which understands the
`kali-rolling` distribution:

```sh
sudo apt update
sudo apt install live-build git
```

Building in a container works, but the container must be privileged
(live-build creates a chroot and mounts pseudo-filesystems):

```sh
docker run --privileged -it -v "$PWD:/argon" -w /argon kalilinux/kali-rolling bash
apt update && apt install -y live-build git ca-certificates
```

Expect the build to download ~2 GB of packages and need ~15 GB of disk.

## Building the ISO

```sh
sudo ./scripts/build-iso.sh --variant xfce --version 0.1.0
```

The script:

1. assembles the live-build config into `build/config/` by layering
   `build/argon-config/common/` and `build/argon-config/variant-<name>/`,
   then copying in `branding/`, `wallpapers/` and `installer/calamares/`;
2. runs `lb clean && lb config && lb build` inside `build/`
   (`build/auto/config` holds all `lb config` arguments);
3. moves the finished image to `iso/argon-<version>-<variant>-amd64.iso`
   and writes a `.sha256` checksum next to it.

Use `--skip-build` to only assemble the configuration (no root needed) —
this is what CI's lint job does to validate the tree.

## Building the Argon packages

```sh
sudo apt install build-essential debhelper devscripts
./scripts/build-packages.sh            # unsigned development build
SIGN=1 ./scripts/build-packages.sh     # signed with your default GPG key
```

Artifacts land in `packages/dist/`. See
[repository.md](repository.md) for publishing them.

## CI builds

`.github/workflows/build-iso.yml` builds the ISO in a privileged
`kalilinux/kali-rolling` container:

* weekly (Monday 03:00 UTC) — rolling snapshot, artifact retained 7 days;
* on tags `v*` — draft GitHub release with checksums (and signatures when
  the `ARGON_SIGNING_KEY_ASC` secret plus `HAS_SIGNING_KEY` variable are set);
* on demand via *Run workflow*.

## Troubleshooting

* **`lb build` fails mid-bootstrap** — usually a mirror hiccup; re-run.
  A specific mirror can be forced with `ARGON_MIRROR=<url>`.
* **No ISO produced** — check `build/build.log`; the last stage logged
  tells you which live-build phase failed.
* **Hooks not executing** — hooks must be executable; `build-iso.sh`
  re-applies `chmod +x`, but if you invoke `lb` manually, check this first.
