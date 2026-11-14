#!/usr/bin/env bash
set -euo pipefail
ROOT="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")/.." && pwd)"
TOPDIR="$ROOT/rpmbuild"
command -v rpmbuild >/dev/null 2>&1 || {
    echo "rpmbuild is required. On Fedora: sudo dnf install rpm-build rpmdevtools"
    exit 1
}
mkdir -p "$TOPDIR"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
tar --exclude=.git --exclude=rpmbuild \
    --transform='s,^,alveus-dock-0.1.1/,' \
    -czf "$TOPDIR/SOURCES/alveus-dock-0.1.1.tar.gz" -C "$ROOT" .
rpmbuild -ba "$ROOT/packaging/alveus-dock.spec" --define "_topdir $TOPDIR"
echo "RPM output: $TOPDIR/RPMS/noarch/"
