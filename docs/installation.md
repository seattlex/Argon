# Installing Argon OS

## 1. Get and verify an image

Download the ISO plus its `.sha256` (and `.sha256.sig` for releases), then:

```sh
sha256sum -c argon-<version>-xfce-amd64.iso.sha256
gpg --verify argon-<version>-xfce-amd64.iso.sha256.sig   # releases only
```

Never install from an image that fails verification.

## 2. Write it to a USB stick

```sh
sudo dd if=argon-<version>-xfce-amd64.iso of=/dev/sdX bs=4M status=progress oflag=sync
```

(Replace `/dev/sdX` with the USB device, not a partition.)

## 3. Boot the live system

The image boots on both UEFI and legacy BIOS machines and takes you
**straight to the Argon desktop** — the live session logs in
automatically, no login screen (just like Kali or Mint). Nothing touches
your disks until you run the installer, and the installer is where you
create your own account.

> **UEFI machines: disable Secure Boot first** (firmware setup → Security).
> Argon's kernel follows Kali and is not Microsoft-signed, so with Secure
> Boot enabled the machine either refuses to boot the USB stick or refuses
> to boot the installed system. Signed-shim support is on the roadmap.

(If a login prompt ever does appear, the live account is `argon` /
`argon`. Automatic screen-locking is disabled in the live session so you
can't get locked out.)

The live session already runs with Argon defaults, so you can check the
hardware works — Wi-Fi (with a randomized MAC), display, sound — before
committing to an install.

## 4. Install

Double-click the **Install Argon OS** icon on the desktop (or launch it
from the menu, or the Welcome window). This starts the Calamares installer.

* **Erase disk** is the guided path. It creates a small unencrypted
  `/boot` plus the root filesystem (defaults to **Btrfs**), and offers
  **LUKS2 encryption** for everything but `/boot` — just set a passphrase.
  Use a long passphrase; it protects everything on the machine when
  powered off. (`/boot` stays unencrypted so GRUB can start the system —
  the same scheme Fedora and Ubuntu use; it contains only the kernel and
  boot assets, no personal data.)
* **Manual partitioning** supports Btrfs and EXT4, encrypted or not,
  and any layout you like. A 512 MB EFI system partition is required on
  UEFI machines.
* Swap defaults to a small swap partition; choose *swap (with hibernate)*
  if you want suspend-to-disk.
* No root account is created: the first user gets sudo. Autologin stays
  off; password quality is enforced.

After installation the live-only packages (Calamares, live-boot) are
removed from the target system, SSH host keys are regenerated on first
boot, and a fresh machine-id is generated — no two installs share any
identifier.

## 5. First boot checklist

Everything below is already on by default — this is a verification list,
not a to-do list:

```sh
sudo ufw status verbose          # firewall: deny incoming
sudo aa-status                   # AppArmor: profiles enforced
resolvectl status                # DNS: +DNSOverTLS, Quad9
systemctl status unattended-upgrades
chronyc -N authdata              # time sync: NTS authenticated
```

If you need remote access, opt in explicitly:

```sh
sudo systemctl enable --now ssh
sudo ufw allow in ssh
```
