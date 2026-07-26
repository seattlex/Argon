# Snapshots & rollback

On a **Btrfs** install (the default), Argon takes a snapshot of the system
**before every package change**, so a bad update can be undone in one step.
Nothing to set up — it configures itself on the first boot after install,
and it's a no-op on ext4 installs.

## What's captured

Each snapshot is of the **root** subvolume: your programs (`/usr`),
system configuration (`/etc`), and the package database (`/var/lib`).

Your **personal files in `/home` are not part of a snapshot** — rolling
back never touches your documents. (`/home` is a separate subvolume.) The
kernel in `/boot` is on its own partition and isn't rolled back either, so
snapshots undo userspace/package breakage, not a bad kernel — for that,
pick an older kernel at the GRUB menu.

## Everyday use

```sh
argon-snapshot status          # is this on? how many kept?
argon-snapshot list            # every snapshot, newest last
sudo argon-snapshot create "before I try something"
```

## Rolling back a bad update

Two ways, safest first:

1. **Preview from the boot menu.** Reboot; in GRUB open
   *"Argon OS snapshots"* and boot a pre-update snapshot **read-only** to
   confirm it's the fix. Nothing is committed.
2. **Commit the rollback.** From the running system (or the previewed one):

   ```sh
   sudo argon-snapshot rollback <number>     # number from `argon-snapshot list`
   sudo reboot
   ```

   snapper snapshots the *current* state first, so the rollback is itself
   undoable.

## Tuning

Argon keeps the last 12 snapshots and prunes automatically; there's **no
background timer** (snapshots happen around `apt`, nothing runs when you're
not changing packages). Adjust limits in `/etc/snapper/configs/root`.

Under the hood this is [snapper](https://wiki.debian.org/Snapper) +
[grub-btrfs](https://github.com/Antynea/grub-btrfs) — standard, well-tested
tools; Argon just wires them up and snapshots on `apt`.
