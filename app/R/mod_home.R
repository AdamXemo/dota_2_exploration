# =============================================================================
# mod_home.R — page 00: the landing page.
#
# One screen that answers "what should I know about carrying this patch?":
#   1. intro + data labels (patch, bracket, sample size) + quick links
#   2. THE tier list of every position-1 carry (re-tiers per bracket)
#   3. your 8 mains as hero tiles
#   4. four insights from the research notes (docs/research/)
#   5. two small bar charts: item gold value and median GPM of your mains
#
# Everything comes from the local snapshot (data/), so the page is instant:
# no OpenDota API calls happen here.
# =============================================================================

# Bracket presets for the tier-list chips: label -> bracket numbers.
HOME_BRACKETS <- list(
  "Herald–Crusader" = 1:3,
  "Archon–Legend"   = 4:5,
  "Ancient–Divine"  = 6:7
)

# --- Data helpers (plain functions, easy to test in the console) -------------

# Carry-pool heroes with their tier for some brackets.
pool_tiers <- function(db, brackets = DEFAULT_BRACKETS) {
  bracket_stats(db$hero_stats, brackets) |>
    filter(id %in% CARRY_POOL) |>
    mutate(tier = assign_tier(wr_adj), is_main = id %in% MY_MAINS) |>
    arrange(desc(wr_adj))
}

# Median (50th percentile) GPM of a hero from the OpenDota benchmarks snapshot.
median_gpm <- function(id) {
  bm <- hero_benchmarks(id)
  if (is.null(bm)) return(NA_real_)
  g <- bm$gold_per_min
  g$value[which.min(abs(g$percentile - 0.5))]
}

# One row per main: winrate high/low MMR, MMR trend, pick rate, median GPM.
mains_summary <- function(db) {
  high <- bracket_stats(db$hero_stats, DEFAULT_BRACKETS)
  low  <- bracket_stats(db$hero_stats, 1:3)
  ids  <- unname(MY_MAINS)
  data.frame(
    id       = ids,
    name     = hero_name(db, ids),
    wr       = high$wr_adj[match(ids, high$id)],
    wr_low   = low$wr_adj[match(ids, low$id)],
    pickrate = high$pickrate[match(ids, high$id)],
    gpm      = vapply(ids, median_gpm, numeric(1))
  ) |>
    mutate(tier = assign_tier(wr), trend_pp = 100 * (wr - wr_low)) |>
    arrange(desc(wr))
}

# Item gold efficiency (scripts/03_item_efficiency.R), only carry items.
home_items <- function() {
  eff <- jsonlite::fromJSON(path_data("processed", "item_efficiency.json"))$items
  ref <- jsonlite::fromJSON(path_data("processed", "items_reference.json"), simplifyVector = FALSE)$items
  carry_keys <- vapply(ref, `[[`, "", "key")
  eff[eff$key %in% carry_keys, ]
}

# --- UI ----------------------------------------------------------------------

