# Research 01 — Carry meta, patch 7.41 (Ancient–Divine)

_Data: OpenDota `heroStats`, fetched 2026-11-17, ~946k Ancient+Divine matches.
Method: winrates shrunk toward 50% with 3,000 prior games (`app/R/scoring.R`);
"carry pool" = 32 heroes actually played as position 1 (`app/R/config.R`)._

## TL;DR
1. **Your pool is half great, half struggling.** Wraith King (53.3%), Phantom Lancer (52.7%) and
   Arc Warden (51.9%) are top-tier. Anti-Mage and Phantom Assassin are solid (~50–51%).
   Morphling (48.1%), Templar Assassin (46.5%) and Shadow Fiend (41.5%) are below average.
2. **The patch rewards tanky, self-sufficient carries.** The top of the board is strength and
   sustain (WK, Juggernaut, Dragon Knight, Spectre, Sven, Lifestealer, Bloodseeker). The bottom is
   fragile, positioning-heavy agility carries (Drow, Gyro, Weaver, Kez, TA, SF).
3. **Your best "learn next" heroes:** Juggernaut and Spectre. Both are S/A tier, and they
   play like heroes you already know (Jugg ≈ self-sufficient PA/WK; Spectre ≈ late-game AM/PL scaler).

## The 15-hero board
| # | Tier | Hero | Adj. WR | Pick rate | Note |
|---|------|------|---------|-----------|------|
| 1 | S | **Wraith King** ★ | 53.3% | 11.9% | Best carry in the bracket. |
| 2 | S | Juggernaut | 52.9% | 18.7% | Most-picked carry, still wins. |
| 3 | S | **Phantom Lancer** ★ | 52.7% | 10.6% | Flat ~52.5–53% in every bracket = robust. |
| 4 | S | Dragon Knight | 52.6% | 17.9% | Also the #1 pro carry/flex (72 pro picks). |
| 5 | A | Spectre | 52.4% | 7.5% | Late-game insurance. |
| 6 | A | **Arc Warden** ★ | 51.9% | 4.9% | Rewards skill: winrate *rises* with MMR. |
| 7 | A | Bloodseeker | 51.8% | 2.5% | |
| 8 | A | Sven | 51.7% | 11.1% | |
| 9 | A | Lifestealer | 51.4% | 14.2% | |
| 10 | A | Lycan | 51.2% | 1.7% | Heavily banned in pro (55 bans). |
| 11 | B | **Anti-Mage** ★ | 50.9% | 17.1% | Your most popular main, pro ban target. |
| 12 | B | Troll Warlord | 50.9% | 2.0% | |
| 13 | B | Chaos Knight | 50.2% | 2.6% | |
| 14 | B | Luna | 50.1% | 14.5% | |
| 15 | B | Ursa | 50.1% | 8.1% | |

Just off the board: Phantom Assassin (50.0%) ★, Razor, Slark, Naga. Bottom of the pool:
Drow (45.6%), Kez (45.0%), Shadow Fiend (41.5%).

## How your mains change with MMR
Adjusted winrate in Herald–Crusader → Archon–Legend → **Ancient–Divine**:

| Hero | Low | Mid | **High** | Trend | What it tells you |
|------|-----|-----|----------|-------|-------------------|
| Wraith King | 56.3 | 55.3 | **53.3** | ↘ −3.0 | A "stomps low MMR" hero: simple kit, punishes bad play. Higher up, players buy Break, Vessel and mana burn. Still the best in your bracket. |
| Phantom Lancer | 52.5 | 52.9 | **52.7** | → | Strong at every level. The Aghanim's-Scepter build is the reason (see Step 2). |
| Arc Warden | 50.6 | 51.6 | **51.9** | ↗ +1.2 | Skill-reward hero: the better the player, the better Arc gets. |
| Anti-Mage | 51.2 | 51.1 | **50.9** | → | Stable. His result depends on the team giving him space, not on raw strength. |
| Phantom Assassin | 52.0 | 51.0 | **50.0** | ↘ −1.9 | Gets worse as players learn to buy MKB / Ghost Scepter vs her. |
| Morphling | 48.3 | 47.3 | **48.1** | → | Weak everywhere this patch; only pick with high comfort. |
| Templar Assassin | 45.6 | 45.8 | **46.5** | ↗ | Weak, mostly a mid hero now; pos-1 TA is worse still. |
| Shadow Fiend | 45.1 | 43.2 | **41.5** | ↘ −3.6 | Worst carry in the game right now, and it gets worse with MMR. Bench him this patch. |

## Why the strong ones are strong (mechanics, not just numbers)
- **Self-sustain beats burst in pubs.** WK (innate lifesteal + Reincarnation), Juggernaut
  (Healing Ward), LS (Feast) and Spectre (Dispersion) all win *long, messy* fights, which is what
  uncoordinated pub teamfights are. TA/SF/Drow need a perfect first five seconds.
- **Illusions are a "free" BKB in pubs.** PL's army forces enemies to have AoE. Most pub drafts
  don't plan for it, so PL wins by default. Pros do plan for it (13 pro bans vs 8 picks).
- **Doubling is a skill multiplier.** Arc's Tempest Double doubles items and actives, but only
  if the player can control two heroes, hence the rising-with-MMR curve.

## Recommendations
- **Comfort + strength core:** Wraith King, Phantom Lancer, Arc Warden, Anti-Mage.
- **Situational:** Phantom Assassin vs right-click lineups *without* MKB/Bloodthorn users;
  Morphling vs magic-heavy drafts where Strength-shift + BKB wins.
- **Avoid this patch:** Shadow Fiend as pos 1 (and honestly also mid). TA only from mid, into melee mids.
- **Hero to add:** Juggernaut (S, 18.7% pick) — Blade Fury = built-in magic immunity, Healing
  Ward = sustain, Omnislash = PA-style burst. Lowest learning cost from your pool.

## Caveats
- OpenDota stats come from its parsed/public match sample, not every match played.
- Ancient + Divine are merged. Immortal currently returns no data (bracket 8 = 0 games).
- Winrate ≠ "how good the hero is for you". Your own winrate per hero comes in Step 5 (My Stats).
