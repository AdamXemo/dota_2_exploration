# Roadmap

Each step ships something you can **open and use**, a piece of **Dota research/analysis**,
and a few focused commits. Status: ✅ done · 🔨 in progress · ⏳ planned.

| Step | Deliverable (presentable) | Research / analysis | Status |
|------|---------------------------|---------------------|--------|
| 1 | Repo foundation, OpenDota pipeline, **Carry Meta board** (Shiny page I) | Patch 7.41 carry tier list for Ancient–Divine, how your pool performs per bracket → `docs/research/01_carry_meta_7.41.md` | ✅ |
| 2 | **Hero pages** for the 8 mains: live build rail with item icons, curated timings, why-it-works | Starting & situational items deep-dive for AM, WK, PA, TA → `docs/research/02_starting_and_situational_items.md` | ✅ |
| 3 | **Item Codex** page: searchable item cards with icons, stats, why/when | Gold efficiency of carry items (cost per stat, which items are "free value") → `docs/research/03_item_efficiency.md` | ✅ |
| 3b | **Redesign → Dota Carry Lab**: cold esports-tool design system (agent) + homepage with tier list (agent) | Design spec `docs/design/DESIGN_SYSTEM.md`; sources register `docs/SOURCES.md` | 🔨 |
| 4 | **Draft Helper** page (ranks your pool vs enemy picks) ✅ + `score_candidate()` TODO for you | Counter-pick analysis: who punishes each main and why (mechanics, not just numbers) → `docs/research/04_matchups_and_counters.md` (research agent, API + documented sources) | 🔨 |
| 5 | **My Stats** page (your OpenDota matches, GPM percentiles, item timing vs targets) + `percentile_of()` TODO | What "good farm" looks like: GPM/LH benchmarks per main at Ancient–Divine → `docs/research/05_farm_benchmarks.md` | ✅ (page done; percentile_of() is your TODO) |
| 6 | **Notes** page (read the knowledge pack in-app) + `CLAUDE.md` agent setup ✅ | General Dota concepts: lane equilibrium, wave management, objectives, vision → `knowledge/03_core_concepts.md` ✅ | 🔨 (in-app notes page pending) |
| 7 | Polish, deploy guide (shinyapps.io), independent review pass | Patch-update checklist: how to refresh everything when 7.42 lands | ⏳ |

## Conventions
- Commits: Conventional Commits (`feat:`, `data:`, `docs:`, `chore:`, `fix:`), body = bullet list of what & why.
- Data flow: `scripts/01_fetch_opendota.R` → `data/raw/` → `scripts/02_build_knowledge.R` → `data/processed/` + `knowledge/`.
- Hand-written truth lives in `data/curated/*.json`; generated files say so in their header.
