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


## Key findings

Net removals from forest land peaked at 30.2 Mt CO2-eq in 2010 and fell to
19.1 Mt in 2024, a decline of 37%; comparing five-year averages, removals fell
from 26.4 Mt (2006–2010) to 15.3 Mt (2020–2024), a decline of 42%. NIBIO and
the Norwegian Environment Agency attribute the weaker sink mainly to increased
harvest, natural tree mortality, a growing share of mature and old forest with
lower uptake, less silviculture and a shrinking forest area. Cropland
(2.36 Mt CO2-eq in 2024) and settlements (1.29 Mt) are the main net emission
sources in the sector. Among land-use conversions, land converted to
settlements is the largest source (1.07 Mt CO2-eq in 2024); forest land
converted to settlements alone accounts for 0.94 Mt CO2, mainly through losses
of dead organic matter and living biomass.

Sources: UNFCCC CRT tables, Norway 2026 submission (own calculations);
[Miljødirektoratet (2024)](https://www.miljodirektoratet.no/aktuelt/nyheter/2024/oktober-2024/nye-tal-for-opptak-og-utslepp-fra-areal-i-kommunar);
[Søgaard (2024), NIBIO](https://www.skog.is/wp-content/uploads/2024/04/2024-04-20-Foredrag-fra-Norge.pdf).