source(here::here("R", "qa_functions.R"))
df <- read.csv(here::here("data", "lulucf_table4_long.csv"))

dir.create("output", showWarnings = FALSE)
write.csv(check_hierarchy(df), "output/qa_hierarchy.csv", row.names = FALSE)
write.csv(check_gwp(df),       "output/qa_gwp.csv",       row.names = FALSE)

testthat::test_dir("tests/testthat")