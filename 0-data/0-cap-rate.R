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
library("readxl")
library("rvest")
library("tidyverse")

# Create a directory for the data
local_dir    <- "0-data/cap_rate"
data_source  <- paste0(local_dir, "/raw")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(data_source)) dir.create(data_source, recursive = T)

cap_rate <- read_csv("0-data/cap_rate/capitalization_rate.csv") %>% 
  select(-contains("fed"))

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

chicago_rates <- paste0("https://www.chicagofed.org/~/",
                        "media/others/research/data/agconditions/",
                        "interest-rates-csv.csv")
fed_file   <- paste(data_source, basename(chicago_rates), sep = "/")
download.file(chicago_rates, fed_file)

chicago_rates <- read_csv(fed_file,
                       col_names = c("YYYYQ", "operating_loans",
                                     "feeder_loans", "real_estate_loans"),
                       skip = 2) %>% 
  mutate(date = as.Date(paste0(YYYYQ, "/01"), format = "%Y/%m/%d") - 1) %>% 
  mutate(month = lubridate::month(date),
         tax_year = lubridate::year(date),
         chicago_fed_re = real_estate_loans,
         chicago_fed_operating = operating_loans)

chicago_fed <- chicago_rates  %>% 
  filter(!is.na(date)) %>% 
  select(date, chicago_fed_re)


# Another suggestion, the Kansas City Fed also has interest rates for their
#  region in their ag finance data book:
# Small issue with how it is handled from a webpage download issue
# Maybe here: https://www.kansascityfed.org/research/indicatorsdata

kc_rates <- paste0("https://www.kansascityfed.org/~/media/files/publicat/",
                   "research/indicatorsdata/agcredit/latestdata/",
                   c("variableinterestrates_kc.xls",
                     "fixedinterestrates_kc.xls"))
fed_file   <- paste(data_source, basename(kc_rates), sep = "/")
set_config(config(ssl_verifypeer = 0L))
map2(kc_rates, fed_file, function(x, y) GET(x, write_disk(y, overwrite = T)))

# excel_sheets(fed_file[2])

kc_rates <- read_excel(fed_file[2], sheet = "Real Estate", skip = 5) %>% 
  fill(Year) %>% 
  mutate(quarter = case_when(Qtr. == 1 ~ "-03-31",
                             Qtr. == 2 ~ "-06-30",
                             Qtr. == 3 ~ "-09-30",
                             Qtr. == 4 ~ "-12-31"),
         date = as.Date(paste0(Year, quarter)))

kc_fed <- kc_rates %>% 
  filter(!is.na(date)) %>% 
  select(date, kansas_fed_re = District)

# Dallas Fed Agricultural Survey:
#  https://www.dallasfed.org/research/econdata/ag.aspx

dallas_rates <- paste0("https://www.dallasfed.org/-/media/Documents/",
                       "research/agsurvey/data/agrates.xlsx")
fed_file   <- paste(data_source, basename(dallas_rates), sep = "/")
download.file(dallas_rates, fed_file)

dallas_rates <- read_excel(fed_file, "fixed", skip = 3) %>% 
  mutate(year = str_sub(Date, 1, 4),
         Qtr = str_sub(Date, -2),
         quarter = case_when(Qtr == "Q1" ~ "-03-31",
                             Qtr == "Q2" ~ "-06-30",
                             Qtr == "Q3" ~ "-09-30",
                             Qtr == "Q4" ~ "-12-31"),
         date = as.Date(paste0(year, quarter)))

dallas_fed <- dallas_rates %>% 
  select(date, dallas_fed_re = "Long-term farm real estate")

suggestion <- dallas_fed %>% 
  full_join(kc_fed) %>% 
  full_join(chicago_fed) %>% 
  arrange(date) %>% 
  filter(lubridate::month(date) == 3) %>% 
  rename_at(vars(-date), ~paste0(., "_q1")) %>% 
  mutate_at(vars(-date), ~./100)

cap_rate <- suggestion %>% 
  mutate(tax_year = lubridate::year(date)) %>% 
  select(-date) %>% 
  # group_by(tax_year) %>% 
  # summarise_all(~mean(. / 100, na.rm = T)) %>% 
  left_join(cap_rate, .) 

write_csv(cap_rate, "0-data/cap_rate/capitalization_rate.csv")

# ---- ag-finance-databook ------------------------------------------------


# Kansas City Fed puts together the Ag Finance Databook:
#  https://www.kansascityfed.org/research/indicatorsdata/agfinancedatabook/past-issues

kc_credit <- paste0("https://www.kansascityfed.org/~/media/files/publicat/",
                     "research/indicatorsdata/agfinance/",
                    "2019_q2_afd_historical_data.xlsx")
fed_file   <- paste(data_source, basename(kc_credit), sep = "/")
set_config(config(ssl_verifypeer = 0L))
GET(kc_credit, write_disk(fed_file, overwrite = T))

# excel_sheets(fed_file)
# "afdr_c4"
j5 <- read_excel(fed_file, sheet = "afdr_c4")

j5 <- j5 %>% 
  select(Period, contains("real estate")) %>% 
  rename_all(~str_remove_all(., " \\-.*")) %>% 
  rename_all(~str_to_lower(str_remove_all(., '[[:punct:] ]+'))) %>% 
  mutate_at(vars(-period), ~as.numeric(.) / 100) %>%
  mutate(year = as.numeric(str_sub(period, 1, 4)),
         quarter = case_when(str_sub(period, 5, 6) == "Q1" ~ "-03-31",
                             str_sub(period, 5, 6) == "Q2" ~ "-06-30",
                             str_sub(period, 5, 6) == "Q3" ~ "-09-30",
                             str_sub(period, 5, 6) == "Q4" ~ "-12-31"),
         date = as.Date(paste0(year, quarter))) %>% 
  select(-period, -quarter) %>% 
  rename_at(vars(-year, -date), ~paste0(., "_fed_re"))

j5 <- cap_rate %>% 
  select(year = tax_year, cap_rate_odt,
         interest_rate_15_odt, interest_rate_25_odt, interest_rate_odt) %>% 
  # mutate_at(vars(-year), ~./100) %>% 
  right_join(j5)

write_csv(j5, "0-data/cap_rate/capitalization_rate_alt.csv")

#######
j5 %>% 
  select(-year, -cap_rate_odt, -interest_rate_25_odt,
         -interest_rate_15_odt, -interest_rate_odt) %>% 
  gather(var, val, -date) %>% 
  ggplot(aes(date, val, color = var, linetype = var)) +
  geom_line() +
  geom_line(data = select(j5, date, interest_rate_25_odt),
            aes(x = date, y = interest_rate_25_odt,
                linetype = NULL, color = NULL)) +
  scale_y_continuous(labels = scales::percent) +
  theme_minimal()
#######

j5 %>% 
  # rename_all(~paste0(., "_fed_re")) %>% 
  mutate(tax_year = year) %>% 
  group_by(tax_year) %>% 
  summarise_all(~mean(., na.rm = T)) %>% 
  View()
