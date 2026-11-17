# =============================================================================
# data.R — load the OpenDota snapshot + curated notes, and small "lookup"
# helpers the pages use (hero portrait url, item icon url, hero builds...).
#
# Everything is read ONCE when the app starts (see app.R) and kept in a list
# called `DB`. Reading files is slow-ish; doing it per click would be wasteful.
# =============================================================================

read_json <- function(..., simplify = TRUE) {
  jsonlite::fromJSON(path_data(...), simplifyVector = simplify)
}

load_db <- function() {
  raw <- function(...) read_json("raw", "opendota", ...)

  hero_stats <- raw("hero_stats.json")
  items      <- raw("constants", "items.json", simplify = FALSE)   # named list
  item_ids   <- raw("constants", "item_ids.json", simplify = FALSE) # "1" -> "blink"

  list(
    meta       = raw("meta.json"),
    hero_stats = hero_stats,
    items      = items,
    item_ids   = unlist(item_ids),
    curated    = read_json("curated", "heroes.json", simplify = FALSE),
    item_notes = read_json("curated", "item_notes.json", simplify = FALSE),
    # Precompute a small hero lookup table: id, name, portrait, icon.
    heroes = data.frame(
      id   = hero_stats$id,
      name = hero_stats$localized_name,
      key  = sub("npc_dota_hero_", "", hero_stats$name),
      img  = cdn_url(hero_stats$img),
      icon = cdn_url(hero_stats$icon),
      attr = hero_stats$primary_attr
    )
  )
}

# --- Lookups -----------------------------------------------------------------

hero_name <- function(db, id) db$heroes$name[match(id, db$heroes$id)]
hero_img  <- function(db, id) db$heroes$img[match(id, db$heroes$id)]

# Item key ("bfury") -> icon url. Unknown keys get NA (handled by the UI).
item_img <- function(db, key) {
  vapply(key, function(k) {
    it <- db$items[[k]]
    if (is.null(it) || is.null(it$img)) NA_character_ else cdn_url(it$img)
  }, character(1), USE.NAMES = FALSE)
}

item_name <- function(db, key) {
  vapply(key, function(k) db$items[[k]]$dname %||% k, character(1), USE.NAMES = FALSE)
}

item_cost <- function(db, key) {
  vapply(key, function(k) as.numeric(db$items[[k]]$cost %||% NA), numeric(1), USE.NAMES = FALSE)
}

# --- Per-hero snapshot files -------------------------------------------------

hero_file <- function(id, file) path_data("raw", "opendota", "heroes", id, file)

# Most bought items per phase -> one tidy data frame:
#   phase | item | count | share (count / most bought item in that phase)
hero_item_popularity <- function(db, id, top = 8) {
  f <- hero_file(id, "items.json")
  if (!file.exists(f)) return(NULL)
  pop <- jsonlite::fromJSON(f, simplifyVector = FALSE)

  phases <- c(start_game_items = "Start", early_game_items = "Early",
              mid_game_items = "Core", late_game_items = "Late")
  # Consumables & wards say nothing about the build after minute 0.
  noise <- c("tpscroll", "ward_observer", "ward_sentry", "smoke_of_deceit",
             "dust", "clarity", "flask", "enchanted_mango", "blood_grenade")

  out <- lapply(names(phases), function(p) {
    counts <- unlist(pop[[p]])
    if (length(counts) == 0) return(NULL)
    df <- data.frame(phase = phases[[p]],
                     item  = unname(db$item_ids[names(counts)]),
                     count = as.numeric(counts))
    if (p != "start_game_items") df <- df[!df$item %in% noise, ]
    df <- df[order(-df$count), ][seq_len(min(top, nrow(df))), ]
    df$share <- df$count / max(df$count)
    df
  })
  out <- do.call(rbind, out)
  out$phase <- factor(out$phase, levels = unname(phases))
  out
}

hero_matchups <- function(id) {
  f <- hero_file(id, "matchups.json")
  if (!file.exists(f)) return(NULL)
  jsonlite::fromJSON(f)
}

# Benchmarks -> named list of data frames (gold_per_min, xp_per_min, ...)
hero_benchmarks <- function(id) {
  f <- hero_file(id, "benchmarks.json")
  if (!file.exists(f)) return(NULL)
  jsonlite::fromJSON(f)$result
}

# Curated notes for one of the mains (NULL if the hero isn't curated).
curated_hero <- function(db, id) {
  for (h in db$curated$heroes) if (h$id == id) return(h)
  NULL
}

# `%||%` = "use the right side if the left side is NULL". (Built into R >= 4.4,
# defined here so the code also runs on R 4.3.)
if (!exists("%||%")) `%||%` <- function(a, b) if (is.null(a)) b else a
