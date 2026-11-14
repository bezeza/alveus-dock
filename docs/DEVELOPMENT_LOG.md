# Alveus Dock — Development Log

This file records dated engineering work. It is not a runtime error log and is not the future roadmap.

## 2026-11-14 — 0.3.0 runtime-readiness audit

### Fixed
- Consolidated duplicate `onModelChanged` handlers in the shared task delegate so model replacement both refreshes KWin icon geometry and closes a stale group chooser from one handler.

### Validation
- Added a regression test that rejects duplicate model-change handlers and verifies both responsibilities remain present.
- Live Plasma behavior remains unverified until the applet can be run in a real desktop session.

## 2026-11-14 — 0.3.0 dual-layer layout implementation

### Implemented
- Added Single, Dual and Adaptive layout modes, with Single remaining the compatibility default.
- Added a Layout settings page with independent icon sizes and spacing for Quick Access and Running Windows, plus configurable spacing between layers.
- Split the existing KDE TasksModel presentation into Quick Access launchers and Running Windows using Qt DelegateModel groups.
- Kept KDE as the single source of truth for launchers, windows, grouping, activation and close actions.
- Extracted the shared task icon delegate into TaskDelegate.qml so the same interaction logic serves every layout.
- Kept launcher reordering in Quick Access and disabled manual reordering in the running-window layer.
- Updated drag/drop target resolution to translate filtered view positions back to source TaskManager model indices.
- Added horizontal two-row and vertical two-column geometry; Adaptive hides the empty running layer.

### Validation
- GitHub Actions passed structural checks, all 25 Python regression tests, Python/shell syntax checks, strict QML lint, Fedora 44 RPM build, RPM metadata/file/dependency verification and artifact upload.
- Successful CI run: https://github.com/bezeza/alveus-dock/actions/runs/43617197076.
- Default Dual thickness is 96 logical pixels with 32 px icons in each layer, 4 px layer spacing and 6 px outer padding.
- A live Plasma session is still required to verify panel thickness, both orientations, launcher persistence, grouped windows and Magic Lamp geometry.

### Next
- Run all three modes in a live Plasma panel.
- Verify group membership updates after launch, close, pin/unpin and grouping changes.
- Test drops, drag reorder, activation and minimize geometry in each layout.
- Compare performance with the single-row baseline.


## 2026-11-14 — 0.2.0 initial window grouping

### Implemented
- Added optional application grouping using KDE TasksModel::GroupApplications. Grouping is disabled by default to preserve the existing dock layout.
- Added a compact Plasma-native PopupPlasmaWindow chooser backed by the hierarchical TasksModel child model.
- Added per-window activation and close actions using makeModelIndex(parentRow, childRow).
- Added a window-count badge and an ungroup action for grouped applications.
- Added keyboard focus and Escape/Enter handling to the grouped window chooser.
- Kept KWin minimize geometry publication working for group-parent delegates.
- Close the chooser when its parent delegate is pooled, reused or no longer represents a group.
- Added regression coverage for grouping configuration, child model indices, chooser actions, count badges and grouped minimize geometry.

### Validation
- GitHub Actions passed on the latest branch head: structural checks, all 20 Python regression tests, Python/shell syntax checks, strict QML lint, Fedora 44 RPM build and RPM metadata/file/dependency verification. [Successful run](https://github.com/bezeza/alveus-dock/actions/runs/43612176399).
- Live Plasma runtime testing is required for popup placement, keyboard navigation, grouped activation/close, ungrouping and minimize effects on Wayland and X11.

### Next
- Verify grouping with two or more windows from the same application.
- Test chooser placement on all four panel edges and vertical panels.
- Test activation, close, ungroup and minimize-to-icon behavior.
- Evaluate native KDE window previews after the chooser is stable.


## 2026-11-14 — 0.1.3 stabilization branch

### Implemented
- Added bound component behavior to make outer QML IDs explicit inside the task delegate.
- Reset hover and finite animation state when ListView pools or reuses delegates.
- Synchronize launcher order after successful task reordering, as required by KDE TasksModel.
- Validate drag source/target indices before calling the task model.
- Changed exception diagnostics to record only the exception type, avoiding raw messages that can contain private paths.
- Added a strict qmllint policy, regression tests for package/configuration contracts, and a plasmashell CPU/RSS sampling tool.
- Updated applet metadata, runtime diagnostics and RPM spec to version 0.1.3.
- Integrated KDE TasksModel::requestPublishDelegateGeometry() so KWin receives the screen geometry of each running-window delegate for minimize-to-icon effects such as Magic Lamp.
- Refresh published geometry after delegate movement/resizing/reuse, task-count changes, panel relocation and screen-geometry changes.
- Added regression coverage for geometry publication and layout refresh triggers.

### Validation
- KDE TaskManager API documentation confirms move() returns a boolean and syncLaunchers() must be called after move operations to persist launcher ordering.
- Previous GitHub Actions run passed: structural checks, all 11 Python regression tests, Python/shell syntax checks, strict QML lint with zero warnings, RPM build and RPM metadata/file/dependency verification. See [the successful CI run](https://github.com/bezeza/alveus-dock/actions/runs/43597366134).
- Latest GitHub Actions run passed after the geometry integration: structural checks, all 13 Python regression tests, Python/shell syntax checks, strict QML lint, Fedora RPM build and RPM metadata/file/dependency verification. [Successful run](https://github.com/bezeza/alveus-dock/actions/runs/43608979486).
- Live Plasma runtime and performance tests remain pending because no KDE desktop session is available here.

### Next
- Run the applet in a live Plasma session and verify drag reorder, launcher persistence, delegate recycling, hover effects and Magic Lamp minimize-to-icon behavior on X11 and Wayland.
- Compare CPU/RSS samples with the dock disabled and enabled.

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
