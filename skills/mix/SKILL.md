---
name: mix
description: Alias for /statusquote:use. Mix multiple franchise or character packs. Usage - /statusquote:mix startrek+starwars or /statusquote:mix characters
user-invocable: true
---

# Mix quote packs (alias for /statusquote:use)

This command is an alias for `/statusquote:use`. It accepts the same arguments — pack keys, aliases, groups, and `+` combinations.

## Steps

Follow the exact same steps as the `use` skill:

1. Parse `$ARGUMENTS` — take the full argument string, trim whitespace, lowercase it.

2. Read the user's current style preference from `~/.statusquote/config.json`. Default to `mix` if not found.

3. Run:
   ```
   bash "${CLAUDE_PLUGIN_ROOT}/src/apply.sh" --keys "<arguments>" --packs-dir "${CLAUDE_PLUGIN_ROOT}/packs/" --style <current_style>
   ```

4. Report results the same way as `/statusquote:use`.
