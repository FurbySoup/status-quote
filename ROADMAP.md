# Statusquote — Implementation Roadmap

## Phase 0: Project Scaffold + Git Init
- [x] Create directory tree
- [x] plugin.json and marketplace.json
- [x] LICENSE, .gitignore, README placeholder
- [x] ROADMAP.md (this file)
- [x] git init + initial commit

**Status:** Complete

---

## Phase 1: Core Apply Script + Pack Schema
- [ ] `schemas/pack.schema.json` — pack validation schema
- [ ] `src/apply.sh` — reads packs, writes spinnerVerbs to settings.json (Python-backed)
- [ ] `src/validate.sh` — standalone pack validator
- [ ] Verify: valid pack passes, invalid rejected
- [ ] Verify: apply preserves existing settings.json keys
- [ ] Verify: reset removes spinnerVerbs cleanly

**Status:** Pending

---

## Phase 2: First 3 Franchise Packs
- [ ] `packs/startrek.json` (~35 entries)
- [ ] `packs/starwars.json` (~35 entries)
- [ ] `packs/lotr.json` (~35 entries)
- [ ] All 3 pass validation
- [ ] Apply works for each style mode

**Status:** Pending

---

## Phase 3: All 5 SKILL.md Slash Commands
- [ ] `skills/use/SKILL.md` — `/statusquote:use <franchise>`
- [ ] `skills/mix/SKILL.md` — `/statusquote:mix <f1>+<f2>`
- [ ] `skills/list/SKILL.md` — `/statusquote:list`
- [ ] `skills/style/SKILL.md` — `/statusquote:style verbs|phrases|mix`
- [ ] `skills/reset/SKILL.md` — `/statusquote:reset`
- [ ] State file config at `~/.statusquote/config.json`
- [ ] All commands work end-to-end

**Status:** Pending

---

## Phase 4: Remaining 7 Franchise Packs
- [ ] `packs/matrix.json`
- [ ] `packs/sherlock.json`
- [ ] `packs/marvel.json`
- [ ] `packs/harrypotter.json`
- [ ] `packs/princessbride.json`
- [ ] `packs/jurassicpark.json`
- [ ] `packs/backtothefuture.json`
- [ ] All 10 packs pass validation

**Status:** Pending

---

## Phase 5: Documentation
- [ ] `CLAUDE.md` — project architecture and maintenance
- [ ] `README.md` — full user-facing docs
- [ ] `CONTRIBUTING.md` — pack contribution guide

**Status:** Pending

---

## Phase 6: CI + Testing
- [ ] `.github/workflows/validate-packs.yml`
- [ ] `src/test.sh` — local test script
- [ ] All tests pass locally

**Status:** Pending

---

## Phase 7: GitHub + Marketplace Submission
- [ ] Create public GitHub repo
- [ ] Push all code
- [ ] Test fresh plugin install
- [ ] Marketplace submission
- [ ] GitHub release v1.0.0

**Status:** Pending
