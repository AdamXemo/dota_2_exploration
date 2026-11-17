# Mechanics cheat sheet

Machine-readable version: `data/curated/mechanics.json`. Values marked *(verify)*
move between patches; formulas are stable.

## Attributes
| Attribute | Each point gives | Primary-attribute bonus |
|-----------|------------------|-------------------------|
| Strength  | +22 max HP, +0.1 HP regen | +1 damage |
| Agility   | +0.167 armor, +1 attack speed | +1 damage |
| Intellect | +12 mana, +0.05 mana regen, +0.1% magic resist | +1 damage |
| Universal | — | ~+0.7 damage per point of every attribute *(verify)* |

## Damage types
- **Physical** reduced by armor:
  `multiplier = 1 − 0.06·armor / (1 + 0.06·|armor|)`
  → 10 armor = take 62.5%, 20 armor = 45.5%, −5 armor = 123%.
  Armor reduction (Desolator, Assault, TA Meld) is therefore huge for burst carries.
- **Magical** reduced by magic resistance (heroes have 25% base). Sources stack
  multiplicatively: 25% + 15% → 36.25%, not 40%.
- **Pure** ignores both.

## Attack speed
`attacks/second = (100 + bonus AS) / (100 · BAT)`. Default BAT 1.7.
Lower BAT multiplies all attack speed. There is a cap (~700 *(verify)*).

## Evasion and true strike
- Evasion only stops attacks, never spells. Multiple sources stack with diminishing returns.
- Counters: MKB (80% pierce), Bloodthorn (pierce chance), Witch Blade/Parasma (first hit),
  and abilities with true strike.

## Disables and resistances
- **Status resistance** shortens disables. **Slow resistance** is a separate stat.
- **Debuff immunity** (BKB) blocks most disables + 60% magic resist (current data).
  Abilities that "pierce debuff immunity" still land (Abyssal Overwhelm, many ultimates).
- **Break**: turns passives off (WK Reincarnation/lifesteal, PA Immaterial). Silver Edge, Doom, PA Aghanim's.
- **Dispel**: *basic* removes most buffs/debuffs but not stuns (Manta, Satanic, BKB on cast,
  Nullifier on the target). *Strong* also removes stuns (Aeon Disk proc, Aphotic Shield, Dark Pact).
- Silence = no spells; Mute = no items; Hex = no spells, no items, no attacks.

## Economy
- Creep wave every **30 s**; siege creep every 5th wave *(verify)*.
- **Pull** small/medium camps at ~x:15 / x:45 so neutrals meet the lane creeps.
- **Stack** a camp by pulling it out of the spawn box at ~x:53–x:55. A stacked camp + cleave/AoE
  = carry gold.
- **Deny**: last-hitting your own creep denies the enemy gold and reduces their XP.
- **Comeback mechanics**: the team behind gets more gold/XP from kills; one bad fight can flip a lead.

## Map objects
- Power runes in river every 2 min from 6:00 *(verify)*. Arc Warden turns them into permanent stats.
- Bounty runes every 3 min (team gold). Wisdom runes at map edges every ~7 min *(verify)*.
- **Tormentor** (mid game, ~15–20 min *(verify)*): gives the team a free Aghanim's Shard.
- **Roshan**: Aegis = an extra life (later kills add Cheese and more *(verify)*). Respawn 8–11 min.
- **Neutral items**: tiers unlock around 5/15/25/35/60 min; the system was reworked in 7.38 *(verify)*.
- Day/night 5 min each; night lowers vision, which is good for ganks and bad for carries farming alone.

## Positions
1 safe-lane carry · 2 mid · 3 offlane · 4 soft support · 5 hard support.
