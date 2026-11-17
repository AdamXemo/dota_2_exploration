# Research 02 — Starting & situational items (AM, WK, PA, TA)

_Data: OpenDota item popularity per hero (`data/raw/opendota/heroes/<id>/items.json`), item stats
from patch 7.41 constants (`data/raw/opendota/constants/items.json`), curated builds in
`data/curated/heroes.json`. Method: counts are purchases in the high-MMR sample. "Share" = count ÷ count of that
hero's most-bought start item (Iron Branch for all four). Each hero's sample is about 100 games
(Boots of Speed is bought 87–102 times). Kit totals are summed from `items.json` costs. Starting gold is ~600:
the average start-phase spend per game (total spend ÷ Boots count) is 572–612g for AM, WK and TA._

## TL;DR
- **Your 600g buys three things:** last-hit damage (Quelling Blade, Faerie Fire, stats), regen
  (Tango, Faerie Fire, Mango) and protection against spell-spam (Magic Stick). Melee carries buy
  all three. TA mid skips Tango and Quelling Blade and opens with a **finished Magic Wand + 2 Faerie Fire (590g)**.
- **Magic Stick at the start is much more common in high-MMR games than our curated builds say:** WK 59, PA 66
  (+13 Wand), TA 31 (+47 Wand). If two or more enemies in your lane cast spells often, buy it.
- **Two curated kits cost more than 600g and need fixing:** PA "Desolator tempo"
  (Tango, QB, Orb of Blight, Branch, Slippers = **685g**) and TA "mid" (… + Blades of Attack =
  **870g**). The corrected kits are below.
- **What players buy in the first 10 minutes (from the data):** AM/PA: Power Treads + Ring of Health → Perseverance (Battle Fury). WK:
  Phase Boots + Bracer (Chainmail 77, Phase 72, Bracer 63). TA: Power Treads + Falcon Blade (61).
- **Situational items answer a mechanic, not a hero name:** BKB (60% magic res + debuff
  immunity) for AoE chain stuns, Linken's for one targeted lockdown, MKB/Bloodthorn for evasion,
  Nullifier for Ghost/Glimmer/Eul's saves, and Abyssal Blade (stun pierces debuff immunity)
  against an enemy BKB.
- **Late game, BKB is the most-bought situational item on every hero:** AM 55, PA 31+22, TA 16+48, WK 18.

---

## Starting items 101

| Item | Cost | What you actually get (7.41 data) | Buy it because |
|---|---|---|---|
| Quelling Blade | 100 | +8 dmg vs non-heroes (melee), **+4 ranged**; chop trees | +8 damage on creeps decides most contested last hits. It is a Battle Fury component. For a ranged hero it is only half as strong. |
| Iron Branch | 55 | +1 all attributes | Cheapest stats in the shop (55g per point). Two of them go into Magic Wand. |
| Circlet | 155 | +2 all attributes | Half of Wraith Band or Bracer. |
| Slippers of Agility | 140 | +3 Agility | Damage + armor + attack speed for agility heroes. Wraith Band component. |
| Gauntlets of Strength | 140 | +3 Strength | HP + damage for WK. Bracer component. |
| Tango | 90 | 7 HP/s for 16s, 3 charges (~336 HP total) | The cheapest regen. You can share a charge with an ally. |
| Faerie Fire | 65 | +2 damage passively, **85 HP instantly** | Two jobs: helps last hits and saves you from dying. Pop it to survive a kill attempt or to win an all-in. |
| Enchanted Mango | 65 | +0.4 HP regen; eat for 100 mana | Lets you cast spells in lane: WK can stun one more time, AM can Blink out. |
| Magic Stick | 200 | 10 charges × 15 HP + 15 mana | Gains a charge when an enemy casts a spell within 1200 range. Against 2 spell-spam laners (Skywrath, Jakiro, Bristleback…) it is worth more than any stat item. |
| Blood Grenade | 50 | +50 HP; 50 + 15/s × 5s dmg, -15% slow | Mostly a support item: almost no carry buys it (1–2 per hero in the sample). |
| Orb of Blight | 300 | -2 armor on hit for 3s | Only for the Desolator rush (it is a Desolator component). |

