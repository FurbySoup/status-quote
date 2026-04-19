---
name: list
description: List all available franchise quote packs and show the currently active pack. Usage - /statusquote:list
user-invocable: true
---

# List available franchise packs

The user wants to see what franchise packs are available and which one is currently active.

## Steps

1. Run the list command:
   ```
   bash "${CLAUDE_PLUGIN_ROOT}/src/apply.sh" --list --packs-dir "${CLAUDE_PLUGIN_ROOT}/packs/"
   ```

2. Check if `~/.statusquote/config.json` exists. If it does, read it and show:
   - Currently active pack(s) from the `activePacks` field
   - Current style setting from the `style` field
   - When it was last applied from the `lastApplied` field

3. If no config exists, note that the user is using Claude Code's default spinner words.

4. Format the output as a clean table showing all available packs and highlight the active one(s).
