#!/bin/bash
# Statusquote test suite
# Tests validation, apply, reset, and mix against a temporary settings.json
set -uo pipefail

SCRIPT_DIR="$(cd "$(dirname "$0")" && pwd)"
PROJECT_DIR="$(cd "$SCRIPT_DIR/.." && pwd)"
PASS=0
FAIL=0

# Colors
GREEN='\033[32m'
RED='\033[31m'
RESET='\033[0m'

pass() { echo -e "  ${GREEN}PASS${RESET}: $1"; PASS=$((PASS + 1)); }
fail() { echo -e "  ${RED}FAIL${RESET}: $1"; FAIL=$((FAIL + 1)); }

# Find Python
PYTHON=""
for cmd in python python3 py; do
  if command -v "$cmd" &>/dev/null; then
    PYTHON="$cmd"
    break
  fi
done
[ -z "$PYTHON" ] && { echo "ERROR: Python not found"; exit 1; }

# Create temp dir — convert to Windows path for Python compatibility
TMPDIR_RAW=$(mktemp -d)
# Use cygpath if available (Git Bash on Windows), otherwise use raw path
if command -v cygpath &>/dev/null; then
  TMPDIR_WIN=$(cygpath -w "$TMPDIR_RAW")
  # Convert back to forward slashes for bash compatibility
  TMPDIR_COMPAT=$(echo "$TMPDIR_WIN" | sed 's/\\/\//g')
else
  TMPDIR_COMPAT="$TMPDIR_RAW"
fi

ORIG_HOME="$HOME"

echo "=== Statusquote Test Suite ==="
echo ""

# --- Test 1: Validate all packs ---
echo "Test 1: Pack validation"
if bash "$SCRIPT_DIR/validate.sh" "$PROJECT_DIR"/packs/*.json; then
  pass "All packs pass validation"
else
  fail "Some packs failed validation"
fi

# --- Test 2: Reject invalid pack ---
echo ""
echo "Test 2: Invalid pack rejection"
cat > "$TMPDIR_RAW/bad.json" << 'JSON'
{"name":"Bad","key":"bad","verbs":["One"],"phrases":["A"],"metadata":{"source":"test","contributor":"test"}}
JSON
if bash "$SCRIPT_DIR/validate.sh" "$TMPDIR_RAW/bad.json" 2>/dev/null; then
  fail "Should reject pack with too few entries"
else
  pass "Correctly rejects invalid pack"
fi

# --- Test 3: Apply to temporary settings ---
echo ""
echo "Test 3: Apply to settings.json"

# Create a fake settings.json using Windows-compatible path
FAKE_HOME="$TMPDIR_COMPAT/fakehome"
mkdir -p "$FAKE_HOME/.claude"
cat > "$FAKE_HOME/.claude/settings.json" << 'JSON'
{
  "env": {"TEST": "true"},
  "hooks": {},
  "statusLine": {"type": "command", "command": "echo test"}
}
JSON

# Override HOME for the test
export HOME="$FAKE_HOME"

if bash "$SCRIPT_DIR/apply.sh" --pack "$PROJECT_DIR/packs/startrek.json" --style verbs; then
  # Check spinnerVerbs was written
  HAS_SPINNER=$($PYTHON -c "import json; s=json.load(open(r'$FAKE_HOME/.claude/settings.json')); print('spinnerVerbs' in s)")
  if [ "$HAS_SPINNER" = "True" ]; then
    pass "spinnerVerbs written to settings.json"
  else
    fail "spinnerVerbs not found after apply"
  fi

  # Check existing keys preserved
  HAS_ENV=$($PYTHON -c "import json; s=json.load(open(r'$FAKE_HOME/.claude/settings.json')); print(s.get('env', {}).get('TEST', ''))")
  if [ "$HAS_ENV" = "true" ]; then
    pass "Existing settings keys preserved"
  else
    fail "Existing settings keys were lost"
  fi
else
  fail "apply.sh returned non-zero"
fi

# --- Test 4: Style modes ---
echo ""
echo "Test 4: Style modes"

for style in verbs phrases mix; do
  bash "$SCRIPT_DIR/apply.sh" --pack "$PROJECT_DIR/packs/startrek.json" --style "$style" >/dev/null 2>&1 || true
  COUNT=$($PYTHON -c "
import json
try:
    s=json.load(open(r'$FAKE_HOME/.claude/settings.json'))
    print(len(s.get('spinnerVerbs', {}).get('verbs', [])))
except:
    print(0)
")
  if [ "$COUNT" -gt 0 ] 2>/dev/null; then
    pass "Style '$style' produced $COUNT entries"
  else
    fail "Style '$style' produced 0 entries"
  fi
done

# --- Test 5: Multi-pack mix ---
echo ""
echo "Test 5: Multi-pack mix"
bash "$SCRIPT_DIR/apply.sh" --pack "$PROJECT_DIR/packs/startrek.json" --pack "$PROJECT_DIR/packs/starwars.json" --style mix >/dev/null 2>&1 || true
COUNT=$($PYTHON -c "
import json
try:
    s=json.load(open(r'$FAKE_HOME/.claude/settings.json'))
    print(len(s.get('spinnerVerbs', {}).get('verbs', [])))
except:
    print(0)
")
if [ "$COUNT" -eq 70 ] 2>/dev/null; then
  pass "Two packs combined: $COUNT entries (expected 70)"
else
  fail "Two packs combined: $COUNT entries (expected 70)"
fi

# --- Test 6: Reset ---
echo ""
echo "Test 6: Reset"
bash "$SCRIPT_DIR/apply.sh" --reset >/dev/null 2>&1 || true
HAS_SPINNER=$($PYTHON -c "
import json
try:
    s=json.load(open(r'$FAKE_HOME/.claude/settings.json'))
    print('spinnerVerbs' in s)
except:
    print('Error')
")
if [ "$HAS_SPINNER" = "False" ]; then
  pass "spinnerVerbs removed after reset"
else
  fail "spinnerVerbs still present after reset"
fi

# Check other keys still there
HAS_ENV=$($PYTHON -c "
import json
try:
    s=json.load(open(r'$FAKE_HOME/.claude/settings.json'))
    print(s.get('env', {}).get('TEST', ''))
except:
    print('')
")
if [ "$HAS_ENV" = "true" ]; then
  pass "Existing keys preserved after reset"
else
  fail "Existing keys lost after reset"
fi

# --- Test 7: Backup created ---
echo ""
echo "Test 7: Backups"
BACKUP_COUNT=$(ls "$FAKE_HOME/.claude/backups/" 2>/dev/null | wc -l)
if [ "$BACKUP_COUNT" -gt 0 ]; then
  pass "Backups created ($BACKUP_COUNT files)"
else
  fail "No backups found"
fi

# --- Test 8: List ---
echo ""
echo "Test 8: List packs"
LIST_OUTPUT=$(bash "$SCRIPT_DIR/apply.sh" --list --packs-dir "$PROJECT_DIR/packs/" 2>/dev/null)
PACK_COUNT=$(echo "$LIST_OUTPUT" | grep -cE "^[a-z]" || true)
if [ "$PACK_COUNT" -ge 10 ]; then
  pass "Listed $PACK_COUNT packs"
else
  fail "Expected 10+ packs, got $PACK_COUNT"
fi

# Cleanup
export HOME="$ORIG_HOME"
rm -rf "$TMPDIR_RAW"

echo ""
echo "=== Results: $PASS passed, $FAIL failed ==="
[ "$FAIL" -eq 0 ] && exit 0 || exit 1
