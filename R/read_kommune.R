library(readxl)
library(dplyr)
library(stringr)

read_kommune <- function(path) {
  read_excel(path, skip = 2, col_types = c("text", "numeric")) |>
    rename(kommunenr = 1, co2eq_t = 2) |>
    filter(!is.na(kommunenr)) |>
    mutate(
      kommunenr = str_pad(kommunenr, 4, pad = "0"),   # keep leading zero, e.g. "0301"
      period    = str_extract(basename(path), "\\d{4}-\\d{4}")
    )
}

library(httr2)

get_kommune_names <- function(date = "2024-01-01") {
  request("https://data.ssb.no/api/klass/v1/classifications/131/codesAt") |>
    req_url_query(date = date) |>
    req_headers(Accept = "application/json") |>
    req_perform() |>
    resp_body_json(simplifyVector = TRUE) |>
    _$codes |>
    select(kommunenr = code, kommune = name)
}