**Wraith Band vs Bracer (both 505g):** Wraith Band = +5 Agility, +2 Str, +2 Int, +6 attack speed, +1.75 armor. Bracer = +5 Strength, +2 Agi,
+2 Int, +50 HP, +0.75 HP regen. You start with the Circlet + Slippers/Gauntlets and the 210g recipe completes
the item on your first trip back to base. Build the band only if the lane is contested. In a free lane, put that gold
into the farming item (Ring of Health → Battle Fury) instead.

**Rules of thumb**
1. Melee carry = Quelling Blade + Tango + something for last hits (Faerie Fire/stats) + Stick if the enemies spam spells.
2. Ranged mid = no Tango (your support or Bottle covers regen), more Faerie Fire and stats.
3. Leave about 0–40g unspent at most. Unspent gold at the horn is wasted gold.

---

## Anti-Mage (id 1)

**Live start items** (top 7)

| Item | Count | Share |
|---|---|---|
| Iron Branch | 202 | 100% |
| Circlet | 143 | 71% |
| Tango | 88 | 44% |
| Faerie Fire | 75 | 37% |
| Quelling Blade | 54 | 27% |
| Magic Stick | 28 | 14% |
| Slippers of Agility | 18 | 9% |

Circlet is bought more often than once per game (143 purchases in ~100 games), so double-Circlet starts are common.
Only ~54 of ~100 games buy Quelling Blade before the horn. The data has no start-phase pattern that
explains the rest, and QB bought after 0:00 does not show up in the buckets (see Caveats).

**Starting kits**

| Kit | Items | Gold | Why |
|---|---|---|---|
| Standard (most common in the data) | Tango, Quelling Blade, 3× Iron Branch, Circlet, Faerie Fire | 575 | Last hits first (QB + Faerie Fire), plus cheap stats that go into Wand or Wraith Band later. |
| Spell-spam lane (Jakiro/Skywrath/Lion dual lane) | Tango, Quelling Blade, 2× Iron Branch, Magic Stick, Faerie Fire | 565 | AM has a small mana pool and low HP. Stick charges keep Blink available. In the matchup sample AM wins 18/47 vs Jakiro and 21/54 vs Lion. |
| Free lane (curated) | Tango, Quelling Blade, 2× Iron Branch, Slippers, Circlet | 595 | Skip regen and go straight for Ring of Health. Slippers + Circlet become Wraith Band only if the lane turns bad. |

**Laning follow-ups (0–10 min, from the data):** Boots 101 → Power Treads 99, Ring of Health 98,
Broadsword 75, Void Stone 32 / Perseverance 26, Wraith Band 25. Almost every game builds Battle Fury in the order Ring of Health → Perseverance → Broadsword ×2.
Treads come early because attack speed = farm speed. Switching Treads to INT before you cast saves mana.
Wraith Band shows up in about 1 game in 4: it is the "hard lane" tax.

**Situational items**

