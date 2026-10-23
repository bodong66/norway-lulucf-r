# norway-lulucf-r

Reproducible R workflow for Norway's greenhouse gas emissions and removals from
land use, land-use change and forestry (LULUCF), based on the UNFCCC Common
Reporting Tables (CRT) and the municipal LULUCF accounts.

The project reads Norway's 2026 inventory submission (inventory years
1990–2024), checks the data with automated tests, reproduces parts of the
IPCC calculation chain, and analyses trends nationally and by municipality.

This is a self-initiated learning project. It is not an official product of
NIBIO, the Norwegian Environment Agency (Miljødirektoratet) or Statistics
Norway (SSB), and the results should not be used as official statistics.

## Data sources

| Data | Source | Used for |
|---|---|---|
| CRT tables, Norway 2026 submission (inventory years 1990–2024) | [UNFCCC](https://unfccc.int/documents/656068) | Table 4 (LULUCF summary) and Table 4.E (settlements) |
| National Inventory Document (NID) 2026 | [UNFCCC](https://unfccc.int/documents/656064) | Methods and checking national totals |
| Municipal LULUCF accounts, periods 2011–2015 and 2016–2020 | [Miljødirektoratet](https://www.miljodirektoratet.no/tjenester/klimagassutslipp-arealbruk-kommuner/) (prepared by NIBIO) | Municipal emissions and removals |
| Municipality names (classification 131, 2024 version) | [SSB Klass API](https://data.ssb.no/api/klass/v1/classifications/131) | Names for municipality numbers |

Raw data files are not stored in this repository (see `data-raw/` below).
Processed data are stored as CSV files in `data/`.

## Repository structure

```
R/                    Functions: data readers and QA checks
  read_table4e.R      Read CRT Table 4.E (settlements)
  read_kommune.R      Read municipal accounts, get names from SSB
  qa_functions.R      All quality checks
scripts/              Run in order
  01_read_crt.R       Read CRT Table 4 and 4.E -> data/
  02_qa.R             Run QA checks -> output/
  03_trends.R         National trends and figures -> output/figures/
  04_kommune.R        Municipal accounts and decomposition -> data/
tests/testthat/       Automated tests
data/                 Processed data (CSV)
output/figures/       Figures
report.qmd            Quarto report
renv.lock             Locked package versions
```

## How to reproduce

**1. Install packages.** The project uses [renv](https://rstudio.github.io/renv/).
Open the project in RStudio and run:

```r
renv::restore()
```

**2. Download the CRT tables.** Download the zip file "Norway. 2026 Common
Reporting Table (CRT)" from [UNFCCC](https://unfccc.int/documents/656068) and
unzip it into `data-raw/`. The files are named
`NOR-CRT-2026-V1.0-<year>-....xlsx`, one file per inventory year (35 files).

**3. Export the municipal accounts.** The municipal accounts are published as
a Power BI dashboard without a download button. The data were exported
manually from the page "Netto utslipp og opptak", using "Export data" on the
map, with all counties selected:

| File in `data-raw/kommune/` | Filter |
|---|---|
| `kommune_lulucf_2011-2015.xlsx` | Period 2011–2015 |
| `kommune_lulucf_2016-2020.xlsx` | Period 2016–2020 |
| `kommune_lulucf_skog_2011-2015.xlsx` | Period 2011–2015, land-use category "1) Skog" |
| `kommune_lulucf_skog_2016-2020.xlsx` | Period 2016–2020, land-use category "1) Skog" |

The dashboard's default filter excludes "6) Annen utmark".

**4. Run the scripts in order:**

```r
source("scripts/01_read_crt.R")
source("scripts/02_qa.R")
source("scripts/03_trends.R")
source("scripts/04_kommune.R")
```

**5. Run the tests and render the report:**

```r
testthat::test_dir("tests/testthat")
quarto::quarto_render("report.qmd")   # or click Render in RStudio
```

Steps 4 and 5 can also be run on the processed CSV files in `data/` without
downloading the raw data: the tests and the report only read from `data/`.

## Quality assurance

Automated checks in `tests/testthat/`:

**CRT tables (`test-crt-qa.R`)**

- All inventory years 1990–2024 are present, with no duplicate rows
- Subcategories sum to their parent category (tolerance 0.5 kt)
- CO2 + CH4 × 28 + N2O × 265 equals the reported CO2-eq total (AR5 GWPs)
- Only valid notation keys are used (NO, NE, IE, NA, C)
- Values have plausible magnitudes (catches unit errors)
- Table 4.E: carbon stock changes × −44/12 equal the reported net CO2
- A control test injects an error to confirm that the checks detect it

**Municipal accounts (`test-kommune-qa.R`)**

- 356 municipalities in each period, all with a name
- National totals match the dashboard (−19.77 Mt CO2-eq in 2011–2015 and
  −12.18 Mt in 2016–2020; forest land −24.81 and −18.34 Mt)
- Forest land plus other land equals the municipal total

## Key findings

**National inventory.** Net removals from forest land peaked at 30.2 Mt
CO2-eq in 2010 and fell to 19.1 Mt in 2024, a decline of 37%. Comparing
five-year averages, removals fell from 26.4 Mt (2006–2010) to 15.3 Mt
(2020–2024), a decline of 42%. NIBIO and the Norwegian Environment Agency
attribute the weaker sink mainly to increased harvest, natural tree mortality,
a growing share of mature and old forest with lower uptake, less silviculture
and a shrinking forest area.

Cropland (2.36 Mt CO2-eq in 2024) and settlements (1.29 Mt) are the main net
emission sources in the sector. Among land-use conversions, land converted to
settlements is the largest source (1.07 Mt CO2-eq in 2024); forest land
converted to settlements alone accounts for 0.94 Mt CO2, mainly through losses
of dead organic matter and living biomass.

**Municipal accounts.** Between 2011–2015 and 2016–2020, net emissions in the
municipal accounts increased by 7.6 Mt CO2-eq per year, and forest land
accounts for 85% of this change. The largest increases are in forest-rich
municipalities in south-eastern Norway (e.g. Aurskog-Høland, Nes, Ringerike,
Indre Østfold), several of which changed from net removals to net emissions.
Forest land also explains nearly all of the large changes in Kautokeino and
Karasjok in Finnmark; the drivers there are not yet clear.

Sources: UNFCCC CRT tables, Norway 2026 submission, and municipal accounts
from Miljødirektoratet (own calculations);
[Miljødirektoratet (2024)](https://www.miljodirektoratet.no/aktuelt/nyheter/2024/oktober-2024/nye-tal-for-opptak-og-utslepp-fra-areal-i-kommunar);
[Søgaard (2024), NIBIO](https://www.skog.is/wp-content/uploads/2024/04/2024-04-20-Foredrag-fra-Norge.pdf).

## Notes and limitations

- **Municipal boundaries.** The municipal accounts use 2024 municipality
  numbers, except 1507 Ålesund, which covers the 2020–2023 municipality
  (today's 1508 Ålesund and 1580 Haram). Names are taken from SSB's
  classification 131 (2024 version); 1507 is labelled manually.
- **Municipalities without forest.** Træna (1835) and Røst (1856) have no
  forest land; their forest values are set to 0.
- **Different methods.** The municipal accounts use five-year periods and a
  different method from the national inventory, and they exclude
  "Annen utmark". Municipal totals are therefore not expected to add up to the
  CRT totals.
- **Uncertainty.** The Norwegian Environment Agency notes that municipal
  estimates of land-use change and the related emissions are uncertain.

## Author

Bo Dong. Licensed under the MIT License.
