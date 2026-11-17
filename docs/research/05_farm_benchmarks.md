# Research 05 — What "good farm" looks like for your carries

_Data: OpenDota `/benchmarks?hero_id=…` (percentiles of GPM, XPM, last hits/min, hero damage,
tower damage, deaths per match), snapshot 2026-11-17, patch 7.41. Compare yourself on the
**My Stats** page. Note: OpenDota computes benchmarks from its recent public-match sample,
not filtered by rank, so treat "50th percentile" as "a typical public game"._

## TL;DR
- **Median GPM targets** for your mains: Arc 705 · AM 672 · PL 639 · TA 629 · PA 618 ·
  Morph 589 · WK 578 · SF 572. Top-10% games sit ~150–250 GPM higher.
- **Wraith King wins with the *least* gold** (578 GPM median, lowest of the pool) and still has
  the highest winrate in your bracket. He's a *gold-efficient* carry: his kit (Reincarnation,
  lifesteal, stun) does the work items do for others. If your team needs farm too, WK is a good pick.
- **Anti-Mage is the opposite:** 672 GPM and 9.5 LH/min at the median, with the lowest
  deaths/min of the pool (0.13). His whole value is turning safety into farm.
- **SF and PA die the most** (0.19 deaths/min): high-risk, high-burst heroes. Your death count on
  them is the first thing to check after a loss.
- **Arc Warden's GPM leads** (705, top 10% = 944) because of the Hand of Midas + Tempest Double gold engine.

## Benchmarks table (median = 50th percentile)
| Hero | GPM median | GPM top 20% | GPM top 10% | XPM median | LH/min median | LH/min top 10% | Hero dmg/min | Tower dmg | Deaths/min |
|------|----:|----:|----:|----:|----:|----:|----:|----:|----:|
| Arc Warden | 705 | 869 | 944 | 758 | 7.2 | 11.2 | 822 | 4.8k | 0.18 |
| Anti-Mage | 672 | 802 | 856 | 937 | 9.5 | 12.6 | 569 | 6.7k | **0.13** |
| Phantom Lancer | 639 | 786 | 849 | 869 | 8.9 | 12.2 | 640 | 6.3k | **0.13** |
| Templar Assassin | 629 | 757 | 827 | 902 | 8.8 | 12.1 | 643 | 4.7k | 0.16 |
| Phantom Assassin | 618 | 752 | 813 | 881 | 7.6 | 10.4 | 703 | 3.8k | 0.19 |
| Morphling | 589 | 727 | 797 | 788 | 8.2 | 11.2 | 528 | 4.8k | 0.15 |
| Wraith King | **578** | 684 | 734 | 814 | 6.7 | 9.4 | 738 | 5.6k | 0.15 |
| Shadow Fiend | 572 | 689 | 753 | 797 | 7.4 | 10.1 | 662 | 2.2k | 0.19 |
| _Juggernaut (ref)_ | 652 | 772 | 828 | 891 | 9.1 | 12.0 | 667 | 6.8k | 0.16 |
| _Spectre (ref)_ | 601 | 708 | 753 | 875 | 7.1 | 9.5 | 938 | 3.2k | 0.16 |
| _Luna (ref)_ | 687 | 825 | 890 | 905 | 10.9 | 14.7 | 702 | 8.3k | 0.16 |

## How to use these numbers
1. **After each game, check one number per hero.**
   AM/PL: LH/min (target ≥ 9). WK: tower damage (≥ 5.5k = you converted fights into
   objectives). SF/PA: deaths (≤ 0.15/min ≈ 6 deaths in 40 min).
2. **GPM percentile ≠ win.** WK with 600 GPM is above median; AM with 600 GPM is below. Always
   compare against the *hero's own* benchmark, never across heroes.
3. **Tower damage separates "farmer" from "carry".** AM, PL, Jugg and Luna show 6–8k at the
   median, while SF and Spectre show 2–3k. If your number is low on a pusher, you farmed but didn't play the map.
4. **The LH/min gap between median and top 10% is ~3 LH/min** for every hero, which is ~120 extra
   creeps in a 40-minute game, about 5–6k gold. Farm patterns (Research 02/03 items + the
   playbook) are where most of a carry's improvement lives.

## Item timing targets (curated, Ancient–Divine)
Core item minute targets live in `data/curated/heroes.json → core[].target_min`; the My Stats
page compares your first-purchase minutes against them. A sanity check against a public pro
account's last TA games gave Desolator at 13.8 min (target 14) and Blink at 18.3 min (target 18).

## Caveats
- Benchmarks are not rank-filtered. Ancient–Divine medians are probably a bit above these.
- Arc Warden's last hits may undercount Tempest Double kills (verify), so judge Arc on GPM.
- Percentiles cover full matches; short stomps inflate GPM and long games deflate it.
