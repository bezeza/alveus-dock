# Alveus Dock — Roadmap

This document contains **future work only**. Completed changes belong in CHANGELOG.md; dated engineering activity belongs in DEVELOPMENT_LOG.md.

## Product direction

Build a small, responsive KDE Plasma dock that feels more expressive than Icons-Only Task Manager without becoming a resource-heavy desktop environment of its own.

## Next: 0.1.x stabilization (0.1.3)

- [ ] Run the applet in a clean Fedora 44 KDE Plasma 6.8.x session.
- [ ] Compare whole-shell CPU/RSS samples with Alveus Dock disabled and enabled using docs/PERFORMANCE.md.
- [ ] Resolve all QML parser, import and runtime warnings in a live Plasma session.
- [ ] Verify launcher pinning, unpinning and persistence after Plasma restart.
- [ ] Verify activation, minimizing, close and new-instance actions.
- [ ] Verify KWin minimize animations target Alveus task icons via published delegate geometry on X11 and Wayland.
- [ ] Verify internal drag/reorder and external .desktop launcher drops.
- [ ] Verify file drops onto running application windows.
- [ ] Verify current-desktop and current-screen filters.
- [ ] Verify appearance and behavior settings persist after logout/login.
- [ ] Test install, upgrade and removal using the built RPM.
- [ ] Confirm package dependencies on a clean Fedora installation.
- [ ] Capture genuine application screenshots for the README.

**Exit criteria:** the core interactions work without QML runtime errors; the applet installs and removes cleanly; no critical performance regression is observed.

## 0.2.0 — window and task experience

- [ ] Runtime-test grouped window activation, close and ungroup actions on X11 and Wayland.
- [ ] Test chooser placement on all four panel edges and vertical panels.
- [ ] Evaluate KDE-supported window previews on hover.
- [ ] Complete keyboard navigation and focus handling across the full dock.
- [ ] Verify task switching across virtual desktops and monitors.

**Exit criteria:** grouping, choosing, activating and closing windows works without stale delegates, wrong-window activation or excessive CPU usage.

## 0.3.0 — dual-layer dock

- [ ] Test Single, Dual and Adaptive modes in a live Plasma panel.
- [ ] Verify pinned launchers remain independent from running windows.
- [ ] Verify launcher reorder persists and cannot move windows into the launcher layer.
- [ ] Verify grouping, Window Chooser and Magic Lamp work in the running layer.
- [ ] Test horizontal two-row and vertical two-column layouts, including panel thickness constraints.
- [ ] Compare CPU/RSS in Single, Dual and Adaptive modes.
- [ ] Capture genuine screenshots of both orientations and all three modes.

**Exit criteria:** both layers show the correct model items, switching layouts does not lose launcher order, and the panel does not clip the dock at supported sizes.

## 0.4.0 — Alveus motion identity

- [ ] Add a liquid-style active-window indicator.
- [ ] Evaluate magnetic spacing between nearby icons.
- [ ] Add a short domino/wave reaction on application launch.
- [ ] Add optional per-effect controls for bounce, pulse and attention reactions.
- [ ] Add a reduced-motion mode.
- [ ] Tune effects for low CPU/GPU overhead and interruptibility.

**Exit criteria:** all effects are finite, interruptible, respect reduced-motion settings and do not cause visible lag during normal desktop use.

## 0.5.0 — polish and compatibility

- [ ] Finish horizontal and vertical layout behavior.
- [ ] Test Wayland and X11 separately where supported.
- [ ] Test multiple monitors, fractional scaling and panel-edge placement.
- [ ] Test Plasma restart, logout/login and configuration persistence.
- [ ] Complete English, Ukrainian and Russian translations.
- [ ] Add verified screenshots, icon assets and user documentation.
- [ ] Verify clean install, upgrade and removal paths.
- [ ] Document supported Fedora/Plasma combinations.

**Exit criteria:** the published compatibility matrix matches real test results and no known critical defects remain.

## 0.6.0 — multiple dock instances and bookmark panels

- [ ] Verify how Plasma handles multiple instances of the Alveus Dock applet in the same or different containments, including per-instance configuration and persistence; confirm the supported behavior before implementation.
- [ ] Support multiple independent Alveus Dock instances on one desktop, placed on different panel edges through native Plasma containment placement.
- [ ] Give each instance its own content profile: **Applications** (Quick Access + Running Windows), **Bookmarks** (web links, files and folders), or **Hybrid** (both).
- [ ] Keep the KDE TasksModel dedicated to application launchers and running windows; implement bookmark items in a separate model so URLs and files never enter task/window handling.
- [ ] Isolate each instance's content list and settings: profile, items, order, grouping, icon size, labels, spacing, background/transparency and relevant task filters.
- [ ] Add bookmark entries for web URLs, local files and directories, opening each through the user's default application or handler.
- [ ] Support bookmark groups/folders, separators, rename, remove, custom icons and drag-to-reorder.
- [ ] Support drag-and-drop to add URLs, files and folders to a Bookmarks Dock, while preserving the existing .desktop/application pinning flow for Applications Dock.
- [ ] Allow labels to be shown or hidden and provide configurable overflow/scrolling for long vertical and horizontal bookmark lists.
- [ ] Verify that creating, moving, configuring or removing one dock instance does not change another instance's content or settings.
- [ ] Test persistence after Plasma restart, panel relocation, multiple monitors and fractional scaling; verify Magic Lamp still targets only running-window delegates.
- [ ] Compare CPU/RSS with one and multiple instances and ensure no polling loop or unnecessary background service is introduced.

**Exit criteria:** a user can run an Applications Dock at the bottom and a separate Bookmarks Dock on a side edge, each with independent content and settings; both survive Plasma restart and behave correctly without regressions to task grouping, window activation or Magic Lamp geometry.

## 0.7.0 — customizable bookmark folder expansion

- [ ] Build a reusable folder-popup controller anchored to the source bookmark icon.
- [ ] Implement Grid as the default folder view, with per-folder style persistence.
- [ ] Implement List and Category tree as the first practical alternatives.
- [ ] Add edge-aware popup placement for bottom, top, left and right docks; keep the full popup within the active screen work area.
- [ ] Add mouse, touchpad and keyboard navigation, including Enter/Space, Escape, outside-click close and predictable focus restoration.
- [ ] Add per-folder controls for icon size, columns, labels, spacing, animation speed, opening direction and opacity.
- [ ] Add reduced-motion support and make animations optional, short and interruptible.
- [ ] Test realistic folders with 5, 12 and 30+ items; use scrolling or pagination instead of shrinking icons indefinitely.
- [ ] Add Radial/Fan, Carousel and Large Tiles as follow-up styles after the base interaction passes live KDE usability tests.
- [ ] Keep Ring, Widget Panel and Combined View experimental until testing proves they improve findability without clutter.
- [ ] Verify that two folders can use different styles and settings simultaneously and that each persists after Plasma restart.
- [ ] Test nested folders, all four dock edges, multiple monitors and fractional scaling.

**Exit criteria:** each folder can independently open in its configured style; popups remain on-screen, are usable with pointer and keyboard, respect reduced motion and preserve their configuration across Plasma restarts.

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
