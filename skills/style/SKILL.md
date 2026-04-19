---
name: style
description: Set quote style for the spinner - verbs only, phrases only, or mix of both. Usage - /statusquote:style verbs|phrases|mix
user-invocable: true
---

# Set quote style

The user wants to change which type of quotes appear in the spinner.

## Styles

- **verbs** — Gerund-style words only (e.g., "Engaging", "Scanning", "Forging")
- **phrases** — Short quote phrases only (e.g., "Make it so", "Use the Force")
- **mix** — Both verbs and phrases combined (default)

## Steps

1. Parse `$ARGUMENTS` for the style mode. Accept: `verbs`, `phrases`, or `mix`. If invalid or missing, show the three options and the current setting.

2. Check if there are currently active packs in `~/.statusquote/config.json`. If no packs are active, save the style preference and tell the user to apply a pack first with `/statusquote:use`.

3. If packs are active, re-apply them with the new style. Read `activePacks` from config and build the apply command:
   ```
   bash "${CLAUDE_PLUGIN_ROOT}/src/apply.sh" --pack "${CLAUDE_PLUGIN_ROOT}/packs/<key1>.json" [--pack ...] --style <new_style>
   ```

4. Report the style change and how many entries are now in the spinner.
