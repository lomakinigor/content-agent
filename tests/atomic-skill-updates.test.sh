#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
MANIFEST="$ROOT/skill-series.tsv"

test -f "$MANIFEST"

while IFS='|' read -r series skill; do
  [ -n "$series" ] || continue
  case "$series" in \#*) continue ;; esac
  test -d "$ROOT/skills/$skill"
  test -f "$ROOT/skills/$skill/SKILL.md"
done < <(tr -d '\r' < "$MANIFEST")

echo "PASS: manifest skills are available from the canonical skills directory"
