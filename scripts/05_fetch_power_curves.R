# =============================================================================
# 05_fetch_power_curves.R — "When does each carry win?"
# Winrate by GAME DURATION for the 32-hero carry pool, Ancient–Divine only,
# from the OpenDota SQL explorer (research 06).
#
# Run from the repo root:   Rscript scripts/05_fetch_power_curves.R [window]
#   window = how many recent match ids to scan (default 10e6 ≈ 1 week ≈ 1.2M
#   Ancient+Divine games). Use a smaller window (e.g. 3e6) if queries time out.
#   Add --fresh to throw away the saved raw files and fetch everything again.
#
# What it does (3 steps):
#   1. FETCH  one SQL query per hero -> data/raw/opendota/power_curves/<hero_id>.json
#             plus one "baseline" query for the whole bracket -> _baseline.json
#   2. BUILD  per hero: winrate per 5-minute bucket, shrunk winrate, early/late
#             index, peak window, curve label -> data/processed/power_curves.json
#   3. CHART  the 8 mains' curves as a PNG -> docs/img/power_curves_mains.png
#
# The explorer has a ~15 s statement timeout and is sometimes overloaded, so
# each hero is retried with growing pauses and finished heroes are skipped
# (just re-run the script later to fill the gaps). We stay gentle: at least
# 3 s between requests and a hard cap on the total number of requests.
#
# What worked (2026-11-17): one query per hero over a 10M match-id window ran
# in ≈4 s each, so the smaller 3e6 window and the "one big grouped query for
# all heroes" plan were not needed.
# =============================================================================

source("app/R/config.R")
source("app/R/opendota.R")
source("app/R/scoring.R")   # for shrink() (also loads dplyr)

# --- Settings ----------------------------------------------------------------
args   <- commandArgs(trailingOnly = TRUE)
FRESH  <- "--fresh" %in% args
num    <- suppressWarnings(as.numeric(args[!args %in% "--fresh"]))
WINDOW <- if (length(num) && !is.na(num[1])) num[1] else 10e6

OUT       <- path_data("raw", "opendota", "power_curves")
PROCESSED <- path_data("processed", "power_curves.json")
CHART     <- file.path(REPO_ROOT, "docs", "img", "power_curves_mains.png")
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)
if (FRESH) unlink(list.files(OUT, full.names = TRUE))

PAUSE_S      <- 3     # seconds between requests (be nice to a free API)
MAX_REQUESTS <- 120   # hard cap for the whole run, retries included
MIN_DURATION <- 600   # drop games shorter than 10 min (remakes / early abandons)
BUCKET_PRIOR <- 500   # shrinkage strength per duration bucket (see step 2)

# Duration buckets. In SQL we compute  duration / 300  (integer division:
# whole 5-minute blocks), then clamp it into 3..10 with GREATEST/LEAST:
#   3 = under 20 min (10-20 after MIN_DURATION), 4 = 20-25, 5 = 25-30, ...,
#   9 = 45-50, 10 = 50 min or longer.
BUCKETS <- data.frame(
  bucket = 3:10,
  label  = c("<20", "20-25", "25-30", "30-35", "35-40", "40-45", "45-50", "50+"),
  from_min = c(10, 20, 25, 30, 35, 40, 45, 50),
  to_min   = c(20, 25, 30, 35, 40, 45, 50, NA)
)

# =============================================================================
# STEP 1 — FETCH
# =============================================================================

# Count every request we send so we never pass MAX_REQUESTS.
n_requests <- 0

# Run one SQL query on the explorer. Returns the rows (a data frame) or NULL.
# The explorer answers timeouts with HTTP 400 + {"err": "...timeout"}; R's
# fromJSON() then throws an error, which tryCatch() turns into a message.
run_explorer <- function(sql, tries = 5) {
  for (i in seq_len(tries)) {
    if (n_requests >= MAX_REQUESTS) { message("   request cap reached"); return(NULL) }
    n_requests <<- n_requests + 1          # <<- updates the counter outside
    url <- paste0(OPENDOTA_API, "/explorer?sql=", URLencode(sql, reserved = TRUE))
    res <- tryCatch(jsonlite::fromJSON(url), error = function(e) list(err = conditionMessage(e)))
    if (is.null(res$err) || identical(res$err, "") || length(res$rows)) return(res$rows)
    message("   timeout/error (", i, "/", tries, "): ", substr(res$err, 1, 60))
    Sys.sleep(10 * i)  # growing pause: 10s, 20s, 30s...
  }
  NULL
}

