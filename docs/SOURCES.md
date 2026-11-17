# Sources register

Every data source used by the research docs and the app: where it comes from, what it gives,
and how far to trust it. **Date accessed: 2026-11-17** for everything below, unless a row says otherwise.
Patch: **7.41** (released 2026-03-24 per `constants/patch`).

Reliability scale: **High** = official game data or full-population stats. **Medium** = large
sample but with a known bias. **Low** = small sample, opinion, or not checked.

---

## 1. Master table

| # | Source | URL | What it provides | Used in | Reliability | Limitations |
|---|--------|-----|------------------|---------|-------------|-------------|
| S1 | OpenDota `heroStats` | https://api.opendota.com/api/heroStats | Picks/wins per hero per rank bracket (`1_pick` … `8_win`), pro picks/bans, base stats | R01, app Meta board, `carry_meta.json` | High for winrates (≈946k Ancient+Divine matches) | Not split by position (a mid TA counts like a pos-1 TA). Covers a recent rolling window, not the whole patch. |
| S2 | OpenDota `constants/items` | https://api.opendota.com/api/constants/items | Item cost, stats (`attrib`), active/passive text, components | R02, R03, R04, Item Codex, `item_efficiency.json` | High (comes from game files via dotaconstants) | Text is a summary. Some values are "generated" placeholders. Lags a few days behind a patch. |
| S3 | OpenDota `constants/item_ids` | https://api.opendota.com/api/constants/item_ids | Numeric item id → item key | R04 (pro item lift query) | High | None known. |
| S4 | OpenDota `constants/heroes` | https://api.opendota.com/api/constants/heroes | Hero id, internal name, localized name, roles, attack type | All | High | None known. |
| S5 | OpenDota `constants/hero_abilities` | https://api.opendota.com/api/constants/hero_abilities | Ability list, talents and facets per hero | R04 | High | Ability *order*, not numbers. Some facets are marked `deprecated`. |
| S6 | OpenDota `constants/abilities` | https://api.opendota.com/api/constants/abilities | Ability descriptions, mana cost, cooldown, `attrib` values (e.g. Refraction instances, Reincarnation mana) | R04 (mechanic claims) | High for numbers | Text is short. It does not list every interaction (e.g. whether Break turns off Reincarnation). |
| S7 | OpenDota `constants/patch` | https://api.opendota.com/api/constants/patch | Patch names + release dates | `meta.json`, R04 time window | High | Lettered sub-patches (7.41a/b) are not listed separately. |
| S8 | OpenDota `heroes/{id}/itemPopularity` | https://api.opendota.com/api/heroes/1/itemPopularity | Item purchase counts per game phase (start/early/mid/late) | R02, hero pages "Live build" | Medium-Low | ≈100 games per hero (high-MMR parsed sample). The phase buckets look filtered by price (early ≥500g, mid ≥1000g, late ≥2000g, inferred). Counts are purchases, not games. |
| S9 | OpenDota `heroes/{id}/matchups` | https://api.opendota.com/api/heroes/1/matchups | Games and wins of hero vs each opponent | R02 (supporting), app Draft helper (local snapshot) | **Low** | 10–180 games per pair (Arc Warden: 0 pairs with ≥30 games). In R04 its correlation with the 1.18M-match explorer sample was −0.09 to +0.22, so it is **mostly noise**. Bracket and window not documented. |
| S10 | OpenDota `benchmarks?hero_id=` | https://api.opendota.com/api/benchmarks?hero_id=1 | GPM/XPM/LH/hero damage/tower damage/deaths percentiles | R05, My Stats page | Medium | Not filtered by rank. It describes "a typical public game", not Ancient–Divine. |
| S11 | OpenDota **SQL explorer**, `public_matches` | https://api.opendota.com/api/explorer?sql=… | Every public match: `radiant_team`/`dire_team` hero arrays, `radiant_win`, `avg_rank_tier` | **R04 (main matchup source)** | **High** for Ancient–Divine matchups (1,184,998 matches, 2026-11-09 → 2026-11-16) | No position/role. ≈15 s query timeout (see §3). The table only keeps ≈1 year. `avg_rank_tier` is a lobby average, so some players are outside the bracket. One week ≠ whole patch. |
| S12 | OpenDota SQL explorer, `player_matches` + `matches` | https://api.opendota.com/api/explorer?sql=… | Final inventories (item_0–5, backpack_0–2) in **pro/league** matches | R04 counter-item "pro lift" | Medium-Low | 9,236 pro/league matches since 2026-03-24. Arc Warden: only ≈71 games. Final inventory ≠ purchase (sold items are missed). Pro ≠ pub. |
| S13 | OpenDota `schema` | https://api.opendota.com/api/schema | Explorer table/column list | R04 (query design) | High | — |
| S14 | OpenDota `players/{account}/matches`, `players/{account}`, `matches/{id}` | https://api.opendota.com/api/players/{id}/matches | The user's own recent games (runtime, app My Stats page) | App only | High (the user's own data) | Needs a public match history. Runtime call, not part of any research doc. |
| S15 | Curated notes `data/curated/heroes.json`, `item_notes.json`, `mechanics.json`; `knowledge/heroes/*.md` | local | Builds, `struggles_vs` / `thrives_vs`, tips | R02, R04 (claims to test) | Low-Medium (opinion) | Hand-written. R04 found several claims the data does not support (see R04 §"Curated claims"). |
| S16 | Official patch notes | https://www.dota2.com/patches/7.41 | Ability/item changes | Planned (PATCH_UPDATE checklist) | High | **Not fetched**: the page is rendered with JavaScript, so it can't be read with a plain fetch. Mechanic numbers come from S6/S2 instead. |
| S17 | Liquipedia Dota 2 | https://liquipedia.net/dota2/Break | Mechanic interactions (Break, illusions, true strike) | R04 (attempted) | High (community wiki, well kept) | **HTTP 403** to the automated fetch on 2026-11-17. Claims that needed it are marked *(general knowledge, verify)*. |
| S18 | Dota 2 Fandom wiki | https://dota2.fandom.com/wiki/Break | Same as S17 | R04 (attempted) | Medium-High | **HTTP 402** to the automated fetch on 2026-11-17. Not used. |

