# Dota Carry Lab — Design System

> Cold, calm, practical. A stats tool made by someone who plays Dota, not a fantasy book.

| File | Role |
|---|---|
| `app/www/styles.css` | The only stylesheet. Tokens (CSS custom properties) at the top, then components. |
| `app/R/theme.R` | `codex_theme()` / `lab_theme()` (bslib Bootstrap 5 theme), `PAL`, `PAL_SERIES`, `theme_codex()` / `theme_lab()` (ggplot2). |
| `docs/design/preview.html` | Static page showing every token and component. Open it in a browser (file://). |

---

## 1. Principles

1. **Data first.** Numbers are the content. Use tabular mono digits, align them right in tables, and keep labels small so the values stand out.
2. **Cold, not dark-for-drama.** Blue-black graphite surfaces, cool off-white text, icy cyan + lilac accents. Nothing warm except the game art itself.
3. **Hairlines over boxes.** 1px borders (`--line`) separate content. Shadows stay low and soft. No bevels, clip-paths, scanlines or grain.
4. **One accent at a time.** Ice is the primary accent (links, active states, your mains). Lilac is the secondary one (methods, curated notes). Mint and rose mean good and bad, and nothing else.
5. **Viral-friendly formats.** Tier lists, ranked lists, deltas and "insight" callouts are first-class components. Make them screenshot-worthy.
6. **Calm motion.** 160ms ease, small lifts (−2px) on hover, no looping animation. `prefers-reduced-motion` turns transitions off.

---

## 2. Tokens

### 2.1 Colour

| Token | Hex | Use | Contrast on `--panel` |
|---|---|---|---|
| `--bg` | `#0b0e13` | Page background | n/a |
| `--bg-2` | `#0f131a` | Sunken wells (meta map, data labels) | n/a |
| `--panel` | `#121820` | Cards, tiles | n/a |
| `--panel-2` | `#18202a` | Inputs, hover, tooltips | n/a |
| `--panel-3` | `#1f2833` | Pressed / selected | n/a |
| `--line` | `#232c38` | Default 1px hairline, chart grid | n/a |
| `--line-strong` | `#2f3a48` | Input borders, icon rings | n/a |
| `--ink` | `#e6ebf2` | Primary text | **14.9 : 1** |
| `--ink-2` | `#b4bfcc` | Secondary strong text (notes) | **9.6 : 1** |
| `--muted` | `#8a96a8` | Labels, captions, axis text | **5.9 : 1** |
| `--faint` | `#5d6878` | Decorative only (index numbers, quadrant labels) | 3.2 : 1 (never body text) |
| `--ice` | `#8fd0f0` | **Primary accent** (`PAL$gold`, `.gold`) | 10.6 : 1 |
| `--lilac` | `#b4a7f5` | Secondary accent (`PAL$arcane`) | 8.3 : 1 |
| `--radiant` | `#5ed6b0` | Good / above average / up | 10.0 : 1 |
| `--dire` | `#f0788a` | Bad / below average / down | 6.6 : 1 |

Each accent has a `*-soft` variant (≈12% alpha) for tinted backgrounds: `--ice-soft`, `--lilac-soft`, `--radiant-soft`, `--dire-soft`.

**Legacy names.** `--gold` / `.gold` / `PAL$gold` now hold the ice accent. The R code keeps working without changes. In new code, write `--ice` / `.ice`.

### 2.2 Attribute colours

| Attribute | Token | Hex | R |
|---|---|---|---|
| Strength | `--attr-str` | `#f0788a` | `PAL$str` |
| Agility | `--attr-agi` | `#5ed6b0` | `PAL$agi` |
| Intelligence | `--attr-int` | `#7fb4ff` | `PAL$int` |
| Universal | `--attr-all` | `#b4a7f5` | `PAL$all` |

These are the in-game hues, cooled down. Use them only next to an attribute label (`.tag.str`, …), never as decoration.

### 2.3 Tier colours

| Tier | Token | Hex | Meaning |
|---|---|---|---|
| S | `--tier-s` | `#a8e1fa` (+ frost gradient) | Meta-defining |
| A | `--tier-a` | `#5ed6b0` | Strong |
| B | `--tier-b` | `#8ea6ff` | Solid |
| C | `--tier-c` | `#8a96a8` | Situational |
| D | `--tier-d` | `#f0788a` | Avoid |

The ramp runs from cold to neutral to rose, so S reads as "premium" without falling back on gold.

### 2.4 Chart series (categorical order)

Use this order for lines and groups. In R it is `PAL_SERIES`; in CSS it is `--series-1` … `--series-8`.

| # | Hex | Name |
|---|---|---|
| 1 | `#8fd0f0` | ice |
| 2 | `#b4a7f5` | lilac |
| 3 | `#5ed6b0` | mint |
| 4 | `#f0788a` | rose |
| 5 | `#8ea6ff` | periwinkle |
| 6 | `#c7d3e0` | steel |
| 7 | `#4fb8c9` | aqua |
| 8 | `#d59ee0` | mauve |

All eight reach at least 7 : 1 against `--panel`, so they also work as text labels on the lines.

### 2.5 Typography

| Role | Family | Why |
|---|---|---|
| UI / body | **Inter** 400–700 | Neutral and very legible at 11–13px. It is the face of the 2017–2021 product and stats-site era. |
| Display / big numbers | **Space Grotesk** 500–700 | A grotesk with slightly technical shapes. It feels cold and "lab", not fantasy. |
| Data / numbers | **JetBrains Mono** 400–600 | Tabular digits, so winrate columns line up. |

| Token | Size | Use |
|---|---|---|
| `--fs-3xl` | 44px | Homepage display title (`.section-title.display`) |
| `--fs-2xl` | 32px | Page / hero title (`.hero-banner .title`) |
| `--fs-xl` | 24px | Section titles, KPI values |
| `--fs-lg` | 18px | Sub-headings |
| `--fs-md` | 15px | Body (Bootstrap base) |
| `--fs-sm` | 13px | Secondary text, notes, tables |
| `--fs-xs` | 12px | Card headers, captions |
| `--fs-2xs` | 11px | Eyebrows / labels (UPPERCASE, `letter-spacing: .1em`) |

Rules:
- Uppercase is only for **labels** ≤ 12px: eyebrows, card headers and table headers. Titles use sentence case.
- Numbers use the `.num` class (mono + `tabular-nums`). KPI values use Space Grotesk with `tabular-nums`.

### 2.6 Spacing, radius, elevation

- Spacing follows a 4px grid: `--sp-1` 4 · `--sp-2` 8 · `--sp-3` 12 · `--sp-4` 16 · `--sp-5` 20 · `--sp-6` 24 · `--sp-8` 32 · `--sp-10` 40 · `--sp-12` 48.
- Radius: `--r-xs` 4 (icons, bars) · `--r-sm` 6 (badges, chips) · `--r-md` 8 (buttons, inputs) · `--r-lg` 12 (cards) · `--r-pill`.
- Elevation:
  - `--shadow-1` is for resting cards (a faint inset top highlight plus a tiny drop).
  - `--shadow-2` is for hover lifts.
  - `--shadow-3` is for popovers and tooltips.
  - `--ring` is the focus ring (ice, 2px).

---

## 3. Components

All class names are in `styles.css`. Snippets are plain HTML. In R, write the same thing with `htmltools` tags, for example `div(class = "stat-card", ...)`.

### 3.1 Existing app hooks (used by `app/R/*.R`, do not rename)

| Class | What it is now |
|---|---|
| `.navbar`, `.navbar-brand`, `.brand-sub`, `.nav-link`, `.chapter` | Frosted-glass top bar. The brand gets an ice→lilac square mark. `.brand-sub` is a mono pill. `.chapter` is a small mono index ("01"). |
| `.card`, `.card-header`, `.hint`, `.codex-panel` | Flat panel with a 12px radius and 1px hairline. The header is an uppercase 12px label, and `.hint` is a muted sentence next to it. |
| `.rune` (`.label/.value/.sub`, `img` in `.value`) | KPI tile, the legacy twin of `.stat-card`. |
| `.tier .tier-S … .tier-D` | 24px rounded-square badge with a dark letter on the tier colour. |
| `.main-flag` | Tiny ice "MAIN" tag. |
| `.hero-icon(.sm)`, `.item-icon(.sm)`, `.item-chip(.cap/.pct)` | Portraits and icons with a 4px radius and a 1px ring. |
| `.meta-map` (+ `.quad .q-* .axis-x .axis-y .tick .pin .pin.is-main .tip`) | Sunken scatter field with ice crosshair lines. Your mains get an ice glow ring. |
| `.rail .stage .stage-title` | Build timeline: a mint→ice→lilac hairline with dot markers. |
| `.core-step .min .name .why` | Timing chip (`~16'`), item, name and reason, separated by hairlines. |
| `.lore`, `.pill(.good/.bad)` | Long-form notes with ice bullet markers; outlined pill labels. |
| `.hero-banner .title .identity` | Hero page header. |
| `.draft-row .rank .bar .score`, `.wr-bar` | Ranked rows and thin winrate bars. |
| `.codex-grid`, `.item-card .item-head .name .item-stats .item-active .why` | Item cards. Stats are mint mono text; actives are lilac-ruled quotes. |
| `.muted .gold .good .bad .num .mono` | Utilities (`.gold` = ice accent). |
| `.rt-*` (reactable), `.form-control`, `.selectize-*`, `.btn-*` | Tables and inputs restyled to the cold palette. |

### 3.2 New components (for the homepage and future pages)

#### Section head: eyebrow + title + subtitle
```html
<header class="section-head">
  <div class="eyebrow"><span class="idx">01</span> Carry meta</div>
  <h2 class="section-title">Who carries patch 7.41</h2>
  <p class="section-sub">Adjusted winrate, Ancient–Divine.</p>
</header>
```
- Add `.display` to the title for the 44px homepage hero.
- `.row-head` puts actions (chips) on the right.
- `.frost-text` gives one word an ice→lilac gradient. Use it once per page at most.

#### Tier list
```html
<div class="tierlist">                     <!-- add .captions to always show names -->
  <div class="tierlist-row t-S">
    <div class="tierlist-label">S<small>4</small></div>
    <div class="tierlist-items">
      <a class="tierlist-hero is-main" href="?tab=hero&hero=42">
        <img src="https://cdn.cloudflare.steamstatic.com/apps/dota2/images/dota_react/heroes/skeleton_king.png" alt="Wraith King">
        <span class="tl-name">Wraith King</span><span class="tl-stat">53.3%</span>
      </a>
    </div>
  </div>
  <!-- .t-A, .t-B, .t-C, .t-D rows -->
</div>
```
- Hovering or focusing a portrait reveals the name and winrate over a scrim.
- `.is-main` adds an ice ring.
- An empty `.tierlist-items` shows "—".

#### Stat card / KPI with delta and sparkline
```html
<div class="stat-card accent">
  <div class="stat-label">Strongest carry <span class="tier tier-S">S</span></div>
  <div class="stat-value">53.32<span class="unit">%</span></div>
  <div class="stat-sub"><span class="delta-up">1.2 pp</span> vs last patch
    <span class="sparkline good"><svg viewBox="0 0 100 30" preserveAspectRatio="none">
      <polyline points="0,20 25,18 50,12 75,14 100,6"/></svg></span></div>
</div>
```
- `.accent` adds a faint ice tint. Use it for the single most important KPI.
- `.delta-up` / `.delta-down` / `.delta-flat` draw a mono value on a tinted chip with a ▲/▼ glyph.
- `.sparkline` sizes an inline SVG: stroke is `currentColor`, `.area` is a 12% fill, and the `.good` / `.bad` / `.lilac` / `.wide` modifiers change colour or width.

#### Hero tile
```html
<a class="hero-tile is-main" href="?tab=hero&hero=42">
  <div class="hero-tile-img"><img src="…/heroes/skeleton_king.png" alt="">
    <span class="tier tier-S">S</span><span class="tag ice">main</span></div>
  <div class="hero-tile-body">
    <div class="hero-tile-name">Wraith King</div>
    <div class="hero-tile-stats">
      <div class="hs"><span class="k">Winrate</span><span class="v good">53.3%</span></div>
      <div class="hs"><span class="k">Picked</span><span class="v">11.9%</span></div>
    </div>
  </div>
</a>
```
Lay hero tiles out with `.grid.grid-auto`.

#### Callout (insight box)
```html
<div class="callout">            <!-- .lilac (method) · .good (pick) · .bad (avoid) -->
  <span class="callout-icon">i</span>
  <div><span class="callout-title">Insight</span>Wraith King gains +3.0 pp from Herald to Divine.</div>
</div>
```

#### Chips, tags, data labels
```html
<button class="chip is-active">Ancient–Divine</button>     <!-- filter toggle; aria-pressed works too -->
<span class="tag good">Buff</span> <span class="tag str"><span class="dot"></span>Str</span>
<span class="data-label"><span class="k">WR</span>53.32%</span>  <!-- kbd-like mono label -->
```
- `.chip` is clickable and fully rounded.
- `.tag` is static: uppercase 11px with a 4px radius.
- `.data-label` shows a value with its unit or key.

#### Buttons
`.btn.btn-primary` (solid ice) · `.btn.btn-secondary` (graphite) · `.btn.btn-outline-primary` · `.btn.btn-ghost` · `.btn-sm`. In Shiny: `actionButton(id, "Open", class = "btn-primary")`.

#### Bar meter
```html
<div class="meter-row">
  <span class="meter-name"><img class="hero-icon sm" src="…">Wraith King</span>
  <div class="bar-meter good" style="--v:82%"><span></span></div>
  <span class="meter-val good">53.3%</span>
</div>
```
- Colour modifiers: `.good` / `.bad` / `.lilac`. Shape modifiers: `.thin` (3px) and `.center` (marks 50%).
- Set the fill with the `--v` custom property.

#### Rank list
`<ol class="rank-list"><li>…<span class="grow">Name</span>…</li></ol>` adds zero-padded numbers (01, 02…) automatically.

#### Empty state
```html
<div class="empty-state"><div class="empty-icon">∅</div>
  <div class="empty-title">No item matches</div><p>Try a broader search.</p></div>
```

#### Layout helpers
- Grids: `.grid` plus `.grid-2` / `.grid-3` / `.grid-4` / `.grid-auto` (minmax 220px). They collapse at 992px and 576px.
- Flex: `.stack` (vertical, 12px gap) and `.cluster` (wrapping row, 8px gap).
- Containers: `.section` (40px vertical margin), `.surface` (panel box without card chrome), `.lab-container` (max 1280px).

---

## 4. Charts

### ggplot2
```r
ggplot(df, aes(bracket, wr_adj, colour = name)) +
  geom_line(linewidth = 1) +
  scale_colour_manual(values = PAL_SERIES) +   # categorical order
  theme_codex()                                 # alias: theme_lab()
# and in the server:  renderPlot({...}, bg = "transparent")
```
- The background is transparent so the card colour shows through. Always pass `bg = "transparent"` to `renderPlot`.
- Use horizontal grid lines only, in the hairline colour. No axis ticks.
- Reference lines (50% winrate, 100% gold efficiency) are dashed `PAL$gold` (ice) at 0.4 linewidth.
- Good/bad bars use `PAL$radiant` / `PAL$dire`, or `PAL$radiant` against neutral `#3a4350` when only "good" matters.
- Label lines directly at their ends instead of using a legend (see `mod_meta.R`).
- Highlight bands (for example the Ancient–Divine range) use `PAL$gold` at `alpha = 0.06`.

### reactable
- Pass `theme = reactableTheme(backgroundColor = "transparent", color = PAL$ink, borderColor = PAL$line, highlightColor = "rgba(143,208,240,.045)")`. The CSS forces the same hover colour anyway.
- Use `compact = TRUE, highlight = TRUE`.
- Wrap numbers in `span(class = "num", …)`.
- Put tiers in `tier_badge()` and winrates in `wr_bar()`.
- Headers are automatically uppercase 11px muted text; the sorted column turns ice.

---

## 5. Do / Don't

| Do | Don't |
|---|---|
| Use ice for "you" / active / primary and lilac for method or curated notes | Use warm gold, orange or parchment tones |
| Use 1px `--line` hairlines and the 12px card radius | Use clip-path bevels, double borders or glowing outlines on every card |
| Use Space Grotesk for titles and big numbers, Inter for text | Use serif or fantasy display fonts (Cinzel etc.) |
| Use mono `tabular-nums` for every column of numbers | Use proportional digits in tables |
| Keep uppercase labels at 11–12px with 0.08–0.12em tracking | Set long titles in uppercase |
| Reserve mint/rose for good/bad and up/down | Use mint/rose as decoration |
| Lead with one tier list or KPI row per screen | Stack five equally loud panels |
| Use the faint top glow as the only background effect | Add scanlines, grain, noise or vignettes |

---

## 6. Accessibility

- Body text (`--ink`, `--ink-2`) is ≥ 9.6 : 1 and labels (`--muted`) are 5.9 : 1 on `--panel`. All exceed the 4.5 : 1 WCAG AA minimum.
- `--faint` (3.2 : 1) is only for decorative or redundant text, such as index numbers and quadrant labels.
- Accent and semantic text colours are all ≥ 6.6 : 1 on panels.
- Text on a solid accent background (`.btn-primary`, `.tier`, `.callout-icon`) uses `#0b0e13`, which gives ≥ 6 : 1.
- Good and bad are never shown by colour alone:
  - deltas carry a sign or a ▲/▼ glyph;
  - matchup values carry `+` / `−`;
  - tiers carry their letter.
- Focus is visible: `:focus-visible` shows a 2px ice ring, and tier-list portraits reveal their caption on focus.
- `prefers-reduced-motion: reduce` disables transitions.
- Responsive:
  - Below 768px the page uses 16px side gutters, grids collapse and the rail goes to 2 columns.
  - Below 576px tier-list portraits shrink to 64px.
  - Wide tables scroll inside their card, not the page.
