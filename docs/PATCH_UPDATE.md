# When a new patch lands (e.g. 7.42)

A checklist so data, notes and the dashboard stay honest. ~30 minutes.

## 1. Refresh the data (5 min)
```bash
Rscript scripts/01_fetch_opendota.R --fresh   # new snapshot; resumable if rate-limited (HTTP 429)
Rscript scripts/02_build_knowledge.R          # regenerates knowledge/heroes/*.md, meta_snapshot, processed/*
Rscript scripts/03_item_efficiency.R          # new item stats -> new efficiency table
```
Check `data/raw/opendota/meta.json` shows the new patch. OpenDota's stats need a few days
after a patch to fill up. Small samples are shrunk, but very early numbers are still noisy.

## 2. Read what changed (10 min)
- Official patch notes: https://www.dota2.com/patches/ (add the URL to `docs/SOURCES.md`).
- For each main: ability reworks? item build path changes? Search the notes for the hero names.
- Items: new or removed items → `git diff data/processed/items_reference.json` shows changed stats.

## 3. Update the hand-written truth (10 min)
- `data/curated/heroes.json`: builds, Aghanim's/Shard text, timings, kits (keep each ≤ 600g;
  the build script prints nothing for cost, so check with the snippet in research 02).
- `data/curated/item_notes.json`: removed items, new items worth a note.
- `knowledge/00_dota_brain.md` / `01_mechanics.md`: anything marked *(verify)* that the patch touched.
- `app/R/config.R`: carry pool changes (new carry, hero no longer played pos 1).
Then rerun step 1's `02_build_knowledge.R`.

## 4. Verify & commit (5 min)
- `shiny::runApp("app")`: Meta board, a hero page, Item Codex, Draft.
- Write a short `docs/research/NN_patch_<x>_carry_meta.md` (copy research 01's structure).
- Commit in pieces: `data: snapshot for patch 7.42`, `fix: update curated builds for 7.42`,
  `docs: research NN carry meta 7.42`.
