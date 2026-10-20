geoyukon_base <- "https://mapservices.gov.yk.ca/arcgis/rest/services/GeoYukon"

#' Build the URL of a GeoYukon `MapServer` layer
#'
#' Return the REST endpoint of a layer of a GeoYukon `MapServer` service,
#' `<GeoYukon base>/<service>/MapServer/<layer>`. [yt_arcgis_fetch()] queries
#' this endpoint (at `/query`); use `yt_layer_url()` to refer to the same layer
#' without copying the GeoYukon base URL.
#'
#' @inheritParams yt_arcgis_fetch
#'
#' @return A character vector of layer URLs, vectorised over `service` and
#'   `layer`. `layer` is converted with [as.integer()].
#' @export
#' @examples
#' yt_layer_url("GY_Biological", 1)
#' yt_layer_url("GY_Biological", 0:2)
yt_layer_url <- function(service, layer) {
  paste0(geoyukon_base, "/", service, "/MapServer/", as.integer(layer))
}

#' Fetch a GeoYukon ArcGIS REST layer as an `sf` object
#'
#' Query one layer of a GeoYukon `MapServer` service and return its features as
#' an [sf::st_sf()] object. Features are requested as GeoJSON (so coordinates are
#' returned in WGS84, EPSG:4326) with optional server-side attribute and
#' bounding-box filtering, and are paged transparently past the service record
#' limit.
#'
#' @param service GeoYukon `MapServer` service name, e.g. `"GY_Biological"`.
#' @param layer Integer layer id within `service`.
#' @param where SQL `where` clause for attribute filtering. Defaults to `"1=1"`
#'   (all features).
#' @param bbox Optional bounding box for a server-side spatial filter, as an
#'   [sf::st_bbox()] object or a length-4 numeric `c(xmin, ymin, xmax, ymax)`.
#' @param bbox_crs CRS of `bbox`, passed to the service as the input spatial
#'   reference. Defaults to `4326`.
#' @param out_fields Character vector (or comma-separated string) of fields to
#'   return. Defaults to `"*"` (all fields).
#' @param page_size Maximum number of records requested per page. Defaults to
#'   `1000`.
#' @param quiet If `FALSE` (default), report progress with the cli package.
#'
#' @return An [sf::st_sf()] object in EPSG:4326. Reproject with
#'   [sf::st_transform()] as needed.
#' @export
#' @examples
#' \dontrun{
#' yt_arcgis_fetch("GY_Biological", 1)
#' }
yt_arcgis_fetch <- function(
  service,
  layer,
  where = "1=1",
  bbox = NULL,
  bbox_crs = 4326,
  out_fields = "*",
  page_size = 1000L,
  quiet = FALSE
) {
  url <- paste0(yt_layer_url(service, layer), "/query")
  out_fields <- paste(out_fields, collapse = ",")

  query <- list(
    where = where,
    outFields = out_fields,
    returnGeometry = "true",
    f = "geojson"
  )
  if (!is.null(bbox)) {
    bb <- as.numeric(bbox)
    if (length(bb) != 4L) {
      cli::cli_abort("{.arg bbox} must have 4 values: xmin, ymin, xmax, ymax.")
    }
    query$geometry <- paste(bb, collapse = ",")
    query$geometryType <- "esriGeometryEnvelope"
    query$inSR <- as.character(bbox_crs)
    query$spatialRel <- "esriSpatialRelIntersects"
  }

  pages <- list()
  offset <- 0L
  repeat {
    q <- c(query, list(resultOffset = offset, resultRecordCount = page_size))
    body <- httr2::request(url) |>
      httr2::req_url_query(!!!q) |>
      httr2::req_user_agent("ytdata (https://github.com/FOR-CAST/ytdata)") |>
      httr2::req_retry(max_tries = 3L) |>
      httr2::req_perform() |>
      httr2::resp_body_string()

    page <- sf::st_read(body, quiet = TRUE, stringsAsFactors = FALSE)
    if (!quiet) {
      cli::cli_alert_info("Fetched {nrow(page)} feature{?s} (offset {offset}).")
    }
    if (nrow(page) == 0L) {
      break
    }
    pages[[length(pages) + 1L]] <- page
    if (nrow(page) < page_size) {
      break
    }
    offset <- offset + page_size
  }

  if (length(pages) == 0L) {
    return(sf::st_sf(geometry = sf::st_sfc(crs = 4326)))
  }
  do.call(rbind, pages)
}
