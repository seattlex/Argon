# Security tooling

The **standard Argon edition** does not preinstall security tools — the
base image is a privacy-hardened desktop, and images stay small and
auditable. But Argon is built on Kali rolling and keeps the full Kali
archive enabled, so the tooling ecosystem is one `apt install` away for
people whose work needs it (defenders, auditors, researchers operating
with authorization).

## Argon Security Edition

For people who want the tools out of the box, the **Security Edition** is
the same OS — identical privacy and hardening defaults — with Kali's
standard tool selection (`kali-linux-default`: nmap, Wireshark,
Metasploit, Burp Suite, sqlmap, John, hydra, aircrack-ng, …)
preinstalled. The tools come unmodified from the same Kali repositories.

* Build it yourself: `sudo ./scripts/build-iso.sh --variant security`
* CI: run the *Build ISO* workflow with variant `security`. The image
  exceeds GitHub's 2 GiB release-asset limit, so it is published in
  `.part*` pieces — download all parts and `cat` them back together (the
  release notes show the exact command).
* Argon's no-listening-services rule still applies: the tools are
  installed, nothing is started or exposed.

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