| Item | Buy when | Why it works (7.41 numbers) |
|---|---|---|
| Black King Bar (4050) | Several AoE disables: Lion+Shaman, Enigma, Magnus, Bane chains | 60% magic res + spells' negative effects ignored for 9s (8/7 on later uses), basic dispel on cast. Counterspell reflects targeted spells only. It does nothing against AoE. Bought 55 times late in the sample. |
| Linken's Sphere (4800) | Enemy relies on one targeted lockdown: Doom, Legion Duel, Batrider Lasso, Hex | Blocks most targeted spells once every 14s, +16 all attributes. It uses Perseverance as a component, which you already know how to farm. Rare in the data (6). |
| Manta Style (core, 4650) | Always, but rush it earlier vs silences and roots | Mirror Image applies a basic dispel and creates 2 illusions (33% damage, take 300%) that also farm. |
| Abyssal Blade (6250) | Slippery targets or an enemy BKB carry | 1.6s Overwhelm stun **pierces debuff immunity**. Passive bash: 25% chance, 1.2s stun (melee). Late: 30 bought + 44 Skull Basher. |
| Eye of Skadi (5900) | Heal and regen lineups (Huskar, Lifestealer, Alchemist), or you are too fragile | +35 all attributes (HP!), attacks reduce health restoration by 50% and slow -25%/-50% (melee/ranged) for 3s. Bought 54 times late. |
| Butterfly (5450) | Physical right-click lineups without MKB | +35% evasion, +35 Agility. 48 bought late. |
| Monkey King Bar (5000) | Enemy PA, Windranger, Butterfly carry | 80% chance per attack to pierce evasion and deal +70 magic damage. |
| Nullifier (4350) | Ghost Scepter / Glimmer / Eul's on supports or the enemy carry | Basic dispel + 4s mute (no items) + continuous dispel/slow. It removes the save and stops them from re-casting it. |
| Orb of Corrosion (1050) | Early vs a healing lane or a melee offlaner you must out-trade | -2 armor, -16% heal (health restoration) and a slow (-8% vs melee, -16% vs ranged) on hit for 3s. Only 1 purchase in the data: niche. |
| Disperser / Diffusal Blade | Very late, vs kiting or Ghost/Eul's users | Suppress dispels **both** you and the target and slows it (Disperser). Manabreak burns 40 mana per hit. Late: 11 Diffusal, 8 Disperser. Whether this stacks with AM's own Mana Break: (verify). |

**Common traps**
- **Buying Wraith Band in a free lane.** Each Wraith Band delays Battle Fury, and AM's whole plan is the Battle Fury timing (target ~15 min).
- **Buying BKB when the enemy disables are single-target.** Counterspell + Linken's covers that for more stats. BKB is
  for AoE chains.
- **Hood of Defiance.** In the 7.41 constants it costs 0, i.e. you cannot buy it in the shop (verify). Vs magic, use BKB or
  Eternal Shroud instead.

---

## Wraith King (id 42)

**Live start items** (top 7)

| Item | Count | Share |
|---|---|---|
| Iron Branch | 146 | 100% |
| Quelling Blade | 89 | 61% |
| Tango | 88 | 60% |
| Gauntlets of Strength | 83 | 57% |
| Magic Stick | 59 | 40% |
| Circlet | 41 | 28% |
| Faerie Fire | 14 | 10% |

**Starting kits**

| Kit | Items | Gold | Why |
|---|---|---|---|
| Default (curated) | Tango, Quelling Blade, Gauntlets, Circlet, 2× Iron Branch | 595 | Strength gives HP + damage. Circlet + Gauntlets become a Bracer on the first trip back. |
| Stick start (very common in the data) | Tango, Quelling Blade, Gauntlets, Magic Stick, Iron Branch | 585 | WK has little mana. Stick charges = extra Wraithfire Blasts and keep mana for Reincarnation. |
| Ranged harass vs you | Tango, Quelling Blade, Gauntlets, 2× Iron Branch, Enchanted Mango, Faerie Fire | 570 | WK has no gap closer early. Mango gives you the stun when they overextend; Faerie Fire wins the all-in. |

**Laning follow-ups:** Boots 100 → Chainmail 77 → Phase Boots 72, Bracer 63, Helm of Iron Will
19 (Armlet path), Soul Ring 13, Power Treads only 12. Phase Boots give +18 damage (melee),
+4 armor and a 20% phase speed boost. WK needs the chase speed and the armor, so Phase is the default and
Treads are rare. Soul Ring (+170 temporary mana) solves the "can't stun + ult" mana problem early.
After the lane: Radiance (64) or Armlet (34), then Blink (57) and Aghanim's Shard (24).

