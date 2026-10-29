# Спецификация: атомарное обновление навыков

## Problem statement

Публичный склад и updater разошлись по структуре. Обновление навыков невозможно проверить по версии и способно частично изменить служебные файлы до ошибки.

## User stories

- Как ученик, я запускаю `bash obnovit-agenta.sh` и получаю все навыки из manifest.
- Как ученик, я вижу commit SHA склада, из которого они поставлены.
- Как ученик, при неполном или повреждённом складе я не получаю частичного обновления.

## Acceptance criteria

- В корне склада есть `skill-series.tsv` с сериями `base`, `today`, `product`, `funnel`.
- Каждый навык из manifest существует в `skills/<name>/` и содержит `SKILL.md`.
- Updater проверяет manifest и все выбранные навыки до любых копирований в рабочий каталог.
- Updater копирует выбранный навык в `.claude/skills/` и `.codex/skills/`.
- После успешной установки updater записывает commit SHA в `.content-agent-version`.
- Неудачная проверка не меняет ни один файл рабочего агента.
- Личные файлы остаются неизменны.

## Affected files

- `skill-series.tsv`
- `skills/installer/`, `skills/unpacking/`, `skills/script-pack/`
- `obnovit-agenta.sh`
- `tests/atomic-skill-updates.test.sh`

## Data and API changes

Добавляется `.content-agent-version` в устанавливаемом агенте: одна строка с SHA склада. Внешних API нет.

## Test plan

- Red: тест требует manifest и всех skills в каноническом каталоге.
- Green: тест запускает updater в изолированной копии, проверяет установку в обе папки, SHA и неизменность личных файлов.
- Negative: неполный manifest завершает updater до изменения рабочего навыка.

## Rollback

Вернуть один commit склада. Установленный агент остаётся на предыдущей зафиксированной SHA до следующего запуска updater.
