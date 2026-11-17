# =============================================================================
# components.R — small reusable pieces of UI (HTML) used by several pages.
#
# htmltools "tags" are R functions that produce HTML:
#   tags$div(class = "x", "hello")   ->   <div class="x">hello</div>
#   div(), span(), img() are shortcuts for the most common ones.
# Every function here returns such a tag, so pages can compose them freely.
# =============================================================================

library(htmltools)

pct <- function(x, digits = 1) sprintf(paste0("%.", digits, "f%%"), 100 * x)

# KPI tile: label on top, big value, small sub-line.
# (Old name "rune" kept so every page keeps working; it now draws the
#  design-system .stat-card. `accent = TRUE` tints the one KPI that matters most.)
rune <- function(label, value, sub = NULL, accent = FALSE) {
  stat_card(label, value, sub, accent = accent)
}

stat_card <- function(label, value, sub = NULL, accent = FALSE, badge = NULL) {
  div(class = paste("stat-card", if (accent) "accent"),
      div(class = "stat-label", span(label), badge),
      div(class = "stat-value", value),
      if (!is.null(sub)) div(class = "stat-sub", sub))
}

# Small coloured chip for a change in percentage points, e.g. "▲ 1.2 pp".
# The ▲/▼ glyph comes from CSS (.delta-up / .delta-down), so we print abs().
# Changes smaller than `flat` pp count as "no real change".
delta_chip <- function(pp, flat = 0.5, unit = " pp") {
  cls <- if (abs(pp) < flat) "delta-flat" else if (pp > 0) "delta-up" else "delta-down"
  span(class = cls, sprintf("%.1f%s", abs(pp), unit))
}

# -----------------------------------------------------------------------------
# Navigation links that work in two ways:
#   - a normal href (?tab=hero&hero=42): open in new tab / copy link works;
#   - an onclick that tells Shiny "go there" WITHOUT reloading the page.
# The onclick sends input$goto = list(tab = ..., hero = ..., note = ...),
# which app.R turns into bslib::nav_select() + updating the page's inputs.
# -----------------------------------------------------------------------------
goto_link <- function(..., tab, hero = NULL, note = NULL, class = NULL, title = NULL) {
  href <- paste0("?tab=", tab, if (!is.null(hero)) paste0("&hero=", hero))
  args <- c(sprintf("tab:'%s'", tab),
            if (!is.null(hero)) sprintf("hero:%d", as.integer(hero)),
            if (!is.null(note)) sprintf("note:'%s'", note))
  js <- sprintf("Shiny.setInputValue('goto', {%s}, {priority: 'event'}); return false;",
                paste(args, collapse = ", "))
  tags$a(href = href, onclick = js, class = class, title = title, ...)
}

hero_link <- function(id, ..., class = NULL, title = NULL) {
  goto_link(..., tab = "hero", hero = id, class = class, title = title)
}

# -----------------------------------------------------------------------------
# Tier list: one row per tier (S..D), hero portraits inside.
# `heroes` is a data frame with columns id, name, img, tier, wr_adj, is_main
# (e.g. bracket_stats() + assign_tier()). Hover a portrait -> name + winrate;
# click -> hero page.
# -----------------------------------------------------------------------------
tier_list <- function(heroes, compact = FALSE) {
  heroes <- heroes[order(-heroes$wr_adj), ]
  rows <- lapply(c("S", "A", "B", "C", "D"), function(t) {
    h <- heroes[heroes$tier == t, ]
    div(class = paste0("tierlist-row t-", t),
        div(class = "tierlist-label", t, tags$small(nrow(h))),
        div(class = "tierlist-items",
            lapply(seq_len(nrow(h)), function(i)
              hero_link(h$id[i], class = paste("tierlist-hero", if (h$is_main[i]) "is-main"),
                        title = sprintf("%s · %s", h$name[i], pct(h$wr_adj[i], 1)),
                        img(src = h$img[i], alt = h$name[i], loading = "lazy"),
                        span(class = "tl-name", h$name[i]),
                        span(class = "tl-stat", pct(h$wr_adj[i], 1))))))
  })
  div(class = paste("tierlist", if (compact) "compact"), rows)
}

# Hero tile: portrait + tier + name + a 2x2 grid of small stats.
# `stats` is a named list: list("Winrate" = span(...), "Median GPM" = "578").
hero_tile <- function(db, id, tier, stats, is_main = TRUE) {
  hero_link(id, class = paste("hero-tile", if (is_main) "is-main"),
            div(class = "hero-tile-img",
                img(src = hero_img(db, id), alt = "", loading = "lazy"),
                tier_badge(tier),
                if (is_main) span(class = "tag ice", "main")),
            div(class = "hero-tile-body",
                div(class = "hero-tile-name", hero_name(db, id)),
                div(class = "hero-tile-stats",
                    lapply(names(stats), function(k)
                      div(class = "hs", span(class = "k", k), span(class = "v", stats[[k]]))))))
}

