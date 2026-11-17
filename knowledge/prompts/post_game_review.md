# Prompt: post-game review

Use after a game, ideally with the match id so Claude can pull it from OpenDota.

```
Read knowledge/00_dota_brain.md, knowledge/02_carry_playbook.md and
knowledge/heroes/[hero].md.

Review my match [match_id] (OpenDota: https://api.opendota.com/api/matches/[match_id]).
I played [hero] (player slot / side: [radiant|dire]).

1. Compare my item timings to the core[].target_min in data/curated/heroes.json.
2. Compare my GPM / last hits at 10 min to data/raw/opendota/heroes/[id]/benchmarks.json.
3. Name the 3 biggest mistakes or missed opportunities (with minute marks if visible).
4. One concrete habit to practise next game.
```
