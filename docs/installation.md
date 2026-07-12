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

The image boots on both UEFI and legacy BIOS machines. The live session
logs in automatically as the `argon` user. Nothing touches your disks
until you run the installer.

The live session already runs with Argon defaults, so you can check the
hardware works — Wi-Fi (with a randomized MAC), display, sound — before
committing to an install.

## 4. Install

Launch **Install Argon OS** (Calamares) from the menu.

* **Erase disk** is the guided path. It defaults to **Btrfs** and offers
  **LUKS2 full-disk encryption** — just set a passphrase. Use a long
  passphrase; it protects everything on the machine when powered off.
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