**Situational items**

| Item | Buy when | Why it works |
|---|---|---|
| Black King Bar (4050) | Chain stuns, silences that would catch you before you can hit, magic burst | 60% magic res + debuff immunity for 9s. Reincarnation is a second life, but it does not protect you from being stunned through it. |
| Blink Dagger (2250, core) | Always vs backline lineups; earlier vs kiters | Teleport up to 1200 range. You cannot use it for 3s after taking hero damage, so blink in before the fight starts. |
| Harpoon (4700) | Kiting ranged carries (Drow, Sniper, Viper) and Blink is not enough | Draw Forth pulls a **melee** caster all the way to melee range of the target. Echo Strike: double attack + 100% slow for 1s every 5s. 8 bought (mid+late). |
| Nullifier (4350) | Ghost Scepter / Glimmer / Eul's saves | +75 damage, +10 armor, dispel + 4s mute. WK has no magic damage, so Ghost Scepter fully blocks you without it. |
| Orchid → Bloodthorn (3275 → 6400) | A key spellcaster or escape hero (Storm, Puck, Weaver-style blinkers), or evasion | 5s silence. Bloodthorn gives true strike against the silenced target and 40% pierce on every attack. Orchid 18, Bloodthorn 6 in the data. |
| Monkey King Bar (5000) | Enemy PA, Butterfly, Windranger | 80% pierce + 70 magic damage per hit. |
| Abyssal Blade (6250) | Enemy BKB carry, or a second lockdown after Wraithfire | Overwhelm (1.6s) pierces debuff immunity. |
| Assault Cuirass (5125) | Physical lineups, tower-taking games | +10 armor for you, an aura giving +5 armor to allies and -5 armor to enemies and **structures** within 1200. 14 bought late. |
| Aghanim's Scepter (4200) | Long late game, Break/mana-burn threats you can't remove | Reincarnation cooldown is reduced. You also get +175 mana (Reincarnation must have mana to trigger). |
| Sentry Ward / Dust / Gem | Enemy Silver Edge | Silver Edge only breaks you (passives off 5s, incl. Reincarnation and lifesteal) when the attacker **leaves** invisibility with the hit. Detection stops that combo. |

**Common traps**
- **"I have two lives so I skip BKB."** Chain stuns kill you twice. In the data, BKB is tied for the most-bought
  late item (18 of 18 top).
- **Radiance into a lost lane / early-fight draft.** Radiance (4700, 60 dps burn aura, 25%
  evasion) is a farming item. When the game is decided by fights at 12–15 min, Armlet (+25 Strength and +35 damage when toggled on)
  is the tempo pick: 34 buyers in the data.
- **Buying lifesteal items into heal reduction.** Against Spirit Vessel (-70% restoration), Skadi or Ancient Apparition, more lifesteal does less.
  Buy armor/HP (Assault Cuirass, BKB Strength) instead. In the matchup sample WK wins 13/35 vs Necrophos (37%), a hero
  whose kit fights sustain.
- Mana burn fear is real but don't overreact: WK wins 17/25 vs Anti-Mage in this sample.

---

## Phantom Assassin (id 44)

**Live start items** (top 7)

| Item | Count | Share |
|---|---|---|
| Iron Branch | 176 | 100% |
| Quelling Blade | 81 | 46% |
| Tango | 79 | 45% |
| Magic Stick | 66 | 38% |
| Faerie Fire | 48 | 27% |
| Circlet | 34 | 19% |
| Slippers of Agility | 19 | 11% |
| _Magic Wand (pre-built)_ | 13 | 7% |
| _Orb of Blight_ | 9 | 5% |

**Starting kits**

