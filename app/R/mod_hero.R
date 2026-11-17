# =============================================================================
# mod_hero.R — page II: one hero in depth.
#
# For the 8 mains we combine two sources:
#   - LIVE   : what high-MMR players actually buy (OpenDota item popularity)
#   - CURATED: why the hero works, timings, situational items (heroes.json)
# Any other carry-pool hero gets the live parts only.
# =============================================================================

mod_hero_ui <- function(id, db) {
  ns <- NS(id)
  pool_ids <- setdiff(CARRY_POOL, MY_MAINS)
  # A named list inside choices = grouped dropdown (optgroup) in selectize.
  choices <- list(
    "Your mains"  = setNames(MY_MAINS, names(MY_MAINS)),
    "Carry pool"  = setNames(pool_ids, hero_name(db, pool_ids))[order(hero_name(db, pool_ids))]
  )
  tagList(
    div(style = "max-width:360px",
        selectizeInput(ns("hero"), NULL, choices = choices, selected = MY_MAINS[["Wraith King"]])),
    uiOutput(ns("page"))
  )
}

mod_hero_server <- function(id, db) {
  moduleServer(id, function(input, output, session) {

    # Pre-compute bracket stats once (they don't depend on the selected hero).
    high <- bracket_stats(db$hero_stats, DEFAULT_BRACKETS)
    low  <- bracket_stats(db$hero_stats, 1:3)

    output$page <- renderUI({
      req(input$hero)
      hid <- as.integer(input$hero)
      h   <- curated_hero(db, hid)          # NULL for non-mains
      s   <- high[high$id == hid, ]
      s_low <- low[low$id == hid, ]

      tagList(
        hero_banner(db, hid, h, s, s_low),
        bslib::layout_columns(
          col_widths = c(7, 5),
          bslib::card(card_title("Live build", "most purchased in high-MMR games · % = vs top item of the phase"),
                      bslib::card_body(build_rail(db, hid))),
          if (!is.null(h)) bslib::card(card_title("Core build & timings", "Ancient–Divine targets"),
                                       bslib::card_body(core_steps(db, h)))
          else bslib::card(card_title("Curated notes"), bslib::card_body(
            p(class = "muted", "No curated notes yet: only your mains have them. Add this hero to data/curated/heroes.json.")))
        ),
        if (!is.null(h)) bslib::layout_columns(
          col_widths = c(6, 6),
          bslib::card(card_title("Why it works"), bslib::card_body(class = "lore",
            insight_callout("Win condition", h$win_condition, kind = "good", icon = "\u2713"),
            tags$ul(lapply(h$why_it_works, tags$li)),
            div(h6(class = "muted", "Power spikes"),
                div(class = "hero-spikes", lapply(h$power_spikes, function(x) span(class = "tag good", x)))))),
          bslib::card(card_title("Starting kit"), bslib::card_body(starting_block(db, h)))
        ),
        bslib::layout_columns(
          col_widths = if (is.null(h)) 12 else c(5, 4, 3),
          if (!is.null(h)) bslib::card(card_title("Situational items"), bslib::card_body(situational_block(db, h))),
          bslib::card(card_title("Matchups", "shrunk · pp vs the hero's average"),
                      bslib::card_body(matchup_block(db, hid))),
          if (!is.null(h)) bslib::card(card_title("Skills & Aghanim's"), bslib::card_body(class = "lore",
            p(h$skill_priority),
            p(strong("Scepter: "), h$aghs$scepter),
            p(strong("Shard: "), h$aghs$shard),
            insight_callout("Verdict", h$aghs$verdict, kind = "lilac", icon = "A")))
        ),
        if (!is.null(h)) bslib::layout_columns(
          col_widths = c(8, 4),
          bslib::card(card_title("Tips by phase"), bslib::card_body(class = "lore",
            bslib::layout_columns(col_widths = c(4, 4, 4),
              div(h5("Lane"),  tags$ul(lapply(h$tips$laning,   tags$li))),
              div(h5("Mid"),   tags$ul(lapply(h$tips$midgame,  tags$li))),
              div(h5("Late"),  tags$ul(lapply(h$tips$lategame, tags$li)))))),
          bslib::card(card_title("Common mistakes"), bslib::card_body(class = "lore",
            tags$ul(lapply(h$mistakes, function(x) tags$li(class = "bad", x)))))
        )
      )
    })
  })
}

# --- Page pieces (plain functions returning HTML) ----------------------------

