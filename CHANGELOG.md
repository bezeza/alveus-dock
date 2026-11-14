# Changelog

All notable user-visible changes to Alveus Dock are recorded here. This file records past changes; future work belongs in docs/ROADMAP.md.

## [Unreleased]

### Changed
- Moved the 0.1.2 source into the dedicated bezeza/alveus-dock repository.
- Standardized project licensing metadata and source headers on GPL-3.0-only.
- Reworked RPM source archive generation so its directory and version match the RPM spec.

### Added
- GitHub Actions workflow for structural checks, QML lint and Fedora RPM builds.
- AI-agent contribution rules in AGENTS.md.
- Screenshot capture checklist and clearer Fedora installation instructions.

### Notes
- Live Plasma runtime testing and real screenshots remain pending.
- COPR has not been published; direct installation by package name is not active yet.

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
