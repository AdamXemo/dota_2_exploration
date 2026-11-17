# =============================================================================
# opendota.R — a tiny client for the OpenDota REST API.
#
# A REST API = a web server you talk to with plain URLs. You request
# "https://api.opendota.com/api/heroStats" and get JSON text back.
# jsonlite::fromJSON() downloads AND parses that JSON into R objects
# (lists / data frames), so we don't need any extra HTTP package.
# =============================================================================

#' Call one OpenDota endpoint and return the parsed JSON.
#'
#' @param endpoint  Path after /api, e.g. "heroStats" or "heroes/1/matchups".
#' @param query     Optional named list of URL parameters, e.g. list(limit = 20).
#' @param simplify  TRUE = turn JSON arrays into data frames where possible.
#' @param retries   How many times to retry if the request fails (rate limits).
od_get <- function(endpoint, query = list(), simplify = TRUE, retries = 4) {
  url <- paste0(OPENDOTA_API, "/", endpoint)

  # Build "?key=value&key2=value2" from the query list (if any).
  if (length(query) > 0) {
    params <- paste0(names(query), "=", unlist(query), collapse = "&")
    url <- paste0(url, "?", params)
  }

  # tryCatch() = "try this, and if it errors run the error handler instead of
  # crashing". We loop so a temporary failure gets a second (third) chance.
  for (attempt in seq_len(retries)) {
    result <- tryCatch(
      jsonlite::fromJSON(url, simplifyVector = simplify),
      error = function(e) e
    )
    if (!inherits(result, "error")) return(result)

    message("  ! request failed (", attempt, "/", retries, "): ", conditionMessage(result))
    # HTTP 429 = "Too Many Requests" (rate limit). Waiting is the only fix,
    # so we back off longer each attempt: 15s, 30s, 45s...
    Sys.sleep(15 * attempt)
  }
  stop("OpenDota request failed after ", retries, " attempts: ", url)
}

#' Turn an OpenDota image path into a full CDN url.
#' "/apps/dota2/images/.../bfury.png?t=123" -> "https://cdn.../bfury.png"
cdn_url <- function(path) {
  path <- sub("\\?.*$", "", path)  # drop the "?t=..." cache-buster
  paste0(STEAM_CDN, path)
}

#' Save any R object as pretty JSON (used by the fetch/build scripts).
write_json_pretty <- function(x, file) {
  dir.create(dirname(file), recursive = TRUE, showWarnings = FALSE)
  jsonlite::write_json(x, file, pretty = TRUE, auto_unbox = TRUE, na = "null")
}
