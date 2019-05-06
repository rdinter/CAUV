# Capitalization rate information, mostly from USDA-ERS:
# https://data.ers.usda.gov/reports.aspx?ID=17838

# Can't really download this in any automated way, so a manual update to the
#  "capitalization_rate.csv" file in the cap_rate folder needs to be done.
#  The "Total rate of return on farm equity" entry is what is used for the
#  equity rate variable titled "equity_rate_usda"

# Keep in mind that the values used for capitalization rates may be jumbled!
#  For instance, the rollbacks used in the tax year 2019 formula would be based
#  on the value that ODT has for the tax year 2018! Please read the 
#  documentation for the capitalization rate


# ---- start --------------------------------------------------------------

library("httr")
library("rvest")
library("tidyverse")

# Create a directory for the data
local_dir    <- "0-data/cap_rate"
data_source  <- paste0(local_dir, "/raw")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(data_source)) dir.create(data_source, recursive = T)

cap_rate <- read_csv("0-data/cap_rate/capitalization_rate.csv")

# ---- automated ----------------------------------------------------------

# Go to url with the all of the current and archived data to scrape the links
ers_links <- paste0("https://www.ers.usda.gov/data-products/",
                    "farm-income-and-wealth-statistics/",
                    "data-files-us-and-state-level-farm-income-",
                    "and-wealth-statistics/") %>% 
  read_html() %>% 
  html_nodes("hr~ ul a:nth-child(1)") %>% 
  html_attr("href") %>% 
  paste0("https://www.ers.usda.gov", .)

# Remove any links that aren't the weathstatisticsdata
ers_links <- ers_links[grepl("wealthstatisticsdata", ers_links)]

# Download the most recent only if it hasn't already been downloaded
fil <- paste(data_source, basename(ers_links[1]), sep = "/")
if (!file.exists(fil)) download.file(ers_links[1], fil)

# Read in the most recent data file
ers <- read_csv(fil)

# Variable for total farm equity: "RTAUSPRRE--P"
ers_equity <- ers %>% 
  filter(artificialKey == "RTAUSPRRE--P") %>% 
  mutate(equity_rate_usda = Amount / 100) %>% 
  select(tax_year = Year, equity_rate_usda)

cap_rate <- cap_rate %>% 
  select(-equity_rate_usda) %>% 
  left_join(ers_equity)

# ---- suggestion ---------------------------------------------------------

# Suggestion for a different source of interest rates is from the Chicago Fed
#  AG Letter: https://www.chicagofed.org/research/data/ag-conditions/index
#  go to the interest rates charged on new farm loans table, download CSV

fed_credit <- paste0("https://www.chicagofed.org/~/",
                     "media/others/research/data/agconditions/",
                     "interest-rates-csv.csv")
fed_file   <- paste(data_source, basename(fed_credit), sep = "/")
download.file(fed_credit, fed_file)

fed_credit <- read_csv(fed_file,
                       col_names = c("YYYYQ", "operating_loans",
                                     "feeder_loans", "real_estate_loans"),
                       skip = 2) %>% 
  mutate(date = as.Date(paste0(YYYYQ, "/01"), format = "%Y/%m/%d"))

chicago_fed <- fed_credit %>% 
  mutate(month = lubridate::month(date),
         tax_year = lubridate::year(date),
         chicago_fed_re = real_estate_loans / 100,
         chicago_fed_operating = operating_loans / 100) %>% 
  filter(month == 1) %>% 
  select(tax_year, chicago_fed_re, chicago_fed_operating)

cap_rate %>% 
  left_join(chicago_fed) %>% 
  write_csv("0-data/cap_rate/capitalization_rate.csv")

# Another suggestion, the Kansas City Fed also has interest rates for their
#  region in their ag finance data book:
#  https://www.kansascityfed.org/research/indicatorsdata/agfinancedatabook

# Small issue with how it is handled from a webpage download issue
# Maybe here: https://www.kansascityfed.org/research/indicatorsdata


kc_credit <- paste0("https://www.kansascityfed.org/research/indicatorsdata/~/",
                     "media/a10e43ee52c945fe8d92ef16838b40bf.ashx")
fed_file   <- paste(data_source, basename(kc_credit), sep = "/")
download.file(kc_credit, fed_file)



