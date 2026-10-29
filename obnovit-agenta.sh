#!/usr/bin/env bash
# Безопасное обновление навыков агента-продюсера.

set -euo pipefail

main() {
  local sklad="${CONTENT_AGENT_SKLAD:-https://github.com/lomakinigor/content-agent.git}"
  local tmp=".obnovlenie-tmp"
  local series="${1:-all}"
  local manifest="skill-series.tsv"
  local -a personal=("USER.md" "MEMORY.md" "SOUL.md" "memory" "knowledge" "content")
  local -a skills=()

  if [ ! -f "CLAUDE.md" ]; then
    echo "❌ Не вижу файла CLAUDE.md - похоже, это не папка агента."
    exit 1
  fi

  if [ -e "$tmp" ]; then
    echo "❌ Папка $tmp уже существует. Удали её вручную и запусти снова."
    exit 1
  fi

  echo "🔄 Проверяю свежую версию навыков. Личные файлы не трогаю."
  git clone --quiet --depth 1 "$sklad" "$tmp"

  if [ ! -f "$tmp/$manifest" ]; then
    echo "❌ В складе нет $manifest. Ничего не обновлено."
    exit 1
  fi

  while IFS='|' read -r group skill; do
    if [ -n "$group" ] && [ "${group#\#}" = "$group" ] && { [ "$series" = "all" ] || [ "$series" = "$group" ]; }; then
      skills+=("$skill")
    fi
  done < <(tr -d '\r' < "$tmp/$manifest")

  if [ "${#skills[@]}" -eq 0 ]; then
    echo "❌ Серия «$series» не найдена. Ничего не обновлено."
    exit 1
  fi

  for skill in "${skills[@]}"; do
    if [ ! -f "$tmp/skills/$skill/SKILL.md" ]; then
      echo "❌ В складе нет навыка $skill. Ничего не обновлено."
      exit 1
    fi
  done

  local before source_sha
  before="$(personal_snapshot "${personal[@]}")"
  source_sha="$(git -C "$tmp" rev-parse HEAD)"

  echo "🧩 Ставлю навыки из $source_sha:"
  for skill in "${skills[@]}"; do
    for agent in ".claude" ".codex"; do
      mkdir -p "$agent/skills/$skill"
      cp -R "$tmp/skills/$skill/." "$agent/skills/$skill/"
    done
    echo "   ✅ $skill"
  done

  cp "$tmp/obnovit-agenta.sh" obnovit-agenta.sh
  cp "$tmp/$manifest" "$manifest"
  printf '%s\n' "$source_sha" > .content-agent-version
  rm -rf -- "$tmp"

  if [ "$before" != "$(personal_snapshot "${personal[@]}")" ]; then
    echo "⚠️ Личные файлы изменились - такого быть не должно. Ничего не удаляй."
    exit 1
  fi

  echo "🔒 Проверка пройдена: личные файлы не изменились."
  echo "✅ Готово. Закрой этот чат и открой новый - агент подхватит обновления. Старый чат удали."
}

personal_snapshot() {
  for path in "$@"; do
    if [ -e "$path" ]; then
      /usr/bin/find "$path" -type f -exec /usr/bin/sha256sum {} \; 2>/dev/null | sort
    fi
  done
}

main "$@"