# Insight callout: icon, bold title, one or two sentences, optional link.
# kind = "" (ice), "lilac" (method), "good" (pick), "bad" (avoid).
insight_callout <- function(title, body, kind = "", icon = "i", link = NULL) {
  div(class = paste("callout", kind),
      span(class = "callout-icon", icon),
      div(span(class = "callout-title", title), body,
          if (!is.null(link)) div(class = "callout-link", link)))
}

# Labelled horizontal bar: name (with icon) | bar | value.
# `share` = how full the bar is (0..1); kind = "" / "good" / "bad" / "lilac".
meter_row <- function(name, share, value, kind = "", icon = NULL, extra_class = "") {
  div(class = "meter-row",
      span(class = "meter-name", icon, name),
      div(class = paste("bar-meter", kind, extra_class),
          style = sprintf("--v:%.1f%%", 100 * max(0, min(1, share))), span()),
      span(class = paste("meter-val", kind), value))
}

# Friendly "nothing here yet" box.
empty_state <- function(title, text = NULL, icon = "∅") {
  div(class = "empty-state", div(class = "empty-icon", icon),
      div(class = "empty-title", title), if (!is.null(text)) p(text))
}

tier_badge <- function(tier) span(class = paste0("tier tier-", tier), tier)

hero_icon <- function(db, id, size = "") {
  img(class = paste("hero-icon", size), src = hero_img(db, id),
      alt = hero_name(db, id), title = hero_name(db, id), loading = "lazy")
}

item_icon <- function(db, key, size = "") {
  src <- item_img(db, key)
  if (is.na(src)) return(span(class = "pill", key))  # unknown item: show text
  img(class = paste("item-icon", size), src = src, alt = item_name(db, key),
      title = paste0(item_name(db, key), " (", item_cost(db, key), "g)"), loading = "lazy")
}

# Icon + caption + optional popularity percentage, used in the build rail.
item_chip <- function(db, key, caption = item_name(db, key), share = NULL) {
  div(class = "item-chip",
      item_icon(db, key),
      div(class = "cap", caption),
      if (!is.null(share)) div(class = "pct", pct(share, 0)))
}

# -----------------------------------------------------------------------------
# The Meta Map: every hero portrait is placed with CSS absolute positioning.
#   left   = pick rate  (popularity)    -> x axis
#   bottom = adjusted winrate (strength) -> y axis
# We rescale both to 0-100% of the box ourselves, which lets us use real images
# as "points" (hard to do in ggplot without extra packages).
# -----------------------------------------------------------------------------
meta_map <- function(board) {
  rescale <- function(v, pad = 0.08) {
    r <- range(v)
    if (diff(r) == 0) return(rep(50, length(v)))
    100 * (pad + (1 - 2 * pad) * (v - r[1]) / diff(r))
  }
  x <- rescale(board$pickrate)
  y <- rescale(board$wr_adj)

  # Axis tick labels at min / middle / max of each axis.
  wr_ticks <- seq(min(board$wr_adj), max(board$wr_adj), length.out = 3)
  pr_ticks <- seq(min(board$pickrate), max(board$pickrate), length.out = 3)

  pins <- lapply(seq_len(nrow(board)), function(i) {
    div(class = paste("pin", if (board$is_main[i]) "is-main"),
        style = sprintf("left:%.1f%%; bottom:%.1f%%;", x[i], y[i]),
        img(src = board$img[i], alt = board$name[i]),
        div(class = "tip", sprintf("%s · %s WR · %s picked",
                                   board$name[i], pct(board$wr_adj[i], 1), pct(board$pickrate[i], 1))))
  })

  div(class = "meta-map",
      span(class = "quad q-tl", "Hidden gems"), span(class = "quad q-tr", "Meta tyrants"),
      span(class = "quad q-bl", "Niche"),       span(class = "quad q-br", "Over-picked"),
      lapply(seq_along(wr_ticks), function(i)
        span(class = "tick", style = sprintf("left:-2.3rem; bottom:calc(%.0f%% - .4rem);", c(8, 50, 92)[i]),
             pct(wr_ticks[i], 1))),
      lapply(seq_along(pr_ticks), function(i)
        span(class = "tick", style = sprintf("bottom:-1.1rem; left:calc(%.0f%% - 1rem);", c(8, 50, 92)[i]),
             pct(pr_ticks[i], 0))),
      pins,
      div(class = "axis-x", "Pick rate →"),
      div(class = "axis-y", "Adjusted winrate →"))
}

# Small horizontal bar centred on 50% for winrates in tables.
wr_bar <- function(wr, lo = 0.44, hi = 0.56) {
  w <- max(0, min(1, (wr - lo) / (hi - lo)))
  col <- if (wr >= 0.5) "var(--radiant)" else "var(--dire)"
  div(class = "wr-bar", span(style = sprintf("width:%.0f%%; background:%s;", 100 * w, col)))
}

# Card header with a small grey hint text next to the title.
card_title <- function(title, hint = NULL) {
  bslib::card_header(title, if (!is.null(hint)) span(class = "hint", hint))
}
