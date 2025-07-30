#!/bin/bash

DEBFILE="$1"
if [[ ! -f "$DEBFILE" ]]; then
  echo "Usage: $0 file.deb"
  exit 1
fi

TMPDIR=$(mktemp -d /tmp/deb.XXXXXXXXXX) || exit 1
trap "rm -rf '$TMPDIR'" EXIT

dpkg-deb -x "$DEBFILE" "$TMPDIR"
dpkg-deb --control "$DEBFILE" "$TMPDIR/DEBIAN"

CONTROL="$TMPDIR/DEBIAN/control"
if [[ ! -f "$CONTROL" ]]; then
  echo "Error: control file not found."
  exit 1
fi

OLD_HASH=$(sha256sum "$CONTROL" | cut -d ' ' -f1)
nano "$CONTROL"
NEW_HASH=$(sha256sum "$CONTROL" | cut -d ' ' -f1)

if [[ "$OLD_HASH" == "$NEW_HASH" ]]; then
  echo "Not modified. Original deb kept."
else
  echo "Modified. Rebuilding and replacing original..."
  dpkg -b "$TMPDIR" "$DEBFILE"
  echo "Updated: $DEBFILE"
  dpkg-scanpackages -m . /dev/null >Packages
fi
