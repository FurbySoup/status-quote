#!/bin/bash
# statusquote apply script
# Reads franchise pack JSON files and writes spinnerVerbs to ~/.claude/settings.json
# Uses Python for safe JSON manipulation

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
SETTINGS_FILE="$HOME/.claude/settings.json"
BACKUP_DIR="$HOME/.claude/backups"
CONFIG_DIR="$HOME/.statusquote"
CONFIG_FILE="$CONFIG_DIR/config.json"

# Find Python
PYTHON=""
for cmd in python python3 py; do
  if command -v "$cmd" &>/dev/null; then
    PYTHON="$cmd"
    break
  fi
done

if [ -z "$PYTHON" ]; then
  echo "ERROR: Python not found. Install Python 3.10+ and ensure it's on PATH." >&2
  exit 1
fi

usage() {
  cat <<'USAGE'
Usage:
  bash apply.sh --pack <pack.json> [--pack <pack2.json>] [--style verbs|phrases|mix]
  bash apply.sh --reset
  bash apply.sh --list --packs-dir <directory>

Options:
  --pack <file>     Path to a franchise pack JSON file (repeatable)
  --style <mode>    Quote style: verbs, phrases, or mix (default: mix)
  --reset           Remove spinnerVerbs and restore Claude Code defaults
  --list            List available packs
  --packs-dir <dir> Directory containing pack JSON files (used with --list)
USAGE
  exit 1
}

# Parse arguments
PACKS=()
STYLE=""
RESET=false
LIST=false
PACKS_DIR=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pack)
      [ -z "${2:-}" ] && usage
      PACKS+=("$2"); shift 2 ;;
    --style)
      [ -z "${2:-}" ] && usage
      STYLE="$2"; shift 2 ;;
    --reset)
      RESET=true; shift ;;
    --list)
      LIST=true; shift ;;
    --packs-dir)
      [ -z "${2:-}" ] && usage
      PACKS_DIR="$2"; shift 2 ;;
    *)
      echo "Unknown option: $1" >&2; usage ;;
  esac
done

# --- LIST MODE ---
if $LIST; then
  [ -z "$PACKS_DIR" ] && { echo "ERROR: --packs-dir required with --list" >&2; exit 1; }
  $PYTHON -c "
import json, glob, os, sys

packs_dir = sys.argv[1]
packs = sorted(glob.glob(os.path.join(packs_dir, '*.json')))
if not packs:
    print('No packs found in', packs_dir)
    sys.exit(0)

print(f'Available packs ({len(packs)}):')
print(f'{\"Key\":<20} {\"Name\":<25} {\"Verbs\":<8} {\"Phrases\":<8}')
print('-' * 61)
for p in packs:
    try:
        data = json.load(open(p))
        key = data.get('key', '?')
        name = data.get('name', '?')
        v = len(data.get('verbs', []))
        ph = len(data.get('phrases', []))
        print(f'{key:<20} {name:<25} {v:<8} {ph:<8}')
    except Exception as e:
        print(f'ERROR reading {os.path.basename(p)}: {e}', file=sys.stderr)
" "$PACKS_DIR"
  exit 0
fi

# --- RESET MODE ---
if $RESET; then
  $PYTHON -c "
import json, os, sys, shutil, time

settings_path = sys.argv[1]
backup_dir = sys.argv[2]
config_path = sys.argv[3]

if not os.path.exists(settings_path):
    print('ERROR: settings.json not found at', settings_path, file=sys.stderr)
    sys.exit(3)

# Backup
os.makedirs(backup_dir, exist_ok=True)
ts = int(time.time())
shutil.copy2(settings_path, os.path.join(backup_dir, f'settings.json.bak.{ts}'))

# Remove spinnerVerbs
with open(settings_path, 'r', encoding='utf-8') as f:
    settings = json.load(f)

if 'spinnerVerbs' not in settings:
    print('spinnerVerbs not set — already using defaults.')
    sys.exit(0)

del settings['spinnerVerbs']

tmp = settings_path + '.tmp'
with open(tmp, 'w', encoding='utf-8') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write('\n')
os.replace(tmp, settings_path)

# Clear statusquote config
if os.path.exists(config_path):
    os.remove(config_path)

print('Reset complete — spinner restored to Claude Code defaults.')
" "$SETTINGS_FILE" "$BACKUP_DIR" "$CONFIG_FILE"
  exit $?
fi

