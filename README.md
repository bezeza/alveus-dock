# Alveus Dock

[![RPM build](https://github.com/bezeza/alveus-dock/actions/workflows/build-rpm.yml/badge.svg)](https://github.com/bezeza/alveus-dock/actions/workflows/build-rpm.yml)
[![License: GPL-3.0-only](https://img.shields.io/badge/License-GPL--3.0--only-blue.svg)](LICENSE)

Alveus Dock is a lightweight, standalone dock applet for KDE Plasma 6. It uses KDE's native TaskManager model for pinned launchers and running windows, then adds compact controls and short, configurable icon reactions.

It is an independent applet, not a patch or replacement for KDE's Icons-Only Task Manager. It can be used on its own or alongside other Plasma panel widgets.

> **Project status:** 0.3.0 dual-layer layout development branch, based on the 0.2.0 window-grouping work. Runtime testing in a live Plasma session is still required. CI checks do not replace testing in a running desktop session.

## Features

### Launchers and windows
- Pinned application launchers and running windows in one dock.
- Left-click activates a window; clicking the already-active window requests minimization.
- Middle-click requests a new application instance.
- Right-click offers pin/unpin, new instance and close actions.
- Drag icons to reorder tasks.
- Drop .desktop files or applications: URLs on the dock to pin launchers.
- Drop files onto a running application icon to open them with that application.
- Optional filtering to the current virtual desktop and current screen.
- Publishes running-window and grouped-task icon geometry to KDE TaskManager so KWin can target the Alveus icon for minimize effects such as Magic Lamp.
- Optional grouping of windows from the same application using KDE's native TaskManager model.
- Compact window chooser for grouped applications, with individual activate and close actions.
- Keyboard navigation in the chooser with Escape to close and Enter to activate the selected window.
- Configurable Single, Dual and Adaptive dock layouts.
- Dual layout separates pinned Quick Access launchers from Running Windows.
- Clicking a Quick Access launcher activates the most recently active matching window when the application is already running; otherwise it launches the application. A matching startup task suppresses duplicate launch requests.
- Horizontal panels use two rows; vertical panels use two columns.
- Adaptive layout hides the running-window layer when no windows are open.
- Running-window delegates preserve KDE's minimize-to-icon geometry for effects such as Magic Lamp.
- Window-count badge on grouped application icons and an ungroup action in the context menu.

### Motion and visual feedback
- Smooth hover scaling.
- Short elastic launch reaction.
- Expanding energy ring on launch.
- Finite attention pulse when an application requests attention.
- Active-window marker and startup busy indicator.
- Animations are event-driven and finite. There is no permanent animation loop.

KWin effects such as Magic Lamp remain KDE/KWin features and are not reimplemented by Alveus Dock. Alveus only publishes the geometry of its running-window delegates through the native TaskManager API; the effect itself remains under KWin's control.

### Settings
- Icon size, spacing and hover scale.
- Optional floating background.
- Active-window indicator.
- Launch bounce and energy pulse toggles.
- Attention reaction toggle.
- Drag-to-reorder toggle.
- Current-desktop and current-screen filters.
- Optional application grouping, disabled by default.
- Dock layout mode: Single, Dual or Adaptive.
- Independent icon sizes and spacing for Quick Access and Running Windows.
- Spacing between the two layers.

### Diagnostics
- Structured INFO, WARN and ERROR messages in the Plasma/Qt journal.
- A log collector for Alveus Dock and relevant Plasma/QML warnings.
- Logs intentionally avoid application names, window titles, file paths and dropped URLs.

See **docs/LOGGING.md**.

## Screenshots

Real screenshots have not been captured yet because the applet has not been run in a live KDE Plasma session. We will add screenshots after the first Fedora KDE runtime test rather than presenting a mockup as a real application screenshot.

See the **docs/SCREENSHOTS.md** capture checklist.

## Supported platform

- KDE Plasma 6.8 or newer.
- Fedora 44 or newer is the current RPM target.
- Wayland and X11 compatibility still need separate runtime verification.
- Windows is out of scope. Alveus Dock is a Plasma applet, not a cross-platform dock.

The RPM declares Plasma 6.8 as its minimum because the current development target is Plasma 6.8.x. Fedora 43 packages may carry an older Plasma version and therefore may not satisfy the dependency.

## Install on Fedora

### Install a locally built RPM

Install the build tools:

~~~bash
sudo dnf install rpm-build rpmdevtools
~~~

Build and install:

~~~bash
python3 scripts/check-package.py
bash scripts/build-rpm.sh
sudo dnf install ./rpmbuild/RPMS/noarch/alveus-dock-*.rpm
~~~

After installation, open the panel's **Add Widgets** menu and add **Alveus Dock**.

Remove it with:

~~~bash
sudo dnf remove alveus-dock
~~~

### Install from a DNF repository

The project does **not** have a published COPR repository yet, so the short command below is not active:

~~~bash
sudo dnf install alveus-dock
~~~

It will become available after a COPR project is created, the RPM is tested on a clean Fedora KDE installation, and the repository owner is added to **packaging/COPR.md**. Until then, use the local RPM instructions above or download the RPM artifact from GitHub Actions.

## Local development install

Install the KPackage command if it is not already present:

~~~bash
sudo dnf install kf6-kpackage
~~~

Install the applet for the current user:

~~~bash
bash scripts/install-local.sh
~~~

Remove the development install:

~~~bash
bash scripts/uninstall-local.sh
~~~

## Performance checks

To compare whole-shell CPU and memory before and after enabling the dock, see **docs/PERFORMANCE.md** and run `python3 scripts/profile-plasmashell.py`. The measurement covers the entire `plasmashell` process, not the dock alone.

## Build and validation

Run the structural checks and regression tests:

~~~bash
python3 scripts/check-package.py
python3 -m unittest discover -s tests -v
~~~

Build the RPM:

~~~bash
bash scripts/build-rpm.sh
~~~

GitHub Actions runs the structural checks, QML lint and RPM build on pushes, pull requests, tags and manual dispatch. The resulting RPM is uploaded as a workflow artifact.

A successful CI build confirms package structure and buildability. It does **not** prove that every interaction works in a live Plasma session.

## Repository map

- **package/** - Plasma applet metadata, QML UI, shared task delegate and settings.
- **packaging/** - Fedora RPM spec and COPR publication notes.
- **scripts/** - local install, uninstall, checks, RPM build and log collection.
- **docs/ROADMAP.md** - future work only.
- **docs/DEVELOPMENT_LOG.md** - dated engineering record.
- **CHANGELOG.md** - user-visible changes by version.
- **AGENTS.md** - rules for AI coding agents and contributors.

The roadmap, development log and changelog serve different purposes and must not be merged into one document.

## Project principles

- Use KDE/Plasma APIs for tasks, launchers and window actions.
- Keep the applet standalone and lightweight.
- Do not modify the stock Icons-Only Task Manager.
- Do not add a background daemon without a measured need.
- Prefer short, interruptible, event-driven animations.
- Keep diagnostic logs useful without recording private window or file data.
- Do not publish a package before runtime testing.

## License

Alveus Dock is licensed under **GNU GPL-3.0-only**. See **LICENSE**.
