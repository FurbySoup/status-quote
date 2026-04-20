---
name: use
description: Apply quote packs to the Claude Code spinner. Accepts pack keys, aliases, or groups. Usage - /statusquote:use startrek, /statusquote:use yoda+vader, /statusquote:use characters, /statusquote:use all, /statusquote:use fantasy+t800, /statusquote:use hp
user-invocable: true
---

# Apply quote packs

The user wants to set their Claude Code spinner words. This command handles single packs, multi-pack mixes, aliases, and group keywords.

## Accepted input formats

- Single pack key: `startrek`, `yoda`, `gandalf`
- Alias: `hp` (Harry Potter), `bttf` (Back to the Future), `jp` (Jurassic Park), `bride` (Princess Bride), `jack` (Jack Sparrow), `t800` or `terminator`
- Group keyword: `all`, `franchises`, `characters`, `custom`, `scifi`, `fantasy`, `comedy`, `action`, `mystery`
- Combinations with `+`: `yoda+vader`, `fantasy+t800`, `characters+startrek`

## Steps

1. Parse `$ARGUMENTS` — take the full argument string, trim whitespace, lowercase it.

2. Read the user's current style preference from `~/.statusquote/config.json`. Default to `mix` if not found.

3. Run the apply command:
   ```
   bash "${CLAUDE_PLUGIN_ROOT}/src/apply.sh" --keys "<arguments>" --packs-dir "${CLAUDE_PLUGIN_ROOT}/packs/" --custom-packs-dir ~/.statusquote/packs/ --style <current_style>
   ```

4. If the command fails (unknown key/alias/group), show the error and run:
   ```
   bash "${CLAUDE_PLUGIN_ROOT}/src/apply.sh" --list --packs-dir "${CLAUDE_PLUGIN_ROOT}/packs/" --custom-packs-dir ~/.statusquote/packs/
   ```

5. On success, report:
   - Which packs were applied and how many entries
   - Show 3-4 sample entries as a preview
   - Mention `/statusquote:style` to change between verbs/phrases/mix
