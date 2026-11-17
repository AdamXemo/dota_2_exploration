# =============================================================================
# theme.R — the "Ancient Codex" look.
#
# bslib::bs_theme() builds a Bootstrap 5 theme from R. Bootstrap is the CSS
# framework Shiny uses under the hood, so changing its variables here recolours
# every button, input and card at once. Finer details (beveled panels, the
# meta map, item rails) live in www/styles.css.
# =============================================================================

# Colour palette. Named so the rest of the R code (ggplot charts) can reuse
# the exact same colours as the CSS.
PAL <- list(
  bg       = "#0a0c0f",  # obsidian background
  panel    = "#11151b",  # card background
  line     = "#232a33",  # hairlines / grid
  ink      = "#e8e2d4",  # main text (warm parchment white)
  muted    = "#8a909a",  # secondary text
  gold     = "#c9a25c",  # Aegis gold: highlights, tiers
  radiant  = "#5fd38d",  # good / above average
  dire     = "#e0524a",  # bad / below average
  arcane   = "#7aa7ff",  # neutral accent (int / magic)
  # Attribute colours, matching the in-game convention.
  str      = "#e0524a",
  agi      = "#5fd38d",
  int      = "#5fb4ff",
  all      = "#c9a25c"
)

codex_theme <- function() {
  bslib::bs_theme(
    version   = 5,
    bg        = PAL$bg,
    fg        = PAL$ink,
    primary   = PAL$gold,
    secondary = PAL$line,
    success   = PAL$radiant,
    danger    = PAL$dire,
    info      = PAL$arcane,
    # font_link() just adds a <link> to Google Fonts (no download needed).
    base_font    = bslib::font_link("Inter",
                     href = "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap"),
    heading_font = bslib::font_link("Cinzel",
                     href = "https://fonts.googleapis.com/css2?family=Cinzel:wght@500;700;900&display=swap"),
    code_font    = bslib::font_link("JetBrains Mono",
                     href = "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;600&display=swap"),
    "border-radius"    = "2px",   # Dota UI is angular, not bubbly
    "card-bg"          = PAL$panel,
    "card-border-color" = PAL$line
  )
}

# ggplot2 theme that matches the CSS, used by every chart in the app.
theme_codex <- function(base_size = 13) {
  ggplot2::theme_minimal(base_size = base_size, base_family = "sans") +
    ggplot2::theme(
      plot.background  = ggplot2::element_rect(fill = PAL$panel, colour = NA),
      panel.background = ggplot2::element_rect(fill = PAL$panel, colour = NA),
      panel.grid.major = ggplot2::element_line(colour = PAL$line, linewidth = 0.3),
      panel.grid.minor = ggplot2::element_blank(),
      text             = ggplot2::element_text(colour = PAL$ink),
      axis.text        = ggplot2::element_text(colour = PAL$muted),
      plot.title       = ggplot2::element_text(colour = PAL$gold, face = "bold"),
      legend.position  = "top"
    )
}
