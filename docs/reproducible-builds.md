# Reproducible builds

**Goal:** anyone can rebuild an Argon release from the tagged source tree
and get a bit-identical image, proving that the shipped ISO contains
exactly what the public repository says it does.

## What Argon does today

* **Pinned timestamps** — `SOURCE_DATE_EPOCH` is derived from the last
  git commit (`build/auto/config`, `scripts/build-iso.sh`), so file
  timestamps inside the image don't depend on when the build ran.
* **No unique state in the image** — the build strips everything that
  would legitimately differ per build or per machine: APT caches and
  lists, logs, the systemd random seed, SSH host keys, machine-id
  (`hooks/normal/0300-argon-cleanup.hook.chroot`).
* **Fully scripted builds** — there is no manual step between
  `git checkout` and the ISO; CI builds use the same
  `scripts/build-iso.sh` as local builds.
* **Verifiable artifacts** — every image ships a SHA-256 checksum;
  releases add a detached GPG signature over the checksum file.

## What still breaks bit-for-bit reproducibility

Being honest about the gap:

1. **The package snapshot.** Kali is a rolling archive; two builds a day
   apart download different package versions. Closing this needs building
   against a snapshotting mirror and recording the snapshot ID with the
   release. This is the main missing piece.
2. **live-build ordering/metadata** — squashfs and ISO metadata are
   mostly stable given identical inputs, but this must be continuously
   verified, not assumed.

## Verifying a release (current state)

```sh
sha256sum -c argon-<version>-xfce-amd64.iso.sha256
gpg --verify argon-<version>-xfce-amd64.iso.sha256.sig
```

## Roadmap

* Record the exact package manifest (`dpkg -l` of the image) as a release
  artifact — done automatically by live-build (`*.packages` file); publish
  it alongside the ISO.
* Build against a snapshot mirror and publish the snapshot ID.
* Two independent CI builders diffing their images (`diffoscope`) before
  a release is published.
