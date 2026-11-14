# Alveus Dock — Roadmap

This document contains **future work only**. Completed changes belong in CHANGELOG.md; dated engineering activity belongs in DEVELOPMENT_LOG.md.

## Product direction

Build a small, responsive KDE Plasma dock that feels more expressive than Icons-Only Task Manager without becoming a resource-heavy desktop environment of its own.

## Next: 0.1.x stabilization

- [ ] Run the applet in a clean Fedora 44 KDE Plasma 6.8.x session.
- [ ] Resolve all QML parser, import and runtime warnings.
- [ ] Verify launcher pinning, unpinning and persistence after Plasma restart.
- [ ] Verify activation, minimizing, close and new-instance actions.
- [ ] Verify internal drag/reorder and external .desktop launcher drops.
- [ ] Verify file drops onto running application windows.
- [ ] Verify current-desktop and current-screen filters.
- [ ] Verify appearance and behavior settings persist after logout/login.
- [ ] Test install, upgrade and removal using the built RPM.
- [ ] Confirm package dependencies on a clean Fedora installation.
- [ ] Capture genuine application screenshots for the README.

**Exit criteria:** the core interactions work without QML runtime errors; the applet installs and removes cleanly; no critical performance regression is observed.

## 0.2.0 — window and task experience

- [ ] Add optional grouping of windows from the same application.
- [ ] Add a compact window chooser for grouped tasks.
- [ ] Evaluate KDE-supported window previews on hover.
- [ ] Add a window-count indicator.
- [ ] Improve keyboard navigation and focus handling.
- [ ] Verify task switching across virtual desktops and monitors.

**Exit criteria:** grouping, choosing, activating and closing windows works without stale delegates, wrong-window activation or excessive CPU usage.

## 0.3.0 — Alveus motion identity

- [ ] Add a liquid-style active-window indicator.
- [ ] Evaluate magnetic spacing between nearby icons.
- [ ] Add a short domino/wave reaction on application launch.
- [ ] Add optional per-effect controls for bounce, pulse and attention reactions.
- [ ] Add a reduced-motion mode.
- [ ] Tune effects for low CPU/GPU overhead and interruptibility.

**Exit criteria:** all effects are finite, interruptible, respect reduced-motion settings and do not cause visible lag during normal desktop use.

## 0.4.0 — polish and compatibility

- [ ] Finish horizontal and vertical layout behavior.
- [ ] Test Wayland and X11 separately where supported.
- [ ] Test multiple monitors, fractional scaling and panel-edge placement.
- [ ] Test Plasma restart, logout/login and configuration persistence.
- [ ] Complete English, Ukrainian and Russian translations.
- [ ] Add verified screenshots, icon assets and user documentation.
- [ ] Verify clean install, upgrade and removal paths.
- [ ] Document supported Fedora/Plasma combinations.

**Exit criteria:** the published compatibility matrix matches real test results and no known critical defects remain.

## 1.0.0 — stable Fedora release

- [ ] Tag a stable release.
- [ ] Build and verify RPMs in CI.
- [ ] Test the package in a clean Fedora KDE environment.
- [ ] Create and publish the COPR repository.
- [ ] Verify the public DNF installation and removal commands.
- [ ] Publish release notes and a troubleshooting guide.

## Explicit non-goals for the first stable release

- Windows support.
- A Rust daemon or separate resident background service.
- Replacing KWin or reimplementing KDE window effects.
- Bundling a desktop shell or a second application launcher.
- Patching the stock Icons-Only Task Manager.
