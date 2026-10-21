library(purrr)
library(here)
source(here("R", "read_kommune.R"))

files_k <- list.files(here("data-raw", "kommune"),
                      pattern = "^kommune_lulucf_\\d{4}-\\d{4}\\.xlsx$",
                      full.names = TRUE)

kommune <- map(files_k, read_kommune) |>
  list_rbind() |>
  left_join(get_kommune_names(), by = "kommunenr") |>
  mutate(kommune = if_else(kommunenr == "1507",
                           "Ålesund (incl. Haram, 2020-2023 boundaries)",
                           kommune))

# Should now be empty
kommune |> filter(is.na(kommune))

# Confirm the split municipalities are not also present (would double count)
kommune |> filter(kommunenr %in% c("1508", "1580"))

write.csv(kommune, here("data", "kommune_lulucf.csv"), row.names = FALSE)