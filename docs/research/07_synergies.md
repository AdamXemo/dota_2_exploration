# Research 07 — Which teammates make your carries win?

_Data: OpenDota SQL explorer (`public_matches`, Ancient+Divine = `avg_rank_tier` 60–79),
**1,185,543 matches from 2026-11-09 18:55 to 2026-11-17 00:10 UTC** (`match_id > 9083518613`), patch 7.41.
Ally = a hero on **your own team** in the same match. Mechanics from 7.41 constants
(`abilities.json`, `hero_abilities.json`), roles from `heroes.json`.
Machine-readable output: `data/processed/synergy_matrix.json` (built by `scripts/06_fetch_synergies.R`).
Sources: `docs/SOURCES.md` (S11, S4, S5, S6; section "Research 07")._

## TL;DR
1. **Teammates move your winrate less than enemies do.** The best ally for any main is worth only
   **+2.4 to +3.5 pp**; the best counters in R04 were −5 to −11 pp. Draft for counters first, synergy second.
2. **Lockdown supports are the theme.** Almost every top support has a long single-target hold
   (Kinetic Field, Rolling Boulder, Hex+Shackles, Fiend's Grip, Cold Feet). Your carries mostly lack
   a reliable stun, so the support's lockdown is what turns their damage into kills.
3. **Anti-Mage has the clearest "save" supports:** Winter Wyvern **+3.3** (n=7,279, the most solid
   number here), Bane +2.4, Dazzle +2.4, Omniknight +2.4. All four can keep AM alive or drain mana.
4. **Wraith King + Ancient Apparition = +3.5 pp** (n=5,516, 58.2% raw winrate). AA's slows and
   Cold Feet let a no-blink WK reach targets; Ice Blast stops the enemy's healing.
5. **Two greedy carries on one team lose.** The worst allies are other farming cores:
   PA+Juggernaut −5.5, PA+Lifestealer −4.2, AM+PL −4.0 (both ways), Morph+Jugg −3.2.
   If a teammate first-picks a hard carry, don't add a second one.
6. **Io is a trap for your pool.** Io is negative for 6 of 8 mains (PL −2.5, Morph −2.6, PA −2.2,
   TA −1.7, WK −1.6, SF −1.3); only Arc likes him (+1.1). **Ogre Magi** is good for SF (+1.9) but bad for
   PL (−2.4) and Arc (−1.9).

**Honest caveat up front:** for Morphling and Templar Assassin the spread of ally results is almost
what pure luck would produce (see "How sure are we?"). Their lists are hints, not rules.

---

## How to read the numbers

| Column | Meaning |
|--------|---------|
| **Syn** | Ally-specific synergy in percentage points (pp), shrunk. **Lists are ranked by this.** |
| **WR** | Your raw winrate in games with that ally. |
| **n** | Matches with that ally on your team. Lists use only n ≥ 300. ±95% CI ≈ 1.4 pp at n=5k, 2.8 pp at n=1.2k, 5.6 pp at n=300. |
| **Tier** | **S** ≥ +2.3 pp with n ≥ 1,500 · **A** ≥ +1.5 pp · **B** +0.8…+1.5 pp or a strong number with small n. |

### Why not just "winrate with ally"?
Winrate with Ogre Magi is high partly because **Ogre is strong with anyone**. We want the part that
belongs to the *pair*. So we compare the pair with what we would expect if the two heroes simply
add their strengths:

- **expected = inv_logit( logit(wr_you) + logit(wr_ally) )**, where `logit(p) = log(p/(1−p))`.
  A 50% ally changes nothing (logit 0.5 = 0). We chose log-odds over the simpler
  `wr_you + wr_ally − 0.5` because it never leaves 0–100% and is the standard way to add "strengths".
  Near 50% both give almost the same number (the JSON keeps the linear one as `raw_diff_pp`).
- **shrunk = (wins + 500·expected) / (games + 500)**: every pair gets 500 imaginary games at the
  expected winrate. A 300-game pair is pulled ~60% toward 0; a 5,000-game pair barely moves.
- **Syn = shrunk − expected.**
- Overall winrates come from the **same window** (a separate explorer query: every hero's
  games/wins in these 1.19M matches), so the "you" and "ally" baselines match the pair data.

Check: the games-weighted average Syn is ~0 for every main (−0.08 … +0.08 pp), so the model is not
biased up or down.

Example: AM wins 50.9% overall, WW 50.5%. Expected together ≈ 51.4%. Real: **55.0%** in 7,279 games.
After shrinking: Syn = **+3.3 pp**.

### How sure are we?
If allies did not matter at all, the z-scores of the 120+ pairs per main would have SD ≈ 1.0.

| Main | SD of z | Read as |
|------|---------|---------|
| Phantom Lancer | 1.95 | clear real pattern |
| Anti-Mage | 1.67 | clear |
| Phantom Assassin | 1.63 | clear |
| Arc Warden | 1.54 | clear |
| Wraith King | 1.51 | clear |
| Shadow Fiend | 1.37 | some |
| Morphling | 1.13 | **mostly noise** |
| Templar Assassin | 1.11 | **mostly noise** |

---

## Per hero: best supports to have / avoid

Supports here = a hand-made pool of heroes usually played as pos 4/5 in pubs (ids in the script;
general knowledge, the data has no roles). Each main also has a "best cores" line: any ally,
including mids and offlaners.

### Anti-Mage (50.9%, n=192k)
| Tier | Support | Syn | WR | n | Why |
|------|---------|-----|----|---|-----|
| **S** | Winter Wyvern | +3.3 | 55.0 | 7,279 | Cold Embrace freezes + heals AM and blocks physical damage; Winter's Curse makes enemies hit their own ally — free time to Blink in and Mana Void. |
| **S** | Bane | +2.4 | 52.9 | 2,541 | Fiend's Grip steals mana by % of max mana → bigger Mana Void; Nightmare/Enfeeble shut the offlaner. |
| **S** | Dazzle | +2.4 | 55.0 | 5,526 | Shallow Grave = AM can't die during a gank; Weave armor swing. |
| **S** | Omniknight | +2.4 | 55.9 | 2,157 | Guardian Angel (physical immunity), Repel (debuff immunity), Purification in lane. |
| A | Abaddon | +1.6 | 54.9 | 2,556 | Aphotic Shield dispels stuns and absorbs damage; Mist Coil heals. |
| A | Warlock | +1.6 | 50.8 | 4,983 | Fatal Bonds shares damage between bound enemies → Mana Void's damage spreads to the whole bond. |
| B | Chen | +1.5 | 49.5 | 499 | Hand of God global heal (small n). |
| B | Techies | +1.1 | 52.4 | 14,693 | Mines/Sticky Bomb control space near AM's farm *(general knowledge, verify)*. |

- **Best cores:** Death Prophet +2.0 (tower pressure while AM farms, *general knowledge, verify*), Kez +2.0 (small n).
- **Avoid:** Disruptor **−1.4** (n=9,418), Venomancer −1.2, Vengeful Spirit −1.0. Cores: **Phantom Lancer −4.0**,
  Nature's Prophet −2.7, Primal Beast −2.3, Terrorblade −2.2, Morphling −2.2.
- Pattern: AM wants a **save**, not a kill-lane. Disruptor/Venge are kill supports; AM can't use the
  early kills they create.

### Morphling (48.3%, n=50k) — *mostly noise, treat as hints*
| Tier | Support | Syn | WR | n | Why |
|------|---------|-----|----|---|-----|
| **S** | Disruptor | +2.4 | 52.1 | 2,223 | Kinetic Field traps targets for Waveform + Adaptive Strike; Glimpse brings escapes back. |
| A | Batrider | +2.4 | 50.8 | 305 | Lasso drags a target to you *(general knowledge, verify; tiny n)*. |
| A | Sand King | +2.2 | 49.6 | 958 | Burrowstrike stun + Epicenter hold enemies in your burst window. |
| A | Earth Spirit | +1.8 | 51.2 | 1,441 | Rolling Boulder stun, Geomagnetic Grip silence. |
| A | Marci | +1.6 | 50.6 | 1,090 | Bodyguard lends lifesteal + damage; Rebound/Dispose reposition. |
| B | Ring Master | +1.3 | 49.3 | 1,595 | Escape Act boxes you (phased, slow resistance): an extra save. |
| B | Earthshaker | +1.3 | 50.4 | 4,645 | Fissure + Echo Slam lockdown. |
| B | Ancient Apparition | +1.2 | 50.5 | 1,843 | Ice Vortex amplifies magic damage (Waveform/Adaptive). |

- **Best cores:** Kez +2.4, Luna +2.1, Broodmother +1.9, Beastmaster +1.7 (all small n).
- **Avoid:** **Io −2.6**, Dazzle −1.9, Vengeful Spirit −1.7. Cores: Juggernaut −3.2, Ursa −3.0, Tiny −2.3, AM −2.2.

### Phantom Lancer (53.1%, n=119k)
| Tier | Support | Syn | WR | n | Why |
|------|---------|-----|----|---|-----|
| **S** | Techies | +2.4 | 56.0 | 9,751 | Mines, Sticky Bomb, Blast Off! add the AoE/zone PL lacks; Techies falls off when PL's illusions take over *(general knowledge, verify)*. |
| **S** | Phoenix | +2.4 | 57.3 | 4,243 | Sun Ray heals allies; Supernova = big AoE stun for illusions to hit. |
| A | Ancient Apparition | +2.1 | 56.1 | 4,287 | Ice Blast stops healing, Bone Chill steals Strength → illusions finish targets. |
| A | Sand King | +2.0 | 53.5 | 2,349 | Epicenter disables the heroes who would AoE-clear your illusions. |
| A | Keeper of the Light | +1.9 | 56.3 | 2,916 | Chakra Magic refills mana (Doppelganger/Spirit Lance are mana hungry early). |
| A | Earthshaker | +1.9 | 55.8 | 13,931 | Fissure + Echo Slam: enemies can't kite or AoE you. Biggest sample in the report. |
| A | Skywrath Mage | +1.8 | 54.1 | 6,204 | Ancient Seal silences AoE clearers; Mystic Flare picks before you come online. |
| A | Treant Protector | +1.6 | 51.1 | 824 | Living Armor + Overgrowth (small n). |

- **Best cores:** Shadow Fiend +2.3 (n=3,689), Tinker +1.9, Lina +1.9.
- **Avoid:** **Omniknight −2.7**, **Io −2.5**, **Ogre Magi −2.4** (n=7,743). Cores: **AM −4.0**,
  Meepo −3.6, Lifestealer −3.6, Storm Spirit −3.2.
- Pattern: PL wants **AoE disable/damage** next to him (his own damage is single-target). Pure
  buff/heal supports (Omni, Io, Ogre's Bloodlust on one hero) add little to an illusion army
  *(interpretation, verify)*.

### Wraith King (53.7%, n=138k)
| Tier | Support | Syn | WR | n | Why |
|------|---------|-----|----|---|-----|
| **S** | Ancient Apparition | **+3.5** | 58.2 | 5,516 | Cold Feet / Ice Vortex / Bone Chill slow and trap targets a no-blink WK must walk to; Ice Blast stops enemy healing. |
| A | Marci | +2.1 | 56.3 | 2,238 | Rebound/Dispose put WK (or the target) in range; Bodyguard adds lifesteal + damage. |
| A | Chen | +1.9 | 54.3 | 304 | Hand of God; Penitence speeds allied attacks (tiny n). |
| A | Shadow Demon | +1.7 | 51.9 | 1,536 | Demonic Purge strips enemy buffs and slows; Disruption saves WK. |
| B | Largo | +1.4 | 56.0 | 1,018 | Croak of Genius cuts mana costs; Hotfeet Hustle speed + slow resistance. |
| B | Venomancer | +1.3 | 53.2 | 4,446 | Gale/Poison Sting slows so WK reaches targets. |
| B | Skywrath Mage | +1.2 | 54.0 | 7,741 | Ancient Seal silences escapes; Concussive Shot slows. |
| B | Treant Protector | +1.0 | 50.8 | 863 | Overgrowth / Leech Seed root. |

- **Best cores:** Primal Beast +2.4 (initiation he can follow on foot), Gyrocopter +2.1, Arc Warden +1.7, Viper +1.6.
- **Avoid:** **Oracle −2.8**, **Abaddon −2.4**, Bounty Hunter −1.9. Cores: Lifestealer −2.7 (n=5,331), Beastmaster −2.8, Naga −2.4.
- Pattern: WK wants **slows and catch**, not saves. He already has a save (Reincarnation);
  heal/save supports overlap with it *(interpretation, verify)*.

### Templar Assassin (46.2%, n=51k) — *mostly noise, treat as hints*
| Tier | Support | Syn | WR | n | Why |
|------|---------|-----|----|---|-----|
| A | Earth Spirit | +2.8 | 50.5 | 1,450 | Rolling Boulder + Grip silence hold the target for Meld; Boulder Smash kicks enemies to you. |
| A | Disruptor | +2.1 | 49.6 | 2,289 | Kinetic Field + Psionic Trap = target can't leave. |
| A | Shadow Demon | +1.8 | 45.6 | 603 | Disruption saves TA; Menace/Disseminate raise damage taken. |
| A | Earthshaker | +1.6 | 48.7 | 4,536 | Fissure blocks escape paths. |
| B | Treant Protector | +1.4 | 44.7 | 425 | Living Armor heals and blocks damage. |
| B | Venomancer | +1.2 | 46.0 | 1,355 | Slows keep targets in range. |
| B | Sand King | +1.0 | 45.9 | 942 | Burrowstrike + Epicenter. |
| B | Shadow Shaman | +0.9 | 48.4 | 3,090 | Hex + Shackles. |

- **Best cores:** Beastmaster +3.5 (Primal Roar, n=605), Slardar +1.8 (Corrosive Haze armor cut), Bristleback +1.8.
- **Avoid:** Io −1.7, Dazzle −1.6, Bounty Hunter −1.5. Cores: Clinkz −3.0, PA −2.9, Leshrac −2.8, Sniper −2.6, Riki −2.4.
- Pattern: TA is happiest next to **lockdown + a tanky frontline**; other fragile right-clickers (Sniper,
  Clinkz, PA, Riki) make the team too squishy *(interpretation, verify)*.

### Shadow Fiend (41.8%, n=89k)
SF is almost always the **mid** in these games *(general knowledge, verify)*, so his "allies" include the
real pos 1.

| Tier | Support | Syn | WR | n | Why |
|------|---------|-----|----|---|-----|
| A | Ogre Magi | +1.9 | 44.2 | 6,648 | Bloodlust = attack + move speed on SF; Fireblast stun = free razes; Fire Shield. |
| A | Shadow Shaman | +1.9 | 45.0 | 5,404 | Hex + Shackles: three razes or a Requiem walk-in. |
| A | Elder Titan | +1.8 | 46.8 | 543 | Natural Order removes armor **and** magic resistance: boosts both raze and right-click. |
| A | Batrider | +1.8 | 42.0 | 448 | Lasso into raze range *(general knowledge, verify; tiny n)*. |
| B | Tusk | +1.4 | 42.7 | 3,117 | Snowball carries SF in; Drinking Buddies armor + speed. |
| B | Omniknight | +1.2 | 45.5 | 1,221 | Repel / Guardian Angel when SF is jumped. |
| B | Treant / Abaddon | +1.0 | — | 721 / 1,256 | Living Armor / Aphotic Shield. |

- **Best cores:** Slardar +2.5 (Corrosive Haze + Crush), Bristleback +2.5, Drow Ranger +2.4
  (Precision Aura gives agility to *ranged* allies — SF is ranged), Phantom Lancer +2.3.
- **Avoid:** Dark Willow −1.9, Venomancer −1.7, Witch Doctor −1.6. Cores: Terrorblade −2.2, Outworld Devourer −2.2, Kunkka −2.0.
- Even the best ally lifts SF to only ~44–47%: **synergy can't rescue a 41.8% hero.**

### Arc Warden (51.5%, n=56k)
| Tier | Support | Syn | WR | n | Why |
|------|---------|-----|----|---|-----|
| **S** | Spirit Breaker | +2.5 | 55.9 | 4,630 | Charge + Nether Strike pick-offs across the map while Arc split-pushes. |
| A | Tusk | +2.5 | 54.1 | 1,727 | Walrus Kick / Ice Shards lock; Tag Team adds physical damage taken — Arc **and** his double hit for it. |
| A | Disruptor | +1.8 | 54.6 | 2,277 | Kinetic Field holds targets for Spark Wraiths and double Flux. |
| A | Jakiro | +1.7 | 51.5 | 1,673 | Ice Path stun; Liquid Fire/Frost push towers early *(tempo = general knowledge, verify)*. |
| A | Omniknight | +1.6 | 56.5 | 682 | Guardian Angel / Repel vs physical burst. |
| A | Hoodwink | +1.6 | 50.5 | 3,330 | Bushwhack stun; Sharpshooter Break. |
| A | Bounty Hunter | +1.5 | 56.6 | 2,008 | Track = True Sight + damage taken + bonus kill gold; Friendly Shadow hides split-pushing Arc. |
| B | Techies | +1.4 | 53.4 | 4,552 | Mines defend the base while Arc is away *(general knowledge, verify)*. |

- **Best cores:** Ursa +2.6, Clockwerk +2.5, Axe +2.2 (Berserker's Call holds the team for Magnetic Field fights), Naga +2.4 (n=366).
- **Avoid:** **Keeper of the Light −4.5** (n=626), **Marci −2.8**, Abaddon −2.1. Cores: Ember −5.1, Storm −4.5,
  Tinker −3.3, Sniper −3.1 (other mid/ranged greedy heroes).
- Note: Arc's "avoid" list is the opposite of PL's — KotL is +1.9 for PL but −4.5 for Arc.

### Phantom Assassin (50.8%, n=122k)
| Tier | Support | Syn | WR | n | Why |
|------|---------|-----|----|---|-----|
| A | Silencer | +1.7 | 52.4 | 5,544 | Global Silence stops saves/escapes; Last Word on the target you Phantom Strike. |
| A | Batrider | +1.7 | 49.9 | 689 | Lasso *(general knowledge, verify)*. |
| B | Earth Spirit | +1.5 | 53.0 | 3,092 | Boulder stun + Grip silence. |
| B | Disruptor | +1.4 | 53.1 | 5,316 | Kinetic Field + Glimpse. |
| B | Jakiro | +1.1 | 49.7 | 4,837 | Ice Path + Liquid Frost; Macropyre AoE. |
| B | Skywrath Mage | +1.0 | 50.9 | 6,558 | Ancient Seal + Concussive Shot. |
| B | Nyx Assassin | +0.9 | 55.2 | 7,104 | Impale stun → PA finishes. |
| B | Ogre Magi | +0.9 | 52.0 | 9,952 | Bloodlust attack speed = more crit procs; Fireblast stun. |

- **Best cores (PA's strongest pairs are mids):** **Invoker +2.0** (n=13,068, tight CI), **Zeus +1.9** (n=8,944),
  Mars +1.6 (Arena of Blood, *general knowledge, verify*), Gyrocopter +1.6. PA lacks magic damage; these add it.
- **Avoid:** Io −2.2, Windranger −1.8, Oracle −1.1. Cores: **Juggernaut −5.5** (the biggest negative in the report),
  Lifestealer −4.2, Meepo −3.7, Ursa −3.2, TA −2.9 — melee physical carries that want the same farm and
  are all stopped by the same items (Ghost/armor) *(interpretation, verify)*.

---

## Cross-table: "Your team already has X support → your best carry is…"

Syn in pp (n ≥ 300 for every cell). "Avoid" = the main with the lowest Syn.

| Teammate picked | Best main (Syn) | Also fine | Avoid |
|-----------------|-----------------|-----------|-------|
| **Ancient Apparition** | **WK +3.5** | PL +2.1, Morph +1.2 | SF −0.6 |
| **Winter Wyvern** | **AM +3.3** | Morph +0.6 | WK −1.4, SF −1.1 |
| **Bane** | **AM +2.4** | PA +0.7 | PL −1.1 |
| **Dazzle** | **AM +2.4** | PA +0.7 | Morph −1.9, TA −1.6 |
| **Omniknight** | **AM +2.4** | Arc +1.6, SF +1.2 | **PL −2.7** |
| **Disruptor** | **Morph +2.4** / TA +2.1 | Arc +1.8, PA +1.4, PL +1.2 | AM −1.4 |
| **Earth Spirit** | **TA +2.8** | Morph +1.8, PA +1.5 | WK −0.5 |
| **Earthshaker** | **PL +1.9** | TA +1.6, Morph +1.3 | SF −0.7 |
| **Techies** | **PL +2.4** | Arc +1.4, AM +1.1, Morph +1.1 | SF −1.4 |
| **Phoenix** | **PL +2.4** | Arc +1.0, AM +1.0 | Morph −1.2, SF −1.2 |
| **Spirit Breaker** | **Arc +2.5** | Morph +1.2 | PL −0.8, PA −0.6 |
| **Tusk** | **Arc +2.5** | SF +1.4 | AM −0.7, PL −0.6 |
| **Marci** | **WK +2.1** | Morph +1.6 | **Arc −2.8**, PL −1.9 |
| **Silencer** | **PA +1.7** | SF +0.3 | PL −1.3, Arc −1.3 |
| **Ogre Magi** | **SF +1.9** | PA +0.9 | **PL −2.4**, Arc −1.9 |
| **Shadow Shaman** | **SF +1.9** | TA +0.9 | PL −1.5 |
| **Skywrath Mage** | **PL +1.8** | WK +1.2, PA +1.0 | Arc −1.4 |
| **Keeper of the Light** | **PL +1.9** | Morph +0.9 | **Arc −4.5**, WK −1.8 |
| **Sand King** | **Morph +2.2** | PL +1.9 | Arc −1.7 |
| **Shadow Demon** | **TA +1.8** | WK +1.7 | AM −0.7 |
| **Venomancer** | **PL +1.6** | WK +1.3, TA +1.2 | SF −1.7, AM −1.2 |
| **Warlock** | **AM +1.6** | — | PL −1.8 |
| **Oracle** | AM +0.7 | Arc +0.3 | **WK −2.8** |
| **Abaddon** | AM +1.6 | SF +1.0 | **WK −2.4**, Arc −2.1 |
| **Io** | Arc +1.1 | AM 0.0 | Morph −2.6, PL −2.5, PA −2.2 |
| **Hoodwink / Jakiro / Lich** | Arc +1.6 / +1.7 / +1.1 | PL, AM ≈ +1 | Grimstroke→Arc −1.7 |

Neutral supports (no main moves more than ±1 pp): **Crystal Maiden, Lion, Pudge, Rubick, Mirana,
Snapfire, Undying, Grimstroke**. With them, just pick your best counter/meta hero.

### One-glance version
- **AM** ← WW, Bane, Dazzle, Omni (saves + mana drain). Not with Disruptor.
- **WK** ← AA, Marci, Shadow Demon (slows/catch). Not with Oracle, Abaddon.
- **PL** ← Techies, Phoenix, AA, ES, KotL, Sky (AoE). Not with Omni, Io, Ogre.
- **Arc** ← Spirit Breaker, Tusk, Disruptor, Jakiro (catch + tempo). Not with KotL, Marci.
- **PA** ← Silencer, Earth Spirit, Disruptor + a magic-damage mid (Invoker/Zeus). Not with Io, WR.
- **SF** ← Ogre, Shaman (stuns for razes). Not with Dark Willow, Venomancer.
- **Morph / TA** ← Disruptor, Earth Spirit (single-target lockdown). Weak evidence.

---

## Practical lane advice (safelane duo)

The data has **no lane or position**, so this section combines the ally numbers with what each support
does in lane *(lane habits = general knowledge, verify)*.

| Your carry | Best safelane partner (pos 5) | Why it wins your lane | Pos 4 you want roaming |
|------------|-------------------------------|------------------------|-------------------------|
| **Anti-Mage** | **Winter Wyvern** or **Dazzle** | Heals / Shallow Grave / Cold Embrace let AM farm through harass; Bane if you want lane control (Nightmare the offlaner). | Omniknight (+2.4) — or keep the save support close in fights. |
| **Wraith King** | **Ancient Apparition** | Chilling Touch/Cold Feet harass + slows keep the offlaner off you; Ice Blast later kills sustain. | Marci or Shadow Demon to catch for you. |
| **Phantom Lancer** | **Techies** or **Keeper of the Light** | Techies zones with mines/Sticky Bomb; KotL's Chakra Magic fixes PL's early mana. | Phoenix / Earthshaker / Skywrath for AoE fights. |
| **Arc Warden** | **Jakiro** or **Disruptor** | Ice Path / Kinetic Field lock targets for Flux + Spark; Jakiro pushes the tower early. | Spirit Breaker or Tusk (+2.5): pick-offs while you split. |
| **Phantom Assassin** | **Disruptor** or **Jakiro** | Thunder Strike/Glimpse or Ice Path → early kills with Phantom Strike. | Earth Spirit or Silencer (late-game Global Silence). |
| **Morphling** | **Disruptor** | Kinetic Field + Glimpse set up Waveform/Adaptive kills. | Earth Spirit, Sand King. |
| **Templar Assassin** (if safelane) | **Disruptor** | Field + Psionic Trap. | Earth Spirit, Shadow Demon. |
| **Shadow Fiend** (mid) | — | Wants **Ogre / Shaman** stuns rotating mid for raze kills. | Tusk (Snowball). |

Rules of thumb:
1. **One carry per team.** If your teammate first-picks Jugg / LS / PL / AM, don't pick a second
   melee hard carry (−3 to −5.5 pp). Take a mid/offlane role or the one main that pairs well
   (e.g. WK with Gyro +2.1, PL with SF +2.3).
2. **Saves for AM, catch for WK/Arc/PA, AoE for PL.**
3. If your support picks **Io**, prefer **Arc** (only positive main) or AM (neutral).
4. If your support picks **KotL**, play **PL**, never Arc.

---

## Caveats

1. **Pubs = random teammates.** You don't choose your supports in solo queue. Use this when you
   **last-pick** (pick the main that fits the supports already chosen) or in a party.
2. **No roles in the data.** `public_matches` has only hero ids. "Ally Disruptor" means Disruptor on
   your team in *any* role; SF is usually mid, Silencer / Lina / Marci are sometimes cores. Role tags in
   the JSON are OpenDota hero tags, not the position played.
3. **Synergy is small.** ±2–3 pp is real only when n is large. At n ≈ 300–700 the 95% CI is ±4–5 pp,
   larger than the effect: we marked those rows (tiny n / noise?). Shrinkage (500 prior games) already
   pulls them toward 0.
4. **Morphling and TA lists are mostly noise** (SD of z ≈ 1.1, i.e. near pure chance).
5. **Draft confounding.** A pair also tells you about the *rest* of the draft: heroes that get picked
   with AM may be picked by players who plan around a late game. The effect is the pair *plus* its
   usual draft context.
6. **One week, one bracket.** 2026-11-09 → 2026-11-17, Ancient–Divine lobby average (`avg_rank_tier`
   60–79). A balance patch can flip any line.
7. **Mechanic lines** quote `abilities.json` (7.41 constants). Lane habits, tempo and item claims are
   *(general knowledge, verify)*. Patterns marked *(interpretation, verify)* are our explanation of the
   numbers, not something the data proves.

---

## Reproduce
```
Rscript scripts/06_fetch_synergies.R          # 10 explorer requests, ~75 s, resumable
Rscript scripts/06_fetch_synergies.R 3e6      # smaller window if the explorer times out
```
Delete `data/raw/opendota/bracket_synergies/` to start a fresh window. The JSON fields are explained in
`synergy_matrix.json` → `_about`.
