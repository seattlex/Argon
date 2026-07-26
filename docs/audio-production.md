# Audio production on Argon (Voicemeeter, FL Studio, VSTs)

Two of the most-missed Windows audio tools are **Voicemeeter** and
**FL Studio**. Neither runs natively on Linux — but Argon can cover both
use cases well, because it ships **PipeWire**, a professional audio engine
that does what Voicemeeter does and more. This guide maps each Windows
workflow to its Argon equivalent.

Install everything mentioned here from **Argon Software → Creative &
Audio** (no terminal needed), or `apt install` the package names given.

---

## Replacing Voicemeeter

The closest single-app equivalent is **Pulsemeeter** — a Voicemeeter-style
graphical mixer with virtual inputs/outputs, per-channel routing and volume,
built for PipeWire. It's in the menu as **Pulsemeeter** (under Sound &
Video); the first launch installs it per-user (isolated, no root) and opens
it. That's the quickest way to get the Voicemeeter layout you're used to.

Under the hood Voicemeeter is really three things: **virtual cables**, a
**mixer/router**, and **effects** (EQ, compression). Pulsemeeter gives you
the first two in one window; the sections below show how to build the same
thing from PipeWire's own pieces (and where the effects come from) if you'd
rather assemble it yourself or go deeper.

### Virtual cables — built into Argon

Argon ships a helper that creates Voicemeeter-style virtual cables:

```sh
argon-virtual-audio enable        # create 2 virtual cables (A, B)
argon-virtual-audio enable 4      # create 4
argon-virtual-audio status
argon-virtual-audio disable
```

Each cable shows up as **both**:

* an **output** device apps can play *into* — "Argon Virtual Cable A", and
* an **input** device (its monitor) other apps can record *from*.

So you can, for example, send a game or browser into Cable A and pick
"Argon Virtual Cable A" as the "microphone" in OBS or a call — exactly
the Voicemeeter routing trick. It's per-user and needs no root.

### The mixer / router — qpwgraph

Install **qpwgraph** (a visual patchbay). Every app, device and cable is a
box with input/output ports; you drag connections between them. This is
the graphical routing surface Voicemeeter gives you, and more flexible.
**Helvum** is a simpler alternative.

### Effects — EasyEffects

Install **EasyEffects** for system-wide EQ, compressor, limiter, noise
reduction, gate, etc. on both outputs and your microphone — covering
Voicemeeter's built-in processing (and its "VoiceMeeter VAIO" mic
enhancements).

### Putting it together

1. `argon-virtual-audio enable`
2. Open **qpwgraph** and route sources → cables → your output/recorder.
3. Add **EasyEffects** on your mic or output chain.

That combination replaces a Voicemeeter Potato setup.

---

## Running FL Studio

FL Studio is a Windows application; Image-Line has stated it runs on Linux
via **Wine**, and in practice it works well.

1. Install Wine from **Creative & Audio → Wine** (or `apt install wine
   winetricks`).
2. Download the FL Studio installer (`.exe`) from image-line.com.
3. Run it: `wine ~/Downloads/flstudio_win64_*.exe` and follow the
   installer.
4. Launch FL Studio from the applications menu (Wine adds an entry) or:
   `wine "$HOME/.wine/drive_c/Program Files/Image-Line/FL Studio 21/FL64.exe"`.
5. For low-latency audio, in FL Studio's audio settings choose the
   **WASAPI** or **DirectSound** device that Wine exposes; Wine routes it
   to PipeWire. Lower the buffer until you hear glitches, then back off one
   step.

**Tips**

* Give Wine a dedicated prefix so audio experiments stay isolated:
  `WINEPREFIX="$HOME/.wine-flstudio" winecfg`, then use that prefix for the
  installer and FL.
* If audio stutters, see *Low-latency setup* below — realtime scheduling
  matters more than raw CPU here.

### Native alternative: LMMS

If you'd rather stay fully native, **LMMS** is free, pattern/step based,
and the closest tool in spirit to FL Studio — same channel-rack + piano-
roll workflow. **Ardour** is the choice for serious recording/mixing.

---

## VST plugins

There are two situations:

### VSTs inside FL Studio (running under Wine)

Because FL Studio is itself a Windows program here, it loads **Windows
VSTs** natively. Install the plugin's Windows installer into the *same
Wine prefix* as FL Studio:

```sh
WINEPREFIX="$HOME/.wine-flstudio" wine ~/Downloads/SomePlugin_installer.exe
```

Then add the install folder in FL Studio's *Plugin Manager* and rescan.
No bridge needed — it all lives inside Wine.

### Windows VSTs inside native Linux DAWs

To use Windows VSTs in **Ardour, Carla, LMMS**, etc., use **yabridge**,
which bridges Windows VST2/VST3/CLAP into native hosts. yabridge isn't in
the Debian/Kali archive, so install it from its official releases:

* Get the latest `yabridge-*.tar.gz` from
  <https://github.com/robbert-vdh/yabridge/releases>, extract to
  `~/.local/share/yabridge`, add that folder to your `PATH`.
* Point it at your Windows plugin folders:
  `yabridgectl add "$HOME/.wine/drive_c/Program Files/Common Files/VST3"`
  then `yabridgectl sync`.
* Your DAW now sees the Windows plugins alongside native ones.

**Carla** (in Creative & Audio) is the easiest host to test bridged
plugins in, and can itself act as a plugin inside another DAW.

### Native Linux plugins

Plenty of high-quality plugins run natively (LV2/VST3/CLAP) with zero
bridging — e.g. the **x42**, **Calf**, **LSP** and **Dragonfly** suites
(`apt install calf-plugins lsp-plugins x42-plugins dragonfly-reverb`).
These are the most reliable, lowest-latency option.

---

## Low-latency setup (pro audio)

PipeWire on Argon already uses **rtkit**, so audio threads get realtime
priority without extra configuration. To push latency lower:

* **Smaller quantum (buffer).** Temporarily:
  `pw-metadata -n settings 0 clock.force-quantum 256` (try 128 for less
  latency, 512 if you hear crackles). Make it permanent with a drop-in in
  `~/.config/pipewire/pipewire.conf.d/`.
* **Realtime limits.** Confirm your user can get realtime priority:
  `ulimit -r` should be non-zero. PipeWire/rtkit handles this; if a native
  DAW asks for JACK realtime, add your user to the `audio` group
  (`sudo usermod -aG audio $USER`, then re-log in).
* **JACK apps** work unchanged: install `pipewire-jack` and launch them
  with `pw-jack yourapp` — PipeWire pretends to be JACK.
* Prefer a wired audio interface over Bluetooth for monitoring; Bluetooth
  adds tens of milliseconds no OS can remove.

---

## Quick reference

| Windows | On Argon |
| --- | --- |
| Voicemeeter (whole app) | **Pulsemeeter** (menu → Sound & Video) |
| Voicemeeter virtual cables | `argon-virtual-audio enable` |
| Voicemeeter routing/mixer | qpwgraph (or Helvum) |
| Voicemeeter EQ/compression | EasyEffects |
| FL Studio | FL Studio via Wine, or LMMS (native) |
| VSTs in FL Studio | Windows VSTs inside the Wine prefix |
| VSTs in a native DAW | yabridge, or native LV2/VST3/CLAP plugins |
| ASIO low latency | PipeWire (rtkit) + small quantum; `pw-jack` for JACK apps |

Hit a snag? Open an issue at
<https://github.com/seattlex/argon/issues> with your interface, DAW and
what you tried.
