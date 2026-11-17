# Research 04 — Who counters your carries, and why

_Data: OpenDota SQL explorer (`public_matches`, Ancient+Divine = `avg_rank_tier` 60–79),
**1,184,998 matches from 2026-11-09 to 2026-11-16**, patch 7.41. Mechanics from 7.41 constants
(`abilities.json`, `items.json`). Counter-item lift from 9,236 pro/league matches since 2026-03-24.
Machine-readable output: `data/processed/counter_matrix.json`. Sources: `docs/SOURCES.md` (S11, S12, S6, S2)._

## TL;DR
1. **Illusions and summons are the big theme.** Your two strongest carries (WK 53.7%, PL 53.1%)
   lose most to heroes that **multiply bodies or clear them**: PL falls to AoE (Tidehunter,
   Underlord, Dark Seer, Axe: −5 to −6 pp), and WK falls to PL itself (−7.7 pp raw).
2. **Meepo is the worst enemy pick for your pool.** He is a top-3 counter to Arc (−9.1), PL (−6.0),
   AM (−5.8) and WK (−3.6). Your only good answer is… Shadow Fiend (+5.0), who is bad overall.
3. **Arc Warden has the sharpest counters:** Broodmother −10.7 pp and Meepo −9.1 pp. The reason is in
   the ability text: *Flux deals no damage if another enemy unit is near the target*. Spiders, Meepos
   and wolves turn off your main laning spell.
4. **Anti-Mage is the best answer to three of your own mains.** AM beats Medusa by **+13 pp** (the
   biggest edge in this report), and he beats **PL (+4.2), WK (+4.4) and Morphling (+4.5)**.
   Our curated note "PL counters AM" is **wrong** for this bracket.
5. **Axe is the most common counter:** AM −5.6, PL −4.8, PA −3.6, Morph −3.3. The cause is
   Counter Helix: every hit on Axe, from the hero *or* from an illusion, charges pure AoE damage.
6. **"Mana burn kills WK" is only half true.** Reincarnation costs 220 / 110 / **0** mana, so mana burn only
   matters before level 18. AM and PL still counter WK (−4.4 / −4.6 specific).
7. **Shadow Fiend has no specific counter.** His worst matchup is only −3.2 pp, but he wins 41.8% overall.
   Your counter-picks won't fix that. The curated "mid gankers counter SF" claim is **not** supported
   (SF is +1.4 to +2.8 vs Storm, Puck, Ember, Void Spirit).
8. **The local snapshot matchups (`heroes/<id>/matchups.json`) are close to noise.** Their correlation
   with the 1.18M-match sample is −0.09 to +0.22. Do not draft from them. Use `counter_matrix.json`.

---

## How to read the numbers

