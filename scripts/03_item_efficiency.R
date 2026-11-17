# =============================================================================
# 03_item_efficiency.R — how much "free value" does each item give?
#
# Run from the repo root:   Rscript scripts/03_item_efficiency.R
# Output: data/processed/item_efficiency.json (+ a printed top list)
#
# Method (the classic "gold efficiency" idea):
#   1. Price each stat by its CHEAPEST basic item (All Attributes = Str+Agi+Int).
#        Gauntlets: 140 gold for +3 Strength  ->  1 Strength = 46.7 gold
#   2. Value an item = sum of (its stats x price of each stat).
#   3. Efficiency = value / cost.
#        > 100%  the stats alone are worth more than you paid
#        < 100%  you pay a "premium" for the active/passive (Manta's
#                illusions, BKB's immunity, ...). That premium is printed too.
#
# Limits: primary-attribute damage, % bonuses and actives are NOT valued, so
# this measures raw stats only. It's a lens, not a ranking of "best items".
# =============================================================================

suppressPackageStartupMessages(library(dplyr))
source("app/R/config.R")
source("app/R/opendota.R")

items <- jsonlite::fromJSON(path_data("raw", "opendota", "constants", "items.json"),
                            simplifyVector = FALSE)

# --- 1. Map the many attribute key spellings to one stat name ----------------
# OpenDota uses e.g. "bonus_strength", "bonus_str" and "strength" for the same
# thing, so we translate every key into a short canonical name.
stat_alias <- c(
  bonus_strength = "str", bonus_str = "str", strength = "str",
  bonus_stat = "str",   # Power Treads' switchable +10: priced like one attribute
  bonus_agility = "agi", bonus_agi = "agi", agility = "agi",
  bonus_intellect = "int", bonus_int = "int", intellect = "int",
  bonus_all_stats = "all", all_stats = "all", bonus_stats = "all",
  bonus_damage = "damage", damage = "damage",
  bonus_armor = "armor", armor = "armor",
  bonus_attack_speed = "attack_speed", attack_speed = "attack_speed",
  bonus_health = "hp", bonus_hp = "hp",
  bonus_mana = "mana",
  bonus_health_regen = "hp_regen", bonus_regen = "hp_regen", hp_regen = "hp_regen",
  health_regen = "hp_regen", bonus_hp_regen = "hp_regen",
  bonus_mana_regen = "mana_regen", mana_regen = "mana_regen",
  bonus_movement_speed = "move_speed", movement_speed = "move_speed",
  bonus_movement = "move_speed", movespeed = "move_speed",
  bonus_movement_speed_melee = "move_speed",   # treads list melee/ranged separately
  bonus_evasion = "evasion", evasion = "evasion",
  tooltip_resist = "magic_resist", magic_resist = "magic_resist",
  bonus_spell_resist = "magic_resist", bonus_magical_armor = "magic_resist",
  lifesteal_percent = "lifesteal", attack_lifesteal = "lifesteal"
)

# Turn one item into a small data frame: stat | amount.
item_stats <- function(it) {
  rows <- lapply(it$attrib, function(a) {
    if (is.null(a$display)) return(NULL)                    # hidden helper values
    if (startsWith(trimws(a$display), "-")) return(NULL)    # negative stats (e.g. MoM armor)
    stat <- stat_alias[a$key]
    if (is.na(stat)) return(NULL)                           # stat we don't price
    # Some values look like "25 / 35" (upgrade levels): take the first number.
    amount <- as.numeric(strsplit(as.character(a$value), " ")[[1]][1])
    if (is.na(amount) || amount == 0) return(NULL)        # "+0 Health Regen" placeholders
    data.frame(stat = unname(stat), amount = amount)
  })
  do.call(rbind, rows)
}

# --- 2. Price every stat from its cheapest basic source ----------------------
price_sources <- c(
  str = "gauntlets", agi = "slippers", int = "mantle",
  damage = "blades_of_attack", armor = "ring_of_protection",
  attack_speed = "gloves", hp = "fluffy_hat", mana = "wizard_hat",
  hp_regen = "ring_of_regen", mana_regen = "sobi_mask", move_speed = "boots",
  evasion = "talisman_of_evasion", magic_resist = "shawl", lifesteal = "lifesteal"
)
stat_price <- sapply(names(price_sources), function(stat) {
  it <- items[[price_sources[[stat]]]]
  s  <- item_stats(it)
  it$cost / s$amount[s$stat == stat][1]
})

# "+1 All Attributes" = +1 Str +1 Agi +1 Int, so it is worth the three single
# prices added up. (Circlet sells it cheaper, 77.5g, but that's a starting-item
# bargain; using it would make every Ultimate Orb item look terrible.)
stat_price["all"] <- stat_price[["str"]] + stat_price[["agi"]] + stat_price[["int"]]

message("Gold per stat point:")
print(round(stat_price, 1))

# --- 3. Evaluate every completed item ---------------------------------------
# "Completed" = has components (built from a recipe), costs >= 1000, and is not
# a neutral item (those have a `tier`).
is_completed <- function(it) {
  length(it$components) > 0 && !is.null(it$cost) && it$cost >= 1000 && is.null(it$tier)
}

results <- lapply(names(items), function(key) {
  it <- items[[key]]
  if (!is_completed(it)) return(NULL)
  s <- item_stats(it)
  value <- if (is.null(s)) 0 else sum(s$amount * stat_price[s$stat])
  data.frame(
    key        = key,
    name       = it$dname,
    cost       = it$cost,
    stat_value = round(value),
    efficiency = round(value / it$cost, 3),
    premium    = round(it$cost - value),         # gold paid for actives/passives
    has_active = length(it$abilities) > 0,
    stats      = if (is.null(s)) "" else paste0("+", s$amount, " ", s$stat, collapse = ", ")
  )
})
eff <- do.call(rbind, results) |>
  distinct(name, .keep_all = TRUE) |>              # drop dupes like Dagon levels / Roshan versions
  arrange(desc(efficiency))

write_json_pretty(
  list(
    method      = "value = sum(stat x cheapest basic price); efficiency = value / cost",
    stat_prices = as.list(round(stat_price, 2)),
    items       = eff
  ),
  path_data("processed", "item_efficiency.json")
)

message("\nMost stat-efficient completed items:")
print(head(eff[, c("name", "cost", "stat_value", "efficiency", "stats")], 20), row.names = FALSE)
message("\nBiggest 'premium' for actives/passives:")
print(head(eff[order(-eff$premium), c("name", "cost", "stat_value", "premium")], 12), row.names = FALSE)
