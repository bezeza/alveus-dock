# Alveus Dock

A small standalone KDE Plasma 6 dock applet, initially targeting Fedora KDE
Plasma 6.8.x. It uses KDE's own task/window infrastructure and does not patch
or replace the stock Icons-Only Task Manager.

## Version 0.1.2 — source prototype

Includes:

- pinned launchers and running windows through `org.kde.taskmanager`;
- activate a window, or minimize it when clicking its active icon;
- middle-click to request a new application instance;
- right-click to pin/unpin, start another instance, or close a window;
- drag an icon onto another icon to reorder tasks;
- drop `.desktop` / `applications:` launchers anywhere on the Dock to pin them;
- drop ordinary files onto a running app icon to open them with that app;
- adjustable icon size, spacing and hover scale;
- finite elastic launch reaction and energy ring;
- finite attention pulse when an application demands attention;
- privacy-conscious diagnostics in the KDE/Qt journal;
- a script to collect Alveus Dock and relevant Plasma/QML log records;
- active-window marker and startup busy indicator;
- current-desktop and current-screen filters;
- no background daemon; KWin effects such as Magic Lamp remain KDE's job.

## Target platform

- Fedora KDE
- First runtime validation target: KDE Plasma 6.8.2
- Plasma 6.0+ metadata/API baseline, subject to runtime testing

## Local test install

```bash
bash scripts/install-local.sh
```

Then open the panel's **Add Widgets** menu and add **Alveus Dock**.

Remove:

```bash
bash scripts/uninstall-local.sh
```

## Build an RPM on Fedora

```bash
sudo dnf install rpm-build rpmdevtools
bash scripts/build-rpm.sh
```

Install a local build:

```bash
sudo dnf install ./rpmbuild/RPMS/noarch/alveus-dock-*.rpm
```

Remove:

```bash
sudo dnf remove alveus-dock
```

The RPM spec declares runtime dependencies for Plasma, KCMUtils, Kirigami and
Qt Quick. Exact dependency names still need verification on the target Fedora
release before publishing.

## COPR

The RPM spec and COPR notes are in `packaging/`. No COPR repository has been
created or published yet. After a successful Plasma runtime test, the intended
installation will be:

```bash
sudo dnf copr enable OWNER/alveus-dock
sudo dnf install alveus-dock
```

## Project history and diagnostics

- `CHANGELOG.md` — release-by-release changes.
- `docs/DEVELOPMENT_LOG.md` — dated development record and validation status.
- `docs/ROADMAP.md` — milestones, checklists and release criteria.
- `docs/LOGGING.md` — live journal viewing and log collection.

Collect a diagnostic file with `bash scripts/collect-logs.sh`.
It is saved under `~/.local/state/alveus-dock/logs/`. Review it before sharing.

## Validation status

Structural checks cover metadata JSON, KConfig XML, expected QML features and
RPM spec dependencies:

```bash
python3 scripts/check-package.py
```

This does not compile QML or verify Plasma runtime behavior. Before release,
run `qmllint` with Plasma 6.8 QML modules available and test the applet in a
separate Plasma user session. This archive has not been run on the user's PC.

## Layout

- `package/contents/ui/` — applet UI
- `package/contents/config/` — settings
- `packaging/` — Fedora RPM and COPR notes
- `.github/workflows/` — RPM build workflow
- `scripts/` — checks and local packaging helpers

## License

GPL-2.0-or-later.
