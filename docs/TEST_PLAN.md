# Alveus Dock — Test Plan

This plan defines evidence required to close milestones. Automated CI and live Plasma testing are separate gates; neither substitutes for the other.

## 1. Environment record

For every live test session, record:

- Fedora release and kernel.
- KDE Plasma and Qt versions.
- Wayland or X11.
- GPU and driver.
- Display scaling and resolution.
- Number of monitors.
- Alveus Dock commit SHA, package version and installation method.

Attach genuine screenshots of the running applet and sanitized logs. Never attach private window titles, document names, raw URLs or local paths.

## 2. Automated CI gate

Run on every relevant pull request:

1. Package structure and metadata validation.
2. Python regression tests.
3. Strict QML lint with zero warnings.
4. Python bytecode compilation.
5. Shell syntax checks.
6. Fedora RPM build.
7. RPM metadata, file-list and dependency checks.
8. Upload the RPM artifact for inspection.

New behavior must receive regression coverage for both the expected action and its important failure/edge cases. Do not weaken lint or tests merely to make CI green.

## 3. Live Plasma compatibility matrix

Where the environment is available, test:

| Dimension | Required coverage |
|---|---|
| Panel edge | Bottom, top, left, right |
| Orientation | Horizontal and vertical |
| Session | Wayland and X11 separately |
| Applet instances | 1, 2, 3+ |
| Display setup | Single and multiple monitors |
| Scaling | 100%, 125%, 150%, 200% where available |
| Lifecycle | Add, remove, move, resize, restart Plasma, logout/login |
| Layout modes | Single, Dual, Adaptive |

Record unsupported combinations explicitly rather than assuming compatibility.

## 4. Task and window regression tests

- Pin, unpin, reorder and persist application launchers.
- Open and close applications; verify running-window appearance and removal.
- Click a pinned launcher for a closed app and verify one launch request.
- Click a pinned launcher for a running app and verify activation without minimizing or duplicate launch.
- Click a pinned launcher while a matching startup task exists and verify no duplicate launch.
- Test matching by KDE AppId, then exact LauncherUrlWithoutIcon fallback when IDs differ or are unavailable.
- Group two or more windows; activate and close each child; ungroup; close the last child. Verify the group context-menu action is explicitly labeled "Close all windows".
- Test Window Chooser focus, Escape, outside click, parent recycling, group collapse and switching to another group while an outside-click close is pending.
- Verify popup dismissal clears its parent-delegate reference and a subsequent chooser opens on the correct group.
- Verify source-model indices are used for all task actions, including after TaskManager rows move or the model emits layoutChanged.
- In Dual/Adaptive modes, verify only the active delegate in Running Windows requests minimization and Quick Access never minimizes an already-running app. Verify Single mode retains its existing one-row task behavior.
- Verify Magic Lamp targets the correct running-window or group icon after resize, reorder, TaskManager layout changes, panel relocation and screen changes.
- Verify file drops onto running application windows. Test launcher drops using .desktop files, applications: URLs and preferred:// URLs; verify mixed launcher/file batches are rejected and duplicate launcher drops are consumed safely.
- Verify the Pin to Dock menu action is disabled when LauncherUrlWithoutIcon is empty.
- Verify Adaptive hides the Running Windows layer when no running or startup tasks are present.
- Verify current-desktop/current-screen filter behavior.

## 5. Multiple dock and bookmark tests (0.6.0+)

- Add two or more Alveus Dock applet instances using native Plasma controls.
- Place an Applications dock at the bottom and a Bookmarks dock on a side edge.
- Verify each instance has independent profile, content, order and appearance settings.
- Change, move, remove and reconfigure one instance; verify other instances are unchanged.
- Restart Plasma and log out/in; verify all instances and their settings persist.
- Verify Applications, Bookmarks and Hybrid profiles.
- Add, open, rename, reorder and remove HTTP/HTTPS bookmarks, local files and directories.
- Verify missing files and unavailable URLs fail gracefully.
- Verify .desktop launchers remain in the application model and are not treated as ordinary bookmarks.
- Test drag-and-drop of URLs, files and folders into the correct content profile.

## 6. Bookmark folder popup tests (0.7.0+)

Use collections of 5, 12, 30 and 100+ items.

- Grid, List and Category tree first; then Radial/Fan, Carousel and Large tiles.
- Experimental Ring, Widget panel and Combined view only after core styles pass.
- Verify two folders can use different styles simultaneously.
- Verify popup opens from the source icon and stays inside the available screen work area.
- Test all four dock edges, vertical and horizontal docks, multiple monitors and fractional scaling.
- Test scrolling/pagination, nested folders and back/up navigation.
- Test mouse, touchpad, keyboard, Enter/Space, Escape and outside-click close.
- Verify focus returns to the source folder when the popup closes.
- Verify animations are optional, short, interruptible and respect reduced-motion settings.
- Verify style and folder order survive Plasma restart.

## 7. Editor, search and data safety tests (0.8.0+)

- Search by title and target; filter by item type and folder.
- Sort by manual order, title and type; verify manual order remains stable when sorting is reset.
- Test favorites, recently used and history opt-out.
- Add, rename, delete, reorder, group and change icons.
- Detect duplicates without silently deleting or merging user data.
- Export and import valid collections; preview changes before applying.
- Test malformed JSON, unsupported schema versions, unknown item types, invalid URLs and missing icon references.
- Verify a failed import does not partially overwrite the current collection.
- Verify backups can restore a previous known-good collection.
- Test migration from each supported previous schema version.
- Verify one applet instance cannot import over or modify another instance's collection by accident.

## 8. Security and privacy tests (0.9.0+)

- Accept only supported target schemes: HTTP, HTTPS and validated local file targets.
- Reject command, script and unknown schemes.
- Verify no bookmark target is interpolated into a shell command.
- Validate imported data and treat all imported text, paths, URLs and icon metadata as untrusted.
- Verify logs do not contain raw URLs, local paths, document names, window titles or application names.
- Verify credentials are not stored or exported.
- Verify remote icons/previews are not fetched automatically by default.

## 9. Accessibility tests (0.9.0+)

- Complete primary workflows with keyboard only.
- Verify visible focus and predictable focus restoration.
- Verify accessible names and roles for icons, folders, popup controls and settings.
- Verify no critical action is available only on hover.
- Test reduced-motion settings and explicit animation-off mode.
- Check contrast and icon sizes at common scaling levels.
- Test with an available screen reader.

## 10. Performance tests

Use **docs/PERFORMANCE.md** and the existing profiling script. Compare like-for-like sessions.

Record at minimum:

- Idle plasmashell CPU and RSS with Alveus Dock disabled.
- Idle CPU and RSS with one, two and three applet instances.
- CPU/RSS while opening/closing windows and expanding bookmark folders.
- Large bookmark collection behavior and popup responsiveness.
- Any animation-related spikes and settling time.

Do not claim dock-only memory usage from whole-process plasmashell measurements. Report the measurement scope and duration. No polling loop or permanent animation loop may be introduced.

## 11. Milestone exit criteria

A milestone can be closed only when:

- Its automated CI checks pass.
- Its live Plasma checklist passes on the documented supported environment.
- No unresolved critical or data-loss defect remains.
- Configuration and user data survive the required restart/migration tests.
- Evidence is attached to the relevant GitHub issue.
- README, CHANGELOG, ROADMAP and DEVELOPMENT_LOG reflect the actual state without presenting planned work as implemented.

A missing test environment is a recorded blocker, not a passing result.