# --- APPLY MODE ---
[ ${#PACKS[@]} -eq 0 ] && { echo "ERROR: At least one --pack required" >&2; usage; }

# Read style from config if not specified
if [ -z "$STYLE" ]; then
  STYLE=$($PYTHON -c "
import json, os, sys
cfg = sys.argv[1]
if os.path.exists(cfg):
    try:
        data = json.load(open(cfg))
        print(data.get('style', 'mix'))
    except:
        print('mix')
else:
    print('mix')
" "$CONFIG_FILE")
fi

# Validate style
case "$STYLE" in
  verbs|phrases|mix) ;;
  *) echo "ERROR: Invalid style '$STYLE'. Use: verbs, phrases, or mix" >&2; exit 1 ;;
esac

# Validate and apply packs
for p in "${PACKS[@]}"; do
  [ ! -f "$p" ] && { echo "ERROR: Pack file not found: $p" >&2; exit 2; }
done

$PYTHON -c "
import json, os, sys, shutil, time, re

style = sys.argv[1]
settings_path = sys.argv[2]
backup_dir = sys.argv[3]
config_dir = sys.argv[4]
config_path = sys.argv[5]
pack_paths = sys.argv[6:]

ALLOWED = re.compile(r\"^[A-Za-z0-9 ',.\-!?]+\$\")

# Validate all packs
all_verbs = []
all_phrases = []
pack_keys = []

for path in pack_paths:
    try:
        with open(path, 'r', encoding='utf-8') as f:
            pack = json.load(f)
    except Exception as e:
        print(f'ERROR: Cannot read {path}: {e}', file=sys.stderr)
        sys.exit(2)

    for field in ('name', 'key', 'verbs', 'phrases', 'metadata'):
        if field not in pack:
            print(f'ERROR: Pack {path} missing required field: {field}', file=sys.stderr)
            sys.exit(2)

    for entry in pack['verbs'] + pack['phrases']:
        if not isinstance(entry, str) or len(entry) < 2 or len(entry) > 50:
            print(f'ERROR: Invalid entry length in {path}: \"{entry}\"', file=sys.stderr)
            sys.exit(2)
        if not ALLOWED.match(entry):
            print(f'ERROR: Invalid characters in {path}: \"{entry}\"', file=sys.stderr)
            sys.exit(2)

    if len(pack['verbs']) < 10:
        print(f'ERROR: Pack {path} needs at least 10 verbs (has {len(pack[\"verbs\"])})', file=sys.stderr)
        sys.exit(2)
    if len(pack['phrases']) < 10:
        print(f'ERROR: Pack {path} needs at least 10 phrases (has {len(pack[\"phrases\"])})', file=sys.stderr)
        sys.exit(2)

    all_verbs.extend(pack['verbs'])
    all_phrases.extend(pack['phrases'])
    pack_keys.append(pack['key'])

# Build spinner list based on style
if style == 'verbs':
    spinner = all_verbs
elif style == 'phrases':
    spinner = all_phrases
else:
    spinner = all_verbs + all_phrases

if not spinner:
    print('ERROR: No entries to apply', file=sys.stderr)
    sys.exit(2)

# Read existing settings
if not os.path.exists(settings_path):
    print(f'ERROR: settings.json not found at {settings_path}', file=sys.stderr)
    sys.exit(3)

with open(settings_path, 'r', encoding='utf-8') as f:
    settings = json.load(f)

# Backup
os.makedirs(backup_dir, exist_ok=True)
ts = int(time.time())
shutil.copy2(settings_path, os.path.join(backup_dir, f'settings.json.bak.{ts}'))

# Write spinnerVerbs
settings['spinnerVerbs'] = {
    'mode': 'replace',
    'verbs': spinner
}

tmp = settings_path + '.tmp'
with open(tmp, 'w', encoding='utf-8') as f:
    json.dump(settings, f, indent=2, ensure_ascii=False)
    f.write('\n')
os.replace(tmp, settings_path)

# Save statusquote config
os.makedirs(config_dir, exist_ok=True)
config = {
    'style': style,
    'activePacks': pack_keys,
    'lastApplied': time.strftime('%Y-%m-%dT%H:%M:%SZ', time.gmtime())
}
with open(config_path, 'w', encoding='utf-8') as f:
    json.dump(config, f, indent=2)
    f.write('\n')

print(f'Applied {len(spinner)} entries from {len(pack_keys)} pack(s) [{style} mode]')
print(f'Packs: {', '.join(pack_keys)}')
print(f'Backup saved to {backup_dir}/')
" "$STYLE" "$SETTINGS_FILE" "$BACKUP_DIR" "$CONFIG_DIR" "$CONFIG_FILE" "${PACKS[@]}"
exit $?
