# =============================================================================
# run_tests.R — a tiny test suite with NO extra packages (base R + dplyr only).
#
# Run from the repo root:
#     Rscript tests/run_tests.R
#
# How a test works:
#   stopifnot(condition)  -> if `condition` is FALSE, R raises an error.
#   test_that_simple()    -> runs a block of code, catches any error, and
#                            prints "ok" or "FAIL" for that test.
#
# So a test is just a block of code with stopifnot() checks inside it.
# =============================================================================

# The tests need the repo root as the working folder (it contains data/).
if (!dir.exists("data") || !dir.exists("app")) {
  stop("Please run this from the repo root:  Rscript tests/run_tests.R")
}

# library() loads a package. dplyr gives us filter(), arrange(), tibble() ...
# suppressPackageStartupMessages() hides the "Attaching package" chatter.
suppressPackageStartupMessages(library(dplyr))

# Load the project code in the same order the app does.
# config.R must come first: the other files read the settings it defines.
for (f in c("app/R/config.R", "app/R/opendota.R", "app/R/data.R", "app/R/scoring.R")) {
  source(f)
}

# -----------------------------------------------------------------------------
# The test helper. It runs `code`; if that stops with an error, the test fails
# and we print the reason. It returns TRUE (pass) or FALSE (fail).
# (We use message() instead of print() so the output goes to stderr and
#  stays readable next to any warnings.)
# -----------------------------------------------------------------------------
test_that_simple <- function(name, code) {
  ok <- tryCatch({ code; TRUE }, error = function(e) {
    message("  FAIL: ", name, " -> ", conditionMessage(e))
    FALSE
  })
  if (ok) message("  ok:   ", name)
  invisible(ok)
}

# Every test adds its TRUE/FALSE result to this vector, so at the end we can
# count passes and failures. Usage looks like:
#   test_results <- c(test_results, test_that_simple("name", { ... }))
test_results <- logical(0)

# Load the big data snapshot once, the same way the app does.
db <- load_db()

# =============================================================================
# 1. scoring.R — the maths
# =============================================================================
message("\n== scoring.R: shrink() ==")

# shrink() pulls small samples toward 0.5. With no games we should get 0.5.
test_results <- c(test_results, test_that_simple("0 games -> baseline 0.5", {
  stopifnot(abs(shrink(0, 0) - 0.5) < 1e-9)
}))

# A huge sample barely moves: 6 million wins out of 10 million games is 60%,
# and the shrunk value should be very close to 0.60.
test_results <- c(test_results, test_that_simple("huge sample -> close to raw winrate", {
  shrunk <- shrink(6e6, 1e7)
  stopifnot(abs(shrunk - 0.6) < 0.001)
}))

# A small sample is pulled toward 0.5, but not all the way:
# the result must sit between the baseline (0.5) and the raw winrate (0.6).
test_results <- c(test_results, test_that_simple("result lies between raw winrate and baseline", {
  shrunk <- shrink(60, 100)              # raw winrate 0.60
  stopifnot(shrunk > 0.5, shrunk < 0.6)
}))

# -----------------------------------------------------------------------------
message("\n== scoring.R: assign_tier() boundaries ==")

# The cut-offs are: S >= 0.525, A >= 0.510, B >= 0.495, C >= 0.480, else D.
# Each line checks a value just above or below a cut-off.
test_results <- c(test_results, test_that_simple("0.53 -> S", {
  stopifnot(assign_tier(0.53) == "S")
}))
test_results <- c(test_results, test_that_simple("0.515 -> A", {
  stopifnot(assign_tier(0.515) == "A")
}))
test_results <- c(test_results, test_that_simple("0.50 -> B", {
  stopifnot(assign_tier(0.50) == "B")
}))
test_results <- c(test_results, test_that_simple("0.485 -> C", {
  stopifnot(assign_tier(0.485) == "C")
}))
test_results <- c(test_results, test_that_simple("0.40 -> D", {
  stopifnot(assign_tier(0.40) == "D")
}))

# -----------------------------------------------------------------------------
message("\n== scoring.R: bracket_stats() on the real data ==")

test_results <- c(test_results, test_that_simple("bracket_stats: one row per hero", {
  bs <- bracket_stats(db$hero_stats)
  stopifnot(nrow(bs) == nrow(db$hero_stats))
}))

test_results <- c(test_results, test_that_simple("bracket_stats: winrate is between 0 and 1", {
  bs <- bracket_stats(db$hero_stats)
  stopifnot(all(bs$winrate >= 0 & bs$winrate <= 1))   # NA here fails too
}))

# Every match has 10 heroes, so the pick rates of all heroes add up to 10
# (1 hero per slot). We allow a little slack for rounding.
test_results <- c(test_results, test_that_simple("bracket_stats: pickrates sum to ~10", {
  bs <- bracket_stats(db$hero_stats)
  total <- sum(bs$pickrate)
  stopifnot(total >= 9.5, total <= 10.5)
}))

