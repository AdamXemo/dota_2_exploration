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

# Rune-shaped KPI tile: label on top, big value, small sub-line.
rune <- function(label, value, sub = NULL) {
  div(class = "rune",
      div(class = "label", label),
      div(class = "value", value),
      if (!is.null(sub)) div(class = "sub", sub))
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
