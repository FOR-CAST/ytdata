## Offline tests: requests are answered by mocked httr2 responses (see
## helper-geojson.R), so none of these tests touches the network.

test_that("yt_layer_url() builds GeoYukon MapServer layer URLs", {
  expect_equal(
    yt_layer_url("GY_Mining", 36),
    "https://mapservices.gov.yk.ca/arcgis/rest/services/GeoYukon/GY_Mining/MapServer/36"
  )

  urls <- yt_layer_url(c("GY_Mining", "GY_Biological"), c(36, 1))
  expect_length(urls, 2L)
  expect_equal(
    urls,
    c(
      "https://mapservices.gov.yk.ca/arcgis/rest/services/GeoYukon/GY_Mining/MapServer/36",
      "https://mapservices.gov.yk.ca/arcgis/rest/services/GeoYukon/GY_Biological/MapServer/1"
    )
  )

  ## as.integer() keeps a large id out of scientific notation
  expect_match(yt_layer_url("GY_Mining", 1e5), "/MapServer/100000$")
})

test_that("yt_layer_url() of zero-length input is character(0)", {
  expect_equal(yt_layer_url(character(0), integer(0)), character(0))
})

test_that("yt_arcgis_fetch() queries <GeoYukon base>/<service>/MapServer/<layer>/query", {
  seen <- local_geojson_mock()

  yt_arcgis_fetch("GY_Mining", 36, quiet = TRUE)

  expect_length(seen$urls, 1L)
  url <- httr2::url_parse(seen$urls)
  expect_equal(url$scheme, "https")
  expect_equal(url$hostname, "mapservices.gov.yk.ca")
  expect_equal(url$path, "/arcgis/rest/services/GeoYukon/GY_Mining/MapServer/36/query")
  expect_equal(
    url$query[c("where", "outFields", "returnGeometry", "f")],
    list(where = "1=1", outFields = "*", returnGeometry = "true", f = "geojson")
  )
})

test_that("a bbox is sent as an envelope in bbox_crs, in xmin, ymin, xmax, ymax order", {
  seen <- local_geojson_mock()

  yt_arcgis_fetch(
    "GY_Mining",
    36,
    bbox = c(xmin = -136, ymin = 61, xmax = -135, ymax = 62),
    quiet = TRUE
  )
  yt_arcgis_fetch(
    "GY_Mining",
    36,
    bbox = c(xmin = 1234567, ymin = 987654, xmax = 1334567, ymax = 1087654),
    bbox_crs = 3578,
    quiet = TRUE
  )

  expect_length(seen$urls, 2L)
  geographic <- httr2::url_parse(seen$urls[[1]])$query
  expect_equal(
    geographic[c("geometry", "geometryType", "inSR", "spatialRel")],
    list(
      geometry = "-136,61,-135,62",
      geometryType = "esriGeometryEnvelope",
      inSR = "4326",
      spatialRel = "esriSpatialRelIntersects"
    )
  )
  projected <- httr2::url_parse(seen$urls[[2]])$query
  expect_equal(projected$geometry, "1234567,987654,1334567,1087654")
  expect_equal(projected$inSR, "3578")
})

test_that("bbox values are sent in full, never in scientific notation", {
  seen <- local_geojson_mock()

  ## paste() would write 1e5 as "1e+05" and 1e-5 as "1e-05"
  yt_arcgis_fetch(
    "GY_Mining",
    36,
    bbox = c(xmin = 100000, ymin = 1e6, xmax = 200000.5, ymax = 1100000),
    bbox_crs = 3578,
    quiet = TRUE
  )
  yt_arcgis_fetch("GY_Mining", 36, bbox = c(-1e-5, 60, 0.25, 61), quiet = TRUE)

  expect_equal(
    httr2::url_parse(seen$urls[[1]])$query$geometry,
    "100000,1000000,200000.5,1100000"
  )
  expect_equal(httr2::url_parse(seen$urls[[2]])$query$geometry, "-0.00001,60,0.25,61")
})

test_that("a bbox without four values is an error", {
  httr2::local_mocked_responses(\(req) stop("unexpected request: ", req$url))

  expect_error(
    yt_arcgis_fetch("GY_Mining", 36, bbox = 1:3, quiet = TRUE),
    "4 values"
  )
})

test_that("no matching feature gives an empty sf in EPSG:4326", {
  local_geojson_mock(\(n) geojson_response())

  x <- yt_arcgis_fetch("GY_Mining", 36, quiet = TRUE)

  expect_s3_class(x, "sf")
  expect_equal(nrow(x), 0L)
  expect_equal(sf::st_crs(x)$epsg, 4326L)
})

test_that("results are paged until a short page and bound together", {
  sizes <- c(2L, 2L, 1L)
  seen <- local_geojson_mock(function(n) {
    if (n > length(sizes)) {
      stop("unexpected request ", n)
    }
    first <- sum(sizes[seq_len(n - 1L)])
    geojson_response(geojson_point(first + seq_len(sizes[[n]])))
  })

  x <- yt_arcgis_fetch("GY_Mining", 36, page_size = 2L, quiet = TRUE)

  expect_s3_class(x, "sf")
  expect_equal(nrow(x), 5L)
  expect_equal(x$id, 1:5)
  queries <- lapply(seen$urls, \(url) httr2::url_parse(url)$query)
  expect_equal(vapply(queries, \(q) q$resultOffset, character(1)), c("0", "2", "4"))
  expect_equal(vapply(queries, \(q) q$resultRecordCount, character(1)), rep("2", 3L))
})

test_that("a mock handler that returns no response errors instead of reaching the network", {
  local_geojson_mock(\(n) NULL)

  expect_error(
    yt_arcgis_fetch("GY_Mining", 36, quiet = TRUE),
    "must return an httr2 response"
  )
})
