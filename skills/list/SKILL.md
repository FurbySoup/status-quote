---
name: list
description: List all available quote packs, groups, aliases, and show the currently active selection. Usage - /statusquote:list
user-invocable: true
---

# List available packs and groups

The user wants to see what's available and what's currently active.

## Steps

1. Run the list command:
   ```
   bash "${CLAUDE_PLUGIN_ROOT}/src/apply.sh" --list --packs-dir "${CLAUDE_PLUGIN_ROOT}/packs/"
   ```

   This outputs franchise packs, character packs, and available groups with entry counts.

2. Check if `~/.statusquote/config.json` exists. If it does, read it and show:
   - Currently active pack(s) from the `activePacks` field
   - Current style setting from the `style` field
   - When it was last applied from the `lastApplied` field

3. If no config exists, note that the user is using Claude Code's default spinner words.

4. Format the output cleanly, preserving the grouped layout from apply.sh.
