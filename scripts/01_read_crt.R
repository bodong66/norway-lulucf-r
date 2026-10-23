source(here::here("R", "read_table4.R"))

files <- list.files("data-raw", pattern = "^NOR-CRT.*\\.xlsx$",
                    full.names = TRUE, recursive = TRUE)

length(files)   # should be 35
lulucf <- map(files, read_table4) |> list_rbind()

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

source(here::here("R", "read_table4e.R"))

files <- list.files(here::here("data-raw"), pattern = "^NOR-CRT.*\\.xlsx$",
                    full.names = TRUE, recursive = TRUE)

settlements <- map(files, read_table4e) |> list_rbind()
write.csv(settlements, here::here("data", "lulucf_table4e_settlements.csv"), row.names = FALSE)


