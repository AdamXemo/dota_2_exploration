# =============================================================================
# 06_fetch_synergies.R — "Which TEAMMATES make my carries win?"
# Ancient–Divine ally data from the OpenDota SQL explorer + a synergy matrix.
#
# Run from the repo root:   Rscript scripts/06_fetch_synergies.R [window]
#   window = how many recent match ids to scan (default 10e6 ≈ 1 week ≈ 1.2M
#   Ancient+Divine games). Use a smaller window (e.g. 3e6) if queries time out.
#
# Same style as scripts/04_fetch_bracket_matchups.R, but instead of the 5
# ENEMY heroes we look at the 4 ALLIED heroes (our own team, minus our hero).
#
# Outputs:
#   data/raw/opendota/bracket_synergies/<hero_id>.json   (one per main)
#     { hero_id, window_from_match_id, fetched_at, rows: [{hero_id, games_played, wins}] }
#     rows = one per ALLY: games where that hero was on OUR team, and wins.
#   data/raw/opendota/bracket_synergies/_overall.json
#     every hero's own games/wins in the SAME window (needed for "expected").
#   data/raw/opendota/bracket_synergies/_window.json
#     first/last match time + number of matches in the window (for the docs).
#   data/processed/synergy_matrix.json   (built in PART B from the files above)
#
# The explorer has a ~15 s statement timeout and is sometimes overloaded, so
# each query is retried with growing pauses and finished files are skipped
# (just re-run the script later to fill the gaps). Budget: 8 heroes + 2 extra
# queries = 10 requests (+ retries), always >= 3 s apart.
# =============================================================================

source("app/R/config.R")
source("app/R/opendota.R")
suppressPackageStartupMessages(library(dplyr))

args   <- commandArgs(trailingOnly = TRUE)
WINDOW <- if (length(args)) as.numeric(args[1]) else 10e6
OUT    <- path_data("raw", "opendota", "bracket_synergies")
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)

PAUSE        <- 3     # seconds between explorer requests (be gentle: shared API)
MAX_REQUESTS <- 60    # hard cap for the whole run (retries included)
n_requests   <- 0

# -----------------------------------------------------------------------------
# PART A — download
# -----------------------------------------------------------------------------

# The newest match id tells us where "the last week" starts. If a previous run
# already saved a window, we REUSE its starting id so all files describe the
# same set of matches (otherwise a re-run a day later would mix two windows).
window_file <- file.path(OUT, "_window.json")
if (file.exists(window_file)) {
  from <- jsonlite::fromJSON(window_file)$window_from_match_id
} else {
  latest <- max(od_get("publicMatches")$match_id)
  from   <- latest - WINDOW
}

run_explorer <- function(sql, tries = 5) {
  for (i in seq_len(tries)) {
    if (n_requests >= MAX_REQUESTS) { message("   request cap reached"); return(NULL) }
    n_requests <<- n_requests + 1          # <<- updates the counter outside the function
    url <- paste0(OPENDOTA_API, "/explorer?sql=", URLencode(sql, reserved = TRUE))
    res <- tryCatch(jsonlite::fromJSON(url), error = function(e) list(err = conditionMessage(e)))
    if (is.null(res$err) || identical(res$err, "") || length(res$rows)) return(res$rows)
    message("   timeout/error (", i, "/", tries, "): ", substr(res$err, 1, 60))
    Sys.sleep(10 * i)  # 10s, 20s, 30s...
  }
  NULL
}

# Shared WHERE clause: Ancient I .. Divine V (avg_rank_tier 60-79) in the window.
where_sql <- sprintf("match_id > %.0f AND avg_rank_tier >= 60 AND avg_rank_tier < 80", from)

# 1) One query per main. In words: "take every Ancient–Divine match in the
#    window that contains hero H; take H's OWN team array (radiant_team if H is
#    Radiant, else dire_team), unnest it into 5 rows, drop H itself (and the
#    hero_id 0 'empty slot' rows); count games and wins per ally".
#    won = (H is Radiant) == radiant_win, i.e. TRUE when H's side won.
synergy_sql <- function(h) sprintf(paste(
  "SELECT ally AS hero_id, count(*) AS games_played,",
  "sum(CASE WHEN won THEN 1 ELSE 0 END) AS wins FROM (",
  "SELECT unnest(CASE WHEN %1$d = ANY(radiant_team) THEN radiant_team ELSE dire_team END) AS ally,",
  "(%1$d = ANY(radiant_team)) = radiant_win AS won",
  "FROM public_matches WHERE %2$s",
  "AND (%1$d = ANY(radiant_team) OR %1$d = ANY(dire_team))) t",
  "WHERE ally <> %1$d AND ally > 0 GROUP BY ally"), h, where_sql)

