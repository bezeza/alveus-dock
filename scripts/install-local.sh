#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
command -v kpackagetool6 >/dev/null 2>&1 || {
    echo "kpackagetool6 is not installed."
    exit 1
}
kpackagetool6 --type Plasma/Applet --install "$ROOT/package"
echo "Alveus Dock installed for the current user. Add it from KDE's Add Widgets menu."
