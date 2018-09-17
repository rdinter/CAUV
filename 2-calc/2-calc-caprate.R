# Providing a calculation/projection of the Capitalization Rate in Ohio

# ---- start --------------------------------------------------------------

library("tidyverse")
library("zoo")

# Create a directory for the data
local_dir <- "2-calc"
cap       <- paste0(local_dir, "/cap")
if (!file.exists(local_dir)) dir.create(local_dir)
if (!file.exists(cap)) dir.create(cap)

j5 <- read_rds("1-tidy/cap/ohio_caprate.rds")

# Add on an additional year for Capitalization Rate:
cap_proj <- data_frame(year = max(j5$year) + 1, mortgage_pct_odt = 0.8,
                       mortgage_years_odt = 25, sinking_years_odt = 25) %>% 
  bind_rows(j5) %>% 
  arrange(year)

# For a tax year, Ohio will use state-wide production for the previous 5 to 1
#  years of official USDA data. For example, the 2019 tax year will use
#  production from 2014 to 2018.

debt_service <- function(r, n) (r*(1 + r)^n) / ((1 + r)^n - 1)
sinking_fund <- function(r, n) (r) / ((1 + r)^n - 1)


# ---- calc ---------------------------------------------------------------

# THIS IS WHERE I NEED TO FIGURE OUT THE DISCREPANCIES FROM 2013 -- 2016
# AND CREATE THE HIGH AND LOW

ohio <- cap_proj %>%
  mutate(tax_additur_cauv = tax_additur_odt) %>% 
  fill(tax_additur_cauv) %>% 
  mutate(equity_rate_cauv = ifelse(year > 2016,
                                   rollapplyr(lag(equity_rate_usda, 2),
                                              25, mean, na.rm = T, fill = NA),
                                   rollapplyr(equity_rate_bankrate, width = 7,
                                              FUN =  mean, trim = 1/7,
                                              na.rm = T, fill = NA)),
         interest_rate_cauv = ifelse(year > 2014,
                                     (rollapplyr(interest_rate_25_odt,
                                                 width = 7, FUN =  mean,
                                                 trim = 1/7, na.rm = T,
                                                 fill = NA)),
                                     (rollapplyr(interest_rate_15_odt,
                                                 width = 7, FUN =  mean,
                                                 trim = 1/7, na.rm = T,
                                                 fill = NA))),
         mortgage_equity_cauv = debt_service(interest_rate_cauv,
                                             mortgage_years_odt),
         cap_intermediate_cauv = (mortgage_pct_odt)*mortgage_equity_cauv +
           ((1 - mortgage_pct_odt))*equity_rate_cauv,
         cap_less_cauv = ifelse(year > 2016,
                                mortgage_pct_odt*
                                  sinking_fund(equity_rate_cauv,
                                               sinking_years_odt),
                                0.05*sinking_fund(equity_rate_cauv,
                                                  sinking_years_odt) +
                                  mortgage_pct_odt*(0.22)*
                                  sinking_fund(equity_rate_cauv,
                                               sinking_years_odt)),
         cap_rate_cauv = cap_intermediate_cauv - cap_less_cauv +
           tax_additur_cauv,
         # Projections of high and low, tax_additur_odt totally unknown so we
         #  will have the previous year's value and have a 0.1% margin. The
         #  only factor we can use Olympic average with is the 25-year interest
         #  rate. NOTE: high and low are backwards here because the cap_rate
         #  is in the denominator of the CAUV calculation
         interest_rate_cauv_h = (rollapplyr(interest_rate_25_odt, width = 7,
                                            FUN = sum, na.rm = T, fill = NA) - 
                                   rollapplyr(interest_rate_25_odt, width = 7,
                                              FUN = max, na.rm = T, fill = NA))/
           (6 - rollapplyr(interest_rate_25_odt, width = 7,
                           FUN = function(x) sum(is.na(x)), fill = NA)),
         interest_rate_cauv_l = (rollapplyr(interest_rate_25_odt, width = 7,
                                            FUN = sum, na.rm = T, fill = NA) - 
                                   rollapplyr(interest_rate_25_odt, width = 7,
                                              FUN = min, na.rm = T, fill = NA))/
           (6 - rollapplyr(interest_rate_25_odt, width = 7,
                           FUN = function(x) sum(is.na(x)), fill = NA)),
         mortgage_equity_cauv_h = debt_service(interest_rate_cauv_h,
                                               mortgage_years_odt),
         mortgage_equity_cauv_l = debt_service(interest_rate_cauv_l,
                                               mortgage_years_odt),
         cap_intermediate_cauv_h = (mortgage_pct_odt)*mortgage_equity_cauv_h +
           ((1 - mortgage_pct_odt))*equity_rate_cauv,
         cap_intermediate_cauv_l = (mortgage_pct_odt)*mortgage_equity_cauv_l +
           ((1 - mortgage_pct_odt))*equity_rate_cauv,
         cap_rate_cauv_h = cap_intermediate_cauv_h - cap_less_cauv +
           tax_additur_cauv - 0.001,
         cap_rate_cauv_l = cap_intermediate_cauv_l - cap_less_cauv +
           tax_additur_cauv + 0.001)

# HACK for cap rate
ohio$cap_rate_cauv_exp <- ohio$cap_rate_cauv



write.csv(ohio, paste0(cap, "/ohio_forecast_caprate.csv"),
          row.names = F)
write_rds(ohio, paste0(cap, "/ohio_forecast_caprate.rds"))

# ---- values -------------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  select("Year" = year, "ODT Value" = cap_rate_odt,
         "Expected" = cap_rate_cauv, "Maybe" = cap_rate_cauv_exp,
         "Low" = cap_rate_cauv_l, "High" = cap_rate_cauv_h) %>% 
  knitr::kable()

# ---- soy ----------------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  select("Year" = year, "ODT Value" = soy_rotate_odt,
         "USDA Acres Harvested" = soy_acres_harvest,
         "AVG Acres Harvested" = soy_harvest_cauv,
         "Projected" = soy_rotate_cauv) %>% 
  knitr::kable()

# ---- wheat --------------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  select("Year" = year, "ODT Value" = wheat_rotate_odt,
         "USDA Acres Harvested" = wheat_acres_harvest,
         "AVG Acres Harvested" = wheat_harvest_cauv,
         "Projected" = wheat_rotate_cauv) %>% 
  knitr::kable()
