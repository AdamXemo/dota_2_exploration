# Dota Brain — compressed context for advice

> Read this first. ~1 page of how Dota is won, written for an LLM giving live advice
> to a **position-1 carry player in Ancient–Divine**. Details: `01_mechanics.md`,
> `02_carry_playbook.md`, `heroes/*.md`, `meta_snapshot.md`, `data/processed/*.json`.

## The player
- Bracket: **Ancient–Divine**. Role: **pos 1 carry**.
- Hero pool (mains): Anti-Mage, Morphling, Phantom Lancer, Wraith King, Templar Assassin,
  Shadow Fiend, Arc Warden, Phantom Assassin.
- Current patch strength of the pool: see `meta_snapshot.md` (WK and PL strongest, SF weakest).

## How games are won (priority order)
1. **Towers > kills.** Kills are only worth it if they turn into towers, Roshan or map control.
2. **Gold and XP are resources; time is the carry's main resource.** Every 30 s without
   farming or a useful objective is lost gold.
3. **Space.** The carry farms in the space the team creates. If the team is grouped and
   fighting, the carry should be either (a) farming the opposite side of the map with a TP ready,
   or (b) in the fight with items that matter. Never in between.
4. **Timings.** Each hero has item spikes (see hero pages). Fight at your spike, avoid fights
   just before it, and respect the enemy's spikes.
5. **Vision decides fights.** No vision = don't walk forward as a carry.

## The carry decision loop (every ~30 s)
1. Where are the 5 enemy heroes? (Count them on the minimap.)
2. Is there a safe wave to catch? → take it. Waves first, then jungle camps.
3. Is my team taking a fight or objective? → TP if my items matter and I'll arrive in time.
4. Is an enemy tower/Roshan free? → hit it.
5. Am I near an item spike? → keep farming until it, then look for a fight.

## Reading the draft (what to tell the player at pick time)
- **Enemy has lots of disables?** BKB earlier; avoid fragile picks (SF, TA).
- **Enemy has AoE magic (Ember, ES, Leshrac)?** PL illusions are weak; WK, AM, Morph are better.
- **Enemy has mana-reliant cores?** AM, PL (Diffusal) punish them.
- **Enemy has evasion (PA, Butterfly carries)?** Plan MKB/Bloodthorn.
- **Enemy has Break / mana burn?** WK suffers (lifesteal + Reincarnation off).
- **Enemy is early-tempo / push heavy?** Avoid the longest farmers (AM, Arc Midas); pick WK, PL, TA.

## Item thinking rules
- Buy the item that **solves the current problem**, not the 'standard' 3rd item.
  Dying to stuns → BKB. Can't catch → Abyssal/Orchid/Skadi. Missing hits → MKB.
  Target always saved by Ghost/Glimmer → Nullifier. Passive heroes → Silver Edge / Break.
- Defensive item before luxury damage when you die in every fight.
- Carry the TP scroll. Always.

## Advice style the player wants
- Short, actionable, ranked: "1) do this now 2) next item 3) watch out for".
- Always explain **why** in one line (the player is learning the game).
- Use current-patch data when available (`meta_snapshot.md`, live builds in hero pages).
