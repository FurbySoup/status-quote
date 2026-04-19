# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Statusquote is a Claude Code plugin that replaces the default spinner words ("Bamboozling", "Pondering", etc.) with iconic movie and TV franchise quotes via the `spinnerVerbs` setting in `~/.claude/settings.json`.

## Architecture

```
Plugin slash commands (SKILL.md) → apply.sh → settings.json
                                      ↑
                                  packs/*.json
```

- **SKILL.md files** instruct Claude what to do when a slash command is invoked. They parse arguments and call `apply.sh`.
- **`src/apply.sh`** is the core engine. It reads pack JSON files, validates content, and atomically writes `spinnerVerbs` to `~/.claude/settings.json` using embedded Python for safe JSON manipulation.
- **`packs/*.json`** are static franchise data files containing curated verbs and phrases.
- **`~/.statusquote/config.json`** persists user preferences (active packs, style mode) across commands.

## Commands

```bash
# Validate a pack file
bash src/validate.sh packs/startrek.json

# Apply a pack directly (bypassing skills)
bash src/apply.sh --pack packs/startrek.json --style mix

# Apply multiple packs
bash src/apply.sh --pack packs/startrek.json --pack packs/matrix.json --style verbs

# List available packs
bash src/apply.sh --list --packs-dir packs/

# Reset to defaults
bash src/apply.sh --reset

# Validate all packs
bash src/validate.sh packs/*.json

# Run tests
bash src/test.sh
```

## Pack Schema

Each pack file must contain:
- `name` (string, max 50 chars) — human-readable franchise name
- `key` (string, lowercase alphanumeric) — identifier used in commands
- `verbs` (array, 10-25 items) — gerund-style words (e.g., "Engaging", "Scanning")
- `phrases` (array, 10-30 items) — short quotes (e.g., "Make it so", "Inconceivable")
- `metadata.source` and `metadata.contributor` — provenance info

All entries: 2-50 characters, allowed chars: `A-Za-z0-9 ',.!?-`

Full schema at `schemas/pack.schema.json`.

## Key Design Decisions

- **Python for JSON manipulation** — `jq` is unreliable on Windows. Python is always available (`C:/Python314/python.exe` confirmed). Embedded inline in `apply.sh` to avoid separate `.py` files.
- **Atomic writes** — write to `.tmp` then `os.replace()` to prevent settings.json corruption on crash.
- **Backup before every write** — `~/.claude/backups/settings.json.bak.<timestamp>`. Never modify settings.json without a backup.
- **No runtime dependencies** — stdlib-only Python, no pip installs, no npm. Works on any system with Python 3.10+ and bash.
- **Plugin cannot set spinnerVerbs via its own settings.json** — Claude Code plugin settings.json only supports `agent` and `subagentStatusLine`. Skills must call `apply.sh` to modify the user's `~/.claude/settings.json`.

## Security

- All pack entries validated: max 50 chars, pattern `^[A-Za-z0-9 ',.!?-]+$`
- No backticks, semicolons, curly braces, or characters that could break JSON or enable injection
- `spinnerVerbs` is UI-only (displayed in spinner, never passed to Claude's context)
- Community pack PRs validated by CI before merge

## File Locations

| File | Purpose |
|------|---------|
| `~/.claude/settings.json` | Where spinnerVerbs is written |
| `~/.claude/backups/` | Settings backups before each modification |
| `~/.statusquote/config.json` | User preferences (style, active packs) |
