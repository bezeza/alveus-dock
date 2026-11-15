# Alveus Dock — Development Log

This file records dated engineering work. It is not a runtime error log and it is not the future roadmap.

## 2026-11-15 — 0.3.0 interaction and model-index hardening

### Fixed
- Keep the grouped Window Chooser's parent source row independent from the Quick Access launcher row when the chooser is anchored to a pinned launcher.
- Close a transient group chooser and resynchronize the presentation groups when TaskManager rows move.
- Republish KWin delegate geometry when a task's source-model row changes, even if its visual bounds stay in the same place.
- Treat a non-empty conflicting AppId as a mismatch; use LauncherUrlWithoutIcon URL matching only when at least one AppId is missing.
- Classify drag-and-drop separately: consume duplicate .desktop launcher drops, reject mixed launcher/file batches, and prevent launcher URLs from falling through to the file-open path.

### Validation
- Added regression coverage for launcher-anchored group chooser indices, row-move handling, geometry refresh, AppId precedence and launcher-drop classification.
- GitHub Actions run #66 on commit `cf22620e81a8569d56cc2a6e3da2d7303c23d440` passed structural checks, regression tests, Python/shell syntax checks, strict QML lint, Fedora RPM build, RPM verification and artifact upload.
- The `alveus-dock-rpm` artifact was uploaded. The package version remains 0.1.3; the 0.3.0 branch is not a release.
- These checks do not replace live Plasma validation. Issue #5 remains open until the Single, Dual and Adaptive modes, drag/drop, grouping, Magic Lamp, panel geometry and performance are verified in a real Plasma session. Do not merge to `main` before that gate passes.

## 2026-11-15 — architecture and delivery plan

### Added
- Added docs/ARCHITECTURE.md to record current KDE TasksModel/DelegateModel boundaries and the planned bookmark, multi-instance, persistence, security, accessibility and performance architecture.
- Added docs/TEST_PLAN.md with automated CI, live Plasma, task/window, bookmark, import/export, accessibility and performance validation matrices.
- Extended ROADMAP with 0.8.0 content management/data portability and 0.9.0 security/accessibility/release hardening.
- Clarified that Plasma owns panel creation and placement; Alveus Dock manages only its own applet instance content and settings.
- Split bookmark-folder expansion into its own 0.7.0 milestone rather than mixing it into the 0.6.0 multiple-dock milestone.

### Tracking
- Issue #7: multiple applet instances and bookmark content.
- Issue #8: per-folder expansion styles.
- Issue #9: content editor, search, presets and data portability.
- Issue #10: security, accessibility and release hardening.
- Issue #11: stable 1.0.0 Fedora release.
- Issue #12: motion identity and icon reactions.
- Issue #13: compatibility, layout polish and documentation.

### Validation
- Documentation and planning changes only; no runtime feature or Plasma behavior is claimed by this entry.
- CI will validate the documentation commit. Live Plasma validation remains governed by docs/TEST_PLAN.md and the milestone issues.

## 2026-11-15 — Quick Access activation routing

### Implemented
- Changed pinned Quick Access clicks to search the existing native KDE TasksModel before dispatching a launch.
- Match running tasks by KDE AppId, with LauncherUrlWithoutIcon matching as a fallback after removing query metadata.
- Activate the currently active matching window or the most recently activated matching window; grouped applications open the native Window Chooser anchored to the Quick Access icon.
- Suppress a second launch request while a matching startup task is already present.
- Keep the lower Running Windows behavior unchanged: selecting an inactive window activates it, while selecting the active window requests minimization.
- Play the launch reaction only when Quick Access actually dispatches a new launch.

### Validation
- Added regression coverage for AppId/launcher URL matching, LastActivated selection, group chooser routing with the source group index, and startup duplicate suppression.
- GitHub Actions run #40 on code/test commit `6c45003e1627044ec7c051ea536c7998561d9339` passed structural checks, all 28 regression tests, Python/shell syntax checks, strict QML lint with zero warnings, Fedora 44 RPM build, RPM metadata/file/dependency verification and artifact upload: https://github.com/bezeza/alveus-dock/actions/runs/43696828389.
- Run #42 is validating the subsequent documentation and AI-agent-rule updates on head `3d4277e862e78c3eb9e70eebbca91c0382ede34e`.
- Live Plasma testing is still required to confirm AppId/launcher URL matching and activation behavior on the target Plasma 6.8 session.
- Matching intentionally follows the same current-desktop/current-screen filters as the dock's running-window layer.


## 2026-11-14 — 0.3.0 runtime-readiness audit

### Fixed
- Consolidated duplicate `onModelChanged` handlers in the shared task delegate so model replacement both refreshes KWin icon geometry and closes a stale group chooser from one handler.
- Corrected the model-change regression test's raw-string regex and block terminator matching. The initial failure was in the test matcher, not in QML compilation.

### Validation
- Added a regression test that rejects duplicate model-change handlers and verifies both responsibilities remain present.
- The current branch contains 26 Python regression tests; all passed in GitHub Actions, along with structural checks, Python/shell syntax checks, strict QML lint, Fedora 44 RPM build, RPM metadata/file/dependency verification and artifact upload.
- Successful CI run for PR head `8234c1b59a3a74ffdca46fe1fcc2db896588a5e3`: https://github.com/bezeza/alveus-dock/actions/runs/43628298835.
- Live Plasma behavior remains unverified until the applet can be run in a real desktop session. No Issue #5 runtime item is considered complete from CI alone.

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
- GitHub Actions passed structural checks, all 26 Python regression tests, Python/shell syntax checks, strict QML lint, Fedora 44 RPM build, RPM metadata/file/dependency verification and artifact upload.
- Latest successful CI run: https://github.com/bezeza/alveus-dock/actions/runs/43628298835.
- Default Dual thickness is 96 logical pixels with 32 px icons in each layer, 4 px layer spacing and 6 px outer padding.
- A live Plasma session is still required to verify panel thickness, both orientations, launcher persistence, grouped windows and Magic Lamp geometry.

### Next
- Run all three modes in a live Plasma panel.
- Verify pinned launchers remain visible while running windows appear separately and disappear on close.
- Verify group membership survives launch, close, pin/unpin, grouping changes and layout-mode switches.
- Verify Magic Lamp targets the running-window icon in the second layer.
- Test horizontal and vertical layouts, panel thickness, resize, screen-edge relocation and fractional scaling.
- Test drops, drag reorder, activation and minimize geometry in each layout.
- Compare CPU/RSS with the single-row baseline; verify no polling or continuous animation.
- Capture genuine screenshots of both orientations and all three modes.

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
