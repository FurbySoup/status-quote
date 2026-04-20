---
name: create
description: Generate a custom quote pack for any movie, TV show, or character. Claude creates the pack, validates it, and saves it for immediate use. Usage - /statusquote:create <name> (e.g., breaking bad, the office, spock, walter white)
user-invocable: true
---

# Generate a custom quote pack

The user wants to create a new quote pack for: **$ARGUMENTS**

## Pack JSON Schema

Generate a JSON file with this exact structure:

```json
{
  "name": "<Human-readable name>",
  "key": "<lowercase-alphanumeric-key>",
  "aliases": ["<short-alias-if-key-is-long>"],
  "type": "<franchise or character>",
  "tags": ["<genre-tags>"],
  "verbs": ["<10-15 gerund-style spinner words>"],
  "phrases": ["<10-20 short iconic quotes>"],
  "metadata": {
    "source": "<Source description>",
    "contributor": "user-generated"
  }
}
```

## Rules for content

- **key**: Lowercase letters and numbers only, no spaces or hyphens (e.g., "breakingbad", "theoffice", "walterwhite")
- **type**: Use `"character"` if the input is a specific person/character, `"franchise"` if it's a show/movie/series
- **tags**: Choose from: `scifi`, `fantasy`, `comedy`, `action`, `mystery`. Use multiple if appropriate. Add new tags if none fit.
- **aliases**: Add a short alias if the key is 10+ characters (e.g., key "breakingbad" gets alias "bb")
- **verbs**: 10-15 entries. Gerund-style words that work as spinner text (e.g., "Cooking", "Heisenberging"). Must feel natural as a loading indicator.
- **phrases**: 10-20 entries. Short, iconic, widely recognizable quotes. Max 50 characters each.
- **All entries**: Only use characters `A-Za-z0-9 ',.!?-`. No backticks, semicolons, colons, or special characters.
- **No duplicates** within the pack (case-insensitive)
- **metadata.contributor**: Always set to `"user-generated"`

## Example entries for quality reference

Good verbs: "Investigating", "Cooking up a plan", "Channeling the Force", "Deducing"
Good phrases: "Say my name", "I am the one who knocks", "Make it so", "Inconceivable"
Bad (too long): "I am not in danger Skyler I am the danger you are looking at it" (over 50 chars)
Bad (invalid chars): "What's up, doc?" (the apostrophe after s is fine but watch for special quotes)

## Steps

1. **Determine type**: Is `$ARGUMENTS` a specific character or a franchise/show/movie? Set `type` accordingly.

2. **Generate the key**: Convert to lowercase, remove spaces and special characters. Examples:
   - "Breaking Bad" → "breakingbad"
   - "The Office" → "theoffice"
   - "Walter White" → "walterwhite"

3. **Check for conflicts**: Read the directory listing of `${CLAUDE_PLUGIN_ROOT}/packs/` and `~/.statusquote/packs/` to ensure no pack with the same key already exists. If a conflict is found, tell the user and ask if they want to overwrite.

4. **Generate content**: Create the verbs and phrases. Focus on:
   - The most iconic, universally recognized quotes
   - Verbs that capture the essence of the franchise/character
   - Variety — don't repeat the same theme across entries

   If the franchise or character is very obscure and you're not confident in the accuracy of the quotes, tell the user upfront — e.g., "I'm not very familiar with this one, so some of these might not be exact quotes. You'll be able to review and edit everything before saving."

5. **Preview before saving**: Show the user the complete generated pack — all verbs and all phrases in a numbered list. Ask them to review it and let them know they can:
   - Remove entries they don't like (e.g., "remove 3 and 7")
   - Replace entries with their own (e.g., "replace phrase 5 with 'I am the danger'")
   - Add new entries
   - Approve as-is

   Wait for the user's response. Apply any requested changes before proceeding. If they make changes, show the updated list for final confirmation.

6. **Write the file**: Once the user approves, save to `~/.statusquote/packs/<key>.json`. Create the directory if it doesn't exist:
   ```bash
   mkdir -p ~/.statusquote/packs
   ```

7. **Validate**: Run the validator to ensure the pack meets all requirements:
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/src/validate.sh" ~/.statusquote/packs/<key>.json
   ```
   If validation fails, fix the errors in the JSON and write it again, then re-validate.

8. **Report results**: Show the user:
   - Pack name and key
   - Number of verbs and phrases
   - File path where the pack was saved

9. **Ask to apply**: Ask the user if they want to apply the pack now. If yes, run:
   ```bash
   bash "${CLAUDE_PLUGIN_ROOT}/src/apply.sh" --keys "<key>" --packs-dir "${CLAUDE_PLUGIN_ROOT}/packs/" --custom-packs-dir ~/.statusquote/packs/ --style mix
   ```
   Use their current style preference from `~/.statusquote/config.json` if it exists.