# The newest match id tells us where "the last week" starts.
n_requests <- n_requests + 1
latest <- max(od_get("publicMatches")$match_id)
from   <- latest - WINDOW
message("Window: match_id > ", format(from, scientific = FALSE), " (", WINDOW, " ids)")

# ---- Per-hero query ---------------------------------------------------------
# In words: "take every Ancient–Divine match in the window that contains hero H
# and lasted at least 10 minutes; put it in a 5-minute duration bucket; count
# games and how many of them H's team won".
#   - avg_rank_tier 60-79 = Ancient I .. Divine V (lobby average).
#   - (H = ANY(radiant_team)) = radiant_win  is TRUE exactly when H's side won:
#     H on Radiant and Radiant won, or H on Dire and Radiant lost.
#   - duration is in seconds.
curve_sql <- function(h) sprintf(paste(
  "SELECT LEAST(GREATEST(duration / 300, 3), 10) AS bucket,",
  "count(*) AS games,",
  "sum(CASE WHEN (%1$d = ANY(radiant_team)) = radiant_win THEN 1 ELSE 0 END) AS wins",
  "FROM public_matches WHERE match_id > %2$.0f",
  "AND avg_rank_tier >= 60 AND avg_rank_tier < 80",
  "AND duration >= %3$d",
  "AND (%1$d = ANY(radiant_team) OR %1$d = ANY(dire_team))",
  "GROUP BY 1 ORDER BY 1"), h, from, MIN_DURATION)

# ---- Baseline query (whole bracket, no hero filter) -------------------------
# How many games end in each bucket, plus the time span of the window
# (start_time is a unix timestamp in seconds). Also counts the short games we
# drop, so the doc can say how much MIN_DURATION removes.
baseline_sql <- sprintf(paste(
  "SELECT LEAST(GREATEST(duration / 300, 1), 10) AS bucket, count(*) AS games,",
  "sum(CASE WHEN radiant_win THEN 1 ELSE 0 END) AS radiant_wins,",
  "min(start_time) AS first_start, max(start_time) AS last_start",
  "FROM public_matches WHERE match_id > %.0f",
  "AND avg_rank_tier >= 60 AND avg_rank_tier < 80 GROUP BY 1 ORDER BY 1"), from)

base_file <- file.path(OUT, "_baseline.json")
if (!file.exists(base_file)) {
  message("-> baseline (all Ancient–Divine matches)")
  rows <- run_explorer(baseline_sql)
  if (!is.null(rows)) {
    write_json_pretty(list(window_from_match_id = from, latest_match_id = latest,
                           fetched_at = format(Sys.time(), "%Y-%m-%d %H:%M %Z"),
                           sql = baseline_sql, rows = rows), base_file)
  }
  Sys.sleep(PAUSE_S)
}

heroes <- unique(c(MY_MAINS, CARRY_POOL))
for (h in heroes) {
  file <- file.path(OUT, paste0(h, ".json"))
  if (file.exists(file)) next                     # resumable: skip finished heroes
  message("-> hero ", h)
  rows <- run_explorer(curve_sql(h))
  if (is.null(rows)) { message("   skipped (re-run later)"); next }
  write_json_pretty(list(hero_id = h, window_from_match_id = from,
                         min_duration_s = MIN_DURATION,
                         fetched_at = format(Sys.time(), "%Y-%m-%d %H:%M %Z"),
                         rows = rows), file)
  Sys.sleep(PAUSE_S)
}
message("Fetched: ", sum(file.exists(file.path(OUT, paste0(heroes, ".json")))),
        " / ", length(heroes), " heroes (", n_requests, " requests this run).")

# =============================================================================
# STEP 2 — BUILD data/processed/power_curves.json
# =============================================================================

# Hero names come from the local constants snapshot (no extra request).
hero_const <- jsonlite::fromJSON(path_data("raw", "opendota", "constants", "heroes.json"))
hero_name  <- function(id) hero_const[[as.character(id)]]$localized_name