# -----------------------------------------------------------------------------
message("\n== scoring.R: carry_meta_board() ==")

test_results <- c(test_results, test_that_simple("carry board: exactly META_BOARD_SIZE rows", {
  board <- carry_meta_board(bracket_stats(db$hero_stats))
  stopifnot(nrow(board) == META_BOARD_SIZE)
}))

test_results <- c(test_results, test_that_simple("carry board: every hero is in CARRY_POOL", {
  board <- carry_meta_board(bracket_stats(db$hero_stats))
  stopifnot(all(board$id %in% CARRY_POOL))
}))

test_results <- c(test_results, test_that_simple("carry board: sorted by wr_adj, best first", {
  board <- carry_meta_board(bracket_stats(db$hero_stats))
  # diff() gives the change from each row to the next; it must never go up.
  stopifnot(all(diff(board$wr_adj) <= 0))
}))

# -----------------------------------------------------------------------------
message("\n== scoring.R: matchup_advantages() ==")

# Symmetric input: the hero wins 60 of 100 vs hero 2 and 40 of 100 vs hero 3.
# The two results mirror each other around 50%, so the advantages should cancel.
test_results <- c(test_results, test_that_simple("matchup_advantages: symmetric input sums to ~0", {
  fake <- data.frame(hero_id = c(2, 3), games_played = c(100, 100), wins = c(60, 40))
  adv <- matchup_advantages(fake)
  stopifnot(abs(sum(adv$advantage)) < 1e-9)
}))

test_results <- c(test_results, test_that_simple("matchup_advantages: winning matchup is positive", {
  fake <- data.frame(hero_id = c(2, 3), games_played = c(100, 100), wins = c(60, 40))
  adv <- matchup_advantages(fake)
  stopifnot(adv$advantage[adv$hero_id == 2] > 0)
}))

test_results <- c(test_results, test_that_simple("matchup_advantages: NULL input -> empty table", {
  adv <- matchup_advantages(NULL)
  stopifnot(is.data.frame(adv), nrow(adv) == 0)
}))

# -----------------------------------------------------------------------------
# TODO(human) functions: we only check the SHAPE of the answer here (one
# number), not the final behaviour, because you will write that yourself.
# -----------------------------------------------------------------------------
message("\n== scoring.R: TODO(human) functions (shape only) ==")

test_results <- c(test_results, test_that_simple("score_candidate() returns one number", {
  s <- score_candidate(0.532, c(0.03, -0.01, NA))
  stopifnot(is.numeric(s), length(s) == 1, !is.na(s))
}))

test_results <- c(test_results, test_that_simple("percentile_of() returns one number (NA allowed)", {
  p <- percentile_of(620, data.frame(percentile = c(.1, .5, .9), value = c(400, 620, 800)))
  stopifnot(is.numeric(p), length(p) == 1)
}))

# -----------------------------------------------------------------------------
# OPTIONAL — enable after you implement percentile_of() and score_candidate().
# Remove the leading "# " from the lines below to turn these checks on.
# They describe the behaviour the TODO comments in app/R/scoring.R ask for.
# -----------------------------------------------------------------------------
#
# bench <- data.frame(percentile = c(.1, .5, .9), value = c(400, 620, 800))
#
# test_results <- c(test_results, test_that_simple("percentile_of: middle value -> 0.5", {
#   stopifnot(abs(percentile_of(620, bench) - 0.5) < 1e-6)
# }))
# test_results <- c(test_results, test_that_simple("percentile_of: below range clamps to 0.1", {
#   stopifnot(abs(percentile_of(100, bench) - 0.1) < 1e-6)
# }))
# test_results <- c(test_results, test_that_simple("percentile_of: above range clamps to 0.9", {
#   stopifnot(abs(percentile_of(999, bench) - 0.9) < 1e-6)
# }))
#
# test_results <- c(test_results, test_that_simple("score_candidate: positive advantage raises the score", {
#   stopifnot(score_candidate(0.52, c(0.03)) > score_candidate(0.52, c(0)))
# }))
# test_results <- c(test_results, test_that_simple("score_candidate: NA advantages are ignored", {
#   stopifnot(abs(score_candidate(0.52, c(0.02, NA)) - score_candidate(0.52, c(0.02))) < 1e-9)
# }))

# =============================================================================
# 2. Data integrity — the hand-written and generated files must be sane.
# =============================================================================
message("\n== data integrity ==")

test_results <- c(test_results, test_that_simple("every JSON in data/curated and data/processed parses", {
  json_files <- c(list.files("data/curated",   pattern = "\\.json$", full.names = TRUE),
                  list.files("data/processed", pattern = "\\.json$", full.names = TRUE))
  stopifnot(length(json_files) > 0)
  for (f in json_files) {
    # tryCatch() again, so the error names the broken file.
    tryCatch(jsonlite::fromJSON(f),
             error = function(e) stop("cannot parse ", f, ": ", conditionMessage(e)))
  }
}))

