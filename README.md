# Statusquote

Replace Claude Code's default spinner words ("Bamboozling", "Pondering"...) with iconic movie, TV, and character quotes.

Instead of generic processing words, see **"Engaging"**, **"There is no spoon"**, or **"Inconceivable!"** while Claude works.

## Install

```bash
/plugin marketplace add FurbySoup/statusquote
/plugin install statusquote@statusquote
```

Or load directly during development:
```bash
claude --plugin-dir /path/to/statusquote
```

## Quick Start

```
/statusquote:use startrek              # Apply Star Trek quotes
/statusquote:use yoda+vader            # Mix character packs
/statusquote:use characters            # All character packs
/statusquote:use fantasy               # All fantasy-tagged packs
/statusquote:use all                   # Everything (520 entries)
/statusquote:use hp                    # Alias for harrypotter
/statusquote:create breaking bad        # Generate a custom pack instantly
/statusquote:create spock              # Works for characters too
/statusquote:style verbs               # Gerund-style only ("Engaging", "Scanning")
/statusquote:style phrases             # Quote phrases only ("Make it so")
/statusquote:style mix                 # Both combined (default)
/statusquote:list                      # Show packs, groups, and aliases
/statusquote:reset                     # Restore Claude Code defaults
```

## Available Packs

### Franchise Packs (10)

| Key | Franchise | Entries | Alias | Sample |
|-----|-----------|---------|-------|--------|
| `startrek` | Star Trek | 35 | | Engaging, Make it so |
| `starwars` | Star Wars | 35 | | Channeling the Force, Do or do not |
| `lotr` | Lord of the Rings | 35 | | Forging, You shall not pass |
| `matrix` | The Matrix | 35 | | Jacking in, There is no spoon |
| `sherlock` | Sherlock Holmes | 35 | | Deducing, Elementary |
| `marvel` | Marvel MCU | 35 | | Assembling, I am Iron Man |
| `harrypotter` | Harry Potter | 35 | `hp` | Casting spells, Expecto Patronum |
| `princessbride` | The Princess Bride | 35 | `bride` | Storming the castle, Inconceivable |
| `jurassicpark` | Jurassic Park | 35 | `jp` | Sequencing DNA, Life finds a way |
| `backtothefuture` | Back to the Future | 35 | `bttf` | Flux capacitating, Great Scott |

### Character Packs (6)

| Key | Character | Entries | Alias | Sample |
|-----|-----------|---------|-------|--------|
| `yoda` | Yoda | 30 | | Contemplating I am, Do or do not |
| `vader` | Darth Vader | 30 | | Force choking, I find your lack of faith disturbing |
| `gandalf` | Gandalf | 30 | | Wizarding, You shall not pass |
| `sparrow` | Jack Sparrow | 30 | `jack` | Swashbuckling, But you have heard of me |
| `t800` | The Terminator | 30 | `terminator` | Scanning, I'll be back |
| `groot` | Groot | 20 | | I am Grooting, I am Groot! |

**Total: 520 entries across 16 packs.**

## Groups

Use group keywords to apply multiple packs at once:

| Group | Packs | Entries |
|-------|-------|---------|
| `all` | Everything | 520 |
| `franchises` | All 10 franchise packs | 350 |
| `characters` | All 6 character packs | 170 |
| `scifi` | Trek, Wars, Matrix, JP, BTTF, Marvel, T-800, Vader, Yoda, Groot | 320 |
| `fantasy` | LOTR, HP, Bride, Wars, Gandalf, Yoda | 200 |
| `comedy` | BTTF, Bride, Sparrow, Groot | 120 |
| `action` | Marvel, T-800 | 65 |
| `mystery` | Sherlock | 35 |

Combine groups and individual packs with `+`:
```
/statusquote:use fantasy+t800          # All fantasy packs + Terminator
/statusquote:use characters+startrek   # All characters + Star Trek
```

## Create Your Own

Don't see your favorite franchise? Generate a custom pack instantly:

```
/statusquote:create breaking bad
/statusquote:create the office
/statusquote:create walter white
```

Claude generates the pack, validates it, and saves it to `~/.statusquote/packs/`. Custom packs are immediately available to all commands — they show up in `/statusquote:list`, work with `/statusquote:use`, and are included in the `all` and `custom` groups.

## How It Works

Statusquote writes to the `spinnerVerbs` setting in `~/.claude/settings.json`:

```json
{
  "spinnerVerbs": {
    "mode": "replace",
    "verbs": ["Engaging", "Scanning", "Make it so", "Fascinating", "..."]
  }
}
```

A backup of your settings is saved before every change to `~/.claude/backups/`.

## Adding Your Own Pack

See [CONTRIBUTING.md](CONTRIBUTING.md) for the pack schema and submission guidelines.

```bash
# Validate your pack
bash src/validate.sh packs/yourpack.json
```

## Requirements

- Claude Code with plugin support
- Python 3.10+ (used for safe JSON manipulation)
- Bash (Git Bash on Windows)

## License

MIT