| Kit | Items | Gold | Why |
|---|---|---|---|
| Standard (most common in the data) | Tango, Quelling Blade, Magic Stick, 2× Iron Branch, Faerie Fire | 565 | PA's Stifling Dagger handles last hits, so the gold goes into sustain. Stick + 2 Branches become a Wand by 2–3 min. |
| Battle Fury, free lane (curated) | Tango, Quelling Blade, 2× Iron Branch, Slippers, Circlet | 595 | Pure stats for trades. Go straight to Ring of Health. |
| Desolator tempo (**corrected**) | Tango, Quelling Blade, Orb of Blight, 2× Iron Branch | 600 | -2 armor on hit wins early trades and is a Desolator component. The curated version (with Slippers instead of the 2nd Branch) costs **685g** and cannot be bought. |

**Laning follow-ups:** Boots 87 → Power Treads 81, Ring of Health 80, Broadsword 53, Void
Stone 51 / Perseverance 43, Wraith Band 21. The data shows Battle Fury is the main line (92 mid-game Battle Fury vs 53
Desolator). Mithril Hammer (176) is the most-bought mid-game component on PA because Desolator and BKB both use it.

**Situational items**

| Item | Buy when | Why it works |
|---|---|---|
| Black King Bar (4050) | Almost always by ~23 min; earlier vs Lion/Shaman/Bane-type lockdown | PA has low HP and only does damage while hitting. 60% magic res + debuff immunity for 9s. Bought in roughly half of games (31 mid + 22 late). |
| Nullifier (4350) | Supports carry Ghost Scepter / Glimmer, or the carry has Eul's | Ghost Form = immune to physical damage for 4s, i.e. immune to all of PA's damage. Nullifier dispels + mutes for 4s. 7 bought. |
| Monkey King Bar (5000) | Enemy PA / Butterfly / Windranger evasion | 80% pierce + 70 magic damage. A missed hit cannot crit, so evasion is the worst thing to face for a crit hero. |
| Satanic (5050) | Long fights, magic chip damage, you need to survive through BKB duration | +30% lifesteal; Unholy Rage = 175% lifesteal for 6s **and a basic dispel**. 21 bought late. |
| Abyssal Blade (6250) | Enemy BKB carry or an escape hero | 1.6s stun through debuff immunity. Basher (31) → Abyssal (14) in the data. |
| Aghanim's Scepter (4200) | Enemy relies on passives: WK Reincarnation, Bristleback, Spectre, Huskar | Fan of Knives applies Break (hero description). It turns off Reincarnation and passive defenses. |
| Manta Style (4650) | Silences/roots (Silencer, Bloodseeker), or you need a split-push tool | Basic dispel on cast + 2 illusions. 12 bought mid game. PA wins only 10/25 vs Silencer in the sample. |
| Linken's Sphere (4800) | One targeted disable decides fights (Doom, Lion Hex, Legion Duel) | Blocks one targeted spell every 14s. Rare (3), but Perseverance is already on the Battle Fury path. |
| Orb of Corrosion (1050) | Early vs healing lanes | -16% heal, -2 armor and a slow on hit for 3s. 3 bought. |

**Common traps**
- **Desolator into armor stackers** is fine, but **crits into Ghost Scepter without Nullifier** do nothing.
  Check support inventories at 15 min.
- **Skipping BKB for a second damage item.** PA's Immaterial evasion does not stop spells.
- **Fighting Lifestealer/Viper/Razor head-on.** Small samples, but PA wins only 15/43 vs LS, 8/23 vs Viper and 9/24 vs Razor. These
  heroes win long trades, so PA needs Abyssal and a fast kill, not a longer fight.

---

## Templar Assassin (id 46)

**Live start items** (top 7)

| Item | Count | Share |
|---|---|---|
| Iron Branch | 136 | 100% |
| Faerie Fire | 123 | 90% |
| Tango | 52 | 38% |
| Magic Wand (pre-built) | 47 | 35% |
| Circlet | 40 | 29% |
| Magic Stick | 31 | 23% |
| Quelling Blade | 30 | 22% |
| _Blades of Attack_ | 4 | 3% |

