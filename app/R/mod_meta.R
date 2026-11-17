# =============================================================================
# mod_meta.R — page I: the 15-hero carry board.
#
# A Shiny MODULE is a pair of functions (UI + server) that share an `id`.
# NS(id) ("namespace") prefixes every input/output id, so two modules can both
# have an input called "bracket" without clashing. Each page of the app is
# one module; app.R just plugs them together.
# =============================================================================

mod_meta_ui <- function(id) {
  ns <- NS(id)
  bslib::layout_columns(
    col_widths = 12,
    # --- controls + KPI tiles ---
    bslib::layout_columns(
      col_widths = c(3, 3, 3, 3),
      div(class = "stat-card",
          div(class = "stat-label", "Rank bracket"),
          selectizeInput(ns("bracket"), NULL, choices = BRACKETS, selected = DEFAULT_BRACKETS,
                         multiple = TRUE, width = "100%")),
      uiOutput(ns("kpi_top")),
      uiOutput(ns("kpi_main")),
      uiOutput(ns("kpi_games"))
    ),
    # --- compact tier strip: the whole carry pool in one line per tier ---
    bslib::card(card_title("Tier strip", "all carry-pool heroes in this bracket · click a portrait for the hero page"),
                bslib::card_body(uiOutput(ns("strip")))),
    # --- meta map + table ---
    bslib::layout_columns(
      col_widths = c(5, 7),
      bslib::card(card_title("Meta map", "Highlighted frame = your main. Hover a portrait."),
                  bslib::card_body(uiOutput(ns("map")))),
      bslib::card(card_title("Top 15 carries", "winrate shrunk toward 50% so small samples don't lie"),
                  bslib::card_body(reactable::reactableOutput(ns("table"))))
    ),
    # --- mains across all brackets ---
    bslib::card(card_title("Your pool across every bracket", "How each main performs from Herald to Divine"),
                bslib::card_body(plotOutput(ns("pool_plot"), height = "320px")))
  )
}