# Pool games and wins of several buckets, return winrate minus `overall`,
# shrunk toward `overall` (so a thin bucket can't produce a big index).
pooled_index <- function(df, buckets, overall, prior = BUCKET_PRIOR) {
  sel <- df[df$bucket %in% buckets, ]
  shrink(sum(sel$wins), sum(sel$games), prior = prior, baseline = overall) - overall
}

# Curve label from the two indices (percentage points, pp):
#   swing = late index − early index  (>0: gets better the longer the game)
#   mid-game     : the 30-40 min window beats BOTH ends by >= 1.5 pp
#                  (checked first: a hump in the middle, e.g. Sven, Lifestealer)
#   late scaler  : swing >= +4 pp
#   early tempo  : swing <= -4 pp
#   flat         : everything else
# Thresholds were chosen after looking at the spread of swings in the pool
# (median ≈ ±3 pp); they are a reading aid, not a law of nature.
curve_label <- function(early, mid, late) {
  swing <- late - early
  if (mid - max(early, late) >= 0.015) return("mid-game")
  if (swing >= 0.04)  return("late scaler")
  if (swing <= -0.04) return("early tempo")
  "flat"
}

build_hero <- function(h) {
  file <- file.path(OUT, paste0(h, ".json"))
  if (!file.exists(file)) return(NULL)
  raw <- jsonlite::fromJSON(file)
  df  <- merge(BUCKETS, raw$rows, by = "bucket", all.x = TRUE)   # keep all 8 buckets
  df$games[is.na(df$games)] <- 0
  df$wins[is.na(df$wins)]   <- 0

  overall <- sum(df$wins) / sum(df$games)
  df$winrate  <- ifelse(df$games > 0, df$wins / df$games, NA)
  # Shrink each bucket toward the hero's OWN overall winrate: a bucket with
  # few games stays close to "normal for this hero" instead of jumping around.
  df$wr_shrunk <- shrink(df$wins, df$games, prior = BUCKET_PRIOR, baseline = overall)
  df$share     <- df$games / sum(df$games)       # how often games end here

  early <- pooled_index(df, 3:5,  overall)       # under 30 min
  mid   <- pooled_index(df, 6:7,  overall)       # 30-40 min
  late  <- pooled_index(df, 8:10, overall)       # over 40 min
  peak  <- df[which.max(df$wr_shrunk), ]

  list(
    hero_id     = h,
    name        = hero_name(h),
    is_main     = h %in% MY_MAINS,
    games       = sum(df$games),
    overall_wr  = round(overall, 4),
    early_index = round(early, 4),
    mid_index   = round(mid, 4),
    late_index  = round(late, 4),
    swing       = round(late - early, 4),
    peak_window = peak$label,
    peak_wr     = round(peak$wr_shrunk, 4),
    curve_type  = curve_label(early, mid, late),
    buckets     = data.frame(label = df$label, from_min = df$from_min, to_min = df$to_min,
                             games = df$games, wins = df$wins,
                             winrate = round(df$winrate, 4),
                             wr_shrunk = round(df$wr_shrunk, 4),
                             share = round(df$share, 4))
  )
}

curves <- Filter(Negate(is.null), lapply(heroes, build_hero))
names(curves) <- sapply(curves, function(x) as.character(x$hero_id))

# Window dates + bracket-wide duration mix from the baseline file.
base <- if (file.exists(base_file)) jsonlite::fromJSON(base_file) else NULL
# The raw files may come from an earlier run, so the window is read back from
# the baseline file (not from today's `from`).
if (!is.null(base)) { from <- base$window_from_match_id; latest <- base$latest_match_id }
fmt_day <- function(t) format(as.POSIXct(t, origin = "1970-01-01", tz = "UTC"), "%Y-%m-%d")
about <- list(
  title   = "Power curves: winrate by game duration, Ancient-Divine, carry pool",
  method  = paste(
    "OpenDota SQL explorer, table public_matches, avg_rank_tier 60-79, duration >= 10 min.",
    "One query per hero: games and wins per 5-minute duration bucket.",
    "wr_shrunk = (wins + prior*overall)/(games + prior), prior =", BUCKET_PRIOR,
    "games at the hero's own overall winrate.",
    "early_index = pooled shrunk winrate of games under 30 min minus overall; mid_index = 30-40 min;",
    "late_index = over 40 min; swing = late - early.",
    "curve_type: mid-game if the 30-40 window beats both ends by >= 1.5pp, else",
    "swing >= +4pp late scaler, <= -4pp early tempo, else flat."),
  caveat  = paste("Duration is an OUTCOME, not a cause: stomps end early, so heroes that win",
                  "stomps look 'early'. No position info: a mid TA/SF counts like a pos-1 one."),
  window_from_match_id = from,
  latest_match_id      = latest,
  window_dates = if (!is.null(base)) paste(fmt_day(min(base$rows$first_start)), "to",
                                           fmt_day(max(base$rows$last_start))) else NA,
  bracket_matches = if (!is.null(base)) sum(base$rows$games) else NA,
  bracket_duration_mix = if (!is.null(base)) base$rows else NA,
  generated_at = format(Sys.time(), "%Y-%m-%d %H:%M %Z"),
  sources = c("S11 OpenDota SQL explorer public_matches (https://api.opendota.com/api/explorer)",
              "S4 OpenDota constants/heroes (local snapshot)"),
  script  = "scripts/05_fetch_power_curves.R"
)