Faerie Fire is bought more often than once per game (123 purchases in ~100 games), and only ~half of games buy Tango (52). This sample is mostly mid TA: the support brings Tangos and
Faerie Fire is the last-hit + burst-heal item. Blades of Attack, which the curated mid kit uses, is almost never bought.

**Starting kits**

| Kit | Items | Gold | Why |
|---|---|---|---|
| Mid, data mode | Magic Wand (Magic Stick + 2 Branches + recipe), 2× Faerie Fire | 590 | Wand: +3 all attributes and 20 charges of 15 HP/mana. Mid heroes cast spells constantly, so it charges fast. 2 Faerie Fire = +4 damage for the last-hit war plus two 85-HP heals. Ask a support for a Tango. |
| Mid, stat start (**corrected curated**) | Tango, Faerie Fire, 2× Iron Branch, Circlet, Slippers | 560 | More stats now and a Wraith Band later. The curated version with Blades of Attack (450g) totals **870g**. Buy Blades later on the way to Falcon Blade. |
| Safe-lane carry (curated) | Tango, Quelling Blade, 2× Iron Branch, Slippers, Circlet | 595 | QB gives TA only **+4** (ranged), but it still helps last hits in a long farming lane. |

**Laning follow-ups:** Boots 102 → Power Treads 98, **Falcon Blade 61** (+200 HP, +14 damage,
+1.8 mana regen: HP and mana to keep casting Refraction), Blade of Alacrity 31 / Dragon Lance 11
(+130 range), Mithril Hammer 14 → Desolator. After the lane, Desolator and Blink tie (94 each), then
Dragon Lance 87 → Hurricane Pike/Force Staff.

**Situational items**

| Item | Buy when | Why it works |
|---|---|---|
| Black King Bar (4050) | Any lineup that can stun TA before Refraction (Lion, Shaman, Bane, Axe) | TA has low HP. Refraction blocks damage but not disables. 60% magic res + debuff immunity. BKB 16 mid + 48 late. |
| Hurricane Pike (4450) | Melee divers (Axe, Slark, Ursa, LS, PA) | Pushes you and the enemy 425 apart, then gives 5 attacks at any range with +100 attack speed. Also +130 range, +200 HP. 46 mid. |
| Monkey King Bar (5000) | Enemy PA / Windranger / Butterfly | 80% pierce + 70 magic per hit. Meld's bonus damage is lost if the hit misses. 28 late. |
| Linken's Sphere (4800) | Single-target lockdown on you: Doom, Lion/Shaman Hex, Batrider, Legion Duel | Blocks one targeted spell per 14s, +16 all attributes. 6 bought. |
| Aghanim's Shard (1400) | Stun-heavy teams | Refraction gets more bonus damage and can be cast while disabled (hero description). |
| Butterfly (5450) | Physical lineups without MKB | +35% evasion + 35 Agility. Evasion protects your HP in a different way than Refraction charges. 15 late. |
| Swift Blink (6800) | Late, to re-initiate onto backliners | +25 Agility. After teleporting: +35 Agility and +40% move speed for 6s. 46 late. |
| Nullifier (4350) | Ghost Scepter / Glimmer saves | TA's damage is physical, so Ghost Form blocks all of it. Rare (4). |
| Hydra's Breath (5900) | Illusion lineups or many units to split-shot into (verify value) | 30% chance per attack to hit 3 more targets for 20 + 75% damage. Miasma deals 2.5% max HP/s for 3s. Bought 11 times: a new 7.41 option, not proven. |

**Common traps**
- **Expecting Refraction to tank many small hits.** Each damage instance uses one charge. In the sample TA wins 45/118 vs Storm,
  39/96 vs Gyrocopter and 31/73 vs Bristleback. Buy HP/range (Falcon, Pike) and BKB. Don't count on Refraction.
