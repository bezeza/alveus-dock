# Changelog

All notable user-visible changes to Alveus Dock are recorded here. This file records past changes; future work belongs in docs/ROADMAP.md.

## [Unreleased]

### Added
- Configurable Single, Dual and Adaptive layouts.
- Separate Quick Access and Running Windows layers using KDE's native TaskManager model.
- Quick Access opens the Window Chooser for grouped applications, otherwise activates the most recently active matching window visible to the dock's current TaskManager filters; in-progress startup tasks suppress duplicate launches.
- Horizontal two-row and vertical two-column arrangements.
- Independent icon sizes and spacing for Quick Access and Running Windows, plus configurable spacing between layers.
- Adaptive hides the running layer when no windows are open.
- Running-window delegates retain KDE minimize geometry and grouped-window actions.
- Optional application grouping using KDE's native TaskManager model.
- Compact Plasma-native window chooser for grouped applications, with per-window activation and close actions.
- Window-count badge on grouped application icons and an ungroup command in the context menu.
- Keyboard navigation in the grouped chooser: Escape closes it and Enter activates the selected window.
- Grouped-task delegates continue publishing their geometry to KWin for minimize effects.

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

