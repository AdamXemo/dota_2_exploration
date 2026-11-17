# CLAUDE.md — Dota Carry Lab (repo: dota_2_exploration)

R + Shiny Dota 2 research lab for a **position-1 carry in Ancient–Divine**. Two jobs:
(1) a dashboard the user studies, (2) a compressed **knowledge pack** you use to give Dota advice.

## When the user asks for Dota advice
1. Read `knowledge/00_dota_brain.md` first (player profile, how games are won, advice style).
2. **Mid-game quick question → load only `knowledge/cards/<key>.md`** (~1.1k chars each).
   Otherwise read only what the question needs:
   - hero question → `knowledge/heroes/<key>.md` (antimage, morphling, phantom_lancer,
     skeleton_king = Wraith King, templar_assassin, nevermore = Shadow Fiend, arc_warden, phantom_assassin)
   - meta / what to pick → `knowledge/meta_snapshot.md`, `docs/research/01_carry_meta_7.41.md`
   - counters → `docs/research/04_matchups_and_counters.md`, `data/processed/counter_matrix.json`
   - items → `data/processed/items_reference.json` (live 7.41 stats), `docs/research/02_*`, `03_*`
   - mechanics / concepts → `knowledge/01_mechanics.md`, `knowledge/03_core_concepts.md`
3. Answer short and ranked ("1) do now 2) next item 3) watch out"), one line of **why** each.
   Prompt templates: `knowledge/prompts/`.
4. Numbers come from the data snapshot (patch in `data/raw/opendota/meta.json`). If the user
   says a new patch is out, say the snapshot may be stale and offer to refresh it.

## Project map
- `app/` Shiny app (`shiny::runApp("app")`), `app/R/*` auto-sourced: config, data, scoring, theme,
  components, one `mod_*.R` per page. Styles: `app/www/styles.css`, spec `docs/design/DESIGN_SYSTEM.md`.
- `scripts/01_fetch_opendota.R` → `data/raw/opendota/` (resumable; `--fresh` to refetch)
- `scripts/02_build_knowledge.R` → `knowledge/heroes/*.md`, `knowledge/meta_snapshot.md`, `data/processed/*`
- `scripts/03_item_efficiency.R` → `data/processed/item_efficiency.json`
- Hand-written truth: `data/curated/*.json` (heroes, item_notes, mechanics). Generated files say so; don't hand-edit them.
- Research write-ups: `docs/research/NN_*.md`; sources: `docs/SOURCES.md`; plan: `docs/ROADMAP.md`.

## Conventions
- The user is learning R (basics): keep code commented, simple base R + dplyr, no clever metaprogramming.
- `TODO(human)` functions in `app/R/scoring.R` (`score_candidate`, `percentile_of`) are the user's
  exercises. Don't implement them unless asked; you may review them.
- Commits: Conventional Commits (`feat:`, `fix:`, `docs:`, `data:`, `chore:`) with a bullet body.
- Design: cold, practical esports-tool UI. No fantasy/"storybook" styling.
- Run `Rscript tests/run_tests.R` after changing scoring, data or curated JSON (must stay green).
- Verify UI changes by running the app and taking a headless Chrome screenshot (deep links:
  `?tab=hero&hero=42`, `?tab=items`, `?tab=draft`, `?tab=me`).