# 2) Every hero's overall games/wins in the same window: unnest BOTH teams
#    (10 rows per match), won = was this hero's side the winner.
overall_sql <- paste(
  "SELECT hero_id, count(*) AS games_played, sum(CASE WHEN won THEN 1 ELSE 0 END) AS wins FROM (",
  "SELECT unnest(radiant_team) AS hero_id, radiant_win AS won FROM public_matches WHERE", where_sql,
  "UNION ALL",
  "SELECT unnest(dire_team) AS hero_id, NOT radiant_win AS won FROM public_matches WHERE", where_sql,
  ") t WHERE hero_id > 0 GROUP BY hero_id")

# 3) Window facts: how many matches and which dates (start_time = unix seconds).
window_sql <- paste(
  "SELECT count(*) AS matches, min(start_time) AS first_start, max(start_time) AS last_start,",
  "max(match_id) AS last_match_id FROM public_matches WHERE", where_sql)

stamp <- function() format(Sys.time(), "%Y-%m-%d %H:%M %Z")

if (!file.exists(window_file)) {
  message("-> window facts")
  rows <- run_explorer(window_sql)
  if (!is.null(rows)) {
    write_json_pretty(list(window_from_match_id = from, matches = rows$matches,
      first_start_utc = format(as.POSIXct(rows$first_start, origin = "1970-01-01", tz = "UTC")),
      last_start_utc  = format(as.POSIXct(rows$last_start,  origin = "1970-01-01", tz = "UTC")),
      last_match_id = rows$last_match_id, fetched_at = stamp()), window_file)
  }
  Sys.sleep(PAUSE)
}

for (h in MY_MAINS) {
  file <- file.path(OUT, paste0(h, ".json"))
  if (file.exists(file)) next
  message("-> hero ", h)
  rows <- run_explorer(synergy_sql(h))
  if (is.null(rows)) { message("   skipped (re-run later)"); Sys.sleep(PAUSE); next }
  write_json_pretty(list(hero_id = h, window_from_match_id = from,
                         fetched_at = stamp(), rows = rows), file)
  Sys.sleep(PAUSE)
}

overall_file <- file.path(OUT, "_overall.json")
if (!file.exists(overall_file)) {
  message("-> overall hero winrates in the window")
  rows <- run_explorer(overall_sql)
  if (!is.null(rows)) write_json_pretty(list(window_from_match_id = from,
                                             fetched_at = stamp(), rows = rows), overall_file)
}
message("Download: ", n_requests, " explorer requests this run; ",
        sum(file.exists(file.path(OUT, paste0(MY_MAINS, ".json")))), " / ",
        length(MY_MAINS), " mains have ally data.")

# -----------------------------------------------------------------------------
# PART B — build data/processed/synergy_matrix.json
# -----------------------------------------------------------------------------
# Problem: "AM wins 56% with Ogre Magi" might only mean "Ogre wins 55% with
# ANYONE". We want the part that is specific to the PAIR.
#
# Choice: a log-odds (logit) model. logit(p) = log(p / (1 - p)) turns a
# winrate into "how many units above a coin flip". If hero and ally just add
# their strengths, the pair's expected winrate is
#     expected = inv_logit( logit(wr_H) + logit(wr_A) )
# (logit(0.5) = 0, so a 50% ally changes nothing). Why not the simple
# wr_H + wr_A - 0.5? Near 50% both give almost the same number (we report the
# linear one too as a check), but the logit version can never go above 100%
# and treats strong heroes more fairly.
#
# Small samples: we shrink the observed winrate towards "expected" as if
# every pair had PRIOR extra games at exactly the expected winrate:
#     shrunk = (wins + PRIOR * expected) / (games + PRIOR)
#     synergy_pp = 100 * (shrunk - expected)
# A pair with 300 games is pulled ~60% of the way to 0; one with 5000 games
# barely moves. Pairs below MIN_GAMES are not ranked at all.
PRIOR     <- 500
MIN_GAMES <- 300
N_TOP     <- 8
N_BOTTOM  <- 5

