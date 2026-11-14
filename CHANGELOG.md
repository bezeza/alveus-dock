# Changelog

All notable user-visible changes to Alveus Dock are recorded here. This file records past changes; future work belongs in docs/ROADMAP.md.

## [Unreleased]

## [0.1.3] - Unreleased — stabilization

### Fixed
- Synchronize launcher order after a successful manual task reorder.
- Validate drag source and target indices before modifying the task model.
- Reset hover and animation state when ListView recycles a task delegate.
- Prevent diagnostic logs from copying raw exception messages that may contain private paths.

### Added
- Strict QML lint policy for unqualified accesses.
- Regression tests for package metadata, settings schema, drag reordering, delegate reuse and diagnostic privacy.
- A plasmashell CPU/RSS sampler and repeatable performance test instructions.
- Publish live running-window icon geometry through KDE TasksModel so KWin can use Alveus Dock icons as minimize-animation targets (including Magic Lamp where supported).
- Refresh icon geometry after dock layout, panel location and screen changes.
- Regression tests for KWin geometry publication and refresh behavior.

### Notes
- Live Plasma runtime testing and measurements on real hardware are still required.
- Process-level performance samples cover all of plasmashell, not Alveus Dock in isolation.

## [0.1.2] - 2026-11-14 — diagnostics and project tracking

### Added
- Privacy-conscious runtime diagnostics with [AlveusDock] log prefixes.
- Lifecycle, task-count, launcher, attention, action and drag/drop events.
- Log collector script that exports relevant KDE journal entries to a local file.
- Development log and release roadmap.

### Fixed
- Corrected the drop overlay placement as a sibling of the task ListView.
- Removed a stale dropTarget reference from the delegate stacking rule.

### Notes
- Logs intentionally omit application names, window titles, dropped URLs and file paths.
- Runtime QML and Plasma behavior still requires validation in a real Plasma 6.8 session.

## [0.1.1] - 2026-11-14 — interaction foundations

### Added
- Drag-and-drop launcher pinning and task reordering prototype.
- File drops onto running applications.
- Finite attention reaction and launch effects.

### Notes
- Structural checks only; no live Plasma runtime test was performed.

## [0.1.0] - 2026-11-14 — initial source prototype

### Added
- Standalone Plasma applet structure.
- KDE TaskManager model integration.
- Basic launcher/window actions and initial icon reactions.
- Fedora RPM spec and initial RPM workflow draft.