write_json_pretty(c(list(`_about` = about), curves), PROCESSED)
message("Wrote ", PROCESSED, " (", length(curves), " heroes)")

# Quick look in the console: sorted by swing.
tab <- do.call(rbind, lapply(curves, function(x) data.frame(
  name = x$name, games = x$games, wr = x$overall_wr, early = x$early_index,
  mid = x$mid_index, late = x$late_index, swing = x$swing, peak = x$peak_window, type = x$curve_type)))
print(tab[order(tab$swing), ], row.names = FALSE)

# =============================================================================
# STEP 3 — CHART docs/img/power_curves_mains.png (8 mains)
# =============================================================================
if (requireNamespace("ggplot2", quietly = TRUE)) {
  library(ggplot2)

  # One long data frame: one row per (main, bucket).
  mains <- curves[as.character(MY_MAINS)]
  mains <- Filter(Negate(is.null), mains)
  plot_df <- do.call(rbind, lapply(mains, function(x)
    data.frame(hero = x$name, label = x$buckets$label,
               x = seq_along(x$buckets$label), wr = x$buckets$wr_shrunk * 100)))
  # Keep the legend in MY_MAINS order (factor levels = drawing order).
  plot_df$hero <- factor(plot_df$hero, levels = sapply(mains, `[[`, "name"))

  PALETTE <- c("#8fd0f0", "#b4a7f5", "#5ed6b0", "#f0788a",
               "#8ea6ff", "#c7d3e0", "#4fb8c9", "#d59ee0")

  p <- ggplot(plot_df, aes(x = x, y = wr, colour = hero)) +
    geom_hline(yintercept = 50, colour = "#5a6878", linetype = "dashed") +
    geom_line(linewidth = 1.1) +
    geom_point(size = 2.2) +
    scale_x_continuous(breaks = seq_along(BUCKETS$label),
                       labels = paste(BUCKETS$label, "min")) +
    scale_colour_manual(values = PALETTE, name = NULL) +
    labs(title = "When do your carries win? Winrate by game length",
         subtitle = paste0("Ancient-Divine, ", about$window_dates, ", shrunk winrate (",
                           BUCKET_PRIOR, "-game prior toward each hero's own average)"),
         x = "Game duration", y = "Winrate (%)",
         caption = "Source: OpenDota SQL explorer, public_matches. Duration is an outcome: stomps end early.") +
    theme_minimal(base_size = 16) +
    theme(
      plot.background  = element_rect(fill = "#0b0e13", colour = NA),
      panel.background = element_rect(fill = "#0b0e13", colour = NA),
      panel.grid.major = element_line(colour = "#232c38"),
      panel.grid.minor = element_blank(),
      text             = element_text(colour = "#e6ebf2"),
      axis.text        = element_text(colour = "#e6ebf2"),
      plot.subtitle    = element_text(colour = "#9aa7b8"),
      plot.caption     = element_text(colour = "#9aa7b8", size = 9),
      legend.position  = "right",
      legend.text      = element_text(colour = "#e6ebf2")
    )

  dir.create(dirname(CHART), recursive = TRUE, showWarnings = FALSE)
  # 14 x 8 inches at 100 dpi = 1400 x 800 px
  ggsave(CHART, p, width = 14, height = 8, dpi = 100, bg = "#0b0e13")
  message("Wrote ", CHART)
} else {
  message("ggplot2 not installed: chart skipped.")
}
