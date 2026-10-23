library(readxl)
library(dplyr)
library(stringr)

read_table4e <- function(path) {
  
  # Inventory year from Table4, cell I1 (same as module 1)
  year <- read_excel(path, sheet = "Table4", range = "I1",
                     col_names = FALSE)[[1]] |>
    as.integer()
  
  raw <- read_excel(path, sheet = "Table4.E",
                    col_names = FALSE, col_types = "text")
  
  raw |>
    select(category = 1, area_kha = 3,
           lb_gains_ktc = 12, lb_losses_ktc = 13, lb_net_ktc = 14,
           dom_net_ktc = 15, min_soil_ktc = 16, org_soil_ktc = 17,
           co2_kt = 18) |>
    mutate(category = str_squish(category)) |>
    # Keep category rows; drops "Norway" subdivision rows and headers
    filter(str_detect(category, "^4\\.E\\.")) |>
    mutate(
      code = str_extract(category, "^4\\.E(\\.[0-9a-z]+)*"),   # e.g. "4.E.2.a"
      across(area_kha:co2_kt, ~ suppressWarnings(as.numeric(.x))),
      year = year
    )
}

