# Upgrading an older Argon install (no reinstall)

If you installed Argon **before** it had the built-in updater and snapshots,
you don't need to reinstall or lose any data. One script brings your system
up to the current build — it only *adds* things (packages, a few system
files, service enables) and never touches `/home`.

## Run it

```sh
curl -fsSL https://raw.githubusercontent.com/seattlex/argon/main/scripts/argon-migrate.sh | sudo sh
```

Prefer to read it first? It's short — download and inspect it, then:

```sh
sudo sh argon-migrate.sh
```

Then **reboot**.

## What it does

* Takes a Btrfs snapshot first (if possible), so the migration itself is
  undoable.
* Installs the packages newer images ship that yours may lack — including
  the ones behind the big fixes: `dbus-user-session` (audio),
  `plymouth-label` (the LUKS passphrase prompt), plus snapshots, Bluetooth,
  Flathub and PipeWire pieces. Already-installed packages are skipped.
* Drops in Argon's system integration (the pre-update snapshot hook and its
  first-boot setup) straight from the repo — one source of truth, no config
  of yours overwritten.
* Installs the latest **Argon apps** (Update, Software, Welcome) from the
  rolling release.
* Rebuilds the initramfs (so the LUKS prompt renders), enables the PipeWire
  and Bluetooth services, and configures snapshots.

It's **idempotent** — safe to run again — and every step is best-effort, so
one failure never leaves the system half-changed.

## After migrating

You're on the current Argon layer. From now on, updates are one click in
**Update Argon** (menu → System), and on Btrfs the system is snapshotted
before each one — see [updates.md](updates.md) and
[snapshots.md](snapshots.md).

> **Testing a pre-release branch?** Point the script at it with
> `ARGON_MIGRATE_REF=<branch> sudo -E sh argon-migrate.sh`.
