# =============================================================================
# app.R — entry point of the "Dota Carry Lab" dashboard.
#
# Run it from the repo root with:   shiny::runApp("app")
# (or open this file in RStudio and press "Run App").
#
# Shiny sources every file in app/R/ automatically before this file runs, so
# config, theme, data loading, scoring and all page modules are available here.
# =============================================================================

library(shiny)
library(dplyr)

# Load the OpenDota snapshot + curated notes once, at startup.
db <- load_db()

# --- UI: a navbar page, one nav_panel per "chapter" --------------------------
ui <- bslib::page_navbar(
  id = "nav",
  title = tagList("DOTA CARRY LAB",
                  span(class = "brand-sub", paste0("patch ", db$meta$patch, " · carry lab"))),
  theme = codex_theme(),
  fillable = FALSE,
  header = tags$head(tags$link(rel = "stylesheet", href = "styles.css")),

  bslib::nav_panel(tagList(span(class = "chapter", "01"), "Carry Meta"), mod_meta_ui("meta"), value = "meta"),
  bslib::nav_panel(tagList(span(class = "chapter", "02"), "Heroes"),    mod_hero_ui("hero", db), value = "hero"),
  bslib::nav_panel(tagList(span(class = "chapter", "03"), "Item Codex"), mod_items_ui("items", db), value = "items"),
  bslib::nav_panel(tagList(span(class = "chapter", "04"), "Draft"), mod_draft_ui("draft", db), value = "draft"),
  bslib::nav_panel(tagList(span(class = "chapter", "05"), "My Stats"), mod_mystats_ui("me"), value = "me"),
  bslib::nav_panel(tagList(span(class = "chapter", "06"), "Notes"), mod_notes_ui("notes"), value = "notes"),

  bslib::nav_spacer(),
  bslib::nav_item(tags$a(href = "https://www.opendota.com", target = "_blank",
                         class = "nav-link", "data: OpenDota"))
)

# --- Server: start each page's module with the shared data -------------------
server <- function(input, output, session) {
  mod_meta_server("meta", db)
  mod_hero_server("hero", db)
  mod_items_server("items", db)
  mod_draft_server("draft", db)
  mod_mystats_server("me", db)
  mod_notes_server("notes")

  # Deep links: ?tab=hero&hero=42 opens the Heroes page on Wraith King.
  # parseQueryString() turns "?a=1&b=2" into list(a = "1", b = "2").
  observeEvent(session$clientData$url_search, once = TRUE, {
    q <- parseQueryString(session$clientData$url_search)
    if (!is.null(q$tab))  bslib::nav_select("nav", q$tab)
    if (!is.null(q$hero)) updateSelectizeInput(session, "hero-hero", selected = q$hero)
  })
}

shinyApp(ui, server)
