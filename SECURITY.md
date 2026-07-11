# Security Policy

## Reporting a vulnerability

**Please do not report security vulnerabilities through public issues.**

Use GitHub's private vulnerability reporting on this repository
(*Security → Report a vulnerability*). You'll get an acknowledgment
within 72 hours and a status update at least every 7 days after that.

Please include: affected component (image build, a shipped default, a
package), reproduction steps, and impact as you understand it. Reports
in English or Norwegian are fine.

## Scope

In scope:

* Argon's shipped defaults (a hardening default that doesn't do what the
  docs claim is a security bug);
* the build pipeline and repository tooling (anything that could let a
  tampered artifact reach users);
* Argon's own packages.

Out of scope: vulnerabilities in upstream Kali/Debian packages — report
those upstream (we'll help route them if you're unsure), though we do
want to know if an Argon default makes an upstream issue worse.

## Supported versions

Argon is a rolling distribution: the latest weekly snapshot and the most
recent versioned release are supported. Fixes ship through the normal
update channel, which every install applies automatically.

## Disclosure

We practice coordinated disclosure: we'll agree on a timeline with you
(default 90 days, faster for actively exploited issues), credit you in
the changelog unless you prefer otherwise, and publish an advisory once
a fix has shipped.
