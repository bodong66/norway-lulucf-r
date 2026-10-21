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

# Test on the 2024 file
t24 <- read_table4(f)
View(t24)

files <- list.files("data-raw", pattern = "^NOR-CRT.*\\.xlsx$",
                    full.names = TRUE, recursive = TRUE)

length(files)   # should be 35
lulucf <- map(files, read_table4) |> list_rbind()
View(lulucf)
# Quick checks
sort(unique(lulucf$year))   # 1990-2024, no gaps?
nrow(lulucf)

dir.create("data", showWarnings = FALSE)
write.csv(lulucf, "data/lulucf_table4_long.csv", row.names = FALSE)

totals <- lulucf |>
  filter(code == "4", gas == "total_co2eq") |>
  select(year, value_kt) |>
  arrange(year)

totals

library(ggplot2)
ggplot(totals, aes(year, value_kt / 1000)) +
  geom_line() +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(y = "Mt CO2-eq", title = "Norway LULUCF net emissions/removals")