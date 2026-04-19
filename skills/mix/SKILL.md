---
name: mix
description: Mix multiple franchise packs together for the Claude Code spinner. Usage - /statusquote:mix startrek+starwars or /statusquote:mix lotr+matrix+marvel
user-invocable: true
---

# Mix multiple franchise packs

The user wants to blend quotes from multiple franchises into their spinner.

## Steps

1. Parse `$ARGUMENTS` — split on `+` to get franchise keys. Strip whitespace from each key and lowercase them.

2. Validate each key has a corresponding pack file at `${CLAUDE_PLUGIN_ROOT}/packs/<key>.json`. If any pack is missing, list the missing ones and show available packs by running:
   ```
   bash "${CLAUDE_PLUGIN_ROOT}/src/apply.sh" --list --packs-dir "${CLAUDE_PLUGIN_ROOT}/packs/"
   ```

3. Read the user's current style preference from `~/.statusquote/config.json`. Default to `mix` if not found.

4. Build the apply command with multiple `--pack` flags:
   ```
   bash "${CLAUDE_PLUGIN_ROOT}/src/apply.sh" --pack "${CLAUDE_PLUGIN_ROOT}/packs/<key1>.json" --pack "${CLAUDE_PLUGIN_ROOT}/packs/<key2>.json" --style <current_style>
   ```

5. Report to the user:
   - Which franchises were blended
   - Total entry count
   - A few sample entries from each franchise
