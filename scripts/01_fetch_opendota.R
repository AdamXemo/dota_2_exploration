# =============================================================================
# 01_fetch_opendota.R — download a fresh "patch snapshot" from OpenDota.
#
# Run from the repo root:   Rscript scripts/01_fetch_opendota.R
#
# What it saves (all under data/raw/opendota/):
#   hero_stats.json            winrate / pickrate per rank bracket, base stats
#   constants/*.json           item + hero + ability dictionaries, patch list
#   heroes/<id>/items.json     most-bought items per game phase (high MMR games)
#   heroes/<id>/matchups.json  win/loss of that hero vs every other hero
#   heroes/<id>/benchmarks.json  GPM/XPM/last-hit percentiles
#   meta.json                  when the snapshot was taken + current patch
#
# Takes a few minutes because we sleep between calls to respect the rate limit.
#
# The script is RESUMABLE: per-hero files that already exist are skipped, so
# if OpenDota rate-limits you halfway, just run it again later.
# To force a full refresh:   Rscript scripts/01_fetch_opendota.R --fresh
# =============================================================================

source("app/R/config.R")
source("app/R/opendota.R")

RAW   <- path_data("raw", "opendota")
FRESH <- "--fresh" %in% commandArgs(trailingOnly = TRUE)

# Helper: fetch RAW json (no simplification) and save it as-is.
# We keep the raw shape so the snapshot mirrors the API exactly.
# skip_existing = TRUE lets the per-hero loop resume after an interruption.
save_endpoint <- function(endpoint, file, query = list(), skip_existing = FALSE) {
  target <- file.path(RAW, file)
  if (skip_existing && !FRESH && file.exists(target)) return(invisible(NULL))

  message("-> ", endpoint)
  x <- od_get(endpoint, query = query, simplify = FALSE)
  write_json_pretty(x, target)
  Sys.sleep(1.5)  # stay well under the free-tier rate limit
  invisible(x)
}

# --- 1. Global data ----------------------------------------------------------
save_endpoint("heroStats",                 "hero_stats.json")
save_endpoint("constants/items",           "constants/items.json")
save_endpoint("constants/item_ids",        "constants/item_ids.json")
save_endpoint("constants/heroes",          "constants/heroes.json")
save_endpoint("constants/hero_abilities",  "constants/hero_abilities.json")
save_endpoint("constants/abilities",       "constants/abilities.json")
patches <- save_endpoint("constants/patch", "constants/patch.json")

# --- 2. Per-hero data for every hero in the carry pool -----------------------
# unique() because mains are also inside CARRY_POOL.
for (hero_id in unique(c(MY_MAINS, CARRY_POOL))) {
  dir <- file.path("heroes", hero_id)
  save_endpoint(paste0("heroes/", hero_id, "/itemPopularity"), file.path(dir, "items.json"),    skip_existing = TRUE)
  save_endpoint(paste0("heroes/", hero_id, "/matchups"),       file.path(dir, "matchups.json"), skip_existing = TRUE)
  save_endpoint("benchmarks", file.path(dir, "benchmarks.json"), query = list(hero_id = hero_id), skip_existing = TRUE)
}

# --- 3. Snapshot metadata ----------------------------------------------------
latest_patch <- patches[[length(patches)]]
write_json_pretty(
  list(
    fetched_at = format(Sys.time(), "%Y-%m-%d %H:%M %Z"),
    patch      = latest_patch$name,
    patch_date = substr(latest_patch$date, 1, 10)
  ),
  file.path(RAW, "meta.json")
)

message("Done. Snapshot for patch ", latest_patch$name, " saved in ", RAW)
