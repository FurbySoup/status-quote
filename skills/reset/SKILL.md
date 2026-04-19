---
name: reset
description: Reset the Claude Code spinner to its default words, removing all franchise quotes. Usage - /statusquote:reset
user-invocable: true
---

# Reset spinner to defaults

The user wants to remove all franchise quotes and restore Claude Code's default spinner words.

## Steps

1. Run the reset command:
   ```
   bash "${CLAUDE_PLUGIN_ROOT}/src/apply.sh" --reset
   ```

2. Confirm to the user that:
   - Custom spinner verbs have been removed
   - Claude Code will use its default spinner words again
   - Their settings.json backup was saved to `~/.claude/backups/`
   - They can re-apply a pack anytime with `/statusquote:use`
