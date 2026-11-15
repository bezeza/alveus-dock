# Alveus Dock — Roadmap

This document contains **future work only**. Completed changes belong in CHANGELOG.md; dated engineering activity belongs in DEVELOPMENT_LOG.md.

## Product direction

Build a small, responsive KDE Plasma dock that feels more expressive than Icons-Only Task Manager without becoming a resource-heavy desktop environment of its own.

## Next: 0.1.x stabilization (0.1.3)

Tracking: [GitHub Issue #2](https://github.com/bezeza/alveus-dock/issues/2).

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

Tracking: [GitHub Issue #4](https://github.com/bezeza/alveus-dock/issues/4).

- [ ] Runtime-test grouped window activation, close and ungroup actions on X11 and Wayland.
- [ ] Test chooser placement on all four panel edges and vertical panels.
- [ ] Evaluate KDE-supported window previews on hover.
- [ ] Complete keyboard navigation and focus handling across the full dock.
- [ ] Verify task switching across virtual desktops and monitors.

**Exit criteria:** grouping, choosing, activating and closing windows works without stale delegates, wrong-window activation or excessive CPU usage.

## 0.3.0 — dual-layer dock

Tracking: [GitHub Issue #5](https://github.com/bezeza/alveus-dock/issues/5).

- [ ] Test Single, Dual and Adaptive modes in a live Plasma panel.
- [ ] Verify pinned launchers remain independent from running windows.
- [ ] Verify launcher reorder persists and cannot move windows into the launcher layer.
- [ ] Verify grouping, Window Chooser and Magic Lamp work in the running layer.
- [ ] Test horizontal two-row and vertical two-column layouts, including panel thickness constraints.
- [ ] Compare CPU/RSS in Single, Dual and Adaptive modes.
- [ ] Capture genuine screenshots of both orientations and all three modes.

**Exit criteria:** both layers show the correct model items, switching layouts does not lose launcher order, and the panel does not clip the dock at supported sizes.

## 0.4.0 — Alveus motion identity

Tracking: [GitHub Issue #12](https://github.com/bezeza/alveus-dock/issues/12).

- [ ] Add a liquid-style active-window indicator.
- [ ] Evaluate magnetic spacing between nearby icons.
- [ ] Add a short domino/wave reaction on application launch.
- [ ] Add optional per-effect controls for bounce, pulse and attention reactions.
- [ ] Add a reduced-motion mode.
- [ ] Tune effects for low CPU/GPU overhead and interruptibility.

**Exit criteria:** all effects are finite, interruptible, respect reduced-motion settings and do not cause visible lag during normal desktop use.

## 0.5.0 — polish and compatibility

Tracking: [GitHub Issue #13](https://github.com/bezeza/alveus-dock/issues/13).

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

Tracking: [GitHub Issue #7](https://github.com/bezeza/alveus-dock/issues/7).

- [ ] Verify how Plasma handles multiple instances of the Alveus Dock applet in the same or different containments, including per-instance configuration and persistence; confirm the supported behavior before implementation.
- [ ] Support multiple independent Alveus Dock applet instances on one desktop. Users create and place instances through native Plasma panel/widget controls; Alveus Dock does not create or manage Plasma containments.
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

Tracking: [GitHub Issue #8](https://github.com/bezeza/alveus-dock/issues/8).

- [ ] Build a reusable **flyout folder popup** anchored to the source bookmark icon. Activating a folder in Quick Access opens a temporary floating panel beside/above/below that icon; this is not a permanently visible Folder Portal.
- [ ] Make the flyout the default folder interaction: clicking/tapping the same folder toggles it closed; opening another folder closes the previous popup; outside click and Escape close it; focus returns to the source folder.
- [ ] Open nested folders inside the same flyout, with a visible breadcrumb and Back/Up action; do not spawn a separate window for each folder level. Selecting a bookmark opens it through the system's default handler.
- [ ] Choose the opening direction from the dock edge (bottom → up, top → down, left → right, right → left), then flip/clamp the popup when needed so it remains inside the active screen work area; allow a per-folder direction override.
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

## 0.8.0 — content management and data portability

Tracking: [GitHub Issue #9](https://github.com/bezeza/alveus-dock/issues/9).

- [ ] Build an editor for the current applet instance's content: add, rename, remove, reorder, group, choose icons and edit item properties.
- [ ] Add search across bookmark titles and targets, plus filters by item type and folder/category.
- [ ] Add sorting by manual order, title and type; preserve manual order when returning from a temporary sort.
- [ ] Add optional favorites and recently used items, including a clear history opt-out.
- [ ] Add duplicate detection and an explicit user-controlled duplicate policy; never silently delete or merge user entries.
- [ ] Define a versioned, validated bookmark export format and preview imports before applying them.
- [ ] Add backup, restore and recovery from a previous known-good collection.
- [ ] Add safe import/export for one applet instance at a time, with explicit handling for duplicates and missing targets.
- [ ] Add schema migrations with a backup before migration and rollback if validation or persistence fails.
- [ ] Verify writes are atomic or recoverable; a failed import must not partially overwrite the current collection.
- [ ] Add saved dock presets for content and appearance without claiming to create, move or configure Plasma panels.
- [ ] Test large collections and ensure editing/search does not block the QML/UI thread.

**Exit criteria:** users can manage and search a bookmark collection, export and restore it safely, migrate supported schema versions, and cannot accidentally overwrite another applet instance's data.

## 0.9.0 — security, accessibility and release hardening

Tracking: [GitHub Issue #10](https://github.com/bezeza/alveus-dock/issues/10).

- [ ] Enforce an allowlist for bookmark targets: HTTP/HTTPS and validated local file targets; reject command, script and unknown schemes.
- [ ] Open targets through system default handlers; never construct shell commands from bookmark content.
- [ ] Validate imported data, schema versions, item types, URLs and icon metadata as untrusted input.
- [ ] Verify credentials are not stored/exported and diagnostic logs never include raw URLs, paths, window titles or document names.
- [ ] Keep remote icon/thumbnail fetching disabled by default unless a separate privacy and performance decision approves it.
- [ ] Complete keyboard-only navigation, visible focus, accessible names/roles and predictable focus restoration.
- [ ] Verify reduced-motion support, optional animations, contrast and practical icon sizes.
- [ ] Test screen-reader workflows with an available reader.
- [ ] Measure CPU/RSS with one, two and three or more dock instances, both idle and during interaction.
- [ ] Test 100+ bookmark items, large folders, grouped windows and popup responsiveness.
- [ ] Verify no polling loop, permanent animation loop or resident background service has been introduced.
- [ ] Complete Wayland/X11, four-edge, multiple-monitor and fractional-scaling tests for the declared support matrix.
- [ ] Resolve all critical/high-severity defects and publish troubleshooting and compatibility documentation.

**Exit criteria:** security, privacy, accessibility and performance checks pass on the documented supported Plasma environments; no critical/high-severity defect or known data-loss path remains.

## 1.0.0 — stable Fedora release

Tracking: [GitHub Issue #11](https://github.com/bezeza/alveus-dock/issues/11).

- [ ] Confirm all milestone exit criteria from 0.1.3 through 0.9.0 are satisfied or explicitly documented as out of scope.
- [ ] Complete a release-candidate freeze and resolve all critical/high-severity defects.
- [ ] Bump the applet metadata, QML plugin version and RPM spec together to 1.0.0 only after release-candidate validation.
- [ ] Build and verify RPMs in CI, including metadata, file list and dependencies.
- [ ] Test clean install, upgrade, restart, logout/login and removal on a clean supported Fedora KDE environment.
- [ ] Verify the published compatibility matrix against actual Wayland/X11 and Plasma test evidence.
- [ ] Create and publish the COPR repository.
- [ ] Verify the public DNF installation and removal commands.
- [ ] Publish release notes, user guide, architecture overview and troubleshooting guide.
- [ ] Tag the stable release and attach the verified RPM artifacts.

## Cross-cutting engineering gates

- Every milestone has a focused GitHub issue, acceptance criteria and a live Plasma checklist where runtime behavior is involved.
- Keep CI green, strict QML lint at zero warnings, and regression coverage for every fixed defect.
- Do not merge a milestone into main until its dependent PRs are validated in order and its live Plasma checklist is complete.
- Keep current product documentation honest: README describes implemented behavior; CHANGELOG records completed user-visible changes; ROADMAP describes future work; DEVELOPMENT_LOG records engineering activity.
- Keep the applet lightweight: no daemon, polling loop, arbitrary shell execution or unnecessary network requests.
- Never claim a feature, compatibility combination, screenshot, performance result or release channel is verified unless evidence exists.

## Explicit non-goals for the first stable release

- Windows support.
- A Rust daemon or separate resident background service.
- Replacing KWin or reimplementing KDE window effects.
- Bundling a desktop shell or a second application launcher.
- Patching the stock Icons-Only Task Manager.