mod_home_ui <- function(id, db) {
  ns <- NS(id)
  n_matches <- round(sum(bracket_stats(db$hero_stats, DEFAULT_BRACKETS)$picks) / 10)

  # Quick links to every page (chips that switch the navbar tab).
  pages <- c("Carry Meta" = "meta", "Heroes" = "hero", "Item Codex" = "items",
             "Draft" = "draft", "My Stats" = "me", "Notes" = "notes")
  quick_links <- div(class = "cluster",
    lapply(seq_along(pages), function(i)
      goto_link(tab = pages[[i]], class = "chip",
                span(class = "count", sprintf("%02d", i)), names(pages)[i])))

  div(class = "home lab-container",
    # 1. Intro ---------------------------------------------------------------
    tags$section(class = "home-hero",
      div(class = "section-head",
        div(class = "eyebrow", span(class = "idx", "00"), "Position 1 · study tool"),
        h1(class = "section-title display", "Carry smarter in patch ",
           span(class = "frost-text", db$meta$patch)),
        p(class = "section-sub",
          "Which carries win in your bracket, what to buy and why, and how much farm is ",
          "“good”. Built on OpenDota data and the research notes in this repo.")),
      div(class = "cluster home-labels",
        span(class = "data-label", span(class = "k", "PATCH"), db$meta$patch),
        span(class = "data-label", span(class = "k", "BRACKET"), "Ancient–Divine"),
        span(class = "data-label", span(class = "k", "MATCHES"), format(n_matches, big.mark = ",")),
        span(class = "data-label", span(class = "k", "CARRIES"), length(CARRY_POOL)),
        span(class = "data-label", span(class = "k", "SNAPSHOT"), substr(db$meta$fetched_at, 1, 10))),
      quick_links),

    # 2. Tier list (the centerpiece) ------------------------------------------
    tags$section(class = "home-section",
      div(class = "section-head row-head",
        div(div(class = "eyebrow", span(class = "idx", "01"), "Carry tier list"),
            h2(class = "section-title", textOutput(ns("tier_title"), inline = TRUE)),
            p(class = "section-sub",
              "All ", length(CARRY_POOL), " position-1 heroes, ranked by adjusted winrate. ",
              "Hover a portrait for its winrate, click it for the hero page. ",
              span(class = "ice", "Ice ring"), " = your main.")),
        uiOutput(ns("bracket_chips"))),
      div(class = "home-tier-grid",
        uiOutput(ns("tierlist")),
        uiOutput(ns("tier_side")))),

    # 3. Your pool --------------------------------------------------------------
    tags$section(class = "home-section",
      div(class = "section-head",
        div(class = "eyebrow", span(class = "idx", "02"), "Your pool at a glance"),
        h2(class = "section-title", "Your 8 mains, Ancient–Divine"),
        p(class = "section-sub",
          "MMR trend = adjusted winrate in Ancient–Divine minus Herald–Crusader. ",
          "Median GPM = a typical public game on that hero (OpenDota benchmarks).")),
      uiOutput(ns("pool"))),

    # 4. Insights ---------------------------------------------------------------
    tags$section(class = "home-section",
      div(class = "section-head",
        div(class = "eyebrow", span(class = "idx", "03"), "What the data says"),
        h2(class = "section-title", "Six things worth knowing this patch")),
      uiOutput(ns("insights"))),

    # 5. Item value + farm ------------------------------------------------------
    tags$section(class = "home-section",
      div(class = "section-head",
        div(class = "eyebrow", span(class = "idx", "04"), "Gold"),
        h2(class = "section-title", "Where your gold goes")),
      uiOutput(ns("gold"))),

    p(class = "home-foot muted",
      "Tiers from adjusted winrate (shrunk toward 50% with ", format(PRIOR_GAMES, big.mark = ","),
      " prior games): S ≥ 52.5% · A ≥ 51% · B ≥ 49.5% · C ≥ 48% · D below. ",
      "Method and caveats: Notes → Research.")
  )
}

# --- Server ------------------------------------------------------------------

