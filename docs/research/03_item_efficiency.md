# Research 03 — Gold efficiency of carry items (patch 7.41)

_Data: OpenDota `constants/items` (7.41), analysis in `scripts/03_item_efficiency.R`,
results in `data/processed/item_efficiency.json`. Shown in the app on the **Item Codex** page._

## TL;DR
- **Best value per gold:** Falcon Blade (138%), Power Treads (117%), Mask of Madness (116%),
  Battle Fury (109%), Butterfly (109%), Nullifier (106%), Radiance (105%), Armlet (102%).
  Their raw stats are worth *more* than their price, so the effect comes free.
- **Best stats per inventory slot (late game):** Butterfly (≈5.9k gold of stats), Radiance (4.9k),
  Skadi (4.9k), Bloodthorn (4.7k), Nullifier (4.6k). When slots, not gold, are the limit,
  this ranking matters more than efficiency.
- **Pure "effect" items:** BKB (41%), Manta (56%), Abyssal (47%), Assault (30%), Swift Blink (17%).
  You pay **2–5k gold for the effect**: immunity, illusions, a stun or an aura. Buy them because
  you need that effect, never for the stats.
- **Why your mains' builds look the way they do:** AM/PA Battle Fury and WK/PL Radiance are
  >100% items that also farm. That's why they come first. BKB and Abyssal come later, when a
  specific problem (stuns, an escaping target) is worth ~2.5–3k gold of "effect tax".

## Method
1. **Price each stat by its cheapest basic source** (7.41 constants):

   | Stat | Source | Gold per point |
   |------|--------|---------------:|
   | Strength / Agility / Intellect | Gauntlets / Slippers / Mantle (140g for +3) | 46.7 |
   | All attributes | = Str + Agi + Int | 140 |
   | Damage | Blades of Attack (450g, +9) | 50 |
   | Armor | Ring of Protection (175g, +2) | 87.5 |
   | Attack speed | Gloves of Haste (450g, +20) | 22.5 |
   | Health / Mana | Fluffy Hat / Wizard Hat (250g, +125) | 2.0 |
   | HP regen | Ring of Regen (175g, +1.25) | 140 |
   | Mana regen | Sage's Mask (175g, +0.7) | 250 |
   | Move speed (flat) | Boots of Speed (500g, +45) | 11.1 |
   | Evasion % | Talisman of Evasion (1300g, 15%) | 86.7 |
   | Magic resist % | Cloak family / Shawl (450g, 10%) | 45 |
   | Lifesteal % | Morbid Mask (900g, 18%) | 50 |

2. **Stat value** of an item = Σ (stat amount × price). **Efficiency** = value ÷ cost.
   **Premium** = cost − value = what the active/passive costs you.
3. Not valued (so true value is *higher* than shown): primary-attribute damage, % move
   speed, status/slow resistance, health-restoration amp, % HP regen (Heart), auras (Assault),
   cleave, bashes, crits and all actives.

## The carry item table
| Item | Cost | Stat value | Efficiency | Premium | Reading |
|------|-----:|-----------:|-----------:|--------:|---------|
| Falcon Blade | 1125 | 1550 | **138%** | −425 | Best early value in the game; great on SF/TA/Morph. |
| Power Treads | 1400 | 1640 | **117%** | −240 | Why every agility carry buys Treads. |
| Mask of Madness | 1900 | 2200 | **116%** | −300 | Cheap DPS + lifesteal; the silence is the hidden cost. |
| Battle Fury | 3900 | 4238 | **109%** | −338 | Free cleave on top of full-value stats: AM/PA core. |
| Butterfly | 5450 | 5917 | **109%** | −467 | Best late stat item for agility carries. |
| Nullifier | 4350 | 4625 | **106%** | −275 | The dispel is basically free; don't fear "wasting" a slot. |
| Radiance | 4700 | 4917 | **105%** | −217 | WK/PL farming item that also gives 25% evasion. |
| Armlet | 2500 | 2538 | **102%** | −38 | WK tempo start; the toggle strength isn't even counted. |
| Linken's Sphere | 4800 | 4212 | 88% | 588 | Spell block costs only ~600g. |
| Daedalus | 5100 | 4400 | 86% | 700 | Crit chance costs ~700g. |
| Eye of Skadi | 5900 | 4900 | 83% | 1000 | HP-heavy stats; the slow costs ~1k. |
| Desolator | 3500 | 2750 | 79% | 750 | −6 armor for 750g: very cheap physical amplification. |
| Satanic | 5050 | 3917 | 78% | 1133 | |
| Monkey King Bar | 5000 | 3625 | 73% | 1375 | The pierce is ~1.4k: only buy it vs real evasion. |
| Hurricane Pike | 4450 | 2733 | 61% | 1717 | |
| Mjollnir | 5500 | 3275 | 60% | 2225 | Chain Lightning procs are what you pay for (Arc). |
| Manta Style | 4650 | 2595 | 56% | 2055 | ~2k for illusions + dispel. Huge for AM/PL farm speed. |
| Aghanim's Scepter | 4200 | 2100 | 50% | 2100 | Depends 100% on the hero's upgrade (PL: core). |
| Abyssal Blade | 6250 | 2963 | 47% | 3287 | Stun through BKB ≈ 3.3k gold. |
| Sange and Yasha | 4200 | 1943 | 46% | 2257 | Status/slow resist not counted, so real value is higher. |
| Black King Bar | 4050 | 1667 | **41%** | **2383** | Immunity is the most expensive effect you'll buy, and the most important. |
| Heart of Tarrasque | 5100 | 2007 | 39% | 3093 | % regen not counted. |
| Disperser | 6100 | 2333 | 38% | 3767 | |
| Hand of Midas | 2200 | 788 | 36% | 1412 | Pays back through transmute gold, not stats. |
| Assault Cuirass | 5125 | 1550 | 30% | 3575 | Auras not counted: a team item. |

## Takeaways for your heroes
- **Anti-Mage / PA:** Battle Fury is the rare item that is both >100% efficient and farm
  acceleration. Delaying it for a "fight item" costs a lot.
- **Wraith King:** Armlet (102%) and Radiance (105%) are both value-positive. Pick by game
  speed: Armlet to fight at ~14 min, Radiance to farm and push.
- **Phantom Lancer:** Manta's stats are poor (56%), but the illusions are PL's whole game.
  An efficiency number can't capture that; this lens is about stats only.
- **Templar Assassin / SF:** Falcon Blade and Desolator are the two cheapest power spikes.
- **Morphling:** Butterfly is the highest-value late slot in the game and fits his
  agility scaling. Skadi brings the HP he otherwise gets from shifting.
- **Everyone:** BKB looks like a terrible deal on paper, at 41% efficiency with ~2.4k gold of
  "premium". It's still bought in most games because immunity has no substitute. Efficiency
  tells you what you pay; it doesn't tell you what you need.

## Caveats
- Stat prices come from basic items, the classic community method; other price anchors
  give different absolute numbers but a similar ranking.
- Items with variable values (Diffusal "25 / 35") use the first value.
