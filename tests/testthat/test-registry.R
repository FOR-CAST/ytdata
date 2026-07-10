test_that("yt_layers returns the registry as a data frame", {
  x <- yt_layers()
  expect_s3_class(x, "data.frame")
  expect_named(x, c("key", "service", "layer", "title"))
  expect_true("caribou_herd_ranges" %in% x$key)
})
