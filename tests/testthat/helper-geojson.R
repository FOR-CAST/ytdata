## Helpers for tests that mock GeoYukon (ArcGIS REST) responses with httr2, so that
## no test touches the network.

geojson_point <- function(id) {
  sprintf(
    '{"type":"Feature","properties":{"id":%d},"geometry":{"type":"Point","coordinates":[-136,61]}}',
    id
  )
}

geojson_response <- function(features = character()) {
  body <- sprintf(
    '{"type":"FeatureCollection","features":[%s]}',
    paste(features, collapse = ",")
  )
  httr2::response(
    status_code = 200L,
    headers = list("Content-Type" = "application/geo+json"),
    body = charToRaw(body)
  )
}

## Answer the n-th request with `respond(n)`, which must return an httr2 response (httr2
## sends the real request when a mock returns NULL). The default answers every request with
## a one-point FeatureCollection. The returned environment holds the URLs requested so far
## in `$urls`. More than 10 requests is an error, so that a paging regression fails a test
## instead of looping.
local_geojson_mock <- function(
  respond = \(n) geojson_response(geojson_point(1)),
  env = parent.frame()
) {
  seen <- new.env(parent = emptyenv())
  seen$urls <- character()
  httr2::local_mocked_responses(
    function(req) {
      seen$urls <- c(seen$urls, req$url)
      if (length(seen$urls) > 10L) {
        stop("runaway paging: more than 10 requests")
      }
      resp <- respond(length(seen$urls))
      if (!inherits(resp, "httr2_response")) {
        stop("the mock handler must return an httr2 response, not ", class(resp)[[1]])
      }
      resp
    },
    env = env
  )
  seen
}