# public_matches has NO position/role column, so "who played support" is
# unknown. For the "best supports to have" lists we use a hand-made pool of
# heroes that are played as pos 4/5 most of the time in 7.41 pubs (general
# knowledge, verify). OpenDota's own "Support" tag is too wide (it includes
# Lina, Abaddon, Marci...), so we do not rely on it here.
SUPPORT_POOL <- c(3, 5, 7, 9, 14, 16, 20, 21, 26, 27, 30, 31, 37, 40, 50, 57, 62,
                  64, 65, 66, 68, 71, 75, 79, 83, 84, 85, 86, 87, 88, 90, 91, 100,
                  101, 102, 103, 105, 107, 110, 111, 112, 119, 121, 123, 128, 131,
                  136, 155)

logit     <- function(p) log(p / (1 - p))
inv_logit <- function(x) 1 / (1 + exp(-x))

have <- file.exists(file.path(OUT, paste0(MY_MAINS, ".json")))
if (!all(have)) stop("Not all mains downloaded yet - re-run the script later.")

# Overall winrates: our own window query if it exists, else hero_stats (6+7).
if (file.exists(overall_file)) {
  overall <- jsonlite::fromJSON(overall_file)$rows |>
    transmute(hero_id, wr = wins / games_played, games = games_played)
  overall_source <- "explorer, same window (_overall.json)"
} else {
  hs <- jsonlite::fromJSON(path_data("raw", "opendota", "hero_stats.json"))
  overall <- data.frame(hero_id = hs$id, games = hs$`6_pick` + hs$`7_pick`,
                        wr = (hs$`6_win` + hs$`7_win`) / (hs$`6_pick` + hs$`7_pick`))
  overall_source <- "hero_stats.json columns 6_* + 7_* (fallback)"
}

# Hero names + roles from the constants (heroes.json is keyed by id).
hc <- jsonlite::fromJSON(path_data("raw", "opendota", "constants", "heroes.json"))
hero_info <- bind_rows(lapply(hc, function(x) data.frame(
  hero_id = x$id, name = x$localized_name, roles = paste(x$roles, collapse = ", "))))

