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
gpg --verify argon-<version>-xfce-amd64.iso.sha256.sig \
            argon-<version>-xfce-amd64.iso.sha256    # signature over the checksum
sha256sum -c argon-<version>-xfce-amd64.iso.sha256    # checksum over the image
```

Verify the signature **first**: it proves the checksum file itself wasn't
tampered with, and only then does matching the checksum mean anything.
(Import Argon's signing key once, from the source published on the releases
page / project site, before the first verify.)

## Signing is on by default

Every build signs its checksums automatically when a signing key is
configured — **both** tagged releases and the rolling snapshot carry a
`.sha256.sig`. Maintainers enable it once by setting two things on the
repository:

* a secret **`ARGON_SIGNING_KEY_ASC`** — the ASCII-armoured private signing
  key, and
* a variable **`HAS_SIGNING_KEY`** set to `true`.

With those present the CI imports the key and signs; without them the build
still publishes, just unsigned. Nothing about the key material lives in the
repository.

## Roadmap

* Record the exact package manifest (`dpkg -l` of the image) as a release
  artifact — done automatically by live-build (`*.packages` file); publish
  it alongside the ISO.
* Build against a snapshot mirror and publish the snapshot ID.
* Two independent CI builders diffing their images (`diffoscope`) before
  a release is published.
