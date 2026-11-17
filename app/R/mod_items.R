# =============================================================================
# mod_items.R — page III: the Item Codex.
#
# Cards for every carry-relevant item (stats come from the live constants via
# data/processed/items_reference.json), plus the gold-efficiency lens from
# scripts/03_item_efficiency.R.
# =============================================================================

load_item_codex <- function() {
  ref <- jsonlite::fromJSON(path_data("processed", "items_reference.json"), simplifyVector = FALSE)$items
  eff <- jsonlite::fromJSON(path_data("processed", "item_efficiency.json"))$items
  # Attach efficiency to each item (NULL for basic items that weren't scored).
  lapply(ref, function(it) {
    row <- eff[eff$key == it$key, ]
    it$efficiency <- if (nrow(row)) row$efficiency[1] else NA
    it$premium    <- if (nrow(row)) row$premium[1] else NA
    it
  })
}

mod_items_ui <- function(id, db) {
  ns <- NS(id)
  cats <- db$item_notes$categories
  tagList(
    bslib::layout_columns(
      col_widths = c(4, 5, 3),
      textInput(ns("q"), NULL, placeholder = "Search items or effects… (e.g. dispel, evasion)"),
      selectizeInput(ns("cat"), NULL, multiple = TRUE,
                     choices = setNames(names(cats), gsub("_", " ", names(cats))),
                     options = list(placeholder = "All categories")),
      selectInput(ns("sort"), NULL, choices = c("Cost (high → low)" = "cost",
                                                "Gold efficiency" = "eff",
                                                "Name" = "name"))
    ),
    bslib::card(card_title("Gold efficiency of carry items",
                           "stat value ÷ cost · above 100% = stats worth more than the price · rest = what you pay for the effect"),
                bslib::card_body(plotOutput(ns("eff_plot"), height = "820px"))),
    uiOutput(ns("grid"))
  )
}

mod_items_server <- function(id, db) {
  moduleServer(id, function(input, output, session) {
    codex <- load_item_codex()

    filtered <- reactive({
      x <- codex
      if (length(input$cat)) x <- Filter(function(it) isTRUE(it$category %in% input$cat), x)
      if (nzchar(input$q)) {
        q <- tolower(input$q)
        x <- Filter(function(it) grepl(q, tolower(paste(it$name, unlist(it$stats), unlist(it$actives),
                                                        it$why, it$when)), fixed = TRUE), x)
      }
      key <- switch(input$sort,
                    cost = -vapply(x, function(it) as.numeric(it$cost %||% 0), 1),
                    eff  = -vapply(x, function(it) it$efficiency %||% -1, 1),
                    name = rank(vapply(x, `[[`, "", "name")))
      x[order(key)]
    })

    output$eff_plot <- renderPlot({
      df <- do.call(rbind, lapply(codex, function(it)
        if (!is.na(it$efficiency)) data.frame(name = it$name, cost = it$cost, eff = it$efficiency)))
      df <- df[order(df$eff), ]
      df$name <- factor(df$name, levels = df$name)   # keep sorted order on the axis

      ggplot2::ggplot(df, ggplot2::aes(eff, name, fill = eff >= 1)) +
        ggplot2::geom_col(width = 0.7) +
        ggplot2::geom_vline(xintercept = 1, colour = PAL$gold, linetype = "dashed") +
        ggplot2::geom_text(ggplot2::aes(label = paste0(round(100 * eff), "%  ·  ", cost, "g")),
                           hjust = -0.08, colour = PAL$muted, size = 3.1) +
        ggplot2::scale_fill_manual(values = c(`TRUE` = PAL$radiant, `FALSE` = "#3a4350"), guide = "none") +
        ggplot2::scale_x_continuous(labels = function(v) paste0(100 * v, "%"),
                                    expand = ggplot2::expansion(mult = c(0, 0.25))) +
        ggplot2::labs(x = NULL, y = NULL) +
        theme_codex(12)
    }, bg = "transparent")

    output$grid <- renderUI({
      items <- filtered()
      if (!length(items)) return(p(class = "muted", "No item matches."))
      div(class = "codex-grid", lapply(items, item_card))
    })
  })
}

# One item card.
item_card <- function(it) {
  eff_label <- if (is.na(it$efficiency %||% NA)) NULL else
    span(class = paste("pill", if (it$efficiency >= 1) "good" else ""),
         paste0(round(100 * it$efficiency), "% stat value"))
  div(class = "codex-panel item-card",
      div(class = "item-head",
          img(class = "item-icon", src = it$icon, alt = it$name, loading = "lazy"),
          div(div(class = "name", it$name),
              div(class = "num gold", paste0(it$cost, "g")),
              if (!is.null(it$category)) span(class = "pill", gsub("_", " ", it$category)),
              eff_label)),
      if (length(it$stats)) tags$ul(class = "item-stats", lapply(unlist(it$stats), tags$li)),
      if (length(it$actives)) div(class = "item-active",
        lapply(unlist(it$actives), function(a) p(substr(a, 1, 220), if (nchar(a) > 220) "…"))),
      if (!is.null(it$why))  p(class = "why", strong("Why: "), it$why),
      if (!is.null(it$when)) p(class = "why", strong("When: "), it$when))
}
