# =============================================================================
# config.R — one place for every "setting" in the project.
#
# Shiny automatically sources every file inside app/R/ before running app.R,
# so these objects are available everywhere in the app. The scripts in
# scripts/ load this same file with source("app/R/config.R").
# =============================================================================

# --- Where is the repo root? -------------------------------------------------
# Scripts run from the repo root, the Shiny app runs from inside app/.
# We detect which one we are in by checking for the data/ folder.
REPO_ROOT <- if (dir.exists("data")) "." else ".."

# Small helper so we never hard-code "../data/..." strings around the code.
# Example: path_data("curated", "heroes.json")
path_data <- function(...) file.path(REPO_ROOT, "data", ...)

# --- OpenDota ----------------------------------------------------------------
# Free public API, no key needed (limit: 60 calls/min, 2000/day).
OPENDOTA_API <- "https://api.opendota.com/api"

# Images (hero portraits, item icons) are served from Valve's CDN.
# OpenDota gives us paths like "/apps/dota2/images/.../bfury.png",
# we glue this prefix in front to get a full URL.
STEAM_CDN <- "https://cdn.cloudflare.steamstatic.com"

# --- Rank brackets -----------------------------------------------------------
# OpenDota splits hero stats into 8 brackets: columns "1_pick", "1_win", ...
# Ancient (6) + Divine (7) is the default bracket for this project.
# Bracket 8 (Immortal) exists in the API but currently returns 0 games for
# every hero, so it is left out (it would show up as fake 50% winrates).
BRACKETS <- c(
  "Herald" = 1, "Guardian" = 2, "Crusader" = 3, "Archon" = 4,
  "Legend" = 5, "Ancient" = 6, "Divine" = 7
)
DEFAULT_BRACKETS <- c(6, 7)

# --- The player's hero pool ("mains") ----------------------------------------
# Named vector: display name = OpenDota hero id.
MY_MAINS <- c(
  "Anti-Mage"        = 1,
  "Morphling"        = 10,
  "Phantom Lancer"   = 12,
  "Wraith King"      = 42,
  "Templar Assassin" = 46,
  "Shadow Fiend"     = 11,
  "Arc Warden"       = 113,
  "Phantom Assassin" = 44
)

# --- Real position-1 carries -------------------------------------------------
# OpenDota tags ~70 heroes with the "Carry" role (incl. mids and offlaners like
# Outworld Devourer or Spirit Breaker). For a *carry* meta board we want heroes
# that are actually farmed as pos 1 in pubs, so we keep a hand-made list.
CARRY_POOL <- c(
  1, 10, 12, 42, 46, 11, 113, 44,            # mains
  8,  67, 18, 54, 95, 81, 48, 70, 93, 89,    # Jugg, Spectre, Sven, LS, Troll, CK, Luna, Ursa, Slark, Naga
  94, 41, 72, 63, 109, 73, 138, 6, 77, 4,    # Medusa, Void, Gyro, Weaver, TB, Alch, Muerta, Drow, Lycan, BS
  114, 145, 49, 15                           # MK, Kez, Dragon Knight, Razor (Meepo left out: mid hero)
)

# How many heroes the carry meta board shows (the brief asked for exactly 15).
META_BOARD_SIZE <- 15

# Shrinkage strength used to stabilise win rates of rarely-picked heroes
# (explained in app/R/scoring.R). "Pretend every hero starts with this many
# extra games at exactly 50%".
PRIOR_GAMES <- 3000
