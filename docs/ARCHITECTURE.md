# Alveus Dock — Architecture

Status: target architecture and implementation constraints. Features marked **planned** are not implemented by the current 0.3.0 development branch.

## 1. Product boundaries

Alveus Dock is a lightweight KDE Plasma 6 applet. Plasma owns panel placement, screen assignment, panel thickness and containment lifecycle. Users add and place applet instances through Plasma's native panel and widget controls.

Alveus Dock does not create a replacement desktop shell, patch KWin, replace Icons-Only Task Manager, or run a resident background daemon. Multiple Alveus Dock instances are separate applet instances hosted by Plasma.

Primary goals:

- Keep launchers, running windows and bookmarks understandable and separate.
- Reuse native KDE/Plasma services for task discovery, window actions, file/URL opening and panel integration.
- Make each applet instance independently configurable.
- Keep idle resource use low and all animations finite and interruptible.
- Preserve existing launcher, task grouping and KWin minimize-effect behavior as features are added.

## 2. Current implementation (0.3.0 development branch)

### 2.1 Plasma applet shell

- The applet is a Plasma Applet package with plugin ID **org.bezeza.alveusdock**.
- The main UI is a **PlasmoidItem** in **package/contents/ui/main.qml**.
- Orientation is derived from Plasma's form factor. Horizontal panels use horizontal layout; vertical panels use vertical layout.
- The applet reads preferences through **Plasmoid.configuration**.
- Plasma containment geometry and screen geometry are used when publishing icon geometry.

The package metadata currently reports version 0.1.3. The 0.3.0 work remains in development branches; do not bump the package version merely because a feature branch has a newer roadmap milestone. Version changes require the release validation gate.

### 2.2 Task and window subsystem

KDE TaskManager's native TasksModel is the single source of truth for application launchers, startup tasks, windows and grouped windows.

- Do not create a second window registry or poll the window manager.
- Single, Dual and Adaptive layouts change presentation, not task ownership.
- In split layouts, Qt DelegateModel groups present Quick Access launchers and Running Windows separately.
- **TaskDelegate.qml** contains shared task and launcher interaction logic.
- Task actions must use source-model indices. A filtered or visual delegate index must never be passed directly to a TasksModel action.
- Launcher matching uses KDE AppId first and normalized LauncherUrlWithoutIcon as a fallback.
- Clicking Quick Access for an already-running application activates its active or most recently activated matching window. A grouped application opens the Window Chooser. A matching startup task suppresses another launch request.
- Only clicking the active item in Running Windows requests minimization.
- Grouped child actions use the native hierarchical model and **makeModelIndex(parentRow, childRow)**.
- Running-window and group-parent delegate geometry is published through the native TaskManager API so KWin can target the dock icon for minimize effects such as Magic Lamp.

KWin remains responsible for its effects. Alveus Dock only publishes the relevant geometry.

### 2.3 Settings and persistence today

- Scalar settings are declared in **package/contents/config/main.xml**.
- Configuration UI is divided into Appearance, Layout and Behavior pages.
- Launcher order is synchronized through the task model's launcher list.
- New settings must have a KConfig entry, a user-facing control where appropriate, validation bounds for numeric values, and regression coverage.

Do not assume that configuration is isolated per applet instance until this is verified in a live Plasma session. Multi-instance persistence is an explicit 0.6.0 validation item.

## 3. Target architecture for bookmarks and multiple docks

### 3.1 Independent applet instances

Plasma creates, positions and owns each applet instance. A user may place one instance at the bottom for applications and another at a side edge for bookmarks.

Each instance has its own:

- Content profile: Applications, Bookmarks or Hybrid.
- Item collection and ordering.
- Appearance, sizing, spacing, labels and background settings.
- Bookmark folder styles and popup preferences.
- Relevant task filters when the instance displays tasks.

Changing one instance must not mutate another instance's settings or content.

