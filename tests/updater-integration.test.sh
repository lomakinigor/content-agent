#!/usr/bin/env bash

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
WORK="$(mktemp -d)"
trap 'rm -rf "$WORK"' EXIT

fixture="$WORK/agent"
mkdir -p "$fixture/.claude/skills" "$fixture/.codex/skills" "$fixture/memory" "$fixture/knowledge" "$fixture/content"
printf 'agent\n' > "$fixture/CLAUDE.md"
printf 'user\n' > "$fixture/USER.md"
printf 'memory\n' > "$fixture/MEMORY.md"
printf 'soul\n' > "$fixture/SOUL.md"
printf 'journal\n' > "$fixture/memory/today.md"
printf 'knowledge\n' > "$fixture/knowledge/notes.md"
printf 'content\n' > "$fixture/content/draft.md"

before="$(/usr/bin/find "$fixture/USER.md" "$fixture/MEMORY.md" "$fixture/SOUL.md" "$fixture/memory" "$fixture/knowledge" "$fixture/content" -type f -exec /usr/bin/sha256sum {} \; | sort)"

(
  cd "$fixture"
  CONTENT_AGENT_SKLAD="$ROOT" bash "$ROOT/obnovit-agenta.sh" base
)

while IFS='|' read -r series skill; do
  [ "$series" = "base" ] || continue
  test -f "$fixture/.claude/skills/$skill/SKILL.md"
  test -f "$fixture/.codex/skills/$skill/SKILL.md"
done < <(tr -d '\r' < "$ROOT/skill-series.tsv")

test "$(cat "$fixture/.content-agent-version")" = "$(git -C "$ROOT" rev-parse HEAD)"
cmp "$ROOT/obnovit-agenta.sh" "$fixture/obnovit-agenta.sh"
cmp "$ROOT/skill-series.tsv" "$fixture/skill-series.tsv"
after="$(/usr/bin/find "$fixture/USER.md" "$fixture/MEMORY.md" "$fixture/SOUL.md" "$fixture/memory" "$fixture/knowledge" "$fixture/content" -type f -exec /usr/bin/sha256sum {} \; | sort)"
test "$before" = "$after"

echo "PASS: updater installs a versioned skill series without changing personal files"
