# norway-lulucf-r
Reproducible R workflow for Norway's LULUCF greenhouse gas emissions and removals (UNFCCC CRT, SSB, municipal accounts)

## Quality assurance

Automated checks (`tests/testthat/test-crt-qa.R`) run on all inventory years 1990–2024:

- All years present, no duplicate rows
- Subcategories sum to parent categories (tolerance 0.5 kt)
- CO2 + CH4 × 28 + N2O × 265 = total CO2-eq (AR5 GWPs)
- Only valid notation keys (NO, NE, IE, NA, C)
- Plausible magnitudes (catches unit errors)
- A control test injects an error to confirm the checks detect it

Run with `testthat::test_dir("tests/testthat")`.