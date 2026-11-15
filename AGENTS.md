# Instructions for AI coding agents

## Project scope

Alveus Dock is a lightweight KDE Plasma 6 applet written in QML. The current target is Fedora 44+ with KDE Plasma 6.8+.

- Keep the dock standalone. Do not patch or replace KDE's Icons-Only Task Manager.
- Use KDE/Plasma APIs for task discovery, launchers and window actions.
- Use the native TasksModel hierarchical grouping API for grouped windows; do not duplicate window discovery or maintain a second window registry.
- For Dual/Adaptive layouts, keep KDE TasksModel as the only source of launcher/window data and split presentation with Qt DelegateModel groups.
- Preserve the source TaskManager row index when using filtered DelegateModel views; never pass a filtered view index to TasksModel actions.
- Keep launcher reordering in Quick Access only when layers are split; do not reorder the Running Windows layer.
- In split layouts, a Quick Access click must first resolve a matching running task by KDE AppId, with LauncherUrlWithoutIcon as a fallback, and activate the active or most recently activated matching window instead of launching another instance.
- Resolve grouped applications to a real child-window index with makeModelIndex(parentRow, childRow); do not attempt to activate a group parent as if it were a window.
- A Quick Access click must never minimize an already-running window. Only clicking the active delegate in Running Windows toggles minimization.
- If a matching startup task already exists, do not dispatch another launch request.
- Quick Access matching uses the same TaskManager filters as the visible Running Windows layer; document this scope and validate it in live Plasma.
- Keep Single mode as the compatibility default; Adaptive hides only the empty running layer, not pinned launchers.
- Derive horizontal two-row and vertical two-column geometry from the same icon extent and spacing settings.
- For a grouped child, build its model index with makeModelIndex(parentRow, childRow). Never pass a child row as a top-level task index.
- Close transient group choosers when their parent delegate is pooled, reused or no longer represents a group.
- Keep group-parent delegate geometry published to TaskManager so KWin minimize effects continue targeting the dock icon.
- KWin effects such as Magic Lamp belong to KWin; do not try to recreate or control them from the applet.
- Keep the project small. Do not add a Rust daemon, resident service, Windows port or broad cross-platform layer unless the maintainer explicitly changes the scope.
- Avoid new runtime dependencies unless they solve a demonstrated problem.

## Performance and interaction rules

- Prefer event-driven work over polling.
- Do not add infinite or always-running animation loops.
- Animations must be finite, interruptible and inexpensive.
- Do not block the QML/UI thread with filesystem scans, thumbnail work or repeated model traversal.
- Preserve keyboard focus, pointer interaction and accessibility when changing delegates.
- Test horizontal and vertical layouts before claiming both are supported.

## Privacy and diagnostics

- Never log application names, window titles, document contents, file paths or dropped URLs.
- Log event names, counts, indices and error messages only when they do not reveal private content.
- Keep diagnostic messages structured and prefixed with AlveusDock.
- Do not silently swallow failures or report an action as successful when the API rejected it.

## Repository workflow

- Work on a dedicated branch; do not commit directly to main.
- Keep one focused task per branch and pull request.
- Use clear conventional commit messages.
- Do not rewrite or delete user work that is unrelated to the current task.
- Do not commit generated RPMs, SRPMs, build directories, caches or private logs.
- Keep Alveus Dock independent from the separate Alveus repository.

## Documentation boundaries

- CHANGELOG.md records user-visible changes that have already happened.
- docs/DEVELOPMENT_LOG.md records dated engineering work and validation results.
- docs/ROADMAP.md contains future work only.
- README.md describes the current project and verified usage.
- Never move completed work into the roadmap as if it were still planned, and never claim a planned feature is already implemented.

## Licensing

- The project license is GNU GPL-3.0-only.
- Keep SPDX identifiers, package metadata and the RPM spec consistent with GPL-3.0-only.
- Do not copy third-party code or assets without checking their license.

## Required checks

Before proposing a change, run the checks available in the environment:

1. `python3 scripts/check-package.py`
2. `python3 -m unittest discover -s tests -v`
3. `qmllint --max-warnings 0` against the applet and configuration QML using installed Plasma/Qt QML modules
4. `python3 -m py_compile scripts/check-package.py scripts/profile-plasmashell.py tests/test_package_contract.py`
5. `bash -n` on all shell scripts
6. `bash scripts/build-rpm.sh` on Fedora with the RPM build dependencies installed

Keep `.qmllint.ini` warning policy strict; do not silence warnings merely to make CI green. Keep `.contextProperties.ini` limited to genuine Plasma context properties.

A CI pass does not replace a live Plasma runtime test. Do not claim runtime validation, screenshot capture, or COPR publication unless it actually happened.

## Release and packaging consistency

- Keep the version in package/metadata.json and packaging/alveus-dock.spec synchronized.
- Ensure the source tarball top-level directory matches the RPM spec's autosetup directory.
- Test the RPM file list and dependencies before publishing.
- Do not publish COPR instructions with a placeholder owner as if they were live.
