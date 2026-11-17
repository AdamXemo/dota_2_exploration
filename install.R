# =============================================================================
# install.R — install every package the project needs (run once).
#     Rscript install.R
# Only installs what is missing, so it is safe to re-run.
# =============================================================================

packages <- c(
  "shiny",      # web app framework
  "bslib",      # Bootstrap 5 theming + layout (cards, navbar)
  "reactable",  # interactive tables
  "ggplot2",    # charts
  "dplyr",      # data wrangling (filter, mutate, arrange...)
  "jsonlite",   # read/write JSON + call the OpenDota API
  "htmltools",  # build HTML from R
  "markdown"    # render the knowledge notes inside the app
)

missing <- setdiff(packages, rownames(installed.packages()))
if (length(missing) > 0) {
  install.packages(missing, repos = "https://cloud.r-project.org")
} else {
  message("All packages already installed.")
}
