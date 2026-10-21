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

change <- kommune |>
  select(kommunenr, kommune, period, co2eq_t) |>
  tidyr::pivot_wider(names_from = period, values_from = co2eq_t) |>
  mutate(change_t = `2016-2020` - `2011-2015`) |>
  arrange(desc(change_t))

head(change, 10)   # largest increase in net emissions (weaker sink)
tail(change, 10)   # largest improvement


kommune |>
  filter(period == "2016-2020") |>
  slice_max(co2eq_t, n = 15) |>
  ggplot(aes(co2eq_t / 1000, reorder(kommune, co2eq_t))) +
  geom_col(fill = "#B5476B") +
  labs(title = "Municipalities with the largest net LULUCF emissions, 2016-2020",
       x = "kt CO2-eq per year", y = NULL) +
  theme_minimal()


files_skog <- list.files(here("data-raw", "kommune"),
                         pattern = "^kommune_lulucf_skog_\\d{4}-\\d{4}\\.xlsx$",
                         full.names = TRUE)

skog <- map(files_skog, read_kommune) |>
  list_rbind() |>
  rename(skog_t = co2eq_t)

decomp <- kommune |>
  left_join(skog, by = c("kommunenr", "period")) |>
  mutate(skog_t  = coalesce(skog_t, 0),          # Træna and Røst have no forest
         other_t = co2eq_t - skog_t)

write.csv(decomp, here("data", "kommune_lulucf_decomp.csv"), row.names = FALSE)

# Change between periods, split into forest and other land
change_decomp <- decomp |>
  select(kommunenr, kommune, period, co2eq_t, skog_t) |>
  tidyr::pivot_wider(names_from = period, values_from = c(co2eq_t, skog_t)) |>
  mutate(total_change = `co2eq_t_2016-2020` - `co2eq_t_2011-2015`,
         skog_change  = `skog_t_2016-2020`  - `skog_t_2011-2015`,
         skog_share   = skog_change / total_change) |>
  arrange(desc(total_change))

head(change_decomp, 10)

# National share of change explained by forest
change_decomp |>
  summarise(total = sum(total_change), skog = sum(skog_change),
            share = skog / total)

change_decomp |>
  select(kommune, total_change, skog_change, skog_share) |>
  head(10)


change_decomp |>
  slice_max(total_change, n = 15) |>
  tidyr::pivot_longer(c(skog_change, total_change),
                      names_to = "part", values_to = "t") |>
  mutate(part = if_else(part == "skog_change", "Forest land", "All land")) |>
  ggplot(aes(t / 1000, reorder(kommune, t), fill = part)) +
  geom_col(position = "dodge") +
  labs(title = "Largest increases in net LULUCF emissions, 2011-2015 to 2016-2020",
       subtitle = "Forest land explains most of the change",
       x = "Change, kt CO2-eq per year", y = NULL, fill = NULL) +
  theme_minimal() +
  theme(legend.position = "bottom")