# Security defaults

Argon's threat model is a personal machine that should (a) expose zero
network surface out of the box, (b) limit what a compromised application
can do, and (c) stay patched without user attention. Everything here ships
enabled; each section says where the config lives and how to override it.

## Firewall (UFW)

Default policy: **deny incoming, allow outgoing**, IPv6 included.
Configured at image build time (`hooks/normal/0200-argon-services.hook.chroot`).

```sh
sudo ufw status verbose
sudo ufw allow in ssh        # example: opt into an inbound service
```

## AppArmor

Enabled on the kernel command line (`apparmor=1 security=apparmor`) with
`apparmor-profiles` installed and enforced.

```sh
sudo aa-status
```

## No listening services

`ss -tlnp` on a fresh install shows nothing listening externally. Installed
but **disabled**: `ssh`, `tor`, `cups`, `avahi`, `bluetooth`. Enable what
you use (`systemctl enable --now <svc>`), and remember to open the
firewall port too.

sshd, when you enable it, is pre-hardened
(`/etc/ssh/sshd_config.d/99-argon-hardening.conf`): no root login,
**keys only** (password auth off), modern ciphers/KEX, ed25519 host keys.
Host keys are generated per-machine on first boot, never shipped in the
image (`argon-firstboot.service`).

## fail2ban

Enabled with the `sshd` jail active (`/etc/fail2ban/jail.local`):
3 failures in 10 minutes → 1 hour ban, doubling for repeat offenders,
enforced through UFW.

## Automatic security updates

`unattended-upgrades` runs daily against the Kali and Argon origins
(`/etc/apt/apt.conf.d/52argon-unattended-upgrades`). Reboots are never
automatic; `needrestart` tells you when one is due.

## Kernel hardening

`/etc/sysctl.d/99-argon-hardening.conf` — commented inline. Highlights:
kernel pointer/dmesg restriction, unprivileged eBPF off, Yama ptrace
scoping, kexec disabled, protected symlinks/hardlinks/FIFOs, reverse-path
filtering, no redirects, SYN cookies, TCP timestamps off.

Deliberately **not** restricted: unprivileged user namespaces — browser
and Flatpak sandboxes depend on them, and on a desktop the sandbox is
worth more than the attack-surface reduction.

To override anything: drop a file that sorts later, e.g.
`/etc/sysctl.d/99-local.conf`; don't edit Argon's file (upgrades replace it).

## Login policy

No root account (sudo-only administration), no autologin, login screen
hides the user list, no guest sessions, weak passwords rejected by the
installer.
