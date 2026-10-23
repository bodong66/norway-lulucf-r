library(readxl)
library(dplyr)
library(tidyr)
library(stringr)
library(purrr)

read_table4 <- function(path) {
  
  # Inventory year is stored in cell I1
  year <- read_excel(path, sheet = "Table4", range = "I1",
                     col_names = FALSE)[[1]] |>
    as.integer()
  
  # Data starts at B10; read columns B:I to the last row.
  # Read as text to keep notation keys (NO, NE, IE, NA).
  read_excel(path, sheet = "Table4",
             range = cell_limits(c(10, 2), c(NA, 9)),
             col_names = FALSE,
             col_types = "text") |>
    rename(category    = 1,
           co2_net     = 2,
           ch4         = 3,
           n2o         = 4,
           nox         = 5,
           co          = 6,
           nmvoc       = 7,
           total_co2eq = 8) |>
    mutate(category = str_squish(category)) |>
    # Keep category rows only (drop footnotes below the table)
    filter(str_detect(category, "^4\\.")) |>
    select(category, co2_net, ch4, n2o, total_co2eq) |>
    mutate(
      code  = str_extract(category, "^4(\\.[A-Z0-9]+)*"),  # e.g. "4.A.1"
      level = str_count(code, "\\."),                        # 4 = 0, 4.A = 1, 4.A.1 = 2
      year  = year
    ) |>
    pivot_longer(c(co2_net, ch4, n2o, total_co2eq),
                 names_to = "gas", values_to = "raw_value") |>
    mutate(
      value_kt     = suppressWarnings(as.numeric(raw_value)),
      notation_key = if_else(is.na(value_kt), raw_value, NA)  # keep NO/NE/IE flags
    )
}


