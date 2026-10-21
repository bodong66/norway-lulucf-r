library(dplyr)
library(ggplot2)
library(here)

df <- read.csv(here("data", "lulucf_table4_long.csv"))

# Use total CO2-eq, convert kt to Mt
tot <- df |>
  filter(gas == "total_co2eq") |>
  mutate(value_mt = value_kt / 1000)

dir.create(here("output", "figures"), recursive = TRUE, showWarnings = FALSE)

forest <- tot |>
  filter(code %in% c("4.A", "4.A.1", "4.A.2"))

p1 <- ggplot(forest, aes(year, value_mt, colour = category)) +
  geom_line(linewidth = 1) +
  geom_hline(yintercept = 0, linetype = "dashed") +
  labs(title = "Forest land: net emissions/removals, 1990-2024",
       subtitle = "Negative values = net removals (carbon sink)",
       x = NULL, y = "Mt CO2-eq", colour = NULL) +
  theme_minimal() +
  theme(legend.position = "bottom") +
  guides(colour = guide_legend(nrow = 2))

library(stringr)

tot <- tot |>
  mutate(category = category |>
           str_remove("\\s*\\((\\d+|please specify)\\)$") |>   # drop "(5)", "(please specify)"
           str_remove("^[0-9A-Z.]+\\s"))                       # drop leading code, e.g. "4.A. "

p1
ggsave(here("output", "figures", "01_forest_sink.png"), p1,
       width = 8, height = 5, dpi = 300)

forest_total <- forest |>
  filter(code == "4.A") |>
  arrange(year) |>
  mutate(ma5 = as.numeric(stats::filter(value_mt, rep(1/5, 5), sides = 2)))  # 5-year moving average

# Year with the largest sink (most negative value)
peak <- forest_total |> slice_min(value_mt, n = 1)
last <- forest_total |> filter(year == 2024)

peak
last
(last$value_mt - peak$value_mt) / abs(peak$value_mt) * 100   # % decline from peak

converted <- tot |>
  filter(code %in% c("4.A.2", "4.B.2", "4.C.2", "4.D.2", "4.E.2", "4.F.2"))

p2 <- ggplot(converted, aes(year, value_mt)) +
  geom_col(fill = "grey40") +
  geom_hline(yintercept = 0) +
  facet_wrap(~ category, scales = "free_y") +
  labs(title = "Emissions/removals from land-use conversion",
       x = NULL, y = "Mt CO2-eq") +
  theme_minimal()

p2
ggsave(here("output", "figures", "02_land_conversion.png"), p2,
       width = 10, height = 6, dpi = 300)


by_cat <- tot |>
  filter(level == 1)   # 4.A, 4.B, ... 4.G

p3 <- ggplot(by_cat, aes(year, value_mt, fill = category)) +
  geom_col() +
  geom_hline(yintercept = 0) +
  labs(title = "LULUCF net emissions/removals by land-use category",
       x = NULL, y = "Mt CO2-eq", fill = NULL) +
  theme_minimal() +
  theme(legend.position = "right") +
  facet_wrap(~ category, scales = "free_y",
             labeller = label_wrap_gen(width = 25))

p3
ggsave(here("output", "figures", "03_by_category.png"), p3,
       width = 10, height = 6, dpi = 300)

forest_total |>
  filter(year %in% c(2006:2010, 2020:2024)) |>
  mutate(period = if_else(year <= 2010, "2006-2010", "2020-2024")) |>
  group_by(period) |>
  summarise(mean_mt = mean(value_mt))

# 2024 values by category (Mt CO2-eq)
tot |>
  filter(year == 2024, code %in% c("4.B", "4.E", "4.E.2")) |>
  select(code, category, value_mt)

# Forest land converted to settlements, 2024 (Mt CO2)
settlements |>
  filter(year == 2024, code == "4.E.2.a") |>
  mutate(co2_mt = co2_kt / 1000) |>
  select(code, area_kha, co2_mt)