# Hand-written 1-line "WHY does this ally help?" notes, keyed
# "<main id>_<ally id>". Written AFTER looking at the numbers: the data picks
# the allies, these lines only try to explain them. Ability names/effects come
# from data/raw/opendota/constants/abilities.json; anything NOT in that file
# (lane habits, tempo, item timings) is marked "(general knowledge, verify)".
# "noise?" = the 95% CI is wider than the synergy itself (a hint, not a fact).
REASONS <- c(
  # --- Anti-Mage (1) ---------------------------------------------------------
  "1_112" = "Cold Embrace freezes+heals AM and blocks physical damage (save while farming); Winter's Curse makes enemies hit their own ally - free time to Blink in and Mana Void.",
  "1_3"   = "Fiend's Grip steals mana every 0.5 s based on max mana -> emptier pools = bigger Mana Void; Nightmare/Enfeeble shut the enemy offlaner in lane.",
  "1_50"  = "Shallow Grave keeps AM alive through ganks while he farms; Weave adds ally armor / removes enemy armor (more Mana Break hits land).",
  "1_57"  = "Guardian Angel = physical immunity, Repel = debuff immunity; Purification heals in lane - covers AM's weak 0-20 min.",
  "1_43"  = "Exorcism takes towers fast and Silence locks spellcasters: DP creates map pressure while AM farms (general knowledge, verify).",
  "1_145" = "Kez is a weak-overall tempo core; AM's late game may cover Kez's falloff (hypothesis, general knowledge, verify; noise?).",
  "1_102" = "Aphotic Shield dispels and absorbs damage, Mist Coil heals: breaks lane harass and disables on AM.",
  "1_37"  = "Fatal Bonds shares damage between bound enemies -> Mana Void's AoE damage is spread to the whole bonded team; Chaotic Offering stun sets it up.",
  "1_66"  = "Hand of God heals the whole team globally; Divine Favor armor/regen in lane; creeps pressure the map (small sample, noise?).",
  "1_105" = "Proximity Mines and Sticky Bomb control space around AM's farm; Reactive Tazer gives speed to escape (general knowledge for 'space', verify).",
  # --- Morphling (10) --------------------------------------------------------
  "10_87"  = "Kinetic Field traps targets for Morph's Adaptive Strike/Waveform burst; Glimpse pulls escaping heroes back.",
  "10_145" = "Both are high-tempo agility cores; small sample, likely draft-context effect (general knowledge, verify; noise?).",
  "10_65"  = "Flaming Lasso drags a target to Morph (general knowledge, verify; 305 games, noise?).",
  "10_16"  = "Burrowstrike stun + Epicenter AoE hold enemies inside Morph's damage window.",
  "10_48"  = "Two late carries with AoE (Luna) + single-target (Morph): strong late fights (general knowledge, verify; noise?).",
  "10_61"  = "Brood splits lanes and soaks attention while Morph farms (general knowledge, verify; noise?).",
  "10_107" = "Rolling Boulder stun, Geomagnetic Grip silence, Boulder Smash/Grip can also reposition Morph (ally targets).",
  "10_38"  = "Primal Roar is a long single-target stun - a free Adaptive Strike/Waveform combo (noise?).",
  "10_136" = "Dispose/Rebound can throw or follow an ally; Bodyguard gives lifesteal+damage to the target ally (Morph).",
  "10_131" = "Escape Act boxes an ally (phased, slow resistance) - an extra save on a squishy agility carry.",
  "10_7"   = "Fissure blocks paths and stuns, Echo Slam big AoE: lockdown that lets Morph burst.",
  "10_68"  = "Cold Feet / Ice Vortex slows keep targets in place; Ice Vortex amplifies magic damage (Waveform/Adaptive).",
  # --- Phantom Lancer (12) ---------------------------------------------------
  "12_105" = "Mines/Sticky Bomb/Blast Off! add AoE and zone control; Techies is weak in long fights where PL's illusions take over (general knowledge, verify).",
  "12_110" = "Sun Ray heals allies, Supernova stuns in a huge area: sustain plus a long AoE lock for illusions to hit.",
  "12_11"  = "SF (usually mid) brings early burst and Requiem AoE fear while PL scales (general knowledge, verify).",
  "12_68"  = "Ice Blast stops healing and Bone Chill steals Strength: illusions finish targets that would otherwise regen.",
  "12_145" = "Small sample; Kez's silence/slow + PL's illusions (general knowledge, verify; noise?).",
  "12_16"  = "Epicenter + Sand Storm AoE: enemies that try to AoE-clear illusions are disabled first (general knowledge, verify).",
  "12_34"  = "Tinker pushes/clears waves from range, PL keeps lanes safe late (general knowledge, verify).",
  "12_25"  = "Lina's burst/stun adds the magic damage PL lacks early (general knowledge, verify).",
  "12_90"  = "Chakra Magic restores mana - PL's Doppelganger/Spirit Lance are mana-hungry early; Blinding Light knockbacks.",
  "12_7"   = "Fissure + Echo Slam control enemies that would otherwise kite or AoE illusions.",
  "12_101" = "Ancient Seal silence + Mystic Flare: kill pickoffs before PL comes online; silence stops AoE-illusion clears.",
  "12_83"  = "Living Armor heals/blocks damage, Overgrowth roots the whole enemy team for illusions to hit (noise?).",
  # --- Wraith King (42) ------------------------------------------------------
  "42_68"  = "Cold Feet/Ice Vortex/Bone Chill slow and stun-trap targets a no-blink WK must walk to; Ice Blast stops enemy healing (no lifesteal race).",
  "42_137" = "Onslaught/Pulverize initiate and hold targets; WK follows on foot with Wraithfire Blast (general knowledge for WK, verify).",
  "42_136" = "Rebound/Dispose throw WK or enemies into range; Bodyguard adds lifesteal+damage to WK.",
  "42_72"  = "Second core with AoE magic (Call Down, Rocket Barrage) next to WK's pure right-click (general knowledge, verify).",
  "42_66"  = "Hand of God global heal; Penitence makes allies attack the target faster (304 games, noise?).",
  "42_113" = "Arc's double items/split push with WK's tanky fighting (general knowledge, verify).",
  "42_79"  = "Demonic Purge removes enemy buffs (Ghost/Euls/BKB? verify) and slows; Disruption saves WK; Menace raises damage taken.",
  "42_47"  = "Viper Strike/Poison Attack slow and break passives: kiting heroes can't run from WK (general knowledge, verify).",
  "42_155" = "Croak of Genius lowers WK's mana costs and adds damage; songs give speed/heal/slow resistance (Hotfeet Hustle).",
  "42_40"  = "Venomous Gale/Poison Sting slows: WK reaches targets; Noxious Plague AoE damage.",
  "42_101" = "Ancient Seal silences escape spells; Concussive Shot slows targets WK can't otherwise catch.",
  "42_83"  = "Overgrowth roots everyone around Treant, Leech Seed roots one: lockdown for a melee walker.",
  # --- Templar Assassin (46) -------------------------------------------------
  "46_38"  = "Primal Roar long single-target stun = free Meld hits; Wild Axes amplify damage taken (605 games, noise?).",
  "46_107" = "Rolling Boulder stun + Geomagnetic Grip silence lock targets for Meld; Boulder Smash can kick an enemy toward TA.",
  "46_87"  = "Kinetic Field traps the target for TA's Psionic Traps + Meld; Glimpse pulls back escapes.",
  "46_79"  = "Disruption saves TA (and creates illusions); Menace and Disseminate raise damage on the TA target.",
  "46_28"  = "Corrosive Haze removes armor (TA is armor-reduction physical burst) + Slithereen Crush stun.",
  "46_99"  = "Frontline that soaks damage/attention so fragile TA can hit (general knowledge, verify; noise?).",
  "46_7"   = "Fissure blocks escape paths; Echo Slam AoE - targets stay in TA's range.",
  "46_83"  = "Living Armor heals TA and blocks damage; Overgrowth roots (noise?).",
  "46_40"  = "Slows from Venomous Gale/Poison Sting keep targets in TA range.",
  "46_16"  = "Burrowstrike stun + Epicenter: lockdown for TA burst.",
  "46_27"  = "Hex + Shackles: two long disables = free kills for TA.",
  # --- Shadow Fiend (11) -----------------------------------------------------
  "11_28"  = "Corrosive Haze removes armor and gives True Sight; Slithereen Crush stuns - SF's raze/Requiem follow-up lands on a held target.",
  "11_99"  = "Tanky frontline that soaks damage while SF stands back; (general knowledge, verify).",
  "11_6"   = "Precision Aura gives agility to RANGED allies (SF is ranged); Gust silences enemies jumping on SF.",
  "11_12"  = "PL illusions draw attention and spells while SF farms/razes; both scale (general knowledge, verify).",
  "11_84"  = "Bloodlust gives SF attack speed + move speed; Fireblast stun = free razes; Fire Shield blocks hero attacks.",
  "11_27"  = "Hex + Shackles hold the target for three razes or a Requiem walk-in.",
  "11_59"  = "Huskar's lane/mid-game damage + SF's AoE: early-game fight team (general knowledge, verify; noise?).",
  "11_103" = "Natural Order removes armor AND magic resistance - boosts both SF's right-click and raze/Requiem damage (noise?).",
  "11_65"  = "Lasso drags a target into raze range (general knowledge, verify; noise?).",
  "11_100" = "Snowball can carry SF into position; Walrus Kick/Ice Shards lock the target; Drinking Buddies gives armor+speed.",
  "11_57"  = "Repel (debuff immunity) / Guardian Angel save SF when he is jumped.",
  "11_83"  = "Living Armor heals/blocks damage on SF; Overgrowth roots (noise?).",
  "11_102" = "Aphotic Shield dispels stuns/silences off SF and absorbs damage.",
  # --- Arc Warden (113) ------------------------------------------------------
  "113_70"  = "Strong early right-click core: Arc's Magnetic Field/Spark Wraith + Ursa take objectives fast (general knowledge, verify).",
  "113_100" = "Walrus Kick/Ice Shards lock targets; Tag Team adds physical damage taken - Arc + Tempest Double both hit for it.",
  "113_71"  = "Charge of Darkness and Nether Strike bash pick-offs across the map while Arc split-pushes (map pressure, general knowledge for 'split', verify).",
  "113_51"  = "Hookshot/Power Cogs trap a target for Arc's double Flux/Spark Wraith (noise?).",
  "113_89"  = "Naga + Arc: double split push; Song of the Siren resets fights (366 games, noise?).",
  "113_2"   = "Berserker's Call holds the enemy team still for Spark Wraith + Magnetic Field fights.",
  "113_19"  = "Tiny stun/burst early + Arc's late game (general knowledge, verify; noise?).",
  "113_22"  = "Global magic damage (Thundergod's Wrath) complements Arc's single-target late game (general knowledge, verify).",
  "113_87"  = "Kinetic Field traps targets for Spark Wraiths and double Flux; Glimpse brings escapes back.",
  "113_64"  = "Ice Path stun + Liquid Frost/Fire push waves and towers fast (Arc wants early towers, general knowledge, verify).",
  "113_57"  = "Guardian Angel/Repel save Arc (and the double, if Omni casts on it) from physical burst (noise?).",
  "113_123" = "Bushwhack stuns near trees; Sharpshooter adds Break + long-range damage for picks.",
  "113_62"  = "Track gives True Sight + damage taken + extra gold on kills; Friendly Shadow can hide Arc while split-pushing.",
  "113_105" = "Mines/Sticky Bomb defend Arc's base area while he split-pushes (general knowledge, verify).",
  # --- Phantom Assassin (44) -------------------------------------------------
  "44_74"  = "Invoker mid brings global/AoE control (Cold Snap, Tornado, EMP; general knowledge, verify) - PA crits on held targets.",
  "44_22"  = "Global magic damage and vision while PA right-clicks; covers PA's lack of magic damage (general knowledge, verify).",
  "44_75"  = "Global Silence stops enemy saves/escapes for the whole team; Last Word silences the target PA jumps.",
  "44_65"  = "Lasso drags a target into PA (general knowledge, verify; noise?).",
  "44_77"  = "Lycan pushes buildings fast while PA fights (general knowledge, verify; noise?).",
  "44_129" = "Arena of Blood traps enemies inside with PA (general knowledge, verify).",
  "44_72"  = "AoE magic (Rocket Barrage, Call Down) on top of PA's single-target physical damage.",
  "44_35"  = "Long-range physical damage and Shrapnel slow; draws focus away from PA (general knowledge, verify).",
  "44_107" = "Rolling Boulder stun, Geomagnetic Grip silence: lockdown for crits.",
  "44_87"  = "Kinetic Field traps the target for PA's Phantom Strike follow-up; Glimpse undoes escapes.",
  "44_64"  = "Ice Path stun + Liquid Frost slow; Macropyre AoE damage while PA crits.",
  "44_101" = "Ancient Seal silences escapes/BKB-less saves; Concussive Shot slows.",
  "44_88"  = "Impale stun + Mind Flare: pick-off combo, then PA finishes.",
  "44_84"  = "Bloodlust attack speed = more crit procs; Fireblast stun; Fire Shield blocks hero attacks."
)