The implementation must first prove how the supported Plasma version identifies applet instances and scopes configuration. Choose the persistence key and data-file strategy only after that check. Do not invent a global singleton or shared configuration file that causes instances to overwrite one another.

### 3.2 Separate content models

The task model and bookmark model have different responsibilities and must remain separate.

**Applications content**

- Uses KDE TasksModel for launchers, startup tasks, windows and groups.
- Keeps Quick Access and Running Windows presentation behavior.
- Preserves activation, minimize, close, drag/reorder and KWin geometry contracts.

**Bookmarks content — planned**

A dedicated bookmark model owns web links, local files, directories, folders/groups and separators. It must not inject URLs or file entries into KDE TasksModel or treat a bookmark as a running window.

A bookmark item should have a stable identity, item type, display title, target, icon specification, sort order and optional child items. Folder view style and its settings belong to that folder, not to the whole dock.

Supported targets initially:

- Web links using HTTP or HTTPS.
- Local files and directories using file URLs or validated local paths.

Open targets through the system's default KDE/application handler. Never construct a shell command from a bookmark, execute raw command strings, or accept arbitrary command schemes. Application launchers remain in the Applications content model.

### 3.3 Folder popup and expansion styles — planned

A reusable popup controller anchors each folder view to its source icon.

Required behavior:

- Calculate available screen space and choose an opening direction that keeps the popup on-screen.
- Work with bottom, top, left and right dock placements.
- Close on Escape, outside click, folder removal or stale source delegate.
- Restore keyboard focus predictably.
- Support mouse, touchpad and keyboard navigation.
- Respect reduced-motion settings; animations are short, optional and interruptible.
- Use scrolling or pagination for large collections instead of shrinking icons indefinitely.

Planned styles, independently selectable per folder:

1. Grid — default.
2. List.
3. Category tree.
4. Radial/fan.
5. Carousel.
6. Large tiles.
7. Ring — experimental.
8. Widget panel — experimental.
9. Combined category-and-content view — experimental.

Grid, List and Category tree are the first delivery set. Other styles follow only after the base interaction passes live usability and performance checks.

### 3.4 Panel and content editor — planned

The Alveus Dock editor manages the applet's own content and settings: add, rename, remove, reorder, group, choose icons and configure appearance.

Creating, deleting, moving or assigning Plasma panels to screens remains a native Plasma operation. Do not imply that the applet can safely manage other containments unless a supported public API is verified and a separate product decision approves it.

## 4. Configuration and data storage

Use Plasma/KConfig for scalar preferences, following the existing **main.xml** schema and configuration pages.

For structured bookmark collections, evaluate a versioned data representation after confirming per-instance storage behavior. Candidate implementations are:

- A structured value in the applet instance's KConfig group; or
- A versioned JSON sidecar in an instance-scoped application-data location, written atomically.

Choose one in a recorded decision after a prototype verifies instance identity, persistence, atomic updates, backup/restore and migration behavior. Do not mix both approaches without a clear ownership rule.

Data requirements:

- Stable item IDs, explicit item types and deterministic ordering.
- Schema version and forward validation on import.
- Safe handling of missing icons, deleted files, invalid URLs and unknown item types.
- Atomic save or recoverable write strategy.
- Backup before destructive import or migration.
- Export/import preview and an explicit duplicate-handling policy.
- No passwords or credentials stored by Alveus Dock.
- Never write raw URLs, local paths, window titles or document names to diagnostic logs.

## 5. Search, organization and profiles — planned

The content manager should support:

- Search across titles and bookmark targets.
- Filter by item type and folder/category.
- Favorites and recently used items, with user control over history.
- Sorting by manual order, title and type.
- Duplicate detection without silently deleting entries.
- Saved dock presets for content and appearance where useful.

A saved preset may restore Alveus Dock settings and content. It must not claim to recreate Plasma panels, screen placement or containment topology unless that is separately implemented through a supported Plasma interface.

## 6. Security and privacy

