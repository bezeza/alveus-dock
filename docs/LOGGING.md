# Logging and diagnostics

## What is logged

Alveus Dock writes structured diagnostic messages through Qt's QML console.
They are collected by the Plasma session and can be read from the system
journal.

Log prefixes:

- `[AlveusDock][INFO]` — lifecycle, task count, launcher changes and dispatched user actions.
- `[AlveusDock][WARN]` — rejected or incomplete operations.
- `[AlveusDock][ERROR]` — caught action failures. Only the exception type is recorded, not its raw message.

Qt/Plasma QML parser and runtime errors are also expected to appear in the
Plasma journal with the QML file and line number.

## Privacy

The applet deliberately does not log raw exception messages because they can contain file paths or other session data. It also does not log:

- application names or window titles;
- file names, full paths or dropped URLs;
- document contents or user data.

The collector also filters the journal to Alveus Dock and relevant Plasma/QML
warnings and errors. Always inspect a log before sharing it.

## Watch logs live

```bash
journalctl --user -b -f | grep --line-buffered -iE 'AlveusDock|alveusdock|plasmashell.*(warning|error)|qml.*(warning|error)'
```

## Collect a diagnostic file

From the project directory:

```bash
bash scripts/collect-logs.sh
```

By default, the script collects the last 30 minutes and saves a timestamped
file under:

```text
~/.local/state/alveus-dock/logs/
```

A different time window can be supplied:

```bash
bash scripts/collect-logs.sh "2 hours ago"
```

If the journal has no matching records, the script writes that fact into the
output file. It does not silently claim that the applet is error-free.

Action log entries record that a KDE API call was dispatched. Some KDE task APIs return no result, so an INFO entry is not proof that the window manager completed the requested action.

## Current limitation

This release does not create a private log file directly from inside the
applet. It uses the existing KDE/Qt journal, avoiding a background daemon,
extra file-writing privileges and another component that could fail. The
collector exports the relevant records to a shareable file when requested.