# Full ranked table of allies for one main (used for the lists AND the cross table).
ally_table <- function(h) {
  raw <- jsonlite::fromJSON(file.path(OUT, paste0(h, ".json")))$rows
  wr_h <- overall$wr[overall$hero_id == h]
  tab <- raw |>
    filter(games_played >= MIN_GAMES) |>
    inner_join(overall |> rename(wr_ally = wr, ally_games = games), by = "hero_id") |>
    left_join(hero_info, by = "hero_id") |>
    mutate(winrate     = wins / games_played,
           expected    = inv_logit(logit(wr_h) + logit(wr_ally)),
           expected_lin = wr_h + wr_ally - 0.5,
           shrunk      = (wins + PRIOR * expected) / (games_played + PRIOR),
           synergy_pp  = round(100 * (shrunk - expected), 2),
           raw_diff_pp = round(100 * (winrate - expected_lin), 2),
           ci95_pp     = round(196 * sqrt(winrate * (1 - winrate) / games_played), 2)) |>
    arrange(desc(synergy_pp))
  tab
}

build_main <- function(h) {
  tab  <- ally_table(h)
  wr_h <- overall$wr[overall$hero_id == h]
  sup  <- tab |> filter(hero_id %in% SUPPORT_POOL)
  fmt <- function(d) lapply(seq_len(nrow(d)), function(i) {
    r <- unname(REASONS[paste0(h, "_", d$hero_id[i])])
    if (length(r) == 0 || is.na(r)) r <- NULL
    list(hero_id = d$hero_id[i], name = d$name[i], roles = d$roles[i],
         games = d$games_played[i], winrate = round(100 * d$winrate[i], 2),
         ally_overall_wr = round(100 * d$wr_ally[i], 2),
         expected_wr = round(100 * d$expected[i], 2),
         synergy_pp = d$synergy_pp[i], raw_diff_pp = d$raw_diff_pp[i],
         ci95_pp = d$ci95_pp[i], reason = if (is.null(r)) NULL else r)
  })
  list(hero_id = h, name = hero_info$name[hero_info$hero_id == h],
       overall_wr = round(100 * wr_h, 2),
       games = overall$games[overall$hero_id == h],
       allies_ranked = nrow(tab),
       top_allies = fmt(head(tab, N_TOP)),
       bottom_allies = fmt(tail(tab, N_BOTTOM)[N_BOTTOM:1, ]),   # worst first
       top_supports = fmt(head(sup, N_TOP)),
       bottom_supports = fmt(tail(sup, 3)[3:1, ]))
}

