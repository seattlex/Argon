# UEFI Secure Boot on Argon

**Out of the box, Secure Boot must be off.** Argon follows Kali and ships an
unsigned kernel, so with Secure Boot enabled the firmware refuses the USB
stick (*"Verification failed: (0x1A) Security Violation"*) and, after
install, the system. See [troubleshooting.md](troubleshooting.md) for the
firmware steps to disable it.

If you *want* Secure Boot on, Argon ships an opt-in path using a **Machine
Owner Key (MOK)** — a key that belongs to your machine, which you enrol
once. This is **experimental**; read this through before starting.

## What it does

`sudo argon-secureboot-setup`:

1. installs Debian's Microsoft-signed **shim** and **signed GRUB** (shim is
   trusted by firmware and validates what it boots),
2. generates a key unique to this machine,
3. signs your installed kernel with it — and a kernel hook re-signs future
   kernel updates automatically,
4. enrols the key with `mokutil` (you set a one-time password).

Nothing about how the machine boots changes until you finish the steps
below, so it's safe to run ahead of time.

## Turning it on

```sh
sudo argon-secureboot-setup
```

Then:

1. **Reboot.** A blue *"MOK Management"* screen appears. Choose
   **Enroll MOK → Continue → Yes**, enter the password you just set, and
   reboot again. (If you miss it, re-run the command — nothing is lost.)
2. **Enter firmware setup** (Del/F2 at power-on) and set **Secure Boot →
   On**.

Your machine now boots with Secure Boot, trusting your own key.

## Turning it back off

```sh
sudo mokutil --delete /var/lib/argon/secureboot/MOK.der   # then confirm at reboot
```

and set Secure Boot back to Off in firmware.

## Why not signed out of the box?

That needs a kernel signed by a key already in every machine's firmware —
i.e. Microsoft's — which means getting Argon's boot chain through
Microsoft's signing, or shipping a distro-signed kernel. Both are on the
roadmap; the MOK path above is the honest interim that works on your
hardware today without trusting anyone else's key.