Images in the app come from the Steam CDN path given by S1/S4 (`cdn.cloudflare.steamstatic.com`). They are not data.

---

## 2. Per research doc

### Research 01 — Carry meta 7.41 (`docs/research/01_carry_meta_7.41.md`)
- **S1 heroStats.** Brackets 6+7 (Ancient, Divine) summed, plus 1–3 / 4–5 for the trend table.
  Winrate shrunk toward 50% with 3,000 prior games (`app/R/scoring.R::shrink`).
- **S4** for names, **S7** for the patch label. Carry pool is a hand list (`app/R/config.R`).
- Limits: no position split. Pro picks/bans are a different population. The "why" section is
  reasoning, not data.

### Research 02 — Starting & situational items (`docs/research/02_starting_and_situational_items.md`)
- **S8 itemPopularity** (≈100 games/hero) for what is bought. **S2** for costs and item text.
  **S15** curated builds. **S9** matchups as weak support only.
- Limits: listed in that doc's Caveats. Note that R04 later showed S9 is close to noise.

### Research 03 — Gold efficiency (`docs/research/03_item_efficiency.md`)
- **S2 constants/items** only, processed by `scripts/03_item_efficiency.R` → `data/processed/item_efficiency.json`.
- Limits: values raw stats only. Actives, % bonuses and primary-attribute damage are not priced.

### Research 04 — Matchups & counters (`docs/research/04_matchups_and_counters.md`)
- **S11 explorer `public_matches`** (main source). One query per main + one for all hero winrates +
  one window check. Bracket filter `avg_rank_tier >= 60 AND < 80`. Window `match_id > 9083505270`
  (2026-11-09 18:44 UTC → 2026-11-16 23:37 UTC). Output: `data/processed/counter_matrix.json`.
