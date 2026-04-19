#!/bin/bash
# Validate a statusquote franchise pack JSON file
set -euo pipefail

if [ $# -lt 1 ]; then
  echo "Usage: bash validate.sh <pack.json> [<pack2.json> ...]" >&2
  exit 1
fi

# Find Python
PYTHON=""
for cmd in python python3 py; do
  if command -v "$cmd" &>/dev/null; then
    PYTHON="$cmd"
    break
  fi
done

if [ -z "$PYTHON" ]; then
  echo "ERROR: Python not found." >&2
  exit 1
fi

ERRORS=0

for PACK in "$@"; do
  $PYTHON -c "
import json, re, sys, os

path = sys.argv[1]
name = os.path.basename(path)
ALLOWED = re.compile(r\"^[A-Za-z0-9 ',.\-!?]+\$\")
errors = []

try:
    with open(path, 'r', encoding='utf-8') as f:
        pack = json.load(f)
except Exception as e:
    print(f'FAIL: {name} — cannot parse JSON: {e}')
    sys.exit(1)

# Required fields
for field in ('name', 'key', 'verbs', 'phrases', 'metadata'):
    if field not in pack:
        errors.append(f'missing required field: {field}')

if errors:
    print(f'FAIL: {name}')
    for e in errors:
        print(f'  - {e}')
    sys.exit(1)

# Key format
if not re.match(r'^[a-z][a-z0-9]*$', pack.get('key', '')):
    errors.append(f'key must be lowercase alphanumeric, got: {pack.get(\"key\", \"\")}')

# Metadata
meta = pack.get('metadata', {})
if 'source' not in meta:
    errors.append('metadata.source required')
if 'contributor' not in meta:
    errors.append('metadata.contributor required')

# Verbs
verbs = pack.get('verbs', [])
if not isinstance(verbs, list):
    errors.append('verbs must be an array')
elif len(verbs) < 10:
    errors.append(f'need at least 10 verbs, got {len(verbs)}')
elif len(verbs) > 25:
    errors.append(f'max 25 verbs, got {len(verbs)}')
else:
    for i, v in enumerate(verbs):
        if not isinstance(v, str) or len(v) < 2 or len(v) > 50:
            errors.append(f'verb[{i}] invalid length: \"{v}\"')
        elif not ALLOWED.match(v):
            errors.append(f'verb[{i}] has invalid characters: \"{v}\"')

# Phrases
phrases = pack.get('phrases', [])
if not isinstance(phrases, list):
    errors.append('phrases must be an array')
elif len(phrases) < 10:
    errors.append(f'need at least 10 phrases, got {len(phrases)}')
elif len(phrases) > 30:
    errors.append(f'max 30 phrases, got {len(phrases)}')
else:
    for i, p in enumerate(phrases):
        if not isinstance(p, str) or len(p) < 2 or len(p) > 50:
            errors.append(f'phrase[{i}] invalid length: \"{p}\"')
        elif not ALLOWED.match(p):
            errors.append(f'phrase[{i}] has invalid characters: \"{p}\"')

# Duplicates
all_entries = verbs + phrases
seen = set()
dupes = []
for e in all_entries:
    lower = e.lower()
    if lower in seen:
        dupes.append(e)
    seen.add(lower)
if dupes:
    errors.append(f'duplicate entries: {dupes}')

if errors:
    print(f'FAIL: {name}')
    for e in errors:
        print(f'  - {e}')
    sys.exit(1)
else:
    print(f'PASS: {name} ({len(verbs)} verbs, {len(phrases)} phrases)')
    sys.exit(0)
" "$PACK" || ERRORS=$((ERRORS + 1))
done

exit $ERRORS
