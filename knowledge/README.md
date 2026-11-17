# Knowledge pack

Compressed Dota 2 context, so an LLM agent (or you) can give useful advice fast.

| File | What | Who writes it |
|------|------|---------------|
| `00_dota_brain.md` | One-page "how Dota is won" + player profile. **Read first.** | hand-written |
| `01_mechanics.md` | Formulas: armor, magic resist, attack speed, dispels, economy | hand-written |
| `02_carry_playbook.md` | Lane / mid / late game as a pos 1 | hand-written |
| `03_core_concepts.md` | Equilibrium, wave management, objectives, vision, timings, teamfights, draft | hand-written |
| `meta_snapshot.md` | Carry tier list for the current patch (Ancient–Divine) | **generated** |
| `heroes/*.md` | One page per main: why it works, builds, matchups, live data | **generated** from `data/curated/heroes.json` |
| `cards/*.md` | ~25-line in-game cheat card per main (plan, build, pivots, danger, rules) | agent-written from the files above |
| `prompts/*.md` | Copy-paste prompts: draft, in-game, post-game | hand-written |

Structured equivalents (better for tools/code) live in `data/`:
`data/curated/mechanics.json`, `data/curated/heroes.json`, `data/curated/item_notes.json`,
`data/processed/carry_meta.json`, `data/processed/items_reference.json`.

**Regenerate after a patch:**
```bash
Rscript scripts/01_fetch_opendota.R --fresh   # new snapshot
Rscript scripts/02_build_knowledge.R           # rebuild generated files
```
Then re-read the hand-written notes and the hero JSON for anything the patch changed.
