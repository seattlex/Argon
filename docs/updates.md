# Keeping Argon up to date

Argon is a **rolling release**: there are no big version jumps to reinstall
for. You update in place and stay current forever.

## Security updates: automatic

You don't have to do anything for these. `unattended-upgrades` installs
security fixes on its own, and **reboots are never forced** — see
[hardening.md](hardening.md). This is on by default on every install.

## Everything else: one click

Feature updates and new application versions aren't installed automatically
(so an update never changes your system while you're in the middle of
something). To get them:

1. Open **Update Argon** — it's in the menu under *System*, and on the
   **Argon Welcome** screen.
2. Click **Check for updates** to see what's available.
3. Click **Update now**. Enter your password once; apt's progress streams
   in the window. That's it.

Under the hood this is just `apt-get update && apt-get full-upgrade`,
run through the same audited, polkit-authenticated helper that Argon
Software uses — no terminal, no root shell.

## From the terminal

If you prefer the command line, the equivalent is:

```sh
sudo apt update && sudo apt full-upgrade
```

`full-upgrade` (not plain `upgrade`) is the right command on a rolling
release: it lets Argon's metapackages add and remove packages as the
default set evolves, which plain `upgrade` won't do.

## Occasional housekeeping

Over months, old packages and kernels accumulate. To reclaim the space
when you feel like it:

```sh
sudo apt autoremove --purge
```

## Does updating change my privacy/security defaults?

No. The hardening and privacy configuration lives in Argon's own packages
and drop-in config; updating pulls newer versions of software but never
turns your defaults off. If a default ever changes, it's called out in the
[changelog](https://github.com/seattlex/argon/blob/main/CHANGELOG.md).
