# =============================================================================
# 02_build_knowledge.R — turn data into compact files an LLM (or you) can read.
#
# Run from the repo root (after 01_fetch_opendota.R):
#     Rscript scripts/02_build_knowledge.R
#
# Inputs : data/raw/opendota/*  (live snapshot)  +  data/curated/*  (notes)
# Outputs:
#   data/processed/carry_meta.json        15-hero carry board (bracket stats)
#   data/processed/items_reference.json   slim stats for every curated item
#   knowledge/heroes/<hero>.md            one page per main: notes + live data
#   knowledge/meta_snapshot.md            the carry board as a markdown table
#
# Why generate markdown instead of writing it by hand? The curated JSON is the
# single source of truth. Re-running this script after a patch refreshes the
# numbers in every note without touching the hand-written reasoning.
# =============================================================================

suppressPackageStartupMessages(library(dplyr))
source("app/R/config.R")
source("app/R/opendota.R")
source("app/R/data.R")
source("app/R/scoring.R")

db    <- load_db()
stats <- bracket_stats(db$hero_stats, DEFAULT_BRACKETS)
board <- carry_meta_board(stats)
pct   <- function(x, d = 1) sprintf(paste0("%.", d, "f%%"), 100 * x)

# --- 1. carry_meta.json + meta_snapshot.md -----------------------------------
write_json_pretty(
  list(
    patch    = db$meta$patch,
    fetched  = db$meta$fetched_at,
    bracket  = "Ancient + Divine",
    method   = paste0("Winrate shrunk toward 50% with ", PRIOR_GAMES,
                      " prior games; pool = hand-picked position-1 heroes."),
    heroes   = board |> transmute(rank, tier, name, id, winrate = round(winrate, 4),
                                  wr_adj = round(wr_adj, 4), pickrate = round(pickrate, 4),
                                  games = picks, is_main)
  ),
  path_data("processed", "carry_meta.json")
)

meta_md <- c(
  paste0("# Carry meta snapshot — patch ", db$meta$patch, " (Ancient + Divine)"),
  "",
  paste0("_Generated ", db$meta$fetched_at, " from OpenDota by scripts/02_build_knowledge.R. ",
         "Do not edit by hand._"),
  "",
  "| # | Tier | Hero | Winrate | Adj. WR | Pick rate | Games | Main? |",
  "|---|------|------|---------|---------|-----------|-------|-------|",
  sprintf("| %d | %s | %s | %s | %s | %s | %s | %s |",
          board$rank, board$tier, board$name, pct(board$winrate, 2), pct(board$wr_adj, 2),
          pct(board$pickrate), format(board$picks, big.mark = ","), ifelse(board$is_main, "★", "")),
  "",
  "## Your mains in this bracket",
  "",
  {
    mains <- stats |> filter(id %in% MY_MAINS) |> arrange(desc(wr_adj))
    sprintf("- **%s** — %s WR (adj %s), picked in %s of games, tier %s",
            mains$name, pct(mains$winrate, 2), pct(mains$wr_adj, 2),
            pct(mains$pickrate), assign_tier(mains$wr_adj))
  }
)
writeLines(meta_md, file.path(REPO_ROOT, "knowledge", "meta_snapshot.md"))

# --- 2. items_reference.json --------------------------------------------------
# Pull stats for every curated item + every item mentioned in hero builds,
# straight from the live constants (so numbers stay correct after a patch).
build_keys <- unlist(lapply(db$curated$heroes, function(h) {
  c(vapply(h$starting, `[[`, "", "item"), vapply(h$laning, `[[`, "", "item"),
    vapply(h$core, `[[`, "", "item"),     vapply(h$situational, `[[`, "", "item"))
}))
note_keys <- vapply(db$item_notes$items, `[[`, "", "key")
all_keys  <- sort(unique(c(note_keys, build_keys)))

items_ref <- lapply(all_keys, function(k) {
  it <- db$items[[k]]
  if (is.null(it)) return(NULL)
  note <- Filter(function(n) n$key == k, db$item_notes$items)
  list(
    key        = k,
    name       = it$dname,
    cost       = it$cost,
    # Only attributes with a display string are real stats ("+25 Agility");
    # skip zero values like Skadi's leftover "+ 0 Health".
    stats      = unname(unlist(lapply(it$attrib, function(a)
                   if (!is.null(a$display) && !identical(as.character(a$value), "0"))
                     sub("{value}", a$value, a$display, fixed = TRUE)))),
    actives    = unname(unlist(lapply(it$abilities, function(a) paste0(a$title, ": ", a$description)))),
    components = unlist(it$components),
    category   = if (length(note)) note[[1]]$cat else NULL,
    why        = if (length(note)) note[[1]]$why else NULL,
    when       = if (length(note)) note[[1]]$when else NULL,
    icon       = cdn_url(it$img)
  )
})
items_ref <- Filter(Negate(is.null), items_ref)
write_json_pretty(list(patch = db$meta$patch, items = items_ref),
                  path_data("processed", "items_reference.json"))

