# =============================================================================
# scoring.R — the "math" of the project, kept separate from the UI so it can
# be tested and reused (the LLM context builder uses it too).
#
# Key idea used everywhere: SHRINKAGE (a.k.a. Bayesian smoothing).
#   A hero with 7 wins out of 10 games shows 70% winrate, but that is mostly
#   luck. A hero with 7000/10000 is genuinely strong. Shrinkage pretends every
#   hero also played `prior` extra games at a baseline winrate, so small samples
#   get pulled toward the baseline and big samples barely move:
#
#       adjusted = (wins + prior * baseline) / (games + prior)
# =============================================================================

library(dplyr)

shrink <- function(wins, games, prior = PRIOR_GAMES, baseline = 0.5) {
  (wins + prior * baseline) / (games + prior)
}

# -----------------------------------------------------------------------------
# Hero stats for a set of rank brackets.
# `hero_stats` is the raw heroStats table; `brackets` e.g. c(6, 7).
# OpenDota stores picks/wins in columns named "6_pick", "6_win", ... so we
# build those column names with paste0() and add them up row by row.
# -----------------------------------------------------------------------------
bracket_stats <- function(hero_stats, brackets = DEFAULT_BRACKETS) {
  pick_cols <- paste0(brackets, "_pick")
  win_cols  <- paste0(brackets, "_win")

  picks <- rowSums(hero_stats[, pick_cols, drop = FALSE])
  wins  <- rowSums(hero_stats[, win_cols,  drop = FALSE])

  # 10 heroes per match -> total matches = all picks / 10
  total_matches <- sum(picks) / 10

  tibble(
    id        = hero_stats$id,
    name      = hero_stats$localized_name,
    attr      = hero_stats$primary_attr,
    img       = cdn_url(hero_stats$img),
    icon      = cdn_url(hero_stats$icon),
    picks     = picks,
    wins      = wins,
    winrate   = wins / picks,
    pickrate  = picks / total_matches,     # share of matches the hero appears in
    wr_adj    = shrink(wins, picks),
    pro_picks = hero_stats$pro_pick,
    pro_bans  = hero_stats$pro_ban
  )
}

# Tier letters from the shrunk winrate. Simple fixed cut-offs so the meaning
# is easy to remember: S = clearly strong, C/D = struggling this patch.
assign_tier <- function(wr_adj) {
  case_when(
    wr_adj >= 0.525 ~ "S",
    wr_adj >= 0.510 ~ "A",
    wr_adj >= 0.495 ~ "B",
    wr_adj >= 0.480 ~ "C",
    TRUE            ~ "D"
  )
}

# The 15-hero carry board: carry pool only, best shrunk winrate first.
carry_meta_board <- function(stats, pool = CARRY_POOL, n = META_BOARD_SIZE) {
  stats |>
    filter(id %in% pool) |>
    arrange(desc(wr_adj)) |>
    mutate(
      rank    = row_number(),
      tier    = assign_tier(wr_adj),
      is_main = id %in% MY_MAINS
    ) |>
    slice_head(n = n)
}

# -----------------------------------------------------------------------------
# Matchups. OpenDota's /heroes/{id}/matchups returns, for hero H, one row per
# opponent: games_played and wins (wins = games H won against that opponent).
#
# advantage = how much better H does vs this opponent than H does on average.
# +0.04 means "4 percentage points better than usual" -> a counter-pick.
# Matchup samples are small (high-MMR parsed games), so we shrink each
# matchup toward H's own average with a smaller prior.
# -----------------------------------------------------------------------------
matchup_advantages <- function(matchups, prior = 60) {
  if (is.null(matchups) || nrow(matchups) == 0) return(tibble(hero_id = integer(), advantage = numeric(), games = integer()))
  overall <- sum(matchups$wins) / sum(matchups$games_played)
  matchups |>
    transmute(
      hero_id   = hero_id,
      games     = games_played,
      advantage = shrink(wins, games_played, prior = prior, baseline = overall) - overall
    )
}

# -----------------------------------------------------------------------------
# TODO(human): score_candidate() — the brain of the Draft Helper.
#
# Inputs
#   base_wr     single number, the candidate's shrunk winrate in your bracket
#               (e.g. 0.532 for Wraith King).
#   advantages  numeric vector, one value per enemy hero already picked,
#               from matchup_advantages() (e.g. c(0.03, -0.01, NA)).
#               NA = no matchup data for that enemy.
#
# Return ONE number: how good this pick is right now, on a "percentage
# points above 50%" scale (so 0 = coin flip, +3 = strong pick).
#
# Spec / hints
#   1. Start from base strength: (base_wr - 0.5) * 100.
#   2. Add the matchup part: sum of the advantages * 100, ignoring NAs
#      (look at sum(..., na.rm = TRUE)).
#   3. Pick a weight for the matchup part. Matchups usually matter more than
#      raw meta strength once 3+ enemies are known, so try 1.0-1.5. Make it an
#      argument with a default, e.g. `matchup_weight = 1.2`.
#   4. Bonus: should 5 known enemies count 5x as much as 1? Maybe average
#      instead of sum, or cap each advantage with pmin()/pmax().
#
# Right now it only returns the base strength, so the helper ranks your pool
# by meta and ignores the enemy draft. Replace the body to make it smart.
# -----------------------------------------------------------------------------
score_candidate <- function(base_wr, advantages) {
  (base_wr - 0.5) * 100
}

# -----------------------------------------------------------------------------
# TODO(human): percentile_of() — "how does my GPM compare to other players?"
#
# Inputs
#   value      your number, e.g. 612 (GPM in one match).
#   benchmark  data frame with columns `percentile` (0.1 ... 0.99) and `value`
#              from OpenDota benchmarks, e.g.
#                percentile value
#                0.1        428
#                0.5        620
#                0.99       890
#
# Return a number between 0 and 1: the share of players you beat.
# 612 above would be about 0.47.
#
# Hint: base R's approx(x, y, xout) does linear interpolation. Here x =
# benchmark$value, y = benchmark$percentile, xout = value. Use rule = 2 so
# values outside the table are clamped to the ends instead of becoming NA.
#
# Right now it returns NA and the My Stats page shows "TODO" in that column.
# -----------------------------------------------------------------------------
percentile_of <- function(value, benchmark) {
  NA_real_
}