- Accept only explicitly supported bookmark target schemes. Initial web support is HTTP/HTTPS; local targets use validated file URLs/paths.
- Reject command, script and unknown schemes. Never pass bookmark strings to a shell.
- Use system default handlers for opening URLs and files.
- Validate imported data against a versioned schema and item-type allowlist.
- Treat imported titles, paths, URLs and icon metadata as untrusted data.
- Do not download remote icons or thumbnails automatically by default.
- Keep diagnostics structured and privacy-preserving. Never log raw URLs, file paths, document names, window titles or application names.
- Do not store authentication credentials.

## 7. Accessibility and interaction

- Every interactive icon, folder and control needs an accessible name and role.
- Keyboard focus must be visible and predictable.
- Support Enter/Space to activate, Escape to close transient popups, and a clear way to navigate back from nested folders.
- Do not make hover the only way to reveal an action.
- Respect desktop reduced-motion preferences and provide an explicit animation toggle.
- Keep contrast and icon-size controls usable at common display scaling levels.
- Test with screen readers and keyboard-only navigation before 1.0.

## 8. Performance constraints

- No resident daemon, permanent polling loop or infinite animation.
- Prefer model-change signals and event-driven updates.
- Avoid synchronous directory scans, network access, thumbnail generation or repeated full-model traversal on the QML/UI thread.
- Load optional previews lazily and keep them disabled by default until measured.
- Test one, two and three or more applet instances.
- Test large bookmark sets (5, 12, 30, 100+ items) and grouped applications.
- Measure whole-shell CPU/RSS consistently using **docs/PERFORMANCE.md**; record idle and interaction samples.
- Performance regressions must be compared against a documented baseline, not judged by impression alone.

## 9. Testing and release gates

Automated checks and live Plasma testing are complementary.

**Automated on every relevant change**

1. **python3 scripts/check-package.py**
2. **python3 -m unittest discover -s tests -v**
3. Strict QML lint with zero warnings.
4. Python and shell syntax checks.
5. Fedora RPM build and metadata/file/dependency verification.
6. Regression tests for model indices, persistence schema, import validation and privacy rules as those features are added.

**Live Plasma before closing a milestone**

- Record Fedora, Plasma, Qt, Wayland/X11, GPU/driver, scaling and monitor count.
- Test all four panel edges and horizontal/vertical layouts.
- Test one and multiple applet instances and confirm settings do not leak between them.
- Test Plasma restart and logout/login persistence.
- Test task grouping, activation, minimizing, close, drag/drop and Magic Lamp.
- Test bookmark opening, folder popup placement, keyboard focus, reduced motion, import/export and recovery as implemented.
- Inspect sanitized logs and compare CPU/RSS.

See **docs/TEST_PLAN.md** for the test matrix and evidence requirements.

A CI pass does not prove runtime correctness. A milestone is not complete until its acceptance criteria pass in a real supported Plasma session.

## 10. Milestone ownership

- 0.1.3 — stabilization and native KWin geometry.
- 0.2.0 — grouped windows and Window Chooser.
- 0.3.0 — Single, Dual and Adaptive layouts.
- 0.4.0 — finite Alveus motion effects.
- 0.5.0 — compatibility and polish.
- 0.6.0 — multiple independent applet instances and bookmark content.
- 0.7.0 — per-folder expansion styles.
- 0.8.0 — content editor, search, presets, backup/import/export and migration.
- 0.9.0 — security, accessibility, performance and release hardening.
- 1.0.0 — stable Fedora release.

See **docs/ROADMAP.md** and the linked milestone issues for the current delivery checklist.

## 11. Explicit non-goals

- Replacing KDE Plasma panels or containments.
- Replacing KWin or reimplementing KWin effects.
- A second task/window registry.
- A Rust daemon or resident background service.
- Executing arbitrary commands from bookmark targets.
- A cross-platform Windows/macOS dock.
- Automatically fetching remote bookmark previews or icons by default.
