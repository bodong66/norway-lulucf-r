library(testthat)
library(dplyr)

kommune <- read.csv(here::here("data", "kommune_lulucf.csv"),
                    colClasses = c(kommunenr = "character"))

test_that("356 municipalities in each period", {
  counts <- kommune |> count(period)
  expect_equal(counts$n, c(356, 356))
})

test_that("national totals match the Miljødirektoratet dashboard", {
  totals <- kommune |> group_by(period) |> summarise(t = sum(co2eq_t))
  expect_equal(totals$t / 1e6, c(-19.77, -12.18), tolerance = 0.005)
})

test_that("all municipalities have a name", {
  expect_equal(sum(is.na(kommune$kommune)), 0)
})



decomp <- read.csv(here::here("data", "kommune_lulucf_decomp.csv"),
                   colClasses = c(kommunenr = "character"))

test_that("forest totals match the dashboard", {
  totals <- decomp |> group_by(period) |> summarise(t = sum(skog_t))
  expect_equal(totals$t / 1e6, c(-24.81, -18.34), tolerance = 0.005)
})

test_that("forest plus other land equals total", {
  expect_equal(decomp$skog_t + decomp$other_t, decomp$co2eq_t)
})