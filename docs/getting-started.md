# Getting started with Argon OS

New to Linux? This guide takes you from "I have another computer" to a
running Argon desktop. You do **not** need Kali, Linux, or the command
line to do any of this.

## What you need

* A USB stick, 8 GB or larger (its contents will be erased).
* The computer you want to install Argon on.
* 20 minutes.

## Step 1 — Download the ISO

An **ISO** is a single file containing the whole operating system.

1. Go to the [Argon releases page](https://github.com/seattlex/argon/releases).
2. Download the newest `argon-…-xfce-amd64.iso`.
3. Download the matching `….iso.sha256` file next to it (you'll use it in
   the next step to confirm the download isn't corrupted).

You don't build anything and you don't need Kali — the ISO is produced
automatically and published for you.

## Step 2 — Check the download (optional but recommended)

This proves the file arrived intact.

* **Windows:** open PowerShell, run `Get-FileHash argon-*.iso`, and check
  the result matches the text inside the `.sha256` file.
* **macOS/Linux:** run `sha256sum -c argon-*.iso.sha256` in the download
  folder — it should say `OK`.

For official releases you can also verify the GPG signature — see
[reproducible-builds.md](reproducible-builds.md).

## Step 3 — Write the ISO to the USB stick

Use **[balenaEtcher](https://etcher.balena.io/)** — it's free, works on
Windows, macOS and Linux, and is hard to get wrong:

1. Install and open Etcher.
2. *Flash from file* → pick the Argon ISO.
3. *Select target* → pick your USB stick (double-check it's the right one).
4. *Flash!* and wait.

## Step 4 — Boot from the USB stick

1. Leave the USB stick plugged in and restart the computer.
2. Open the boot menu — tap the boot-menu key right after powering on.
   It's usually **F12**, sometimes **F9**, **F10**, **Esc**, or **F2**
   (the screen often shows which for a moment).
3. Choose the USB stick from the list.

You'll see the **Argon boot menu**. Just press Enter on *Start Argon OS
(live)*. If the screen looks broken or won't start, reboot and choose
*safe graphics* instead.

## Step 5 — Try it, then install

Argon now runs **entirely from the USB stick** — nothing on the computer
has been touched yet. This is the *live* session: login happens
automatically, and you can test that Wi-Fi, sound and the display all
work.

> **Live login:** if you're ever asked for a password in the live session
> (for example to install something), it's username **`argon`**, password
> **`argon`**. This is only the throwaway demo account — when you install
> Argon you create your own username and password.

The **Welcome** window opens automatically. When you're ready:

1. Click **Install Argon OS**.
2. Follow the steps: language → keyboard → **where to install**.
   * The simple choice is *Erase disk*, which also offers
     **encryption** — turn it on and pick a strong passphrase so your
     data is protected if the machine is lost or stolen. Write that
     passphrase down somewhere safe; it cannot be recovered.
3. Create your username and password (this account can administer the
   system; there's no separate "root" login to worry about).
4. Let it finish, remove the USB stick, and reboot.

## Step 6 — Your first login

Everything is already secured — there's nothing you must configure. The
**Welcome** window's *Your Privacy Defaults* button shows what's already
protecting you.

To add programs, open **Argon Software** (in the menu, or from Welcome).
Browse a category or search, click **Install**, and enter your password
when asked. No terminal required.

## Common questions

**Can I keep Windows and use Argon too?**
Yes — that's "dual boot". Choose *Install alongside* (or manual
partitioning) in the installer instead of *Erase disk*. If you're new,
practising in the live session or a virtual machine first is wise.

**Is the live USB safe to try?**
Yes. Until you run the installer and choose a disk, nothing on the
computer is changed.

**Where are the security tools Kali is known for?**
The whole Kali software archive is available. Defensive and analysis
tools (network inspection, auditing, forensics) are in **Argon
Software** under *Security & Analysis*; the wider toolset can be
installed as described in [security-tools.md](security-tools.md).

**Something went wrong.**
Open an issue at
[github.com/seattlex/argon/issues](https://github.com/seattlex/argon/issues)
— include what you did and what happened.
