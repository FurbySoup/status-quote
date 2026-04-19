# Contributing to Statusquote

## Adding a New Franchise Pack

1. Create a JSON file in `packs/` named after the franchise (lowercase, no spaces): e.g., `packs/doctorwho.json`

2. Follow the pack schema:
```json
{
  "name": "Doctor Who",
  "key": "doctorwho",
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

4. Validate locally: `bash src/validate.sh packs/doctorwho.json`

5. Open a PR with just the new pack file.

## Content Guidelines

- Quotes should be widely recognizable — iconic lines, not deep cuts
- Keep it family-friendly
- No copyrighted song lyrics
- Attribute the correct franchise in `metadata.source`
- Prefer shorter phrases that look good as spinner text

## What Not to Include

- URLs or file paths
- Special characters beyond basic punctuation
- Spoiler-heavy quotes that only make sense with full context
- Quotes longer than 50 characters
