# Troubleshooting Argon OS

## "Verification failed: (0x1A) Security Violation" — the USB won't boot

**Symptom.** On a UEFI machine (MSI, ASUS, Gigabyte, most laptops) the
Argon USB refuses to start and the firmware shows:

```
Verification failed: (0x1A) Security Violation
```

**Your ISO is not corrupt.** This is UEFI **Secure Boot** rejecting
Argon's bootloader. Argon follows Kali: its boot chain and kernel are not
signed by a key your firmware trusts, so Secure Boot blocks it before the
OS gets a single instruction in.

**Fix: disable Secure Boot** in the firmware setup (usually
Del/F2 at power-on → *Security* or *Boot* → **Secure Boot → Disabled**;
on MSI boards it lives under *Settings → Advanced → Windows OS
Configuration → Secure Boot*). It must stay disabled for the installed
system too — re-enabling it later blocks the installed Argon the same way.

Dual-booters: disabling Secure Boot does not break Windows; BitLocker may
ask for its recovery key once after the change, so have it available.

Want Secure Boot *on* instead? Argon has an opt-in Machine Owner Key path —
see [secure-boot.md](secure-boot.md).

## Encrypted install: black/stuck screen at boot — where is the passphrase prompt?

An encrypted install **must ask for your passphrase at every boot** —
that screen appearing is the system working, not failing. If the boot
splash sits there and nothing seems to happen, the machine is almost
certainly *waiting at the passphrase prompt*:

* Type the passphrase and press Enter even if you see no prompt or no
  feedback, then give it a few seconds.
* Or press **Esc** to leave the graphical splash — the text console
  underneath shows the `Please unlock disk` prompt explicitly.

Images built before 2026-07-25 had a bug where the splash rendered the
prompt invisibly (the text plugin was missing from the image), which made
encrypted installs look like a hung boot. Current images render the
prompt; if you hit this, reinstall from the latest rolling ISO.

If the passphrase is accepted but boot still fails, boot the live USB,
and collect `/var/log/calamares/session.log` (if still present) plus a
photo of the failure for a bug report.

## Boot stops at a `(initramfs)` prompt

**Symptom.** The boot splash runs for a while, then the screen switches to:

```
BusyBox v1.xx.x (Debian 1:1.xx.x-1) built-in shell (ash)
Enter 'help' for a list of built-in commands.

(initramfs)
```

**What it means.** The early boot environment (the initramfs) could not
find the live filesystem on the medium you booted from. `live-boot` looks
for `/live/filesystem.squashfs`, retries for 60 seconds, then gives up and
drops you to this shell. It is not a corrupt install — the system never got
as far as starting.

The message explaining *why* is normally hidden behind the graphical splash,
which is what makes this look like a mystery crash.

### First: get the real error

Reboot and pick **"Start Argon OS (verbose — troubleshoot boot)"** from the
boot menu. That entry disables the splash and enables `live-boot` debugging,
so the failure is printed on screen instead of hidden.

### Second: identify the cause from the prompt

If you are already at `(initramfs)`, these four commands identify almost
every case:

```sh
cat /proc/cmdline     # is boot=live present?
blkid                 # is the USB stick visible at all?
ls /dev/sd* /dev/nvme*  # did any storage device appear?
dmesg | tail -40      # what did the kernel say about USB?
```

Read them like this:

| What you see | Cause | Fix |
| --- | --- | --- |
| `blkid` lists nothing resembling your USB stick | The kernel never saw the stick | Try a different port — a **USB 2 port** if you have one — and avoid hubs |
| The stick appears, but boot still failed | The live files are unreadable on it | Rewrite the stick (see below) |
| `boot=live` missing from `/proc/cmdline` | The stick was written by a tool that rebuilt the boot menu | Rewrite the stick with a byte-for-byte tool |

### Third: rewrite the USB stick correctly

This is the most common cause. Argon ships a *hybrid* ISO, which must be
written **byte for byte**, not extracted file-by-file.

* **balenaEtcher** — always correct, nothing to configure.
* **Rufus** — when it asks, choose **"Write in DD Image mode"**, *not*
  "ISO Image mode". ISO mode unpacks the image onto a FAT32 partition and
  rebuilds the boot menu, which can lose the boot parameters and cannot
  hold files larger than 4 GB.
* **Linux/macOS command line:**

  ```sh
  sudo dd if=argon-rolling-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync
  ```

  `/dev/sdX` is the **device** (`/dev/sdb`), never a partition (`/dev/sdb1`).

Verify the download before writing it — a truncated download fails in
exactly this way:

```sh
sha256sum -c argon-rolling-amd64.iso.sha256
```

### Other things worth trying

* **Use a different USB port.** USB 3 controllers on some laptops need
  drivers that only appear later in boot; a USB 2 port sidesteps this.
* **Disable Secure Boot** (firmware setup → Security). Argon follows Kali
  and ships an unsigned kernel.
* **Disable Fast Boot / "fast startup"** in the firmware, which can leave
  USB controllers powered down at boot.
* **Pick "Start Argon OS (failsafe)"** from the menu, which disables the
  power-management and graphics features that break some older machines.

## Screen goes black after the boot menu

Pick **"Start Argon OS (safe graphics)"**. This boots with `nomodeset`,
which avoids the kernel graphics driver that some hybrid-GPU laptops and
older Intel chips do not tolerate. Once you are on the desktop, the
installed system can use the proper driver.

## The installer fails at the bootloader step

Make sure Secure Boot is disabled, and use the **Erase disk** path, which
creates the separate unencrypted `/boot` partition that GRUB needs. See
[installation.md](installation.md).

If it still fails, the installer keeps a full log at
`/var/log/calamares/session.log` in the live session — attach it to a bug
report.

## Reporting a problem

Open an issue at <https://github.com/seattlex/argon/issues> with:

* what you see on screen (a photo of the failure is fine),
* the output of the four diagnostic commands above, if you reached a prompt,
* the machine (make/model), whether it booted UEFI or legacy BIOS, and
* how you wrote the USB stick.
