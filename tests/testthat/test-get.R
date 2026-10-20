test_that("yt_get errors on an unknown key", {
  expect_snapshot(yt_get("nope"), error = TRUE)
})

test_that("yt_get_caribou_herds builds a HERD where clause from `herds`", {
  local_mocked_bindings(
    yt_get = function(key, where = "1=1", ...) where
  )
  expect_equal(yt_get_caribou_herds(), "1=1")
  expect_equal(
    yt_get_caribou_herds(herds = c("Klaza", "O'Connor")),
    "HERD IN ('Klaza', 'O''Connor')"
  )
})

test_that("yt_get_caribou_herds() returns HERD and HERD_CLASS in EPSG:4326", {
  herd <- paste0(
    '{"type":"Feature","properties":{"HERD":"Klaza","HERD_CLASS":"A"},"geometry":',
    '{"type":"Polygon","coordinates":[[[-136,61],[-135,61],[-135,62],[-136,62],[-136,61]]]}}'
  )
  seen <- local_geojson_mock(\(n) geojson_response(herd))

  x <- yt_get_caribou_herds(quiet = TRUE)

  expect_match(seen$urls, "/GY_Biological/MapServer/1/query", fixed = TRUE)
  expect_s3_class(x, "sf")
  expect_equal(nrow(x), 1L)
  expect_named(x, c("HERD", "HERD_CLASS", "geometry"))
  expect_equal(x$HERD, "Klaza")
  expect_equal(x$HERD_CLASS, "A")
  expect_equal(sf::st_crs(x)$epsg, 4326L)
})
