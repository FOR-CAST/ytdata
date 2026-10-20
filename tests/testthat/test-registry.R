test_that("yt_layers returns the registry as a data frame", {
  x <- yt_layers()
  expect_s3_class(x, "data.frame")
  expect_named(x, c("key", "service", "layer", "title"))
  expect_true("caribou_herd_ranges" %in% x$key)
})

test_that("yt_layers() maps caribou_herd_ranges to GY_Biological layer 1", {
  x <- yt_layers()
  herds <- x[x$key == "caribou_herd_ranges", ]

  expect_equal(herds$service, "GY_Biological")
  expect_equal(herds$layer, 1L)
})
