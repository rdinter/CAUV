# Robert Dinterman
# Automated projections.


# ---- data ---------------------------------------------------------------

# Manually update the following files:
# - 0-data/odt/odt_values_used.csv
# - 0-data/cap_rate/capitalization_rate.csv
# - 0-data/osu_budget/osu_budgets - R.csv

# These commands will automate the downloading of NASS and ODT related data
source("0-data/0-ohio-cauv.R")
source("0-data/0-ohio-nass.R")
source("0-data/0-ohio-taxation.R")


# ---- tidy ---------------------------------------------------------------

# Automatically organizes the raw data into a consistent format
source("1-tidy/1-tidy-cauv.R")



# ---- calc ---------------------------------------------------------------

# Automatically calculate projected values for each component of CAUV
source("2-calc/2-calc-caprate.R")
source("2-calc/2-calc-nonland.R")
source("2-calc/2-calc-prices.R")
source("2-calc/2-calc-rot.R")
source("2-calc/2-calc-yields.R")


# ---- proj ---------------------------------------------------------------

source("3-proj/3-projection-2019.R")
