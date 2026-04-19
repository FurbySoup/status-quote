# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

Statusquote is a Claude Code plugin that replaces the default spinner words ("Bamboozling", "Pondering", etc.) with iconic movie, TV, and character quotes via the `spinnerVerbs` setting in `~/.claude/settings.json`. 16 packs (10 franchises + 6 characters) with 520 total entries.

## Architecture

```
Plugin slash commands (SKILL.md) → apply.sh --keys → resolve aliases/groups → settings.json
                                        ↑
                                    packs/*.json (type, tags, aliases)
```

- **SKILL.md files** instruct Claude what to do when a slash command is invoked. They parse arguments and call `apply.sh`.
- **`src/apply.sh`** is the core engine. Accepts `--keys` (alias/group resolution) or `--pack` (direct path). Validates content and atomically writes `spinnerVerbs` to `~/.claude/settings.json` using embedded Python.
- **`packs/*.json`** are static franchise/character data files with `type`, `tags`, and optional `aliases` for UX shortcuts.
- **`~/.statusquote/config.json`** persists user preferences (active packs, style mode) across commands.

## Commands

```bash
# Apply via key resolution (aliases, groups, combinations)
bash src/apply.sh --keys "startrek" --packs-dir packs/ --style mix
bash src/apply.sh --keys "hp+bttf" --packs-dir packs/ --style verbs
bash src/apply.sh --keys "characters" --packs-dir packs/
bash src/apply.sh --keys "fantasy+t800" --packs-dir packs/
bash src/apply.sh --keys "all" --packs-dir packs/

# Apply via direct path (legacy)
bash src/apply.sh --pack packs/startrek.json --style mix

# List packs, groups, and aliases
bash src/apply.sh --list --packs-dir packs/

# Reset to defaults
bash src/apply.sh --reset

# Validate packs
bash src/validate.sh packs/*.json

# Run tests
bash src/test.sh
```

## Key Resolution

The `--keys` flag resolves input tokens in this order:
1. Built-in group: `all`, `franchises`, `characters`
2. Tag-based group: `scifi`, `fantasy`, `comedy`, `action`, `mystery`
3. Pack key: `startrek`, `yoda`, `gandalf`
4. Pack alias: `hp`, `bttf`, `jp`, `bride`, `jack`, `terminator`

Tokens are combined with `+` and deduplicated.

## Pack Schema

Required fields:
- `name` (string, max 50 chars) — human-readable name
- `key` (string, lowercase alphanumeric) — identifier used in commands
- `verbs` (array, 10-25 items) — gerund-style words
- `phrases` (array, 10-30 items) — short quotes
- `metadata.source` and `metadata.contributor`

Optional fields:
- `aliases` (array of strings) — short alternative keys (e.g., `["hp"]`)
- `type` (`"franchise"` or `"character"`) — for group selection
- `tags` (array of strings) — genre tags (e.g., `["scifi", "comedy"]`)

All entries: 2-50 characters, allowed chars: `A-Za-z0-9 ',.!?-`

Full schema at `schemas/pack.schema.json`.

## Key Design Decisions

- **Python for JSON manipulation** — `jq` is unreliable on Windows. Embedded inline in `apply.sh` to avoid separate `.py` files.
- **Atomic writes** — write to `.tmp` then `os.replace()` to prevent settings.json corruption.
- **Backup before every write** — `~/.claude/backups/settings.json.bak.<timestamp>`.
- **No runtime dependencies** — stdlib-only Python, no pip installs, no npm.
- **Strip `\r` from Python output** — Windows Python adds carriage returns that corrupt bash arrays. Line 276 of apply.sh strips these.
- **`use` and `mix` are the same command** — `mix` is an alias for `use`. Both accept keys, aliases, groups, and `+` combinations.

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
