#!/bin/bash
# statusquote apply script
# Reads franchise/character pack JSON files and writes spinnerVerbs to ~/.claude/settings.json
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
  bash apply.sh --keys <key1+key2+...> --packs-dir <directory> [--style verbs|phrases|mix]
  bash apply.sh --pack <pack.json> [--pack <pack2.json>] [--style verbs|phrases|mix]
  bash apply.sh --reset
  bash apply.sh --list --packs-dir <directory>

Options:
  --keys <string>          Keys, aliases, or groups separated by + (e.g. startrek+yoda, characters, all)
  --pack <file>            Path to a pack JSON file (repeatable, legacy)
  --packs-dir <dir>        Directory containing built-in pack JSON files
  --custom-packs-dir <dir> Directory containing user-created packs (default: ~/.statusquote/packs/)
  --style <mode>           Quote style: verbs, phrases, or mix (default: mix)
  --reset                  Remove spinnerVerbs and restore Claude Code defaults
  --list                   List available packs, groups, and aliases

Groups: all, franchises, characters, scifi, fantasy, comedy, action, mystery
USAGE
  exit 1
}

# Parse arguments
PACKS=()
KEYS=""
STYLE=""
RESET=false
LIST=false
PACKS_DIR=""
CUSTOM_PACKS_DIR="$HOME/.statusquote/packs"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --pack)
      [ -z "${2:-}" ] && usage
      PACKS+=("$2"); shift 2 ;;
    --keys)
      [ -z "${2:-}" ] && usage
      KEYS="$2"; shift 2 ;;
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
    --custom-packs-dir)
      [ -z "${2:-}" ] && usage
      CUSTOM_PACKS_DIR="$2"; shift 2 ;;
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
custom_dir = sys.argv[2]

def load_packs(directory, source):
    result = []
    if not os.path.isdir(directory):
        return result
    for p in sorted(glob.glob(os.path.join(directory, '*.json'))):
        try:
            data = json.load(open(p))
            data['_path'] = p
            data['_source'] = source
            result.append(data)
        except Exception as e:
            print(f'ERROR reading {os.path.basename(p)}: {e}', file=sys.stderr)
    return result

builtin = load_packs(packs_dir, 'builtin')
custom = load_packs(custom_dir, 'custom')

# Merge: custom packs override builtin with same key
seen_keys = set()
packs = []
for p in custom:
    packs.append(p)
    seen_keys.add(p.get('key'))
for p in builtin:
    if p.get('key') not in seen_keys:
        packs.append(p)
        seen_keys.add(p.get('key'))

if not packs:
    print('No packs found')
    sys.exit(0)

# Group by type and source
franchises = [p for p in packs if p.get('type') == 'franchise' and p['_source'] == 'builtin']
characters = [p for p in packs if p.get('type') == 'character' and p['_source'] == 'builtin']
custom_packs = [p for p in packs if p['_source'] == 'custom']
other = [p for p in packs if p['_source'] == 'builtin' and p.get('type') not in ('franchise', 'character')]

def print_pack(p):
    key = p.get('key', '?')
    name = p.get('name', '?')
    v = len(p.get('verbs', []))
    ph = len(p.get('phrases', []))
    aliases = p.get('aliases', [])
    alias_str = f'  (alias: {', '.join(aliases)})' if aliases else ''
    print(f'  {key:<18} {name:<25} {v:>2}v  {ph:>2}p{alias_str}')

if franchises:
    print(f'Franchise Packs ({len(franchises)}):')
    for p in sorted(franchises, key=lambda x: x.get('key','')):
        print_pack(p)

if characters:
    print(f'')
    print(f'Character Packs ({len(characters)}):')
    for p in sorted(characters, key=lambda x: x.get('key','')):
        print_pack(p)

if custom_packs:
    print(f'')
    print(f'Custom Packs ({len(custom_packs)}):')
    for p in sorted(custom_packs, key=lambda x: x.get('key','')):
        print_pack(p)

if other:
    print(f'')
    print(f'Other Packs ({len(other)}):')
    for p in sorted(other, key=lambda x: x.get('key','')):
        print_pack(p)

# Collect all tags
all_tags = set()
for p in packs:
    all_tags.update(p.get('tags', []))

total = sum(len(p.get('verbs', [])) + len(p.get('phrases', [])) for p in packs)