# Cross table: for every pool support, synergy_pp with each of the 8 mains
# ("my team already has X - which of my carries fits best?").
cross <- bind_rows(lapply(MY_MAINS, function(h)
  ally_table(h) |> filter(hero_id %in% SUPPORT_POOL) |>
    transmute(support_id = hero_id, support = name, main_id = h, synergy_pp, games = games_played)))
cross_out <- lapply(split(cross, cross$support), function(d) {
  d <- d[order(-d$synergy_pp), ]
  list(support_id = d$support_id[1],
       by_main = lapply(seq_len(nrow(d)), function(i) list(
         main = names(MY_MAINS)[MY_MAINS == d$main_id[i]], synergy_pp = d$synergy_pp[i],
         games = d$games[i])))
})

win <- if (file.exists(window_file)) jsonlite::fromJSON(window_file) else list()
matrix_out <- list(
  `_about` = list(
    title = "Ally synergy matrix for the 8 mains, patch 7.41, Ancient-Divine",
    generated = format(Sys.Date()),
    doc = "docs/research/07_synergies.md",
    script = "scripts/06_fetch_synergies.R",
    window = list(from_match_id = from, matches = win$matches,
                  first_start_utc = win$first_start_utc, last_start_utc = win$last_start_utc),
    method = paste0(
      "OpenDota SQL explorer, public_matches, avg_rank_tier 60-79 (Ancient+Divine). For main H and ally A: ",
      "games = matches with A on H's own team, wins = H's team won. Overall winrates (wr_H, wr_A) from ",
      overall_source, ". expected = inv_logit(logit(wr_H) + logit(wr_A)) (additive log-odds: 'no special ",
      "interaction'). synergy_pp = 100*(shrunk - expected) with shrunk = (wins + ", PRIOR,
      "*expected)/(games + ", PRIOR, "). raw_diff_pp = raw winrate - (wr_H + wr_A - 0.5), unshrunk linear check. ",
      "Only allies with games >= ", MIN_GAMES, " are ranked. ci95_pp = 1.96*binomial SE of the raw winrate. ",
      "Positions/roles are NOT in public_matches: 'roles' are OpenDota hero tags, not the role played."),
    sources = c("S11 OpenDota SQL explorer, public_matches (docs/SOURCES.md, Research 07)",
                "data/raw/opendota/constants/heroes.json (roles)",
                "data/raw/opendota/constants/abilities.json + hero_abilities.json (reasons)"),
    support_pool = "top_supports/bottom_supports/support_cross use a hand-made pool of usual pos 4/5 heroes (ids in the script, general knowledge): roles are not in the data.",
    reason_marking = "Reasons that rely on knowledge not in abilities.json are marked '(general knowledge, verify)'."),
  mains = setNames(lapply(MY_MAINS, build_main), names(MY_MAINS)),
  support_cross = cross_out)

write_json_pretty(matrix_out, path_data("processed", "synergy_matrix.json"))
message("Wrote data/processed/synergy_matrix.json")
