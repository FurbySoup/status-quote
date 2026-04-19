# Statusquote — Implementation Roadmap

## Phase 0: Project Scaffold + Git Init
- [x] Create directory tree
- [x] plugin.json and marketplace.json
- [x] LICENSE, .gitignore, README placeholder
- [x] ROADMAP.md (this file)
- [x] git init + initial commit

**Status:** Complete (2026-04-19)

---

## Phase 1: Core Apply Script + Pack Schema
- [x] `schemas/pack.schema.json` — pack validation schema
- [x] `src/apply.sh` — reads packs, writes spinnerVerbs to settings.json (Python-backed)
- [x] `src/validate.sh` — standalone pack validator
- [x] Verify: valid pack passes, invalid rejected
- [x] Verify: apply preserves existing settings.json keys
- [x] Verify: reset removes spinnerVerbs cleanly

**Status:** Complete (2026-04-19)
**Notes:** Used Python for JSON manipulation instead of jq. Fixed path quoting for directories with spaces.

---

## Phase 2: First 3 Franchise Packs
- [x] `packs/startrek.json` (15 verbs, 20 phrases)
- [x] `packs/starwars.json` (15 verbs, 20 phrases)
- [x] `packs/lotr.json` (15 verbs, 20 phrases)
- [x] All 3 pass validation
- [x] Apply works for each style mode

**Status:** Complete (2026-04-19)

---

## Phase 3: All 5 SKILL.md Slash Commands
- [x] `skills/use/SKILL.md` — `/statusquote:use <franchise>`
- [x] `skills/mix/SKILL.md` — `/statusquote:mix <f1>+<f2>`
- [x] `skills/list/SKILL.md` — `/statusquote:list`
- [x] `skills/style/SKILL.md` — `/statusquote:style verbs|phrases|mix`
- [x] `skills/reset/SKILL.md` — `/statusquote:reset`
- [x] State file config at `~/.statusquote/config.json`
- [x] All commands work end-to-end

**Status:** Complete (2026-04-19)

---

## Phase 4: Remaining 7 Franchise Packs
- [x] `packs/matrix.json`
- [x] `packs/sherlock.json`
- [x] `packs/marvel.json`
- [x] `packs/harrypotter.json`
- [x] `packs/princessbride.json`
- [x] `packs/jurassicpark.json`
- [x] `packs/backtothefuture.json`
- [x] All 10 packs pass validation

**Status:** Complete (2026-04-19)

---

## Phase 5: Documentation
- [x] `CLAUDE.md` — project architecture and maintenance
- [x] `README.md` — full user-facing docs
- [x] `CONTRIBUTING.md` — pack contribution guide

**Status:** Complete (2026-04-19)

---

## Phase 6: CI + Testing
- [x] `.github/workflows/validate-packs.yml`
- [x] `src/test.sh` — local test script
- [x] All tests pass locally (12/12)

**Status:** Complete (2026-04-19)

---

## Phase 7: GitHub + Marketplace Submission
- [ ] Create public GitHub repo
- [ ] Push all code
- [ ] Test fresh plugin install
- [ ] Marketplace submission
- [ ] GitHub release v1.0.0

**Status:** Pending

---

## Phase 8: Character Packs, Groups, Aliases, UX Overhaul
- [x] Pack schema: add `aliases`, `type`, `tags` fields
- [x] Add type/tags/aliases to all 10 existing franchise packs
- [x] 6 character packs: Yoda, Vader, Gandalf, Sparrow, T-800, Groot
- [x] `apply.sh --keys` resolution: aliases, groups, tag-based groups, `+` combos
- [x] `--list` grouped output: franchise/character sections, groups table
- [x] Merge `use` and `mix` skills (`mix` → alias for `use`)
- [x] `validate.sh`: accept and validate new optional fields
- [x] Test suite: 17 tests (alias, group, mixed resolution)
- [x] Documentation: README, CONTRIBUTING, CLAUDE.md updated

**Status:** Complete (2026-04-19)
**Notes:** Windows path separator fix needed (`chr(92)` replacement). Carriage return stripping for Python→bash output. Groot pack uses creative variations to meet min 10 entries.