# The curated hero notes refer to items by key ("bfury"). Every key must exist
# in the OpenDota item list we loaded into db$items.
test_results <- c(test_results, test_that_simple("every item key in curated heroes.json exists in db$items", {
  for (h in db$curated$heroes) {
    keys <- c(vapply(h$starting, function(x) x$item, character(1)),
              unlist(lapply(h$starting_variants, function(v) v$items)),
              vapply(h$laning,       function(x) x$item, character(1)),
              vapply(h$core,         function(x) x$item, character(1)),
              vapply(h$situational,  function(x) x$item, character(1)))
    missing_keys <- setdiff(keys, names(db$items))
    if (length(missing_keys) > 0) {
      stop(h$key, " uses unknown items: ", paste(missing_keys, collapse = ", "))
    }
  }
}))

test_results <- c(test_results, test_that_simple("every curated hero id is one of MY_MAINS", {
  curated_ids <- vapply(db$curated$heroes, function(h) h$id, numeric(1))
  stopifnot(all(curated_ids %in% MY_MAINS))
}))

# Starting kits are bought at the start of the game, so they must fit in 600
# gold (the starting gold). We check the normal kit and each variant.
test_results <- c(test_results, test_that_simple("starting kits and variants cost <= 600 gold", {
  for (h in db$curated$heroes) {
    kit_keys <- vapply(h$starting, function(x) x$item, character(1))
    kit_cost <- sum(item_cost(db, kit_keys))
    if (!isTRUE(kit_cost <= 600)) stop(h$key, " starting kit costs ", kit_cost)

    for (v in h$starting_variants) {
      var_cost <- sum(item_cost(db, unlist(v$items)))
      if (!isTRUE(var_cost <= 600)) stop(h$key, " variant '", v$situation, "' costs ", var_cost)
    }
  }
}))

# Core items come with a target minute ("buy bfury by minute 15").
# Rules: whole number, between 5 and 60, and later items never get an earlier target.
test_results <- c(test_results, test_that_simple("core targets: whole minutes 5-60, non-decreasing", {
  for (h in db$curated$heroes) {
    targets <- vapply(h$core, function(x) x$target_min %||% NA_real_, numeric(1))
    in_range <- !is.na(targets) & targets == round(targets) & targets >= 5 & targets <= 60
    if (!all(in_range)) stop(h$key, " has a core target that is missing, not whole, or outside 5-60")
    if (any(diff(targets) < 0)) stop(h$key, " core targets go backwards in time")
  }
}))

test_results <- c(test_results, test_that_simple("every CARRY_POOL hero id exists in db$heroes", {
  stopifnot(all(CARRY_POOL %in% db$heroes$id))
}))

test_results <- c(test_results, test_that_simple("bracket matchup file exists with games for every CARRY_POOL hero", {
  for (id in CARRY_POOL) {
    f <- path_data("raw", "opendota", "bracket_matchups", paste0(id, ".json"))
    if (!file.exists(f)) stop("missing file for hero ", id)
    rows <- jsonlite::fromJSON(f)$rows
    if (!isTRUE(sum(rows$games_played) > 0)) stop("no games in ", basename(f))
  }
}))

# =============================================================================
# 3. Data helpers (the small lookup functions in data.R)
# =============================================================================
message("\n== data helpers ==")

test_results <- c(test_results, test_that_simple("item_img(\"bfury\") is an https url", {
  url <- item_img(db, "bfury")
  stopifnot(startsWith(url, "https://"))
}))

test_results <- c(test_results, test_that_simple("hero_item_popularity(db, 1) has Start/Early/Core/Late", {
  pop <- hero_item_popularity(db, 1)
  stopifnot(all(c("Start", "Early", "Core", "Late") %in% as.character(pop$phase)))
}))

test_results <- c(test_results, test_that_simple("hero_matchups(42) carries a 'source' attribute", {
  m <- hero_matchups(42)
  stopifnot(!is.null(attr(m, "source")))
}))

# ally_synergies(): research 07 says WK + Ancient Apparition (68) is about +3.5 pp,
# and synergies should average out near 0 (the model has no built-in bias).
test_results <- c(test_results, test_that_simple("ally_synergies(42): WK + AA positive, mean near 0", {
  s <- ally_synergies(42)
  stopifnot(nrow(s) > 50)
  stopifnot(s$synergy[s$hero_id == 68] > 0.02)
  stopifnot(abs(mean(s$synergy)) < 0.005)
  stopifnot(is.null(ally_synergies(8)))   # no synergy file for non-mains
}))

# =============================================================================
# Summary
# =============================================================================
n_total <- length(test_results)
n_pass  <- sum(test_results)
n_fail  <- n_total - n_pass

message("\n----------------------------------------")
message(n_pass, " passed, ", n_fail, " failed, ", n_total, " tests in total")

# Exit with status 1 when anything failed, so scripts and CI can notice.
if (n_fail > 0) quit(status = 1)
