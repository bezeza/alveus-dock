# Changelog

All notable changes to Alveus Dock are recorded here.

## [0.1.2] - 2026-11-14 — diagnostics and project tracking

### Added
- Privacy-conscious runtime diagnostics with `[AlveusDock]` log prefixes.
- Lifecycle, task-count, launcher, attention, action and drag/drop events.
- Log collector script that exports relevant KDE journal entries to a local file.
- Development log and expanded release roadmap.

### Fixed
- Corrected the drop overlay's placement as a sibling of the task ListView.
- Removed a stale `dropTarget` reference from the delegate stacking rule.

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
- Fedora RPM spec and GitHub Actions RPM build workflow.