- **S9 heroes/{id}/matchups** (local snapshot) for comparison only.
- **S12 explorer `player_matches`** for counter-item lift in pro games.
- **S6 abilities / S5 hero_abilities / S2 items** for every mechanic claim with a number.
- **S15** curated `struggles_vs` / `thrives_vs` as hypotheses to test.
- **S16–S18** tried for mechanic confirmation; blocked (see table).

### Research 05 — Farm benchmarks (`docs/research/05_farm_benchmarks.md`)
- **S10 benchmarks** per hero (local snapshot `data/raw/opendota/heroes/<id>/benchmarks.json`).
- Limits: not rank-filtered.

---

## 3. OpenDota API — practical notes (learned 2026-11-17)

- **Free tier, no key.** We stay at ≤1 request per 1.5 s (`scripts/01_fetch_opendota.R` sleeps 1.5 s).
  R04 used 21 API requests in total (3 hit the explorer timeout); no HTTP 429 was returned.
- **Explorer timeout ≈15 s** (`{"err":"Error: Query read timeout"}`, HTTP 400). What worked:
  - Filter by **`match_id` range**, not `start_time`. `start_time` is not indexed: a 30-day
    `start_time` filter timed out, while `match_id > X` over ~10M ids (≈1 week, ≈1.18M Ancient+Divine
    matches) ran in 3–11 s.
  - The **first** heavy query can time out on a cold cache. Re-running the same query worked (Anti-Mage).
  - `public_matches` keeps ≈1 year (oldest row 2025-11-16).
  - Rough id→time rate: ≈17 match ids per second (useful for choosing a window).
- `avg_rank_tier` is a double: 60–65 = Ancient I–V, 70–75 = Divine I–V, 80 = Immortal.
- `hero_id = 0` appears in team arrays (≈0.15% of slots: missing or abandoned picks). Drop it.
- `player_matches` in the explorer only holds pro/league (and some parsed) games. It is **not** a pub source.

## 4. How to cite in a new doc
Put a `_Data:` line under the title that names the source IDs (S1…S18), the date, and the sample size.
Add any new endpoint or site to the master table first.

## Reproducibility note (added by the lead)
The bracket matchup pull behind research 04 is reproducible with
`scripts/04_fetch_bracket_matchups.R` (SQL written out in the script). Its snapshot lives in
`data/raw/opendota/bracket_matchups/` and is what the app's Draft Helper and hero pages use.
If the explorer times out (statement timeout ≈ 15 s, common under load), re-run the script later:
finished heroes are skipped.


## Research 07 — synergies
_Doc: `docs/research/07_synergies.md` · data: `data/processed/synergy_matrix.json` · script: `scripts/06_fetch_synergies.R` (added 2026-11-17)._

- **S11 explorer `public_matches`** — main source. One query per main: unnest the main's **own** team
  array (minus the main and `hero_id 0`), count games/wins per ally. Bracket `avg_rank_tier >= 60 AND < 80`.
  Window `match_id > 9083518613` (2026-11-09 18:55 UTC → 2026-11-17 00:10 UTC, **1,185,543 matches**).
  Plus one query for every hero's overall games/wins in the **same window** (baseline for "expected")
  and one for window facts. Raw: `data/raw/opendota/bracket_synergies/<hero_id>.json`, `_overall.json`, `_window.json`.
- **S4 constants/heroes** — ally role tags (hero tags, not positions played).
- **S5 hero_abilities / S6 abilities** — every mechanic line in the "why" column; other claims marked
  *(general knowledge, verify)*.
- Method: log-odds additive expectation `inv_logit(logit(wr_H)+logit(wr_A))`, shrunk with 500 prior games,
  n ≥ 300. Support lists use a hand-made pos 4/5 pool (general knowledge) because the data has no roles.
- Limits: no position/lane; teammates are random in solo queue; Morphling and TA ally spreads are close to
  pure noise (SD of z ≈ 1.1).
- API notes: 10 explorer requests in total (≥ 3 s apart), **0 timeouts**; each query took ≈ 3–8 s with the
  10M-id window. Unnesting both team arrays for all 1.19M matches (≈ 11.9M rows) also finished under the
  ≈ 15 s limit. No HTTP 429.
