#!/usr/bin/env bash
set -euo pipefail

SINCE="${1:-30 minutes ago}"
STATE_HOME="${XDG_STATE_HOME:-$HOME/.local/state}"
OUT_DIR="$STATE_HOME/alveus-dock/logs"
STAMP="$(date '+%Y%m%d-%H%M%S')"
OUT_FILE="$OUT_DIR/alveus-dock-$STAMP.log"
TMP_FILE="$(mktemp)"
trap 'rm -f "$TMP_FILE"' EXIT

mkdir -p "$OUT_DIR"

if ! command -v journalctl >/dev/null 2>&1; then
    echo "journalctl is not available on this system." >&2
    exit 1
fi

if ! journalctl --user -b --since "$SINCE" --no-pager >"$TMP_FILE" 2>/dev/null; then
    journalctl -b --since "$SINCE" --no-pager >"$TMP_FILE" 2>/dev/null || true
fi

{
    echo "Alveus Dock diagnostic export"
    echo "Generated: $(date --iso-8601=seconds)"
    echo "Window: $SINCE"
    echo "Filter: Alveus Dock and relevant Plasma/QML warnings/errors"
    echo "Privacy: inspect this file before sharing."
    echo
    if ! grep -iE 'AlveusDock|org\.bezeza\.alveusdock|alveus-dock|main\.qml.*(warning|error)|plasmashell.*(warning|error)|qml.*(warning|error)' "$TMP_FILE"; then
        echo "No matching journal records found for this time window."
    fi
} > "$OUT_FILE"

echo "Diagnostic log saved to: $OUT_FILE"
echo "Review it before sharing; system logs may contain unrelated session details."
