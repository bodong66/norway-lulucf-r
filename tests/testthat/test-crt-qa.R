library(testthat)
source(here::here("R", "qa_functions.R"), local = TRUE)

df <- read.csv(here::here("data", "lulucf_table4_long.csv"))

test_that("all inventory years 1990-2024 are present", {
  expect_length(check_years(df), 0)
})

test_that("no duplicate category-year-gas rows", {
  expect_equal(nrow(check_duplicates(df)), 0)
})

test_that("subcategories sum to parent category", {
  expect_equal(nrow(check_hierarchy(df)), 0)
})

test_that("CO2 + CH4*28 + N2O*265 equals total CO2-eq", {
  expect_equal(nrow(check_gwp(df)), 0)
})

test_that("only valid notation keys are used", {
  expect_equal(nrow(check_notation_keys(df)), 0)
})

test_that("values have plausible magnitude (kt)", {
  expect_equal(nrow(check_magnitude(df)), 0)
})

source(here::here("R", "qa_functions.R"))
df <- read.csv(here::here("data", "lulucf_table4_long.csv"))

# How many parent-child comparisons were actually made?
df |>
  filter(level > 0) |>
  mutate(parent = parent_code(code)) |>
  distinct(parent) |>
  pull(parent)

bad <- df
bad$value_kt[bad$code == "4.A.1" & bad$year == 2024 & bad$gas == "co2_net"] <- 0

check_hierarchy(bad)   # should return rows for 4.A in 2024
check_gwp(bad)         # should return the 4.A.1 row for 2024

test_that("QA checks detect an injected error", {
  bad <- df
  bad$value_kt[bad$code == "4.A.1" & bad$year == 2024 & bad$gas == "co2_net"] <- 0
  expect_gt(nrow(check_hierarchy(bad)), 0)
  expect_gt(nrow(check_gwp(bad)), 0)
})


s4e <- read.csv(here::here("data", "lulucf_table4e_settlements.csv"))

test_that("carbon stock changes convert to reported CO2 (x -44/12)", {
  expect_equal(nrow(check_c_to_co2(s4e)), 0)
})