print(f'')
print(f'Groups:')
print(f'  all              Everything ({total} entries)')
f_count = sum(len(p.get('verbs',[]))+len(p.get('phrases',[])) for p in franchises)
c_count = sum(len(p.get('verbs',[]))+len(p.get('phrases',[])) for p in characters)
print(f'  franchises       All franchise packs ({f_count} entries)')
print(f'  characters       All character packs ({c_count} entries)')
if custom_packs:
    cu_count = sum(len(p.get('verbs',[]))+len(p.get('phrases',[])) for p in custom_packs)
    print(f'  custom           All custom packs ({cu_count} entries)')
for tag in sorted(all_tags):
    matching = [p for p in packs if tag in p.get('tags', [])]
    count = sum(len(p.get('verbs',[]))+len(p.get('phrases',[])) for p in matching)
    names = ', '.join(p.get('key') for p in matching)
    print(f'  {tag:<16} {names} ({count} entries)')
" "$PACKS_DIR" "$CUSTOM_PACKS_DIR"
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

# --- RESOLVE KEYS TO PACK PATHS ---
if [ -n "$KEYS" ] && [ -z "${PACKS[*]:-}" ]; then
  [ -z "$PACKS_DIR" ] && { echo "ERROR: --packs-dir required with --keys" >&2; exit 1; }

  RESOLVED=$($PYTHON -c "
import json, glob, os, sys

keys_str = sys.argv[1]
packs_dir = sys.argv[2]
custom_dir = sys.argv[3]

# Load packs from both directories (custom overrides builtin)
def load_dir(directory):
    result = []
    if not os.path.isdir(directory):
        return result
    for p in sorted(glob.glob(os.path.join(directory, '*.json'))):
        try:
            data = json.load(open(p))
            data['_path'] = p
            result.append(data)
        except:
            pass
    return result

all_packs = []
seen_keys = set()
for p in load_dir(custom_dir):
    all_packs.append(p)
    seen_keys.add(p.get('key'))
for p in load_dir(packs_dir):
    if p.get('key') not in seen_keys:
        all_packs.append(p)
        seen_keys.add(p.get('key'))

# Build lookup tables
by_key = {p['key']: p for p in all_packs}
by_alias = {}
for p in all_packs:
    for a in p.get('aliases', []):
        by_alias[a] = p

# Resolve a single token
def resolve_token(token):
    # Built-in group: all
    if token == 'all':
        return list(all_packs)
    # Built-in group: franchises
    if token == 'franchises':
        return [p for p in all_packs if p.get('type') == 'franchise']
    # Built-in group: characters
    if token == 'characters':
        return [p for p in all_packs if p.get('type') == 'character']
    # Built-in group: custom
    if token == 'custom':
        return [p for p in all_packs if p.get('metadata', {}).get('contributor') == 'user-generated']
    # Tag-based group
    tag_matches = [p for p in all_packs if token in p.get('tags', [])]
    if tag_matches:
        return tag_matches
    # Direct key match
    if token in by_key:
        return [by_key[token]]
    # Alias match
    if token in by_alias:
        return [by_alias[token]]
    # No match
    print(f'ERROR: Unknown pack, alias, or group: \"{token}\"', file=sys.stderr)
    print(f'Available keys: {', '.join(sorted(by_key.keys()))}', file=sys.stderr)
    print(f'Available aliases: {', '.join(sorted(by_alias.keys()))}', file=sys.stderr)
    print(f'Available groups: all, franchises, characters, scifi, fantasy, comedy, action, mystery', file=sys.stderr)
    sys.exit(2)

# Split on + and resolve each token
tokens = [t.strip().lower() for t in keys_str.split('+') if t.strip()]
resolved_packs = []
seen_keys = set()

for token in tokens:
    for pack in resolve_token(token):
        if pack['key'] not in seen_keys:
            resolved_packs.append(pack)
            seen_keys.add(pack['key'])

# Output resolved pack paths, one per line
for p in resolved_packs:
    print(p['_path'].replace(chr(92), '/'))
" "$KEYS" "$PACKS_DIR" "$CUSTOM_PACKS_DIR")

  if [ $? -ne 0 ]; then
    exit 2
  fi

  # Read resolved paths into PACKS array (strip \r from Windows Python output)
  while IFS= read -r line; do
    line="${line%$'\r'}"
    [ -n "$line" ] && PACKS+=("$line")
  done <<< "$RESOLVED"
fi

# --- APPLY MODE ---
[ ${#PACKS[@]} -eq 0 ] && { echo "ERROR: At least one --pack or --keys required" >&2; usage; }

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
