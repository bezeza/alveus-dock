# Alveus Dock — Roadmap

**Product goal:** a small, responsive, standalone KDE Plasma dock for Fedora
KDE. It should feel more expressive than Icons-Only Task Manager without
becoming a resource-heavy desktop environment of its own.

**Design rules**
- Use KDE/Plasma APIs for windows, launchers and KWin effects.
- Keep the applet standalone; do not patch the stock Task Manager.
- No resident daemon unless a measured feature absolutely requires one.
- Prefer event-driven animations; no infinite animation loops.
- Keep logs privacy-conscious and useful for debugging.
- Do not publish a Fedora COPR package before real runtime testing.

## Release status

| Version | Scope | Status |
|---|---|---|
| 0.1.0 | Standalone applet skeleton, basic tasks and RPM layout | Source prepared; runtime test pending |
| 0.1.1 | Drag/drop and first interactions | Prototype; runtime test pending |
| 0.1.2 | Diagnostics, project logs, roadmap and static fixes | Source prepared; runtime test pending |
| 0.2.0 | Grouped windows and window chooser | Planned |
| 0.3.0 | Signature animations and motion settings | Planned |
| 0.4.0 | Stability, performance, accessibility and packaging | Planned |
| 1.0.0 | First stable Fedora release | Not started |

## 0.1.x — foundation and observability

- [x] Standalone Plasma applet package structure.
- [x] KDE TaskManager model integration prototype.
- [x] Basic activate/minimize/close and launcher actions.
- [x] First finite launch and attention reactions.
- [x] RPM spec and CI workflow skeleton.
- [x] Changelog and development journal.
- [x] Runtime diagnostic messages and journal collector.
- [ ] QML lint and real Plasma 6.8.2 runtime validation.
- [ ] Verify task drag/reorder and external launcher drops.
- [ ] Verify install, upgrade and removal using a built RPM.
- [ ] Confirm Fedora runtime dependency names.

**Exit criteria:** no QML runtime errors in the core flows; applet can be
installed and removed cleanly; logs can identify a failed action without
recording private window or file data.

## 0.2.0 — task and window experience

- [ ] Group multiple windows from the same application.
- [ ] Show a compact window chooser when a grouped icon is clicked.
- [ ] Add window previews on hover, using KDE-supported APIs.
- [ ] Show a count indicator for multiple windows.
- [ ] Improve keyboard navigation and focus handling.
- [ ] Verify task switching across virtual desktops and monitors.

**Exit criteria:** grouping, choosing, activating and closing windows works
without stale delegates, wrong-window activation or excessive CPU usage.

## 0.3.0 — Alveus motion identity

- [ ] Liquid-style active-window indicator.
- [ ] Magnetic spacing between nearby icons.
- [ ] Short domino/wave reaction on application launch.
- [ ] Optional bounce, pulse and attention effects.
- [ ] Reduced-motion mode and per-effect toggles.
- [ ] Tune all effects for low CPU/GPU overhead.

**Exit criteria:** effects are finite, interruptible, respect reduced-motion
settings and do not cause visible lag during normal desktop use.

## 0.4.0 — polish and compatibility

- [ ] Finish horizontal and vertical layouts.
- [ ] Test Wayland and X11 where supported.
- [ ] Test multiple monitors, fractional scaling and panel edge placement.
- [ ] Test Plasma restart, logout/login and configuration persistence.
- [ ] Complete English, Ukrainian and Russian translations.
- [ ] Add application icon, screenshots and user documentation.
- [ ] Verify clean install, upgrade, downgrade policy and removal.
- [ ] Verify RPM dependencies on the target Fedora release.

**Exit criteria:** repeatable test checklist passes on the supported Fedora
Plasma target and no known critical defects remain.

## 1.0.0 — stable Fedora package

- [ ] Tag a stable release.
- [ ] Build RPM in CI.
- [ ] Test package in a clean Fedora KDE environment.
- [ ] Publish COPR repository and exact DNF commands.
- [ ] Publish release notes and troubleshooting guide.

## Explicitly out of scope for the first release

- Windows support.
- A Rust daemon or separate background service.
- Replacing KWin or reimplementing KDE window effects.
- Bundling a full desktop shell or application launcher.
