# =============================================================================
# 04_fetch_bracket_matchups.R — Ancient–Divine matchups from the OpenDota
# SQL explorer (much better than the generic /heroes/{id}/matchups sample).
#
# Run from the repo root:   Rscript scripts/04_fetch_bracket_matchups.R [window]
#   window = how many recent match ids to scan (default 10e6 ≈ 1 week ≈ 1.2M
#   Ancient+Divine games). Use a smaller window (e.g. 3e6) if queries time out.
#
# Why: research 04 found the per-hero /matchups snapshot correlates only
# -0.09..0.22 with real Ancient–Divine results (it is a small high-skill
# sample), so the Draft Helper uses this bracket data whenever it exists.
#
# Output: data/raw/opendota/bracket_matchups/<hero_id>.json
#   { hero_id, window_from_match_id, fetched_at, rows: [{hero_id, games_played, wins}] }
#   rows = one per OPPONENT: games vs that hero and how many of them OUR hero won.
#
# The explorer has a ~15 s statement timeout and is sometimes overloaded, so
# each hero is retried with growing pauses and finished heroes are skipped
# (just re-run the script later to fill the gaps).
# =============================================================================

source("app/R/config.R")
source("app/R/opendota.R")

args   <- commandArgs(trailingOnly = TRUE)
WINDOW <- if (length(args)) as.numeric(args[1]) else 10e6
OUT    <- path_data("raw", "opendota", "bracket_matchups")
dir.create(OUT, recursive = TRUE, showWarnings = FALSE)

# The newest match id tells us where "the last week" starts.
latest <- max(od_get("publicMatches")$match_id)
from   <- latest - WINDOW

# One query per hero. In words: "take every Ancient–Divine match in the window
# that contains hero H; for each such match list the 5 enemy heroes (unnest);
# count games and wins per enemy". avg_rank_tier 60-79 = Ancient I .. Divine V.
matchup_sql <- function(h) sprintf(paste(
  "SELECT opp AS hero_id, count(*) AS games_played,",
  "sum(CASE WHEN won THEN 1 ELSE 0 END) AS wins FROM (",
  "SELECT unnest(CASE WHEN %1$d = ANY(radiant_team) THEN dire_team ELSE radiant_team END) AS opp,",
  "(%1$d = ANY(radiant_team)) = radiant_win AS won",
  "FROM public_matches WHERE match_id > %2$.0f",
  "AND avg_rank_tier >= 60 AND avg_rank_tier < 80",
  "AND (%1$d = ANY(radiant_team) OR %1$d = ANY(dire_team))) t GROUP BY opp"), h, from)

run_explorer <- function(sql, tries = 5) {
  for (i in seq_len(tries)) {
    url <- paste0(OPENDOTA_API, "/explorer?sql=", URLencode(sql, reserved = TRUE))
    res <- tryCatch(jsonlite::fromJSON(url), error = function(e) list(err = conditionMessage(e)))
    if (is.null(res$err) || identical(res$err, "") || length(res$rows)) return(res$rows)
    message("   timeout/error (", i, "/", tries, "): ", substr(res$err, 1, 60))
    Sys.sleep(10 * i)  # 10s, 20s, 30s...
  }
  NULL
}

heroes <- unique(c(MY_MAINS, CARRY_POOL))
for (h in heroes) {
  file <- file.path(OUT, paste0(h, ".json"))
  if (file.exists(file)) next
  message("-> hero ", h)
  rows <- run_explorer(matchup_sql(h))
  if (is.null(rows)) { message("   skipped (re-run later)"); next }
  write_json_pretty(list(hero_id = h, window_from_match_id = from,
                         fetched_at = format(Sys.time(), "%Y-%m-%d %H:%M %Z"), rows = rows), file)
  Sys.sleep(2)
}
message("Done: ", length(list.files(OUT)), " / ", length(heroes), " heroes have bracket matchups.")
