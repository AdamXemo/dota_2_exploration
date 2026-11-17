# =============================================================================
# mod_mystats.R — page V: your own games from OpenDota.
#
# Needs your account id (the number in your OpenDota/Dotabuff profile URL).
# Put it in .Renviron as DOTA_ACCOUNT_ID=... (see .Renviron.example) or paste
# it into the box. Your match history must be public in the Dota client
# (Settings -> Options -> "Expose Public Match Data").
# =============================================================================

mod_mystats_ui <- function(id) {
  ns <- NS(id)
  tagList(
    bslib::layout_columns(
      col_widths = c(3, 2, 7),
      textInput(ns("account"), NULL, value = Sys.getenv("DOTA_ACCOUNT_ID"),
                placeholder = "OpenDota account id"),
      actionButton(ns("load"), "Load my games", class = "btn-primary"),
      uiOutput(ns("profile"))
    ),
    uiOutput(ns("kpis")),
    bslib::layout_columns(
      col_widths = c(7, 5),
      bslib::card(card_title("Per hero", "last 200 ranked/normal games · GPM percentile vs OpenDota benchmarks"),
                  bslib::card_body(reactable::reactableOutput(ns("by_hero")))),
      bslib::card(card_title("Form", "rolling 10-game winrate and GPM"),
                  bslib::card_body(plotOutput(ns("form"), height = "330px")))
    ),
    bslib::card(
      card_title("Item timings vs targets", "parsed games only · targets = data/curated/heroes.json"),
      bslib::card_body(
        bslib::layout_columns(col_widths = c(3, 3, 6),
          selectInput(ns("timing_hero"), NULL, choices = MY_MAINS),
          actionButton(ns("timings"), "Analyze last 8 games on this hero"),
          p(class = "muted small", "Fetches each match from OpenDota (1 request per game). ",
            "Unparsed matches have no purchase log; request a parse on opendota.com first.")),
        uiOutput(ns("timing_table"))
      )
    )
  )
}

