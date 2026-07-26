# The Wayland session (experimental)

Argon's default desktop is **XFCE on X11** — that's what boots, and it's
unchanged. For people who want Wayland, Argon also ships an optional,
**experimental** Wayland session you can pick at the login screen.

## Trying it

At the login screen, click the session chooser (usually a small icon near
the login button) and choose **"Argon (Wayland)"**, then log in. To go
back, log out and pick the normal XFCE session again — nothing is
committed by trying it.

## What you get

A small [labwc](https://labwc.github.io/) (wlroots) compositor with:

- the Argon wallpaper (via `swaybg`) and a [waybar](https://github.com/Alexays/Waybar) panel,
- **Super+D** app launcher (fuzzel), **Super+Enter** terminal,
- **Super+←/→** snap, **Super+↑** maximize, **Alt+F4** close,
- your network/Bluetooth/volume trays.

Most apps run fine (native Wayland where they support it, XWayland
otherwise).

## Why "experimental"

It's a minimal compositor, not a full desktop — expect rough edges
compared to XFCE (fewer settings GUIs, simpler panel), and some X11-only
tools behave differently under XWayland. It's here to use and give feedback
on, not yet as a daily driver. The default XFCE session is untouched and
remains the supported one.
