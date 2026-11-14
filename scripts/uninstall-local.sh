#!/usr/bin/env bash
set -euo pipefail
command -v kpackagetool6 >/dev/null 2>&1 || {
    echo "kpackagetool6 is not installed."
    exit 1
}
kpackagetool6 --type Plasma/Applet --remove org.bezeza.alveusdock
echo "Alveus Dock removed from the current user's Plasma applets."
