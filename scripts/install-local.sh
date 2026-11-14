#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
set -euo pipefail
ROOT="$(cd "$(dirname "$0")/.." && pwd)"
command -v kpackagetool6 >/dev/null 2>&1 || {
    echo "kpackagetool6 is not installed. On Fedora: sudo dnf install kf6-kpackage" >&2
    exit 1
}
kpackagetool6 --type Plasma/Applet --install "$ROOT/package"
echo "Alveus Dock installed for the current user. Add it from KDE's Add Widgets menu."
