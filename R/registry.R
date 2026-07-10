yt_registry <- function() {
  list(
    caribou_herd_ranges = list(
      service = "GY_Biological",
      layer = 1L,
      title = "Caribou Herd Ranges - 250k"
    )
  )
}

#' List the GeoYukon layers registered in ytdata
#'
#' @return A data frame with one row per registered layer and columns `key`,
#'   `service`, `layer`, and `title`.
#' @export
#' @examples
#' yt_layers()
yt_layers <- function() {
  reg <- yt_registry()
  data.frame(
    key = names(reg),
    service = vapply(reg, function(x) x$service, character(1)),
    layer = vapply(reg, function(x) as.integer(x$layer), integer(1)),
    title = vapply(reg, function(x) x$title, character(1)),
    row.names = NULL,
    stringsAsFactors = FALSE
  )
}
