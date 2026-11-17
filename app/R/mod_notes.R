# =============================================================================
# mod_notes.R — page VI: read the knowledge pack and research write-ups in-app.
#
# shiny::includeMarkdown() converts a .md file to HTML (via the markdown
# package), so the same notes the LLM reads are readable here too.
# =============================================================================

# Build the list of readable notes: "Group" -> c(label = path).
notes_index <- function() {
  label <- function(paths) {
    nm <- sub("\\.md$", "", basename(paths))
    nm <- gsub("_", " ", sub("^[0-9]+_", "", nm))
    setNames(paths, tools::toTitleCase(nm))
  }
  root <- REPO_ROOT
  list(
    "Start here" = label(file.path(root, "knowledge", c("00_dota_brain.md", "02_carry_playbook.md",
                                                        "03_core_concepts.md", "01_mechanics.md",
                                                        "meta_snapshot.md"))),
    "Research"   = label(sort(list.files(file.path(root, "docs", "research"), full.names = TRUE))),
    "Hero notes" = label(sort(list.files(file.path(root, "knowledge", "heroes"), full.names = TRUE))),
    "Prompts"    = label(sort(list.files(file.path(root, "knowledge", "prompts"), full.names = TRUE)))
  )
}

mod_notes_ui <- function(id) {
  ns <- NS(id)
  idx <- notes_index()
  bslib::layout_columns(
    col_widths = c(3, 9),
    bslib::card(card_title("Notes"), bslib::card_body(
      selectInput(ns("file"), NULL, choices = idx, selected = idx[[1]][[1]], selectize = FALSE, size = 22),
      p(class = "muted small", "Same files the LLM agent reads (see CLAUDE.md)."))),
    bslib::card(bslib::card_body(class = "lore notes", uiOutput(ns("doc"))))
  )
}

mod_notes_server <- function(id) {
  moduleServer(id, function(input, output, session) {
    output$doc <- renderUI({
      req(input$file, file.exists(input$file))
      includeMarkdown(input$file)
    })
  })
}
