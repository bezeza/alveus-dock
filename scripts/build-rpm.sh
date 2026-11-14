#!/usr/bin/env bash
# SPDX-License-Identifier: GPL-3.0-only
set -euo pipefail

ROOT="$(cd "$(dirname "$0")/.." && pwd)"
NAME="alveus-dock"
SPEC="$ROOT/packaging/$NAME.spec"
TOPDIR="$ROOT/rpmbuild"
VERSION="$(awk '$1 == "Version:" { print $2; exit }' "$SPEC")"

if [[ -z "$VERSION" ]]; then
    echo "Could not read Version from $SPEC" >&2
    exit 1
fi

command -v rpmbuild >/dev/null 2>&1 || {
    echo "rpmbuild is required. On Fedora: sudo dnf install rpm-build rpmdevtools" >&2
    exit 1
}

command -v tar >/dev/null 2>&1 || {
    echo "tar is required." >&2
    exit 1
}

STAGE="$(mktemp -d)"
trap 'rm -rf "$STAGE"' EXIT

mkdir -p "$TOPDIR"/{BUILD,BUILDROOT,RPMS,SOURCES,SPECS,SRPMS}
mkdir -p "$STAGE/$NAME-$VERSION"

tar -C "$ROOT" --exclude=.git --exclude=rpmbuild --exclude=build -cf - . \
    | tar -C "$STAGE/$NAME-$VERSION" -xf -

tar -C "$STAGE" -czf "$TOPDIR/SOURCES/$NAME-$VERSION.tar.gz" "$NAME-$VERSION"

rpmbuild -ba "$SPEC" --define "_topdir $TOPDIR"

echo "RPM output: $TOPDIR/RPMS/noarch/"
