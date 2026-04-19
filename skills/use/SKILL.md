---
name: use
description: Apply a franchise quote pack to the Claude Code spinner. Replaces default spinner words with themed quotes. Usage - /statusquote:use <franchise> (e.g., startrek, starwars, lotr, matrix, sherlock, marvel, harrypotter, princessbride, jurassicpark, backtothefuture)
user-invocable: true
---

# Apply a franchise quote pack

The user wants to switch their Claude Code spinner words to a specific franchise.

## Steps

1. Parse `$ARGUMENTS` to get the franchise key (e.g., `startrek`). The key is the first argument, lowercased and stripped of whitespace.

2. Check if the pack file exists at `${CLAUDE_PLUGIN_ROOT}/packs/<key>.json`. If not found, run `bash "${CLAUDE_PLUGIN_ROOT}/src/apply.sh" --list --packs-dir "${CLAUDE_PLUGIN_ROOT}/packs/"` and show the user the available packs.

3. Read the user's current style preference. Check if `~/.statusquote/config.json` exists and read the `style` field. Default to `mix` if not found.

4. Run the apply command:
   ```
   bash "${CLAUDE_PLUGIN_ROOT}/src/apply.sh" --pack "${CLAUDE_PLUGIN_ROOT}/packs/<key>.json" --style <current_style>
   ```

5. Read the pack file and report to the user:
   - Which franchise was applied
   - How many entries were loaded
   - Show 3-4 sample entries as a preview
   - Mention they can change style with `/statusquote:style`
