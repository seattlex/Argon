# Security tooling

Argon does **not** preinstall security tools — the base image is a
privacy-hardened desktop, and images stay small and auditable. But Argon
is built on Kali rolling and keeps the full Kali archive enabled, so the
tooling ecosystem is one `apt install` away for people whose work needs
it (defenders, auditors, researchers operating with authorization).

## Installing tools

Individual tools:

```sh
sudo apt install nmap wireshark
```

Kali's curated metapackages also work — see the
[Kali metapackages documentation](https://www.kali.org/docs/general-use/metapackages/)
for the list (`kali-tools-*` by area, `kali-linux-default` for the
standard set). Install only what you need; each metapackage pulls in a
lot.

## Argon's stance

* Nothing in the base system depends on Kali's tool metapackages, so
  removing tools never breaks the OS.
* Tools that ship background services follow the same rule as everything
  else on Argon: **no service auto-enables**. Installing a package must
  not open a port.
* Argon's hardening (UFW deny-in, AppArmor, unattended upgrades) applies
  unchanged; some capture tools need firewall or group adjustments, which
  their Kali documentation covers.

## A note on responsibility

These tools are for systems you own or are explicitly authorized to
test. Unauthorized access to computer systems is illegal in Norway
(Straffeloven § 204/205), across the EU, and virtually everywhere else.
