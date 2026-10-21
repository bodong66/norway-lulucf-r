library(dplyr)
library(tidyr)
library(stringr)

# Parent code: "4.A.1" -> "4.A", "4.A" -> "4"
parent_code <- function(code) {
  str_remove(code, "\\.[A-Z0-9]+$")
}

# 1. Missing years
check_years <- function(df, expected = 1990:2024) {
  setdiff(expected, unique(df$year))
}

# 2. Duplicate rows (same category, year, gas)
check_duplicates <- function(df) {
  df |>
    count(code, year, gas) |>
    filter(n > 1)
}

# 3. Sum of subcategories equals parent category
#    Notation keys (NO, NE, IE) are treated as 0 in the sum.
check_hierarchy <- function(df, tol = 0.5) {
  children <- df |>
    filter(level > 0) |>
    mutate(parent = parent_code(code)) |>
    group_by(parent, year, gas) |>
    summarise(children_sum = sum(value_kt, na.rm = TRUE), .groups = "drop")
  
  parents <- df |>
    select(parent = code, year, gas, parent_value = value_kt)
  
  children |>
    inner_join(parents, by = c("parent", "year", "gas")) |>
    mutate(diff = children_sum - coalesce(parent_value, 0)) |>
    filter(abs(diff) > tol)
}

# 4. GWP consistency: CO2 + CH4*28 + N2O*265 = total CO2-eq (AR5)
check_gwp <- function(df, gwp_ch4 = 28, gwp_n2o = 265, tol = 0.5) {
  df |>
    select(code, year, gas, value_kt) |>
    pivot_wider(names_from = gas, values_from = value_kt) |>
    mutate(
      calc = coalesce(co2_net, 0) + coalesce(ch4, 0) * gwp_ch4 +
        coalesce(n2o, 0) * gwp_n2o,
      diff = calc - total_co2eq
    ) |>
    filter(abs(diff) > tol)
}

# 5. Only valid notation keys
check_notation_keys <- function(df) {
  valid <- c("NO", "NE", "IE", "NA", "C")
  df |>
    filter(!is.na(notation_key)) |>
    mutate(keys = str_split(notation_key, ",")) |>
    filter(!map_lgl(keys, ~ all(str_trim(.x) %in% valid)))
}

# 6. Plausible magnitude (catches unit errors, e.g. t instead of kt)
check_magnitude <- function(df, max_abs_kt = 1e5) {
  df |>
    filter(abs(value_kt) > max_abs_kt)
}