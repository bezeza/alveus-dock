# Alveus Dock — Development Log

This file records repository-level work. It is not a substitute for runtime
error logs; those are written by Qt/Plasma to the system journal.

## 2026-11-14 — 0.1.2 diagnostics and tracking

### Implemented
- Added structured log prefixes: `[AlveusDock][INFO]`,
  `[AlveusDock][WARN]`, `[AlveusDock][ERROR]`.
- Added lifecycle, task-model, launcher, attention, action and drop/reorder
  diagnostics.
- Avoided logging application names, window titles, dropped URLs and file paths.
- Added `scripts/collect-logs.sh` to export relevant journal records.
- Added `CHANGELOG.md`, `docs/LOGGING.md` and expanded `docs/ROADMAP.md`.
- Fixed two static issues in the previous prototype: the drop overlay was
  nested inside the ListView instead of being its sibling, and the delegate
  referenced an undefined `dropTarget` property.

### Validation
- JSON metadata parsed successfully.
- KConfig XML parsed successfully.
- Static package checks passed.
- QML compilation and live Plasma behavior have not yet been tested.

### Next
- Run `qmllint` with the Plasma 6.8 QML modules installed.
- Install in a separate test user/session on Fedora KDE Plasma 6.8.2.
- Verify pinning, reordering, opening dropped files, activation and removal.
- Confirm actual RPM dependency names and build/install/upgrade/remove cycle.

## 2026-11-14 — 0.1.1 interaction prototype

- Added a prototype for task reordering and external launcher/file drops.
- Added a finite attention reaction.
- Runtime validation was not available.

## 2026-11-14 — 0.1.0 initial project

- Created a standalone Plasma applet source layout.
- Added RPM packaging and a GitHub Actions build workflow.