- **Playing pos-1 TA for late game.** TA's plan is Desolator + Blink to win fights early. Late-game purchases (Daedalus 54, Swift
  Blink 46) only help if you are already ahead. If the game is slow, push and end it.
- **Quelling Blade on mid TA.** It gives only +4 damage for ranged heroes, and Psi Blades already lets you last hit through creeps.

---

## Situational item decision table

| Enemy problem | Anti-Mage | Wraith King | Phantom Assassin | Templar Assassin |
|---|---|---|---|---|
| AoE chain stuns (Lion+Shaman, Enigma, Magnus) | BKB | BKB | BKB | BKB |
| One targeted lockdown (Doom, Duel, Hex, Lasso) | Linken's (+ Counterspell) | BKB; Blink so you are not caught | Linken's or BKB | Linken's or BKB |
| Evasion carry (PA, Butterfly, Windranger) | MKB | MKB / Bloodthorn | MKB | MKB |
| Ghost / Glimmer / Eul's saves | Nullifier (Disperser late) | Nullifier | Nullifier | Nullifier |
| Heavy magic burst | BKB (Counterspell helps vs targeted) | BKB; Eternal Shroud as a theory pick (20%+ magic res, turns 25% of spell damage into mana for Reincarnation, not in data) | BKB, Satanic | BKB, Pike for spacing |
| Kiting ranged carry (Drow, Sniper, Viper) | Blink + Manta; Abyssal | Blink, Harpoon, Abyssal | Phantom Strike + Abyssal | Hurricane Pike, Blink |
| Healing / regen lineup (Huskar, LS, Alchemist) | Skadi (-50%); Orb of Corrosion early | Your supports buy Spirit Vessel (-70%); you buy Abyssal | Orb of Corrosion early; Skadi (verify fit) | Desolator burst, end the fight fast |
| Break on me (Silver Edge, Doom, PA Scepter) | Mostly fine (no key passive). Detection vs Silver Edge | Sentry/Dust/Gem vs Silver Edge; Aghanim's Scepter for shorter Reincarnation cooldown; BKB vs spells (verify vs Doom) | Detection vs Silver Edge; MKB-style lineup → BKB + Satanic | Detection; Pike to disengage |
| Melee dive on me (Axe, Slark, Ursa) | Manta to escape, Abyssal | You want this fight: BKB + lifesteal | Satanic, Abyssal | Hurricane Pike, Force Staff |
| Mana burn on me (AM, Nyx) | — | Soul Ring early, Aghanim's Scepter mana; keep 1 stun of mana | — | Falcon Blade regen |

---

## Caveats
- **Small sample.** About 100 games per hero in `items.json`. A difference of 5–10 counts is
  noise. Use the counts for "what is standard", not for fine ranking.
- **The phase buckets seem to filter by item price.** Early items here are ≥500g, mid ≥1000g and late ≥2000g
  (inferred from the data). Quelling Blade, Magic Stick and Wand completion bought after 0:00 are therefore invisible. "Only 54% of AM buy QB" really means "only 54% buy it **before the horn**".
- **Counts are purchases, not games.** That is why Branch, Circlet and Faerie Fire can exceed the game count.
- **Matchup records** (`matchups.json`) are 10–180 games each. They support the claims above, but none of them proves anything alone.
- **Numbers are patch 7.41 constants.** BKB duration (9/8/7), Linken's 14s cooldown, Aeon Disk thresholds etc. change between
  patches. Hero ability interactions (Fan of Knives Break, Refraction Shard, Diffusal + Mana Break,
  Silver Edge vs debuff immunity) are taken from hero notes or general knowledge and marked (verify) where uncertain.
- The curated kits for PA Desolator (685g) and TA mid (870g) in `data/curated/heroes.json` cost more than ~600g starting gold.
  This doc gives the corrected kits. The JSON itself has not been changed.
