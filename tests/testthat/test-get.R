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
