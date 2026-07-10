test_that("yt_get_caribou_herds fetches herd polygons from GeoYukon", {
  skip_on_cran()
  skip_if_offline("mapservices.gov.yk.ca")

  x <- yt_get_caribou_herds(quiet = TRUE)
  expect_s3_class(x, "sf")
  expect_gt(nrow(x), 0L)
  expect_true("HERD" %in% names(x))
  expect_equal(sf::st_crs(x)$epsg, 4326L)
})