| Column | Meaning |
|--------|---------|
| **Spec** | *Specific* advantage in percentage points (pp): your winrate vs X, minus your normal winrate, **plus X's own winrate − 50**. It removes "X is just strong this patch". **Lists are ranked by this.** |
| **Raw** | Your winrate vs X minus your normal winrate (the app's `matchup_advantages()`, shrunk with 60 prior games). This is what you will *feel* in a game. |
| **n** | Matches with X on the enemy team. Lists use only n ≥ 500. ±95% CI ≈ 1.4 pp at n=5k, 2.8 pp at n=1.2k, 4 pp at n=600. |
| **Ev.** | `both` = data and an ability/item mechanic agree. `data` = numbers only. `mech` = mechanic only. |
| **Tier** | **S** hard counter (≈ −5 pp or worse, solid n, clear mechanic) · **A** strong (−4 to −5) · **B** noticeable (−3 to −4) · **C** mild / mechanic only. |

Example: Wraith King vs Phantom Lancer. Raw is **−7.7**: you win about 46% instead of 53.7%.
PL himself wins 53.1% (+3.1 above 50), so the part that is *specifically* about this matchup is −4.6.

---

## If the enemy picks X → avoid / pick (cross-hero table)

The 14 heroes that show up most often as counters to your pool. Spec in pp, n ≥ 500 for every cell.

| Enemy picks | Avoid (spec) | Pick (spec) | Why, in one line |
|-------------|--------------|-------------|------------------|
| **Axe** | AM −5.6 · PL −4.8 · PA −3.6 · Morph −3.3 | **WK +0.9** (raw +2.1), Arc +0.6 | Counter Helix punishes attackers and illusions; WK out-sustains him. |
| **Meepo** | Arc −9.1 · PL −6.0 · AM −5.8 · WK −3.6 | SF +5.0 (weak hero); otherwise TA −1.2 / PA −1.8 | Nets, Poof AoE, many bodies vs Flux/illusions. |
| **Phantom Lancer** | TA −4.7 · WK −4.6 · Arc −3.3 | **AM +4.2** | Illusions burn Refraction, find no WK stun target; AM's Mana Break + Battle Fury solve PL. |
| **Phoenix** | TA −4.1 · WK −3.7 · AM −3.4 | **Arc +3.8**, SF +2.8, Morph +2.5 | Damage-over-time ticks eat Refraction; Arc out-pushes a slow hero. |
| **Dark Seer** | PL −5.5 · WK −3.8 · TA −2.9 | AM +0.5, PA +0.5, Morph +0.7 | Ion Shell/Vacuum/Wall vs illusions and melee. |
| **Tidehunter** | PL −5.8 · WK −2.4 | **AM +2.2** | Anchor Smash + Ravage clear illusions. |
| **Underlord** | PL −5.8 · WK −4.3 | **AM +2.2** (raw +4.6) | Firestorm + Pit vs illusions; Atrophy cuts damage. |
| **Warlock** | PL −4.8 · WK −4.7 | PA +1.7, SF +1.0 | Upheaval + golems kite melee, AoE vs illusions. |
| **Troll Warlord** | PA −4.0 · AM −3.6 · SF −3.2 | **Arc +3.8** (n=611), WK +2.2 | Ensnare + blind (melee Whirling Axes) vs melee carries; Magnetic Field stops ranged Troll. |
| **Anti-Mage** | Morph −4.5 · WK −4.4 · PL −4.1 | TA +2.3, SF +1.6, PA +1.2 | Mana Break vs mana-hungry kits; TA/PA burst him early. |
| **Bristleback** | PA −4.5 · Arc −3.2 | **AM +4.6** | Spell damage ignores evasion; AM burns BB's spell mana. |
| **Medusa** | Arc −4.4 · SF −2.7 | **AM +13.3** | Mana Shield = mana is HP; AM deletes it. |
| **Ursa** | AM −4.4 · SF −2.4 | **WK +4.1**, TA +2.4, PL +2.1 | Ursa wins early fights vs AM; WK out-duels him. |
| **Nyx Assassin** | Morph −3.2 (raw −6.7) · AM −2.4 · PA −2.2 | TA +2.3, WK +1.2 | Mind Flare + Mana Burn vs mana users; Carapace vs right-clickers. |

**Your mains vs each other** (row hero's spec vs column hero):

| | vs AM | vs PL | vs WK | vs PA |
|--|--|--|--|--|
| **AM** | — | **+4.2** | **+4.4** | −1.2 |
| **PL** | −4.1 | — | **+4.7** | −0.6 |
| **WK** | −4.4 | −4.6 | — | **+3.3** |
| **PA** | +1.2 | +0.6 | −3.3 | — |

So it is a rock-paper-scissors loop: **AM > PL > WK > PA**, AM also beats WK, and PA is slightly ahead of AM.
If an enemy first-picks WK, you have two good mains for it (AM, PL). (n = 6k–13k per pair.)

---

## Anti-Mage (id 1) — 50.9%, 192k matches, picked in 16.2% of games

### Counter tier list
| Tier | Hero | Spec | Raw | n | Ev. | Why |
|------|------|------|-----|---|-----|-----|
| S | **Axe** | −5.6 | −4.4 | 12,196 | both | Berserker's Call goes through Blink; every hit charges Counter Helix (pure). |
| S | **Meepo** | −5.8 | −8.8 | 2,123 | both | Earthbind roots you (no Blink); 2–5 Meepos jump you before Battle Fury. |
| A | Huskar | −6.1 | −2.6 | 4,115 | both | Blood Magic: *"Huskar does not have mana"*. Mana Break, Persecutor and Mana Void do nothing. |
| A | Ursa | −4.4 | −4.6 | 8,435 | both | Fury Swipes + Enrage win minute-10 to 20 fights and an early Roshan. |
| B | Slardar | −3.9 | −2.6 | 4,939 | both | Crush + Bash before you Blink; Corrosive Haze = armor cut + true sight. |
| B | Troll Warlord | −3.6 | −4.7 | 2,545 | both | Low-mana hero, ensnare stops Blink (*"preventing … mobility spells"*). |
| C | Night Stalker | −3.5 | −6.5 | 7,248 | both | Crippling Fear silences, night chase. Raw −6.5: NS is strong right now. |
| C | Legion Commander | −2.7 | −4.1 | 12,047 | both | Duel ignores Blink; buy Linken's or time Counterspell. |

### Best victims
| Hero | Spec | n | Why |
|------|------|---|-----|
| **Medusa** | **+13.3** | 1,817 | Mana Shield turns mana into HP: Mana Break + Mana Void hit both at once. |
| Largo | +4.9 | 2,308 | New support with no hard lock on you (mechanic not verified). |
| Storm Spirit | +4.7 | 5,466 | Ball Lightning needs mana; no mana = no escape. |
| Bristleback | +4.6 | 3,524 | His damage is spell spam; Counterspell reflects Goo. |
| Morphling | +4.5 | 4,603 | Shift costs 10 mana/s. |

### Mechanical counters
- **No mana pool / low mana** (Huskar, Troll, Ursa): your whole kit scales with enemy mana. *both*
- **Lock through Blink** (taunt, Duel, roots, bash): Blink is a movement spell. *both*
- **Early tempo** before Battle Fury (Ursa, Meepo, NS, Slardar). *both*

### Items enemies buy against you
Orchid (silence Blink; pro lift **1.9×**), Monkey King Bar (**2.0×**), Abyssal Blade (BKB-piercing stun),
Scythe of Vyse (careful: a pre-cast Counterspell reflects it).

---

## Morphling (id 10) — 48.2%, 50k matches, 4.3%

### Counter tier list
| Tier | Hero | Spec | Raw | n | Ev. | Why |
|------|------|------|-----|---|-----|-----|
| S | **Anti-Mage** | −4.5 | −5.4 | 4,602 | both | Mana Break empties the mana you need for Attribute Shift (10 mana/s) and Waveform (115). |
| A | Nyx Assassin | −3.2 | **−6.7** | 2,370 | both | Mind Flare burns % of max mana + passive Mana Burn. |
| A | Bane | −5.3 | −4.4 | 633 | both | Fiend's Grip / Nightmare. Attribute Shift is *not castable while stunned*. Wide CI (±3.9). |
| A | Ancient Apparition | −3.3 | −4.0 | 1,307 | both | Ice Blast blocks healing, so the STR shift does not save you *(general knowledge, verify)*. |
| B | Axe | −3.3 | −2.2 | 3,176 | both | Taunt locks you in; Helix is pure damage. |
| B | Rubick | −3.1 | −3.2 | 6,523 | data | Steals Waveform/Adaptive Strike; Telekinesis lock. |
| C | Outworld Destroyer | −2.9 | **−7.1** | 3,283 | both | Mana-based damage + Astral. Raw −7.1: OD is a strong hero right now. |

### Best victims
| Hero | Spec | n | Why |
|------|------|---|-----|
| Huskar | +5.1 | 1,013 | You out-range him (Agility → attack range via Ebb and Flow). |
| Lifestealer | +4.3 | 3,695 | Melee with no gap closer vs Waveform + slow resistance. |
| Brewmaster | +4.0 | 800 | Magic-heavy split; STR shift survives. |
| Jakiro | +4.0 | 1,887 | Slow magic support: shift STR, Waveform on him. |
| Sniper | +3.9 | 4,215 | Fragile, no escape: Waveform is invulnerable. |

### Mechanical counters
- **Mana burn / drain** (AM, Nyx, Diffusal, Bane's Fiend's Grip steals mana). *both*
- **Heal block**: Doom (*"prevents … healing in any way"*), Ice Blast, Spirit Vessel, Skadi. *both*
- **Stun/silence chains** (Bane, Lion, Shaman, Orchid): you can't shift while stunned. *both*
- The curated "Silencer counters Morph" is **not** supported (+0.9, n=2,135).

### Items enemies buy against you (pro lift)
MKB **1.9×**, Eye of Skadi **1.6×** (−50% health restoration), Orchid **1.6×**, Spirit Vessel **1.5×** (−70% health restoration), Diffusal 1.3×.

---

## Phantom Lancer (id 12) — 53.1%, 119k matches, 10.1%

Key number: Juxtapose illusions take **600% damage** (`abilities.json`). Any AoE is a counter.

### Counter tier list
| Tier | Hero | Spec | Raw | n | Ev. | Why |
|------|------|------|-----|---|-----|-----|
| S | **Tidehunter** | −5.8 | −4.2 | 5,828 | both | Anchor Smash hits every illusion around him; Ravage stuns the army. |
| S | **Underlord** | −5.8 | −3.4 | 2,290 | both | Firestorm + Pit of Malice root; Atrophy Aura cuts their damage. |
| S | **Dark Seer** | −5.5 | −7.1 | 2,725 | both | Ion Shell, Vacuum; Wall of Replica copies PL for Dark Seer. |
| S | **Axe** | −4.8 | −3.7 | 7,279 | both | Illusions attacking Axe charge Counter Helix: your army kills itself. |
| A | Meepo | −6.0 | −9.0 | 1,164 | both | Poof AoE from many bodies + net. |
| A | Warlock / Leshrac / Sven / Earthshaker | −4.8 / −4.7 / −4.5 / −4.3 | −3.0 / −7.7 / −6.0 / −5.0 | 2.7k–12.8k | both | Upheaval, Pulse Nova + Edict, Great Cleave, Echo Slam. |
| A | Anti-Mage | −4.1 | −5.0 | 10,300 | both | Battle Fury cleave clears illusions; Mana Break vs your spell mana. |
| B | Ember Spirit | −3.5 | −2.8 | 5,008 | both | Sleight of Fist hits every illusion (curated claim confirmed). |

### Best victims
| Hero | Spec | n | Why |
|------|------|---|-----|
| Clinkz | +5.4 | 2,144 | Single-target; can't find the real you. |
| Ogre Magi | +4.7 | 9,363 | Single-target support; Diffusal drains him. |
| Templar Assassin | +4.7 | 2,545 | Each illusion hit removes one Refraction instance. |
| Wraith King | +4.7 | 7,349 | Single-target stun; you burn his Reincarnation mana. |
| Terrorblade | +4.6 | 1,969 | Single-target damage; Sunder can go on an illusion *(verify)*. |

### Mechanical counters
- **AoE spells** (Tide, Underlord, Dark Seer, Leshrac, ES, Ember, Warlock). *both*
- **AoE on attack / when attacked**: Counter Helix, Great Cleave, Battle Fury, Mjollnir, Radiance. *both*
- **Hex**: Scythe of Vyse *"instantly destroys illusions"*. *mech*
- The curated "Medusa / Viper / Bristleback counter PL" is **not** supported: +0.1 / +4.5 / +0.8.

### Items enemies buy against you (pro lift)
Radiance **1.7×**, Mjollnir **1.65×**, Gleipnir **1.5×** (roots everything in 350), Battle Fury 1.2×, Shiva's 1.1×.

---

## Wraith King (id 42) — 53.7%, 138k matches, 11.6%

Key numbers: Reincarnation mana **220 / 110 / 0**, cooldown 180 / 150 / 120 s. *"Wraith King cannot
reincarnate after being a Wraith"* (Vampiric Spirit).

### Counter tier list
| Tier | Hero | Spec | Raw | n | Ev. | Why |
|------|------|------|-----|---|-----|-----|
| S | **Phantom Lancer** | −4.6 | **−7.7** | 7,349 | both | Illusions + Diffusal burn mana; your single-target stun finds no real target. |
| S | **Anti-Mage** | −4.4 | −5.3 | 13,061 | both | Mana Break empties you before Reincarnation level 3. |
| A | Warlock | −4.7 | −2.8 | 3,311 | both | Upheaval slow + golems kite and body-block a hero with no gap closer. |
| A | Keeper of the Light | −4.6 | −5.6 | 2,407 | both | Blinding Light: knock-back + misses; Solar Bind slow. |
| A | Undying | −4.1 | −3.5 | 5,773 | both | Decay steals Strength; Tombstone zombies slow you. |
| A | Naga Siren | −5.7 | −5.4 | 760 | both | Illusions + Ensnare + Song (wide CI ±3.6). |
| B | Underlord | −4.3 | −1.9 | 3,255 | both | Pit root + Atrophy. |

### Best victims
| Hero | Spec | n | Why |
|------|------|---|-----|
| Ursa | +4.1 | 4,774 | Melee duel: stun + lifesteal + second life. |
| Enigma | +3.8 | 3,753 | Black Hole kills you once; you come back and it's on cooldown. |
| Shadow Shaman | +3.6 | 8,988 | Single-target lockdown vs a hero with two lives. |
| Phantom Assassin | +3.3 | 7,302 | She bursts you once; Wraithfire stun is not an attack, so evasion doesn't help her. |
| Muerta | +3.1 | 1,732 | Burst vs Reincarnation. |

### Mechanical counters
- **Mana burn before level 18** (AM, PL with Diffusal). *both*
- **Kiting / blind / slows** (Warlock, KotL, Naga, Undying). *both*. The curated "Drow/Razor/Viper" is
  **not** supported (+0.6 / +0.9 / −0.3).
- **Break** (Silver Edge, PA's Fan of Knives, Hoodwink Sharpshooter) turns off Vampiric Spirit lifesteal
  and, by general knowledge, Reincarnation *(verify)*. *mech*. But pros do **not** buy Silver Edge more vs WK (lift 0.6).
- **Heal reduction** (Vessel, Skadi, Doom). *mech*. Data says it's minor: WK is +2.2 vs Doom, and Vessel lift is 0.75.
- Curated "Nyx counters WK" is **not** supported (spec +1.2; raw −2.2 only because Nyx is strong).

### Items enemies buy against you
Blade Mail (pro lift **1.7×**), Battle Fury 1.5×, Mjollnir 1.4×; mechanic picks: Silver Edge (Break),
Spirit Vessel, Diffusal (before level 18), Heaven's Halberd.

---

## Templar Assassin (id 46) — 46.2%, 51k matches, 4.3%
_Most pub TAs are mid. These numbers mix mid and safe lane._

Key number: Refraction blocks **3 / 4 / 5 / 6 instances** of damage (30 barrier each). Counters = many hits.

### Counter tier list
| Tier | Hero | Spec | Raw | n | Ev. | Why |
|------|------|------|-----|---|-----|-----|
| S | **Phantom Lancer** | −4.7 | −7.8 | 2,545 | both | Many illusions = many hits = Refraction gone in a second. |
| S | **Phoenix** | −4.1 | −5.7 | 1,393 | both | Fire Spirits, Sun Ray, Dying Light tick every second. |
| A | Spectre | −3.8 | −6.5 | 1,973 | both | Dispersion reflects your burst; Haunt illusions strip Refraction. |
| A | Shadow Shaman | −3.2 | −4.3 | 2,897 | both | Shackles/Hex disable without damage: Refraction doesn't help. |
| B | Sand King | −3.2 | −1.2 | 1,048 | both | Sand Storm ticks; Epicenter pulses. |
| B | Slardar | −3.1 | −1.8 | 1,265 | both | Corrosive Haze true sight beats Meld; armor cut. |
| C | Batrider | −9.4 (n=349) | −5.7 | 349 | both | Firefly ticks + Lasso. **Too few games for the main list.** |

### Best victims
Night Stalker +4.3 · Sven +4.2 · Lone Druid +3.3 · Tiny +2.9 · Techies +2.8. All of them deal damage in **a few
big hits**, and Refraction blocks a whole hit no matter its size (*"all of the damage is absorbed"*).

### Mechanical counters
- **Many small damage instances** (Phoenix, SK, PL). *both*. The curated "Gyro, Razor, Viper, Jakiro" is
  **not** supported (−1.4 / +1.4 / −0.1 / −1.0).
- **Detection**: Haze, Track, Dust, Gem. *both*
- **Physical immunity / disarm**: pros buy Ghost Scepter **1.4×** and Heaven's Halberd **3.3×** more vs TA. *data*

### Items enemies buy against you
Ghost Scepter, Heaven's Halberd, Crimson Guard (**1.8×**), Dust, Gem.

---

## Shadow Fiend (id 11) — 41.8%, 88k matches, 7.5%
_Mostly mid in pubs._

| Tier | Hero | Spec | Raw | n | Ev. | Why |
|------|------|------|-----|---|-----|-----|
| B | Troll Warlord | −3.2 | −4.3 | 1,067 | both | Ensnare: you can't walk away; Fervor wins the trade. |
| B | Medusa | −2.7 | −2.3 | 1,074 | data | Out-scales; Split Shot hits you from range *(mechanic weak)*. |
| B | Ursa | −2.4 | −2.6 | 3,556 | both | Jumps a hero with no escape. |
| B | Dragon Knight | −2.3 | −4.9 | 6,816 | both | Dragon Blood armor vs your physical damage; Dragon Tail stun. |
| B | Phantom Lancer | −2.0 | −5.1 | 4,661 | both | You can't kill the army fast enough. |

Victims: Meepo +5.0 (razes hit several Meepos) · Beastmaster +3.6 · Io +3.2 · Bane +3.1 · Bloodseeker +2.9.

**The honest conclusion:** no hero in the list is a real counter (all ≥ −3.2). SF is 8 pp below 50% against
*everyone*. The curated "Storm/Puck/Ember/Void Spirit counter SF" is **not** supported (spec −0.4 / +1.5 / +2.8 / +1.4).
Bench SF this patch (same as research 01).

Items enemies buy: Blade Mail **1.5×**, Glimmer Cape 1.2× (saves Requiem targets), Heaven's Halberd 1.6×, Orchid (no razes).

---

## Arc Warden (id 113) — 51.5%, 56k matches, 4.7%

Key text (`abilities.json`): *Flux — "The damage is not applied if another enemy unit is near the target"*
(225 radius). Tempest Double gives **180–300 gold bounty** when killed.

### Counter tier list
| Tier | Hero | Spec | Raw | n | Ev. | Why |
|------|------|------|-----|---|-----|-----|
| S | **Broodmother** | **−10.7** | −9.6 | 812 | both | Spiderlings turn off Flux; Brood out-pushes you. |
| S | **Meepo** | **−9.1** | −12.1 | 737 | both | Many bodies vs Flux; Poof kills the Double; net roots both. |
| A | Lycan | −5.6 | −6.8 | 571 | both | Wolves turn off Flux; Lycan wins the split-push race. |
| A | Medusa | −4.4 | −4.0 | 659 | data | You can't burst her; Split Shot hits both of you. |
| A | Marci | −4.4 | −4.4 | 1,366 | both | Rebound + Unleash dive kills a low-HP ranged hero. |
| B | Sand King / Lone Druid | −3.3 / −3.3 | −1.4 / −2.2 | 1,170 / 993 | both | AoE that kills the Double / Bear vs Flux. |
| C | Phantom Lancer | −3.3 | −6.4 | 3,374 | both | Illusions vs Flux and your single-target damage. |

Small samples: every Arc counter has n < 1.4k, so CIs are ±2.6–4 pp. The top two are still clearly negative.

### Best victims
Doom +5.8 (n=1,903) · Clinkz +4.5 · Viper +4.4 · Troll +3.8 (n=611) · Phoenix +3.8. Slow heroes and
ranged right-clickers: Magnetic Field makes *attacks from outside the field miss*.

### Mechanical counters
- **Summons / extra units** (Brood, Meepo, Lycan, LD, Chen) turn off Flux. *both*
- **Faster split push** (Brood, Lycan). *both*
- **Divers** (Marci; Slark −2.0, Spirit Breaker −2.0 are mild). *both*. Curated "Storm Spirit" is **not** supported (+2.5).

### Items enemies buy against you (pro, only ≈71 games)
Diffusal 2.2×, Maelstrom 2.2× (bounces hit both Arcs), MKB 1.75× (ignores Magnetic Field), Bloodthorn 1.5×.

---

## Phantom Assassin (id 44) — 50.8%, 122k matches, 10.3%

### Counter tier list
| Tier | Hero | Spec | Raw | n | Ev. | Why |
|------|------|------|-----|---|-----|-----|
| A | **Bristleback** | −4.5 | −1.4 | 2,886 | both | Quill Spray is spell damage (no evasion vs spells); back damage reduction up to 40% cuts your crits. |
| A | **Troll Warlord** | −4.0 | −5.1 | 1,656 | both | Melee Whirling Axes make you miss; ensnare; Fervor out-DPSes you. |
| A | **Axe** | −3.6 | −2.5 | 8,197 | both | Your fast attacks charge Counter Helix (pure damage). |
| A | **Wraith King** | −3.3 | **−7.0** | 7,302 | both | You burst him once; he comes back. His stun is a spell, not an attack. |
| A | **Omniknight** | −3.2 | −5.2 | 1,461 | both | Guardian Angel = 4–5 s physical immunity; Hammer of Purity is pure. |
| B | Phoenix | −2.8 | −4.4 | 3,069 | both | All-magic damage; Supernova can't be crit. |
| C | Centaur | −2.5 | −1.8 | 2,948 | both | Retaliate returns damage to every attacker. |

### Best victims
Broodmother +4.9 · Huskar +4.9 · Night Stalker +4.1 · Enigma +3.6 · Clinkz +3.5. Right-click heroes
miss vs Immaterial; low-HP heroes die to one Coup de Grace.

### Mechanical counters
- **Evasion pierce**: MKB has an 80% pierce chance. Pros buy MKB **3.35× more vs PA**, the strongest item
  signal in this report. *both*
- **Physical immunity** (Omni, Ghost Scepter 1.2×). *both*
- **Spell / pure damage** (BB, Axe, Phoenix). *both*
- **Break** turns off Immaterial (general knowledge, verify). Silver Edge is bought **1.6×** more vs PA.
- The curated "armor stackers (DK)" is weak (−1.0 spec / −3.6 raw).

### Items enemies buy against you
MKB, Silver Edge, Ghost Scepter, Blade Mail (1.5×), Heaven's Halberd (1.9×, few games).

---

## Curated claims vs data (`data/curated/heroes.json` → `struggles_vs`)

| Main | Curated "struggles vs" | Data (spec, n) | Verdict |
|------|------------------------|----------------|---------|
| AM | Axe | −5.6 (12k) | ✅ confirmed |
| AM | Legion Commander | −2.7 (12k) | ✅ mild |
| AM | **Phantom Lancer** | **+4.2** (10k) | ❌ AM *beats* PL |
| AM | Bane / Shaman / Lion | +1.0 / −1.1 / −1.6 | ➖ weak |
| Morph | Anti-Mage, Nyx, AA | −4.5 / −3.2 / −3.3 | ✅ confirmed |
| Morph | Silencer | +0.9 (2.1k) | ❌ |
| PL | Ember, ES, Leshrac, Sven | −3.5 / −4.3 / −4.7 / −4.5 | ✅ confirmed |
| PL | Medusa, Viper, Bristleback | +0.1 / +4.5 / +0.8 | ❌ |
| WK | Anti-Mage | −4.4 (13k) | ✅ confirmed |
| WK | Nyx, Drow, Razor, Viper, Doom | +1.2 / +0.6 / +0.9 / −0.3 / +2.2 | ❌ |
| TA | Gyro, Razor, Viper, Jakiro | −1.4 / +1.4 / −0.1 / −1.0 | ❌ (the idea "many hits" is right, the examples are wrong) |
| SF | Storm, Puck, Ember, Void Spirit | −0.4 / +1.5 / +2.8 / +1.4 | ❌ |
| Arc | Slark, Spirit Breaker / Storm | −2.0 / −2.0 / +2.5 | ➖ mild / ❌ |
| PA | Dragon Knight | −1.0 (8.8k) | ➖ weak |

Suggested edits for `heroes.json` (not made here): add Huskar/Meepo/Ursa to AM, remove PL from AM; add
Tidehunter/Underlord/Dark Seer/Axe to PL; replace WK's "kiting heroes" with Warlock/KotL/PL; replace TA's
examples with Phoenix/PL/Spectre; add Broodmother/Meepo/Lycan to Arc; add Bristleback/Troll/Axe/Omni to PA.

---

## Data quality: which numbers to trust

| | Explorer (`public_matches`) | Local snapshot (`heroes/<id>/matchups.json`) |
|--|--|--|
| Bracket | Ancient–Divine (avg rank 60–79) | not documented (high-MMR parsed) |
| Matches per main | 50k–192k | ≈190–4,400 |
| Pairs with ≥30 games | all ≈125 | 0 (Arc) – 119 (SF) |
| Main winrate | close to `heroStats` (WK 53.7, PL 53.1) | off (PL 45.9 vs 52.7 in heroStats) |
| Correlation with the other | — | **−0.09 to +0.22** |

**Trust the explorer.** The local file disagrees even on the hero's own winrate, so its per-opponent
numbers are mostly noise. The app's Draft helper should read `counter_matrix.json` (or a fuller explorer pull)
instead of `matchups.json`.

## Caveats
- **No position filter.** TA, SF and Morph are often mid in pubs. AM/PL/WK/PA/Arc are almost always cores.
- **One week of one patch** (2026-11-09 → 16). Re-run after a patch. The SQL is in `docs/SOURCES.md` §3, and
  `_about` in the JSON describes it.
- **Spec vs raw.** Spec tells you *why* (matchup-specific). Raw tells you *what you'll feel*. When an enemy is
  strong overall (Nyx, OD, Meepo, NS), raw is much worse than spec, and both matter in the draft.
- **Pro item lift** = final inventories in pro/league games. Pros ≠ pubs, sold items are missed, and Arc has only ≈71 games.
- **Mechanics** come from 7.41 `abilities.json`/`items.json`. Liquipedia (HTTP 403) and Fandom (HTTP 402)
  could not be fetched, so interactions not in those texts are marked *(verify)*. The most important one
  is whether Break turns off Reincarnation.