mod_home_server <- function(id, db) {
  moduleServer(id, function(input, output, session) {
    ns <- session$ns

    # Computed once per session (they never change while the app runs).
    mains <- mains_summary(db)
    items <- home_items()
    all_high <- pool_tiers(db, DEFAULT_BRACKETS)

    # Which bracket preset the tier list shows. The chips send its name.
    bracket <- reactive(input$bracket %||% "Ancient–Divine")
    tiers   <- reactive(pool_tiers(db, HOME_BRACKETS[[bracket()]]))

    output$tier_title <- renderText(paste0("Patch ", db$meta$patch, ", ", bracket()))

    output$bracket_chips <- renderUI({
      div(class = "cluster", role = "group", `aria-label` = "Rank bracket",
        lapply(names(HOME_BRACKETS), function(b)
          tags$button(type = "button", class = paste("chip", if (b == bracket()) "is-active"),
                      `aria-pressed` = tolower(b == bracket()),
                      onclick = sprintf("Shiny.setInputValue('%s', '%s', {priority: 'event'})",
                                        ns("bracket"), b),
                      b)))
    })

    output$tierlist <- renderUI(tier_list(tiers()))

    # Small stat cards next to the tier list.
    output$tier_side <- renderUI({
      t <- tiers()
      best <- t[1, ]
      worst <- t[nrow(t), ]
      my <- t[t$is_main, ]
      n_good <- sum(my$tier %in% c("S", "A"))
      div(class = "stack",
        stat_card("Strongest carry",
                  hero_link(best$id, class = "stat-hero", img(src = best$img, alt = ""), best$name),
                  tagList(span(class = "num good", pct(best$wr_adj, 1)), "adjusted winrate"),
                  accent = TRUE, badge = tier_badge(best$tier)),
        stat_card("Weakest carry",
                  hero_link(worst$id, class = "stat-hero", img(src = worst$img, alt = ""), worst$name),
                  tagList(span(class = "num bad", pct(worst$wr_adj, 1)), "adjusted winrate"),
                  badge = tier_badge(worst$tier)),
        stat_card("Your mains in S/A",
                  tagList(n_good, span(class = "unit", paste0("/ ", nrow(my)))),
                  paste(my$name[my$tier %in% c("S", "A")], collapse = " · ")),
        stat_card("Tier spread",
                  div(class = "tier-spread",
                      lapply(c("S", "A", "B", "C", "D"), function(x)
                        span(class = "ts", tier_badge(x), span(class = "num", sum(t$tier == x))))),
                  "heroes per tier"))
    })

    # Hero tiles for the 8 mains.
    output$pool <- renderUI({
      div(class = "grid home-pool",
        lapply(seq_len(nrow(mains)), function(i) {
          m <- mains[i, ]
          hero_tile(db, m$id, m$tier, list(
            "Winrate"    = span(class = if (m$wr >= 0.5) "good" else "bad", pct(m$wr, 1)),
            "Median GPM" = if (is.na(m$gpm)) "–" else format(m$gpm),
            "MMR trend"  = delta_chip(m$trend_pp),
            "Picked"     = pct(m$pickrate, 1)))
        }))
    })

    # Insights: the numbers are computed from the snapshot, the wording comes
    # from docs/research/*.md (01 carry meta, 03 item efficiency, 05 benchmarks).
    output$insights <- renderUI({
      wk  <- mains[mains$id == 42, ]
      sf  <- all_high[all_high$id == 11, ]
      sf_trend <- mains$trend_pp[mains$id == 11]
      fal <- items[items$key == "falcon_blade", ]
      bkb <- items[items$key == "black_king_bar", ]
      arc <- mains[mains$id == 113, ]

      div(class = "grid grid-2",
        insight_callout(
          "Wraith King wins on little gold", kind = "good", icon = "↑",
          sprintf("Median %s GPM, second-lowest of your 8 mains (only Shadow Fiend farms less), yet the best winrate in Ancient–Divine (%s). Reincarnation, lifesteal and the stun do the work items do for other carries.",
                  wk$gpm, pct(wk$wr, 1)),
          link = hero_link(42, "Wraith King page →")),
        insight_callout(
          "Shadow Fiend is the weakest carry this patch", kind = "bad", icon = "↓",
          sprintf("%s adjusted winrate, #%d of %d carries, and it drops %.1f pp from Herald to Divine. Bench him as pos 1.",
                  pct(sf$wr_adj, 1), which(all_high$id == 11), nrow(all_high), abs(sf_trend)),
          link = goto_link(tab = "notes", note = "01_carry_meta_7.41.md", "Research: carry meta →")),
        insight_callout(
          sprintf("Falcon Blade = %d%% gold value", round(100 * fal$efficiency)), icon = "g",
          sprintf("Its stats are worth %sg for a %sg price, so the item is cheaper than its parts. Power Treads and Mask of Madness come next.",
                  format(fal$stat_value, big.mark = ","), format(fal$cost, big.mark = ",")),
          link = goto_link(tab = "items", "Item Codex →")),
        insight_callout(
          sprintf("BKB is %d%% stats, %d%% immunity tax", round(100 * bkb$efficiency), 100 - round(100 * bkb$efficiency)),
          kind = "lilac", icon = "%",
          sprintf("You pay about %sg of its %sg for debuff immunity. Buy it for the effect when stuns decide fights, never for the stats.",
                  format(round(bkb$premium, -1), big.mark = ","), format(bkb$cost, big.mark = ",")),
          link = goto_link(tab = "notes", note = "03_item_efficiency.md", "Research: item efficiency →")),
        if (nrow(arc)) insight_callout(
          "Arc Warden rewards skill", icon = "↗",
          sprintf("His winrate goes up %.1f pp from Herald to Divine%s. Tempest Double pays off only when you control both heroes.",
                  arc$trend_pp,
                  if (arc$trend_pp == max(mains$trend_pp)) ", the biggest rise in your pool" else ""),
          link = hero_link(113, "Arc Warden page →")),
        insight_callout(
          "Learn next: Juggernaut", kind = "lilac", icon = "+",
          sprintf("%s winrate at %s pick rate. Blade Fury is built-in magic immunity and Healing Ward is sustain: the lowest learning cost from your pool.",
                  pct(all_high$wr_adj[all_high$id == 8], 1), pct(all_high$pickrate[all_high$id == 8], 1)),
          link = hero_link(8, "Juggernaut page →")))
    })

    # Item value + GPM bar meters.
    output$gold <- renderUI({
      scale_max <- 1.5   # bars run from 0% to 150% efficiency
      value_items <- head(items[items$efficiency > 1, ], 6)
      value_items <- value_items[order(-value_items$efficiency), ]
      tax_keys <- c("black_king_bar", "manta", "abyssal_blade", "assault", "swift_blink")
      tax_items <- items[match(tax_keys, items$key), ]
      eff_row <- function(r, kind) meter_row(
        r$name, r$efficiency / scale_max, paste0(round(100 * r$efficiency), "%"),
        kind = kind, extra_class = "par100",
        icon = img(class = "item-icon sm", src = item_img(db, r$key), alt = ""))

      g <- mains[order(mains$gpm), ]
      # Bars start at 400 GPM (not 0) so the differences between heroes are
      # visible; every main's median is well above 400.
      gpm_floor <- 400
      gpm_max <- max(g$gpm, na.rm = TRUE)

      div(class = "grid grid-2",
        bslib::card(
          card_title("Gold value of items", "stat value ÷ cost · line = 100%"),
          bslib::card_body(
            h6(class = "good", "Stats worth more than the price"),
            lapply(split(value_items, seq_len(nrow(value_items))), eff_row, kind = "good"),
            h6(class = "lilac home-h6", "You pay for the effect"),
            lapply(split(tax_items, seq_len(nrow(tax_items))), eff_row, kind = "lilac"),
            div(class = "callout-link", goto_link(tab = "items", "Full gold-efficiency chart →")))),
        bslib::card(
          card_title("How much farm your mains need", "median GPM, public games · bars start at 400 · green = best winrate"),
          bslib::card_body(
            lapply(seq_len(nrow(g)), function(i)
              meter_row(g$name[i], (g$gpm[i] - gpm_floor) / (gpm_max - gpm_floor), g$gpm[i],
                        # highlight the main with the best winrate (it is the 1st row of `mains`)
                        kind = if (g$id[i] == mains$id[1]) "good" else "",
                        icon = img(class = "hero-icon sm", src = hero_img(db, g$id[i]), alt = ""))),
            p(class = "muted small home-note",
              "Compare against the hero's own number, never across heroes: 600 GPM is above median on ",
              "Wraith King and below median on Anti-Mage."),
            div(class = "callout-link", goto_link(tab = "notes", note = "05_farm_benchmarks.md",
                                                   "Research: farm benchmarks →")))))
    })
  })
}