mod_mystats_server <- function(id, db) {
  moduleServer(id, function(input, output, session) {

    # eventReactive(): only recompute when the button is clicked.
    matches <- eventReactive(input$load, {
      acc <- trimws(input$account)
      validate(need(grepl("^[0-9]+$", acc), "Enter a numeric OpenDota account id."))
      # `project` picks which fields OpenDota returns for each match.
      fields <- c("match_id", "player_slot", "radiant_win", "duration", "hero_id", "start_time",
                  "kills", "deaths", "assists", "gold_per_min", "xp_per_min", "last_hits")
      query <- c(list(limit = 200, significant = 1), setNames(as.list(fields), rep("project", length(fields))))
      m <- tryCatch(od_get(paste0("players/", acc, "/matches"), query = query),
                    error = function(e) NULL)
      validate(need(is.data.frame(m) && nrow(m) > 0,
                    "No public matches found for this id (is 'Expose Public Match Data' on?)."))
      m |>
        mutate(
          # player_slot < 128 = Radiant; you win when your side matches radiant_win.
          win     = (player_slot < 128) == radiant_win,
          hero    = hero_name(db, hero_id),
          date    = as.POSIXct(start_time, origin = "1970-01-01"),
          lh_min  = last_hits / (duration / 60)
        ) |>
        arrange(start_time)
    })

    profile <- eventReactive(input$load, {
      tryCatch(od_get(paste0("players/", trimws(input$account))), error = function(e) NULL)
    })

    output$profile <- renderUI({
      p <- profile(); req(p, p$profile)
      div(class = "muted", style = "padding-top:.45rem",
          img(src = p$profile$avatarmedium, style = "height:28px;border-radius:50%;margin-right:.5rem"),
          strong(p$profile$personaname), " · rank tier ", p$rank_tier %||% "?")
    })

    output$kpis <- renderUI({
      m <- matches()
      mains <- m[m$hero_id %in% MY_MAINS, ]
      bslib::layout_columns(col_widths = c(3, 3, 3, 3),
        rune("Games", nrow(m), sprintf("%s on your mains", nrow(mains))),
        rune("Winrate", pct(mean(m$win), 1), sprintf("mains: %s", if (nrow(mains)) pct(mean(mains$win), 1) else "–")),
        rune("Avg GPM", round(mean(m$gold_per_min)), sprintf("mains: %s", if (nrow(mains)) round(mean(mains$gold_per_min)) else "–")),
        rune("Last hits / min", sprintf("%.1f", mean(m$lh_min)), "all games"))
    })

    output$by_hero <- reactable::renderReactable({
      m <- matches()
      tbl <- m |>
        group_by(hero_id, hero) |>
        summarise(games = n(), winrate = mean(win), kda = (sum(kills) + sum(assists)) / pmax(sum(deaths), 1),
                  gpm = mean(gold_per_min), lh_min = mean(lh_min), .groups = "drop") |>
        arrange(desc(games))
      # GPM percentile against OpenDota's benchmark for that hero (NA if no data).
      tbl$gpm_pct <- vapply(seq_len(nrow(tbl)), function(i) {
        bm <- hero_benchmarks(tbl$hero_id[i])
        if (is.null(bm)) NA_real_ else percentile_of(tbl$gpm[i], bm$gold_per_min)
      }, numeric(1))

      reactable::reactable(tbl |> select(-hero_id), compact = TRUE, pagination = FALSE, highlight = TRUE,
        columns = list(
          hero    = reactable::colDef(name = "Hero", minWidth = 150, cell = function(v, i)
            div(style = "display:flex;gap:.5rem;align-items:center",
                hero_icon(db, tbl$hero_id[i], "sm"), v,
                if (tbl$hero_id[i] %in% MY_MAINS) span(class = "main-flag", "main"))),
          games   = reactable::colDef(name = "Games", width = 70),
          winrate = reactable::colDef(name = "Win", cell = function(v) div(span(class = "num", pct(v, 0)), wr_bar(v, 0.3, 0.7))),
          kda     = reactable::colDef(name = "KDA", format = reactable::colFormat(digits = 2)),
          gpm     = reactable::colDef(name = "GPM", format = reactable::colFormat(digits = 0)),
          lh_min  = reactable::colDef(name = "LH/min", format = reactable::colFormat(digits = 1)),
          gpm_pct = reactable::colDef(name = "GPM pct", cell = function(v)
            if (is.na(v)) span(class = "muted", "TODO") else span(class = "num", pct(v, 0)))
        ),
        theme = reactable::reactableTheme(backgroundColor = "transparent", color = PAL$ink, borderColor = PAL$line))
    })

    output$form <- renderPlot({
      m <- matches()
      # stats::filter with rep(1/10, 10) = moving average over the last 10 games.
      roll <- function(x) as.numeric(stats::filter(x, rep(1 / 10, 10), sides = 1))
      df <- data.frame(game = seq_len(nrow(m)), winrate = roll(m$win), gpm = roll(m$gold_per_min))
      df <- df[!is.na(df$winrate), ]
      ggplot2::ggplot(df, ggplot2::aes(game)) +
        ggplot2::geom_hline(yintercept = 0.5, colour = PAL$muted, linetype = "dashed", linewidth = 0.3) +
        ggplot2::geom_line(ggplot2::aes(y = winrate, colour = "Winrate (10 games)"), linewidth = 1) +
        # GPM drawn on the same axis by rescaling 0..1000 GPM to 0..1
        ggplot2::geom_line(ggplot2::aes(y = gpm / 1000, colour = "GPM (÷1000)"), linewidth = 0.8, alpha = 0.8) +
        ggplot2::scale_y_continuous(labels = function(v) pct(v, 0),
                                    sec.axis = ggplot2::sec_axis(~ . * 1000, name = "GPM")) +
        ggplot2::scale_colour_manual(values = c(PAL$gold, PAL$arcane), name = NULL) +
        ggplot2::labs(x = "game (oldest → newest)", y = "winrate") +
        theme_codex()
    }, bg = "transparent")

    # --- Item timings --------------------------------------------------------
    timings <- eventReactive(input$timings, {
      m <- matches()
      hid <- as.integer(input$timing_hero)
      recent <- tail(m[m$hero_id == hid, ], 8)
      validate(need(nrow(recent) > 0, "No recent games on this hero."))
      h <- curated_hero(db, hid)
      targets <- data.frame(item = vapply(h$core, `[[`, "", "item"),
                            target = vapply(h$core, `[[`, 1, "target_min"))

      withProgress(message = "Fetching matches", value = 0, {
        rows <- lapply(seq_len(nrow(recent)), function(i) {
          incProgress(1 / nrow(recent))
          Sys.sleep(1.1)  # stay under the API rate limit
          md <- tryCatch(od_get(paste0("matches/", recent$match_id[i]), simplify = FALSE), error = function(e) NULL)
          if (is.null(md)) return(NULL)
          me <- Filter(function(p) p$player_slot == recent$player_slot[i], md$players)[[1]]
          if (is.null(me$purchase_log)) return(NULL)            # match not parsed
          log <- do.call(rbind, lapply(me$purchase_log, function(x) data.frame(key = x$key, time = x$time)))
          data.frame(item = targets$item,
                     minute = vapply(targets$item, function(k) {
                       t <- log$time[log$key == k]; if (length(t)) min(t) / 60 else NA_real_ }, 1))
        })
      })
      all <- do.call(rbind, rows)
      validate(need(!is.null(all), "None of these games are parsed yet."))
      all |>
        group_by(item) |>
        summarise(games = sum(!is.na(minute)), avg = mean(minute, na.rm = TRUE), .groups = "drop") |>
        right_join(targets, by = "item") |>
        mutate(delta = avg - target)
    })

    output$timing_table <- renderUI({
      t <- timings()
      tagList(lapply(seq_len(nrow(t)), function(i) {
        r <- t[i, ]
        div(class = "core-step",
            div(class = "min", paste0("~", r$target, "'")),
            item_icon(db, r$item),
            div(style = "flex:1", div(class = "name", item_name(db, r$item)),
                div(class = "why", if (is.na(r$avg) || r$games == 0) "not bought in these games" else
                  sprintf("your average: %.1f min (%d games)", r$avg, r$games))),
            if (!is.na(r$delta)) span(class = paste("num", if (r$delta <= 0) "good" else "bad"),
                                     sprintf("%+.1f min", r$delta)))
      }))
    })
  })
}
