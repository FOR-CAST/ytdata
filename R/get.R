#' Fetch a registered GeoYukon layer by key
#'
#' Look up `key` in the ytdata layer registry (see [yt_layers()]) and fetch it
#' with [yt_arcgis_fetch()].
#'
#' @param key A registry key; see [yt_layers()].
#' @inheritParams yt_arcgis_fetch
#'
#' @return An [sf::st_sf()] object in EPSG:4326.
#' @export
#' @examples
#' \dontrun{
#' yt_get("caribou_herd_ranges")
#' }
yt_get <- function(
  key,
  where = "1=1",
  bbox = NULL,
  bbox_crs = 4326,
  out_fields = "*",
  page_size = 1000L,
  quiet = FALSE
) {
  reg <- yt_registry()
  if (!key %in% names(reg)) {
    cli::cli_abort(c(
      "Unknown layer key {.val {key}}.",
      i = "See {.fun yt_layers} for the available keys."
    ))
  }
  e <- reg[[key]]
  yt_arcgis_fetch(
    e$service,
    e$layer,
    where = where,
    bbox = bbox,
    bbox_crs = bbox_crs,
    out_fields = out_fields,
    page_size = page_size,
    quiet = quiet
  )
}

#' Fetch Yukon caribou herd ranges
#'
#' Convenience wrapper around [yt_get()] for the GeoYukon "Caribou Herd Ranges"
#' layer, with optional filtering to specific herds.
#'
#' @param herds Optional character vector of herd names, matched against the
#'   `HERD` field. `NULL` (default) returns all herds.
#' @inheritParams yt_arcgis_fetch
#'
#' @return An [sf::st_sf()] object of caribou herd range polygons in EPSG:4326,
#'   with `HERD` (herd name) and `HERD_CLASS` (grouping) columns.
#' @export
#' @examples
#' \dontrun{
#' yt_get_caribou_herds()
#' yt_get_caribou_herds(herds = c("Aishihik", "Klaza"))
#' }
yt_get_caribou_herds <- function(herds = NULL, bbox = NULL, quiet = FALSE) {
  where <- "1=1"
  if (!is.null(herds)) {
    vals <- paste0("'", gsub("'", "''", herds), "'", collapse = ", ")
    where <- paste0("HERD IN (", vals, ")")
  }
  yt_get("caribou_herd_ranges", where = where, bbox = bbox, quiet = quiet)
}