mod_meta_server <- function(id, db) {
  moduleServer(id, function(input, output, session) {

    # reactive() = a value that recomputes automatically when an input it
    # uses (here input$bracket) changes, and is cached otherwise.
    stats <- reactive({
      req(length(input$bracket) > 0)  # req(): pause until the user picked something
      bracket_stats(db$hero_stats, as.integer(input$bracket))
    })
    board <- reactive(carry_meta_board(stats()))

    output$kpi_top <- renderUI({
      b <- board()[1, ]
      stat_card("Strongest carry", hero_link(b$id, class = "stat-hero", img(src = b$img, alt = ""), b$name),
                tagList(span(class = "num good", pct(b$wr_adj, 2)), "adjusted winrate"),
                accent = TRUE, badge = tier_badge(b$tier))
    })

    output$kpi_main <- renderUI({
      m <- stats() |> filter(id %in% MY_MAINS) |> arrange(desc(wr_adj)) |> slice_head(n = 1)
      stat_card("Best of your mains", hero_link(m$id, class = "stat-hero", img(src = m$img, alt = ""), m$name),
                tagList(span(class = "num", pct(m$wr_adj, 2)), "adjusted winrate"),
                badge = tier_badge(assign_tier(m$wr_adj)))
    })

    output$kpi_games <- renderUI({
      rune("Sample size", format(round(sum(stats()$picks) / 10), big.mark = ","),
           sprintf("matches · patch %s · fetched %s", db$meta$patch, substr(db$meta$fetched_at, 1, 10)))
    })

    output$map <- renderUI(meta_map(board()))

    # Tier strip: every carry-pool hero, grouped by tier, best first.
    output$strip <- renderUI({
      pool <- stats() |>
        filter(id %in% CARRY_POOL) |>
        mutate(tier = assign_tier(wr_adj)) |>
        arrange(desc(wr_adj))
      div(class = "tier-strip",
        lapply(c("S", "A", "B", "C", "D"), function(t) {
          h <- pool[pool$tier == t, ]
          if (nrow(h) == 0) return(NULL)
          div(class = "ts-group", tier_badge(t),
              lapply(seq_len(nrow(h)), function(i)
                hero_link(h$id[i], class = if (h$id[i] %in% MY_MAINS) "is-main",
                          title = sprintf("%s · %s", h$name[i], pct(h$wr_adj[i], 1)),
                          img(src = h$img[i], alt = h$name[i], loading = "lazy"))))
        }))
    })

    output$table <- reactable::renderReactable({
      b <- board()
      reactable::reactable(
        b |> select(rank, tier, name, winrate, wr_adj, pickrate, picks, pro_picks),
        compact = TRUE, highlight = TRUE, pagination = FALSE,
        defaultSorted = "rank",
        columns = list(
          rank = reactable::colDef(name = "#", width = 44, align = "center",
                   style = list(fontFamily = "JetBrains Mono", color = PAL$muted)),
          tier = reactable::colDef(name = "Tier", width = 56, align = "center",
                   cell = function(v) tier_badge(v)),
          # cell = function(value, index) lets us return HTML per cell.
          name = reactable::colDef(name = "Hero", minWidth = 210, cell = function(v, i) {
            div(style = "display:flex;align-items:center;gap:.5rem",
                img(class = "hero-icon sm", src = b$img[i]), v,
                if (b$is_main[i]) span(class = "main-flag", "main"))
          }),
          winrate  = reactable::colDef(name = "Winrate", cell = function(v) div(span(class = "num", pct(v, 2)), wr_bar(v))),
          wr_adj   = reactable::colDef(name = "Adj.", cell = function(v) span(class = "num", pct(v, 2))),
          pickrate = reactable::colDef(name = "Picked", cell = function(v) span(class = "num", pct(v, 1))),
          picks    = reactable::colDef(name = "Games", format = reactable::colFormat(separators = TRUE)),
          pro_picks = reactable::colDef(name = "Pro picks", width = 80)
        ),
        theme = reactable::reactableTheme(backgroundColor = "transparent", color = PAL$ink,
                                          borderColor = PAL$line, highlightColor = "rgba(143,208,240,.06)")
      )
    })

    # Line chart: winrate of each main in every bracket (1 = Herald ... 8 = Immortal).
    output$pool_plot <- renderPlot({
      rows <- lapply(BRACKETS, function(b) {
        s <- bracket_stats(db$hero_stats, b)
        s$bracket <- b
        s[s$id %in% MY_MAINS, c("name", "bracket", "wr_adj")]
      })
      df <- do.call(rbind, rows)
      # Label each line at its right end. Labels of close lines would overlap,
      # so we spread them: walk up the sorted list and keep a minimum gap.
      last <- df[df$bracket == max(BRACKETS), ]
      last <- last[order(last$wr_adj), ]
      last$label_y <- last$wr_adj
      for (i in seq_len(nrow(last))[-1]) {
        last$label_y[i] <- max(last$label_y[i], last$label_y[i - 1] + 0.0065)
      }

      ggplot2::ggplot(df, ggplot2::aes(bracket, wr_adj, colour = name)) +
        ggplot2::geom_hline(yintercept = 0.5, colour = PAL$gold, linetype = "dashed", linewidth = 0.4) +
        ggplot2::annotate("rect", xmin = 5.5, xmax = 7.5, ymin = -Inf, ymax = Inf,
                          fill = PAL$gold, alpha = 0.06) +           # highlight Ancient-Divine
        ggplot2::geom_line(linewidth = 1) +
        ggplot2::geom_point(size = 2) +
        ggplot2::geom_text(data = last, ggplot2::aes(y = label_y, label = paste0(name, "  ", pct(wr_adj, 1))),
                           hjust = 0, nudge_x = 0.12, size = 3.6, show.legend = FALSE) +
        ggplot2::scale_x_continuous(breaks = BRACKETS, labels = names(BRACKETS),
                                    expand = ggplot2::expansion(add = c(0.2, 1.4))) +
        ggplot2::scale_y_continuous(labels = function(v) pct(v, 0)) +
        ggplot2::scale_colour_manual(values = c("#8fd0f0", "#b4a7f5", "#5ed6b0", "#f0788a",
                                                "#8ea6ff", "#c7d3e0", "#4fb8c9", "#d59ee0")) +
        ggplot2::labs(x = NULL, y = "Adjusted winrate", colour = NULL) +
        theme_codex() + ggplot2::theme(legend.position = "none")
    }, bg = "transparent")
  })
}
