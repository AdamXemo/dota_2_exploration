# Carry playbook (pos 1, Ancient–Divine)

## Phase 1 — Lane (0–10 min)
**Goal:** 50–70 last hits by 10 min (Ancient–Divine average is ~45–60 depending on hero),
no deaths, first item component.

- Stand where you can last-hit **and** the offlaner can't free-hit you. Usually slightly
  behind your creeps on the high ground side.
- **Creep equilibrium:** you want the lane to sit near *your* tower. Don't push it. If it's
  pushed, have your support pull (x:15/x:45) to reset it.
- Trade only when the enemy uses a cooldown or runs out of mana.
- Buy Magic Wand/Stick vs spell-spam lanes. Fill regen with the courier, don't walk back.
- Rotate to the jungle when the lane is lost: a jungle carry with 5 min of free farm beats a dead carry.

## Phase 2 — Mid game (10–25 min)
**Goal:** hit the first big item spike (BF/Radiance/Desolator/Manta) on time and **convert it**.

- Farm pattern: *lane wave → nearest camps → next lane wave*. Follow waves toward where the
  enemy is NOT. Push side lanes out so the enemy has to defend.
- **Stacks:** ask your 4/5 to stack the ancients or big camp near your farm area at ~x:53.
- Join fights when: (a) it's near you, (b) your spike item is done, (c) the team has vision.
- After a won fight: **tower → Roshan → next tower**. Don't farm the jungle after winning.
- After a lost fight: farm the safest waves, don't TP into a lost cause.

## Phase 3 — Late game (25 min+)
**Goal:** win one big fight and end, or out-scale safely.

- **BKB timing**: buy it before the fight that decides the game, not after.
- Stand near the team but slightly behind the frontline until key enemy disables are used.
- Keep the Aegis on the carry. With Aegis, look for high ground immediately.
- Buyback gold: after ~35 min always keep buyback money. Losing a fight without buyback = losing the game.
- Split-push heroes (AM, Arc, PL) pressure the side lane while the team holds in front of a tower.

## Common carry questions → short answers
- **"Should I join this fight?"** Only if you arrive before it ends, your items matter, and
  you have a TP back. Otherwise farm and make space for a later fight.
- **"Next item?"** What's killing me / what can't I kill? Solve that. (See `00_dota_brain.md` → item thinking rules.)
- **"They have Aegis / huge lead."** Stop fighting in the open, defend high ground with your
  waves, farm side lanes, wait for a spike or a mistake.
- **"I'm behind in farm."** Group with the team for tempo items? No: carries behind need *safe*
  farm. Farm the jungle/safe waves near your towers and avoid fights you can't win.

## Benchmarks
Per-hero GPM/XPM/last-hit percentiles: `data/raw/opendota/heroes/<id>/benchmarks.json`
(the app's **My Stats** page compares you against them). Core item timing targets:
`data/curated/heroes.json → core[].target_min`.
