# =============================================================================
# mod_draft.R — page IV: the Draft Helper.
#
# You type the enemy heroes (and your allies); the page ranks your pool by
#     score_candidate(base winrate, matchup advantages vs each enemy,
#                     synergies with each ally)
# score_candidate() lives in scoring.R and is YOUR exercise (TODO(human)).
# Until you write it, the ranking uses only the base winrate, and a hint says so.
# =============================================================================

mod_draft_ui <- function(id, db) {
  ns <- NS(id)
  all_heroes <- setNames(db$heroes$id, db$heroes$name)
  all_heroes <- all_heroes[order(names(all_heroes))]

  bslib::layout_columns(
    col_widths = c(4, 8),
    bslib::card(
      card_title("Enemy draft"),
      bslib::card_body(
        selectizeInput(ns("enemies"), "Enemy heroes (up to 5)", choices = all_heroes,
                       multiple = TRUE, options = list(maxItems = 5, placeholder = "Type a hero…")),
        selectizeInput(ns("allies"), "Your allies (up to 4)", choices = all_heroes,
                       multiple = TRUE, options = list(maxItems = 4, placeholder = "Optional…")),
        radioButtons(ns("pool"), "Candidates", inline = TRUE,
                     choices = c("My mains" = "mains", "Whole carry pool" = "pool")),
        selectInput(ns("bracket"), "Base winrate from", choices = c(
          "Ancient–Divine" = "6,7", "Archon–Legend" = "4,5", "Herald–Crusader" = "1,2,3")),
        uiOutput(ns("todo_hint")),
        p(class = "muted small",
          "Enemy chips: Ancient–Divine matchups (research 04), pp vs the hero's usual winrate. ",
          "Ally chips (lilac): synergy beyond both heroes' own strength (research 07, mains only).")
      )
    ),
    bslib::card(
      card_title("Best picks right now", "score = how far above a coin flip this pick is, in pp"),
      bslib::card_body(uiOutput(ns("ranking")))
    )
  )
}

mod_draft_server <- function(id, db) {
  moduleServer(id, function(input, output, session) {

    # Advantage tables are read from disk once per hero and then reused.
    # memoise-by-hand: an environment works like a mutable dictionary in R.
    cache <- new.env()
    advantages_of <- function(hid) {
      key <- as.character(hid)
      if (is.null(cache[[key]])) cache[[key]] <- matchup_advantages(hero_matchups(hid))
      cache[[key]]
    }
    syn_cache <- new.env()
    synergies_of <- function(hid) {
      key <- as.character(hid)
      if (!exists(key, envir = syn_cache, inherits = FALSE)) assign(key, ally_synergies(hid), envir = syn_cache)
      get(key, envir = syn_cache)
    }

    output$todo_hint <- renderUI({
      # If adding a +5pp matchup changes nothing, score_candidate() still ignores matchups.
      if (isTRUE(all.equal(score_candidate(0.5, 0.05), score_candidate(0.5, 0)))) {
        insight_callout("TODO(human): score_candidate()", kind = "lilac", icon = "!",
          tagList("It lives in ", tags$code("app/R/scoring.R"), " and still ignores the enemy draft, ",
                  "so this ranking is meta-only. Implement it to make the helper counter-pick."))
      }
    })

    ranking <- reactive({
      brackets <- as.integer(strsplit(input$bracket, ",")[[1]])
      stats <- bracket_stats(db$hero_stats, brackets)
      ids <- if (input$pool == "mains") unname(MY_MAINS) else CARRY_POOL
      enemies <- as.integer(input$enemies %||% integer())
      allies  <- as.integer(input$allies %||% integer())

      rows <- lapply(ids, function(hid) {
        adv_tbl <- advantages_of(hid)
        # One advantage per enemy (NA when we have no matchup row for that enemy).
        adv <- vapply(enemies, function(e) {
          a <- adv_tbl$advantage[adv_tbl$hero_id == e]
          if (length(a)) a[1] else NA_real_
        }, numeric(1))
        # One synergy per ally (NA if no data: only the 8 mains have synergy files).
        syn_tbl <- synergies_of(hid)
        syn <- vapply(allies, function(a) {
          v <- if (is.null(syn_tbl)) numeric() else syn_tbl$synergy[syn_tbl$hero_id == a]
          if (length(v)) v[1] else NA_real_
        }, numeric(1))
        base <- stats$wr_adj[stats$id == hid]
        list(id = hid, base = base, adv = adv, enemies = enemies, syn = syn, allies = allies,
             score = score_candidate(base, adv, syn))
      })
      rows[order(-vapply(rows, `[[`, 1, "score"))]
    })

    output$ranking <- renderUI({
      rows <- ranking()
      top <- max(abs(vapply(rows, `[[`, 1, "score")), 1)
      tagList(lapply(seq_along(rows), function(i) {
        r <- rows[[i]]
        w <- 50 * abs(r$score) / top               # bar grows left/right from the centre
        bar_style <- if (r$score >= 0) sprintf("left:50%%; width:%.1f%%; background:var(--radiant)", w)
                     else sprintf("right:50%%; width:%.1f%%; background:var(--dire)", w)
        div(class = "draft-row",
            div(class = "rank", sprintf("%02d", i)),
            hero_link(r$id, hero_icon(db, r$id)),
            div(
              div(strong(hero_name(db, r$id)),
                  if (r$id %in% MY_MAINS) span(class = "main-flag", "main"),
                  " ", tier_badge(assign_tier(r$base)),
                  span(class = "muted small", sprintf("  base %s", pct(r$base, 1)))),
              div(lapply(seq_along(r$enemies), function(j) {
                a <- r$adv[j]
                if (is.na(a)) return(NULL)
                span(class = paste("pill", if (a >= 0) "good" else "bad"),
                     img(class = "hero-icon sm", src = hero_img(db, r$enemies[j]), alt = ""),
                     sprintf("%+.1f", 100 * a))
              }),
              lapply(seq_along(r$allies), function(j) {
                v <- r$syn[j]
                if (is.na(v)) return(NULL)
                span(class = "pill", style = "border-color:var(--lilac,#b4a7f5);color:var(--lilac,#b4a7f5)",
                     img(class = "hero-icon sm", src = hero_img(db, r$allies[j]), alt = ""),
                     sprintf("ally %+.1f", 100 * v))
              })),
              div(class = "bar", span(style = bar_style))),
            div(class = paste("score", if (r$score >= 0) "good" else "bad"), sprintf("%+.1f", r$score)))
      }))
    })
  })
}
