# =============================================================================
# theme.R — the "Dota Carry Lab" look (cold esports stats tool).
#
# Two layers make up the look:
#   1. bslib::bs_theme() (this file) builds a Bootstrap 5 theme from R.
#      Bootstrap is the CSS framework Shiny uses under the hood, so the colours
#      and fonts set here restyle every button, input and card at once.
#   2. www/styles.css adds the details: design tokens (CSS variables), tier
#      lists, KPI cards, the meta map, tables, etc.
#
# Both layers read from the SAME palette (PAL below / --tokens in the CSS), so
# a ggplot chart, a Bootstrap button and a CSS tier badge all match.
# The full spec lives in docs/design/DESIGN_SYSTEM.md.
# =============================================================================

# --- Colour palette -----------------------------------------------------------
# Idea: graphite / blue-black surfaces, cool off-white text, and two icy
# accents (pale cyan "ice" + soft lilac). Radiant / Dire stay as the good / bad
# colours but are cooled down to mint-teal and soft rose.
#
# The element NAMES are kept from the old theme so the rest of the R code keeps
# working. Note: `gold` is now just "the primary accent" — its value is ice
# blue, not gold. (Renaming it would break every PAL$gold in the modules.)
PAL <- list(
  bg       = "#0b0e13",  # page background (blue-black)
  panel    = "#121820",  # cards / panels
  line     = "#232c38",  # 1px hairlines, chart grid
  ink      = "#e6ebf2",  # main text (cool white)    — 14.9:1 on panel
  muted    = "#8a96a8",  # secondary text            —  5.9:1 on panel
  gold     = "#8fd0f0",  # PRIMARY ACCENT ("ice")    — 10.6:1 on panel
  radiant  = "#5ed6b0",  # good / above average (mint-teal)
  dire     = "#f0788a",  # bad / below average (soft rose)
  arcane   = "#b4a7f5",  # secondary accent (lilac)
  # Attribute colours: same hues players know from the game, cooled down.
  str      = "#f0788a",  # strength  -> rose
  agi      = "#5ed6b0",  # agility   -> mint
  int      = "#7fb4ff",  # intellect -> ice blue
  all      = "#b4a7f5"   # universal -> lilac
)

# Ordered colour list for CATEGORICAL series in charts (lines, groups).
# Use them in this order: ggplot2::scale_colour_manual(values = PAL_SERIES).
# Neighbours are chosen to differ in hue AND lightness so lines stay apart.
PAL_SERIES <- c(
  "#8fd0f0",  # 1 ice
  "#b4a7f5",  # 2 lilac
  "#5ed6b0",  # 3 mint
  "#f0788a",  # 4 rose
  "#8ea6ff",  # 5 periwinkle
  "#c7d3e0",  # 6 steel
  "#4fb8c9",  # 7 aqua
  "#d59ee0"   # 8 mauve
)

# --- Fonts --------------------------------------------------------------------
# font_link() only adds a <link> to Google Fonts (nothing is downloaded).
#  * Inter          — UI/body text. Neutral, very legible at small sizes; the
#                     default face of the 2017-2021 product/stats-site era.
#  * Space Grotesk  — headings & big numbers. A grotesk with slightly quirky
#                     shapes: technical and cold, not "fantasy book".
#  * JetBrains Mono — numbers in tables/KPIs. Tabular (equal-width) digits so
#                     columns of winrates line up.
font_inter <- bslib::font_link(
  "Inter", href = "https://fonts.googleapis.com/css2?family=Inter:wght@400;500;600;700&display=swap")
font_grotesk <- bslib::font_link(
  "Space Grotesk", href = "https://fonts.googleapis.com/css2?family=Space+Grotesk:wght@500;600;700&display=swap")
font_mono <- bslib::font_link(
  "JetBrains Mono", href = "https://fonts.googleapis.com/css2?family=JetBrains+Mono:wght@400;500;600&display=swap")

# --- Bootstrap theme ----------------------------------------------------------
# app.R calls codex_theme(); lab_theme() is the same thing under the new name.
codex_theme <- function() {
  bslib::bs_theme(
    version   = 5,
    bg        = PAL$bg,
    fg        = PAL$ink,
    primary   = PAL$gold,     # ice accent: links, primary buttons, focus rings
    secondary = "#2f3a48",
    success   = PAL$radiant,
    danger    = PAL$dire,
    info      = PAL$arcane,
    base_font    = font_inter,
    heading_font = font_grotesk,
    code_font    = font_mono,
    "font-size-base"     = "0.9375rem",  # 15px: dense but readable, like stats sites
    "headings-font-weight" = 600,
    "border-radius"      = "8px",        # soft, modern corners (no bevels)
    "border-radius-sm"   = "6px",
    "border-radius-lg"   = "12px",
    "card-bg"            = PAL$panel,
    "card-border-color"  = PAL$line,
    "border-color"       = PAL$line,
    "body-secondary-color" = PAL$muted,
    "link-decoration"    = "none",
    "navbar-bg"          = PAL$bg
  )
}
lab_theme <- codex_theme

# --- ggplot2 theme ------------------------------------------------------------
# Matches the cards: transparent background (renderPlot(..., bg = "transparent")
# lets the card colour show through), faint hairline grid, muted axis text.
theme_codex <- function(base_size = 13) {
  ggplot2::theme_minimal(base_size = base_size, base_family = "sans") +
    ggplot2::theme(
      plot.background  = ggplot2::element_rect(fill = "transparent", colour = NA),
      panel.background = ggplot2::element_rect(fill = "transparent", colour = NA),
      panel.grid.major = ggplot2::element_line(colour = PAL$line, linewidth = 0.35),
      panel.grid.minor = ggplot2::element_blank(),
      panel.grid.major.x = ggplot2::element_blank(),   # horizontal grid only: calmer
      axis.ticks       = ggplot2::element_blank(),
      text             = ggplot2::element_text(colour = PAL$ink),
      axis.text        = ggplot2::element_text(colour = PAL$muted, size = ggplot2::rel(0.85)),
      axis.title       = ggplot2::element_text(colour = PAL$muted, size = ggplot2::rel(0.8)),
      plot.title       = ggplot2::element_text(colour = PAL$ink, face = "bold", size = ggplot2::rel(1.1)),
      plot.subtitle    = ggplot2::element_text(colour = PAL$muted),
      legend.text      = ggplot2::element_text(colour = PAL$muted),
      legend.position  = "top",
      legend.justification = "left",
      plot.margin      = ggplot2::margin(8, 12, 8, 8)
    )
}
theme_lab <- theme_codex
