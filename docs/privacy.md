# Privacy defaults

Argon ships **zero telemetry**: no component of the OS phones home, and
the defaults below minimize what third parties on the network path can
learn. Each section notes the config file so you can audit or change it.

## DNS

All system DNS goes through systemd-resolved with **DNS-over-TLS** to
Quad9 (primary) and Mullvad (fallback), DNSSEC in allow-downgrade mode,
and mDNS/LLMNR disabled (`/etc/systemd/resolved.conf.d/argon-dns.conf`).

```sh
resolvectl status    # expect: +DNSOverTLS, DNS=9.9.9.9#dns.quad9.net
```

Firefox additionally does its own **DNS-over-HTTPS** to Quad9 (see below),
so browser lookups are encrypted even on networks that block port 853.

## MAC address randomization

`/etc/NetworkManager/conf.d/99-argon-privacy.conf`:

* **Scanning**: fully random MAC — an idle laptop is not trackable
  across locations.
* **Connected**: "stable" random — a distinct MAC per network (no
  cross-network correlation) that stays constant within one network
  (captive portals and DHCP reservations keep working).
* Hostname is never sent to DHCP servers; IPv6 privacy addresses are
  preferred.

For a new MAC on *every* connect, change `cloned-mac-address` to `random`.

## Browser

Firefox ESR is policy-hardened system-wide
(`/usr/lib/firefox-esr/distribution/policies.json`):

* telemetry, studies, Pocket, sponsored content: **off** (locked where
  Mozilla allows);
* tracking protection: strict (trackers, cryptominers, fingerprinters);
* HTTPS-Only mode on; DNS-over-HTTPS to Quad9; Global Privacy Control on;
* uBlock Origin pre-installed; DuckDuckGo default search;
* users can still change any of it — policies set defaults, they don't
  take freedom away.

## Time synchronization

chrony with **NTS** (authenticated NTP, RFC 8915) against Cloudflare,
Netnod and PTB (`/etc/chrony/conf.d/argon-nts.conf`). Verify:
`chronyc -N authdata`.

## Metadata

`mat2` is installed for stripping metadata from documents and images
before sharing: `mat2 --inplace file.jpg`, or via the file manager.

## Tor

Tor is installed but **off** (it draws attention on some networks and
should be a choice): `sudo systemctl enable --now tor`, then
`torsocks <app>` or configure a proxy. `torbrowser-launcher` is available
from the repositories for browsing.

## Honest limitations

Privacy defaults reduce, not eliminate, exposure:

* your IP address is visible to every service you contact (use Tor or a
  VPN — WireGuard and OpenVPN are preinstalled — when that matters);
* DoT/DoH hide DNS *contents*, but TLS SNI still reveals hostnames to
  the network path unless ECH is negotiated;
* the resolver operators (Quad9/Mullvad) see your queries — they are
  chosen for no-logging policies, and you can switch resolvers in one file.
