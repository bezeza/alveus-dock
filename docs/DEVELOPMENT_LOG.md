# Alveus Dock — Development Log

This file records dated engineering work. It is not a runtime error log and is not the future roadmap.

## 2026-11-14 — dedicated repository and packaging audit

### Implemented
- Recovered all 21 source entries from the legacy 0.1.2 archive.
- Verified each recovered file against its stored size and CRC before adding it to the dedicated repository.
- Preserved the new repository's full GPL-3.0 license file.
- Moved the applet package, configuration, scripts, RPM spec, changelog and project documentation into the repository root.
- Identified a version mismatch in the RPM helper: it generated a 0.1.1 source archive while the spec expected 0.1.2.
- Identified inconsistent GPL-2.0-or-later identifiers in the old applet files while the new repository selected GPL-3.0-only.

### Validation
- The source recovery step verified all 21 archive entries.
- Structural checks passed in GitHub Actions.
- QML lint passed with Fedora 44 Qt and Plasma QML modules; the CI PATH was corrected to use Fedora's Qt tool directory.
- The noarch RPM built successfully as alveus-dock-0.1.2-1.fc44 and its package metadata, file list and dependencies were verified.
- GitHub Actions uploaded the RPM artifact for download.
- No live Plasma session was available during this work.
- No genuine application screenshots have been captured.
- COPR has not been created or published.

### Next
- Run the applet in Fedora 44 KDE Plasma 6.8.x.
- Verify task interactions, settings persistence, installation and removal.
- Capture real screenshots after runtime validation.

## 2026-11-14 — 0.1.2 diagnostics and tracking

### Implemented
- Added structured log prefixes: [AlveusDock][INFO], [AlveusDock][WARN] and [AlveusDock][ERROR].
- Added lifecycle, task-model, launcher, attention, action and drop/reorder diagnostics.
- Avoided logging application names, window titles, dropped URLs and file paths.
- Added scripts/collect-logs.sh to export relevant journal records.
- Added CHANGELOG.md, docs/LOGGING.md and an initial docs/ROADMAP.md.
- Fixed two static issues in the previous prototype: the drop overlay was nested inside the ListView instead of being its sibling, and the delegate referenced an undefined dropTarget property.

### Validation
- JSON metadata parsed successfully.
- KConfig XML parsed successfully.
- Static package checks passed.
- QML compilation and live Plasma behavior had not yet been tested.

## 2026-11-14 — 0.1.1 interaction prototype

- Added a prototype for task reordering and external launcher/file drops.
- Added a finite attention reaction.
- Runtime validation was not available.

## 2026-11-14 — 0.1.0 initial project

- Created a standalone Plasma applet source layout.
- Added the first Fedora RPM spec and CI workflow draft.
