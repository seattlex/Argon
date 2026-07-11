# The Argon APT repository

Argon systems use two package sources:

1. **Kali rolling** — the full Kali archive (this is where almost every
   package comes from);
2. **Argon** — Argon's own packages: metapackages, and (in future
   phases) branding and configuration packages.

## Using the repository

```sh
# 1. Import the archive signing key (fingerprint published on the website
#    and in signed release notes — verify out-of-band!)
curl -fsSL https://<host>/argon/argon-archive-key.asc \
  | sudo gpg --dearmor -o /usr/share/keyrings/argon-archive-keyring.gpg

# 2. Add the source
echo 'deb [signed-by=/usr/share/keyrings/argon-archive-keyring.gpg] https://<host>/argon argon-rolling main' \
  | sudo tee /etc/apt/sources.list.d/argon.list

sudo apt update
sudo apt install argon-core
```

Packages offered:

| Package | Purpose |
| --- | --- |
| `argon-core` | hardening/privacy baseline (dependency metapackage) |
| `argon-desktop-xfce` | the default XFCE desktop |
| `argon-privacy-tools` | Tor, torsocks, mat2, WireGuard, OpenVPN |
| `argon-dev-tools` | git, C/C++, Python (+ Go/Rust/containers as recommends) |

## Operating the repository (maintainers)

The repo is managed with [reprepro](https://wiki.debian.org/DebianRepository/SetupWithReprepro);
its definition lives in `packages/repo/conf/distributions` (suite
`argon-rolling`, components `main`, amd64/arm64/source). The pool and
indices are generated — only `conf/` is committed.

```sh
./scripts/build-packages.sh                          # build the .debs
./scripts/manage-repo.sh add packages/dist/*.deb     # include + sign
./scripts/manage-repo.sh list
rsync -a packages/repo/{dists,pool} <host>:/srv/argon/   # publish
```

Every index is GPG-signed by reprepro (`SignWith:`); replace `default`
with the production key fingerprint before publishing. APT clients verify
signatures on every update — an unsigned or tampered repo fails closed.