# --- 3. knowledge/heroes/<hero>.md -------------------------------------------
item_list <- function(x, field = "why") {
  vapply(x, function(e) sprintf("- **%s** — %s", item_name(db, e$item), e[[field]]), "")
}

for (h in db$curated$heroes) {
  s  <- stats |> filter(id == h$id)
  raw_mu <- hero_matchups(h$id)
  src <- attr(raw_mu, "source")              # "bracket" (Ancient–Divine) or "generic"
  mu <- matchup_advantages(raw_mu) |>
    filter(games >= if (identical(src, "bracket")) 300 else 30) |>
    mutate(name = hero_name(db, hero_id))
  worst <- mu |> arrange(advantage) |> slice_head(n = 6)
  best  <- mu |> arrange(desc(advantage)) |> slice_head(n = 6)
  pop   <- hero_item_popularity(db, h$id, top = 6)
  live  <- if (is.null(pop)) "" else vapply(levels(pop$phase), function(ph)
    paste0("- ", ph, ": ", paste(item_name(db, pop$item[pop$phase == ph]), collapse = ", ")), "")

  md <- c(
    paste0("# ", h$name, " (", h$attack, ", ", toupper(h$attr), ", pos ",
           paste(h$positions, collapse = "/"), ")"),
    "",
    paste0("> ", h$identity),
    "",
    sprintf("**Patch %s, Ancient+Divine:** %s winrate (adjusted %s, tier %s) over %s games; picked in %s of matches.",
            db$meta$patch, pct(s$winrate, 2), pct(s$wr_adj, 2), assign_tier(s$wr_adj),
            format(s$picks, big.mark = ","), pct(s$pickrate)),
    "",
    paste0("**Win condition:** ", h$win_condition),
    "",
    "## Why it works", paste0("- ", unlist(h$why_it_works)), "",
    "## Power spikes", paste0("- ", unlist(h$power_spikes)), "",
    "## Skills", h$skill_priority, "",
    paste0("- **Aghanim's Scepter:** ", h$aghs$scepter),
    paste0("- **Aghanim's Shard:** ", h$aghs$shard),
    paste0("- **Verdict:** ", h$aghs$verdict), "",
    "## Starting items", item_list(h$starting), "",
    if (!is.null(h$starting_variants)) c("### Starting variants",
      vapply(h$starting_variants, function(v) sprintf("- *%s*: %s. %s", v$situation,
             paste(item_name(db, unlist(v$items)), collapse = ", "), v$note), ""), "") else NULL,
    "## Laning items", item_list(h$laning), "",
    "## Core build (Ancient–Divine target timings)",
    vapply(h$core, function(e) sprintf("- ~%d min **%s** — %s", e$target_min, item_name(db, e$item), e$why), ""), "",
    "## Situational", item_list(h$situational, "when"), "",
    "## Struggles vs", vapply(h$struggles_vs, function(e) sprintf("- **%s** — %s", e$name, e$why), ""), "",
    "## Thrives vs",   vapply(h$thrives_vs,   function(e) sprintf("- **%s** — %s", e$name, e$why), ""), "",
    paste0("## Data: hardest matchups (", if (identical(src, "bracket"))
      "Ancient–Divine, last ~week, OpenDota explorer" else "OpenDota generic sample", ", shrunk)"),
    sprintf("- %s (%+.1f pp, %d games)", worst$name, 100 * worst$advantage, worst$games), "",
    "## Data: best matchups",
    sprintf("- %s (%+.1f pp, %d games)", best$name, 100 * best$advantage, best$games), "",
    "## Live build snapshot (most purchased, high MMR)", live, "",
    "## Tips",
    paste0("- Lane: ",    unlist(h$tips$laning)),
    paste0("- Mid: ",     unlist(h$tips$midgame)),
    paste0("- Late: ",    unlist(h$tips$lategame)), "",
    "## Common mistakes", paste0("- ", unlist(h$mistakes))
  )
  writeLines(md, file.path(REPO_ROOT, "knowledge", "heroes", paste0(h$key, ".md")))
  message("wrote knowledge/heroes/", h$key, ".md")
}

message("Knowledge pack rebuilt for patch ", db$meta$patch)
