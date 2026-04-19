# Statusquote

Replace Claude Code's default spinner words ("Bamboozling", "Pondering"...) with iconic movie and TV franchise quotes.

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
/statusquote:use startrek        # Apply Star Trek quotes
/statusquote:use matrix          # Switch to The Matrix
/statusquote:mix starwars+lotr   # Blend franchises
/statusquote:style verbs         # Gerund-style only ("Engaging", "Scanning")
/statusquote:style phrases       # Quote phrases only ("Make it so", "Use the Force")
/statusquote:style mix           # Both combined (default)
/statusquote:list                # Show available packs
/statusquote:reset               # Restore Claude Code defaults
```

## Available Packs

| Key | Franchise | Entries | Sample |
|-----|-----------|---------|--------|
| `startrek` | Star Trek | 35 | Engaging, Make it so, Beam me up |
| `starwars` | Star Wars | 35 | Channeling the Force, Do or do not |
| `lotr` | Lord of the Rings | 35 | Forging, You shall not pass |
| `matrix` | The Matrix | 35 | Jacking in, There is no spoon |
| `sherlock` | Sherlock Holmes | 35 | Deducing, Elementary, The game is afoot |
| `marvel` | Marvel MCU | 35 | Assembling, I am Iron Man |
| `harrypotter` | Harry Potter | 35 | Casting spells, Expecto Patronum |
| `princessbride` | The Princess Bride | 35 | Storming the castle, Inconceivable |
| `jurassicpark` | Jurassic Park | 35 | Sequencing DNA, Life finds a way |
| `backtothefuture` | Back to the Future | 35 | Flux capacitating, Great Scott |

**Total: 350 entries across 10 franchises.**

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