hero_banner <- function(db, hid, h, s, s_low) {
  trend <- s$wr_adj - s_low$wr_adj
  div(class = "hero-banner",
      img(src = hero_img(db, hid), alt = hero_name(db, hid)),
      div(style = "flex:1",
          div(class = "title", hero_name(db, hid), " ", tier_badge(assign_tier(s$wr_adj))),
          div(class = "identity", if (!is.null(h)) h$identity else
              paste(db$hero_stats$roles[[which(db$hero_stats$id == hid)]], collapse = " · ")),
          if (!is.null(h)) div(class = "cluster", style = "margin-top:.6rem",
            span(class = paste("tag", tolower(h$attr)), span(class = "dot"), toupper(h$attr)),
            span(class = "tag", h$attack),
            span(class = "tag", paste("pos", paste(h$positions, collapse = "/"))),
            span(class = "tag lilac", paste("complexity", strrep("◆", h$complexity))),
            if (hid %in% MY_MAINS) span(class = "tag ice", "main"))),
      div(class = "hero-kpis",
        stat_card("Winrate", pct(s$wr_adj, 2), "Ancient–Divine, adjusted", accent = TRUE),
        stat_card("Pick rate", pct(s$pickrate, 1), paste(format(s$picks, big.mark = ","), "games")),
        stat_card("MMR trend", span(class = if (trend >= 0) "good" else "bad", sprintf("%+.1f", 100 * trend),
                                    span(class = "unit", "pp")),
                  "Herald–Crusader → Ancient–Divine")))
}

# Start -> Early -> Core -> Late, item icons with popularity share.
build_rail <- function(db, hid) {
  pop <- hero_item_popularity(db, hid, top = 6)
  if (is.null(pop)) return(p(class = "muted", "No item data in the snapshot for this hero."))
  div(class = "rail",
      lapply(levels(pop$phase), function(ph) {
        rows <- pop[pop$phase == ph, ]
        div(class = "stage",
            div(class = "stage-title", ph),
            div(lapply(seq_len(nrow(rows)), function(i)
              item_chip(db, rows$item[i], share = rows$share[i]))))
      }))
}

core_steps <- function(db, h) {
  lapply(h$core, function(e)
    div(class = "core-step",
        div(class = "min", paste0("~", e$target_min, "'")),
        item_icon(db, e$item),
        div(div(class = "name", item_name(db, e$item)), div(class = "why", e$why))))
}

starting_block <- function(db, h) {
  total <- sum(item_cost(db, vapply(h$starting, `[[`, "", "item")), na.rm = TRUE)
  tagList(
    div(lapply(h$starting, function(e) item_chip(db, e$item))),
    p(class = "muted", sprintf("Core kit ≈ %dg of the 600g starting gold.", total)),
    if (!is.null(h$starting_variants)) lapply(h$starting_variants, function(v)
      div(class = "core-step",
          div(style = "min-width:9rem", strong(v$situation)),
          div(div(lapply(unlist(v$items), function(k) item_icon(db, k, "sm"))),
              div(class = "why", v$note)))),
    h5(style = "margin-top:.8rem", "Laning"),
    lapply(h$laning, function(e)
      div(class = "core-step", item_icon(db, e$item, "sm"),
          div(div(class = "name", item_name(db, e$item)), div(class = "why", e$why))))
  )
}

situational_block <- function(db, h) {
  lapply(h$situational, function(e)
    div(class = "core-step", item_icon(db, e$item),
        div(div(class = "name", item_name(db, e$item)), div(class = "why", e$when))))
}

matchup_block <- function(db, hid, n = 5) {
  mu <- matchup_advantages(hero_matchups(hid))
  mu <- mu[mu$games >= 30, ]
  if (nrow(mu) == 0) return(p(class = "muted", "Not enough matchup data."))
  row <- function(r) div(style = "display:flex;align-items:center;gap:.5rem;margin-bottom:.35rem",
                         hero_icon(db, r$hero_id, "sm"),
                         span(style = "flex:1", hero_name(db, r$hero_id)),
                         span(class = paste("num", if (r$advantage >= 0) "good" else "bad"),
                              sprintf("%+.1f", 100 * r$advantage)))
  worst <- mu[order(mu$advantage), ][seq_len(min(n, nrow(mu))), ]
  best  <- mu[order(-mu$advantage), ][seq_len(min(n, nrow(mu))), ]
  bslib::layout_columns(col_widths = c(6, 6),
    div(h6(class = "bad", "Struggles vs"), lapply(split(worst, seq_len(nrow(worst))), row)),
    div(h6(class = "good", "Good vs"),     lapply(split(best,  seq_len(nrow(best))),  row)))
}
