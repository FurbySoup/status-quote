# Contributing to Statusquote

## For Personal Use

Use `/statusquote:create <name>` to generate any pack instantly — no PR needed. Custom packs are saved to `~/.statusquote/packs/` and immediately available to all commands.

## Adding to the Built-in Set

Want to add a pack that ships with the plugin for everyone? Packs can be **franchise packs** (a whole show/movie series) or **character packs** (a specific character's voice).

1. Create a JSON file in `packs/` named after the franchise or character (lowercase, no spaces): e.g., `packs/doctorwho.json` or `packs/spock.json`

2. Follow the pack schema:
```json
{
  "name": "Doctor Who",
  "key": "doctorwho",
  "aliases": ["drwho"],
  "type": "franchise",
  "tags": ["scifi"],
  "verbs": ["Regenerating", "Sonic screwdriving", "..."],
  "phrases": ["Allons-y", "Fantastic", "..."],
  "metadata": {
    "source": "Doctor Who (TV series)",
    "contributor": "your-github-username"
  }
}
```

3. Requirements:
   - **10-25 verbs** — gerund-style words that work as spinner text (e.g., "Scanning", "Investigating")
   - **10-30 phrases** — short, recognizable quotes (e.g., "Make it so", "Inconceivable")
   - **2-50 characters** per entry
   - **Allowed characters:** letters, numbers, spaces, `'` `,` `.` `!` `?` `-`
   - **No duplicates** within a pack (case-insensitive)

4. Optional fields:
   - **`aliases`** — short alternative keys (e.g., `["drwho"]`). Lowercase alphanumeric, max 10 chars.
   - **`type`** — `"franchise"` or `"character"`
   - **`tags`** — genre tags for group selection. Current tags: `scifi`, `fantasy`, `comedy`, `action`, `mystery`

5. Validate locally: `bash src/validate.sh packs/doctorwho.json`

6. Open a PR with just the new pack file.

## Content Guidelines

- Quotes should be widely recognizable — iconic lines, not deep cuts
- Keep it family-friendly
- No copyrighted song lyrics
- Attribute the correct source in `metadata.source`
- Prefer shorter phrases that look good as spinner text
- For character packs, capture the character's distinctive voice and speech patterns

## What Not to Include

- URLs or file paths
- Special characters beyond basic punctuation
- Spoiler-heavy quotes that only make sense with full context
- Quotes longer than 50 characters
