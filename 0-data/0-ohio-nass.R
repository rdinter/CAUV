# NASS API for their Quickstats web interface:
# https://quickstats.nass.usda.gov/

# devtools::install_github("rdinter/usdarnass")
library("usdarnass")
library("tidyverse")
# nass_set_key("YOUR API HERE")

# Create a directory for the data
local_dir    <- "0-data/ohio"
data_source <- paste0(local_dir, "/raw")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(data_source)) dir.create(data_source, recursive = T)


# ---- prices -------------------------------------------------------------

prices <- map(c("CORN", "HAY", "SOYBEANS", "WHEAT"), function(x){
  nass_data(commodity_desc = x, statisticcat_desc = "PRICE RECEIVED",
            state_name = "OHIO", numeric_vals = T)})

from_price <- c("CORN, GRAIN - PRICE RECEIVED, MEASURED IN $ / BU",
                "HAY, ALFALFA - PRICE RECEIVED, MEASURED IN $ / TON",
                "HAY, (EXCL ALFALFA) - PRICE RECEIVED, MEASURED IN $ / TON",
                "HAY - PRICE RECEIVED, MEASURED IN $ / TON",
                "SOYBEANS - PRICE RECEIVED, MEASURED IN $ / BU",
                "WHEAT - PRICE RECEIVED, MEASURED IN $ / BU",
                "WHEAT, WINTER - PRICE RECEIVED, MEASURED IN $ / BU")
to_price <- c("corn_price", "hay_alfa_price", "hay_nonalfa_price", "hay_price",
              "soy_price", "wheat_price", "wheat_winter_price")

prices_data <- prices %>% 
  bind_rows() %>% 
  rename(time = reference_period_desc) %>% 
  mutate(year = as.numeric(year),
         time = case_when(.$time == "JAN" ~ 1, .$time == "FEB" ~ 2,
                          .$time == "MAR" ~ 3, .$time == "APR" ~ 4,
                          .$time == "MAY" ~ 5, .$time == "JUN" ~ 6,
                          .$time == "JUL" ~ 7, .$time == "AUG" ~ 8,
                          .$time == "SEP" ~ 9, .$time == "OCT" ~ 10,
                          .$time == "NOV" ~ 11, .$time == "DEC" ~ 12,
                          TRUE ~ 13),
         short_desc = factor(short_desc,
                             levels = from_price, labels = to_price),
         date = as.Date(paste0(year, "-", time, "-1"),
                        format = "%Y-%m-%d")) %>% 
  select(year, val = Value, short_desc, time, date) %>% 
  spread(short_desc, val)

monthly <- prices_data %>% 
  filter(time != 13) %>% 
  select(-time)
annual  <- prices_data %>% 
  filter(time == 13) %>% 
  select(-date, -time)

# Add in a blank holder for next year's prices
annual <- data.frame(year = max(annual$year) + 1) %>% 
  bind_rows(annual) %>% 
  arrange(year)

# Sales
sales <- map(c("CORN", "HAY", "SOYBEANS", "WHEAT"), function(x){
  nass_data(commodity_desc = x, statisticcat_desc = "SALES",
            freq_desc = "MONTHLY", state_name = "OHIO",
            numeric_vals = T)})

from_sales <- c("CORN, GRAIN - SALES, MEASURED IN PCT OF MKTG YEAR",
                "HAY - SALES, MEASURED IN PCT OF MKTG YEAR",
                "SOYBEANS - SALES, MEASURED IN PCT OF MKTG YEAR",
                "WHEAT - SALES, MEASURED IN PCT OF MKTG YEAR")
to_sales <- c("corn_sales", "hay_sales",
              "soy_sales", "wheat_sales")

sales_data <- sales %>% 
  bind_rows() %>% 
  rename(time = reference_period_desc) %>% 
  mutate(year = as.numeric(year),
         time = case_when(.$time == "JAN" ~ 1, .$time == "FEB" ~ 2,
                          .$time == "MAR" ~ 3, .$time == "APR" ~ 4,
                          .$time == "MAY" ~ 5, .$time == "JUN" ~ 6,
                          .$time == "JUL" ~ 7, .$time == "AUG" ~ 8,
                          .$time == "SEP" ~ 9, .$time == "OCT" ~ 10,
                          .$time == "NOV" ~ 11, .$time == "DEC" ~ 12,
                          TRUE ~ 13),
         short_desc = factor(short_desc,
                             levels = from_sales, labels = to_sales),
         date = as.Date(paste0(year, "-", time, "-1"),
                        format = "%Y-%m-%d")) %>% 
  select(year, val = Value, short_desc, time, date) %>% 
  spread(short_desc, val)

monthly <- sales_data %>% 
  select(-time) %>% 
  right_join(monthly)

write.csv(annual, paste0(local_dir, "/ohio_prices_annual.csv"),
          row.names = F)
write_rds(annual, paste0(local_dir, "/ohio_prices_annual.rds"))

write.csv(monthly, paste0(local_dir, "/ohio_prices_monthly.csv"),
          row.names = F)
write_rds(monthly, paste0(local_dir, "/ohio_prices_monthly.rds"))

# ---- crops --------------------------------------------------------------

# statisticcat_desc - category
# short_desc - data item
# category - area harvested, area planted, production, sales, yields
corn_vals  <- c("CORN - ACRES PLANTED",
                "CORN, GRAIN - ACRES HARVESTED",
                "CORN, SILAGE - ACRES HARVESTED",
                "CORN, GRAIN - PRODUCTION, MEASURED IN BU",
                "CORN, SILAGE - PRODUCTION, MEASURED IN TONS",
                "CORN, GRAIN - YIELD, MEASURED IN BU / ACRE",
                "CORN, SILAGE - YIELD, MEASURED IN TONS / ACRE")
corn_names <- c("corn_acres_planted",
                "corn_grain_acres_harvest",
                "corn_silage_acres_harvest",
                "corn_grain_prod_bu",
                "corn_silage_prod_tons",
                "corn_grain_yield",
                "corn_silage_yield")
hay_vals  <- c("HAY - ACRES HARVESTED",
               "HAY - PRODUCTION, MEASURED IN TONS",
               "HAY - YIELD, MEASURED IN TONS / ACRE")
hay_names <- c("hay_acres_harvest", "hay_prod_tons", "hay_yield")
soy_vals  <- c("SOYBEANS - ACRES HARVESTED",
               "SOYBEANS - ACRES PLANTED",
               "SOYBEANS - PRODUCTION, MEASURED IN BU",
               "SOYBEANS - YIELD, MEASURED IN BU / ACRE")
soy_names  <- c("soy_acres_harvest", "soy_acres_planted",
                "soy_prod_bu", "soy_yield")
wheat_vals <- c("WHEAT - ACRES HARVESTED",
                "WHEAT - ACRES PLANTED",
                "WHEAT - PRODUCTION, MEASURED IN BU",
                "WHEAT, WINTER - ACRES HARVESTED",
                "WHEAT, WINTER - ACRES PLANTED",
                "WHEAT, WINTER - PRODUCTION, MEASURED IN BU",
                "WHEAT, WINTER - YIELD, MEASURED IN BU / ACRE",
                "WHEAT - YIELD, MEASURED IN BU / ACRE")
wheat_names <- c("wheat_acres_harvest", "wheat_acres_planted", "wheat_prod_bu",
                 "wheat_winter_acres_harvest", "wheat_winter_acres_planted",
                 "wheat_winter_prod_bu", "wheat_winter_yield", "wheat_yield")

state_crops <- map(c(corn_vals, soy_vals, wheat_vals), function(x){
  nass_data(short_desc = x, agg_level_desc = "STATE", state_name = "OHIO",
            sector = "CROPS", source_desc = "SURVEY", token = api_nass_key,
            numeric_vals = T)
})

crops <- state_crops %>% 
  bind_rows() %>% 
  # Filter out the forecast values
  filter(reference_period_desc == "YEAR") %>% 
  mutate(year = as.numeric(year),
         short_desc = factor(short_desc,
                             levels = c(corn_vals, soy_vals, wheat_vals),
                             labels = c(corn_names, soy_names, wheat_names))) %>% 
  select(year, asd_desc, val = Value, short_desc) %>% 
  spread(short_desc, val)

crops <- crops %>% 
  mutate(wheat_acres_harvest = ifelse(is.na(wheat_acres_harvest),
                                      wheat_winter_acres_harvest,
                                      wheat_acres_harvest),
         wheat_acres_planted = ifelse(is.na(wheat_acres_planted),
                                      wheat_winter_acres_planted,
                                      wheat_acres_planted),
         wheat_prod_bu = ifelse(is.na(wheat_prod_bu),
                                wheat_winter_prod_bu, wheat_prod_bu),
         wheat_yield = ifelse(is.na(wheat_yield),
                              wheat_winter_yield, wheat_yield)) %>% 
  select(-contains("winter"))

write.csv(crops, paste0(local_dir, "/ohio_state_crops.csv"),
          row.names = F)
write_rds(crops, paste0(local_dir, "/ohio_state_crops.rds"))

# Gather up the forecasted values

forecast_crops <- state_crops %>% 
  bind_rows() %>% 
  # Filter out the forecast values
  filter(reference_period_desc != "YEAR") %>% 
  mutate(year = as.numeric(year),
         reference = tolower(str_replace_all(str_remove(reference_period_desc,
                                                        "YEAR - "),
                                             "[:space:]", "_")),
         short_desc = factor(short_desc,
                             levels = c(corn_vals, soy_vals, wheat_vals),
                             labels = c(corn_names, soy_names, wheat_names))) %>% 
  select(year, reference, val = Value, short_desc) %>% 
  spread(short_desc, val)

forecast_crops <- forecast_crops %>% 
  mutate(wheat_acres_harvest = ifelse(is.na(wheat_acres_harvest),
                                      wheat_winter_acres_harvest,
                                      wheat_acres_harvest),
         wheat_acres_planted = ifelse(is.na(wheat_acres_planted),
                                      wheat_winter_acres_planted,
                                      wheat_acres_planted),
         wheat_prod_bu = ifelse(is.na(wheat_prod_bu),
                                wheat_winter_prod_bu, wheat_prod_bu),
         wheat_yield = ifelse(is.na(wheat_yield),
                              wheat_winter_yield, wheat_yield)) %>% 
  select(-contains("winter")) %>% 
  gather(short_desc, val, -year, -reference) %>% 
  unite(temp, short_desc, reference) %>% 
  spread(temp, val) %>% 
  select_if(not_all_na)

write.csv(forecast_crops, paste0(local_dir, "/ohio_forecast_crops.csv"),
          row.names = F)
write_rds(forecast_crops, paste0(local_dir, "/ohio_forecast_crops.rds"))

# ---- county -------------------------------------------------------------

# NOTE: a major issue in USDA county level data is that sometimes there are
#  multiple counties combined together as "OTHER (COMBINED) COUNTIES" which
#  should be where we simply impute downward at this level. This can be done
#  by recognizing that the "asd_desc" is the level which counties are combined
#  at. Therefore, group by "asd_desc" and check if values are missing. If they
#  are missing, then replace them with the "OTHER (COMBINED) COUNTIES" which
#  also has the county_code of "998
# 
# ohio_crops <- map(c(corn_vals, soy_vals, wheat_vals), function(x){
#   nass_data(short_desc = x, agg_level_desc = "COUNTY", state_name = "OHIO",
#             sector = "CROPS", source_desc = "SURVEY", token = api_nass_key,
#             numeric_vals = T)
# })
# 
# crops <- ohio_crops %>% 
#   bind_rows() %>% 
#   mutate(county = tolower(county_name),
#          year = as.numeric(year),
#          short_desc = factor(short_desc,
#                              levels = c(corn_vals, soy_vals, wheat_vals),
#                              labels = c(corn_names, soy_names, wheat_names))) %>% 
#   select(year, county, county_code, asd_desc, val = Value, short_desc) %>% 
#   spread(short_desc, val)
# 
# crops <- crops %>%
#   expand(nesting(county, county_code, asd_desc), year) %>% 
#   left_join(crops)
# 
# crops <- crops %>% 
#   group_by(year, asd_desc) %>% 
#   mutate_at(vars(corn_acres_planted:wheat_yield),
#             funs(ifelse(is.na(.), .[county_code == "998"], .))) %>% 
#   filter(county_code != "998")
# 
# # Drop out winter wheat, just have wheat
# crops <- crops %>% 
#   mutate(wheat_acres_harvest = ifelse(is.na(wheat_acres_harvest),
#                                       wheat_winter_acres_harvest,
#                                       wheat_acres_harvest),
#          wheat_acres_planted = ifelse(is.na(wheat_acres_planted),
#                                       wheat_winter_acres_planted,
#                                       wheat_acres_planted),
#          wheat_prod_bu = ifelse(is.na(wheat_prod_bu),
#                                 wheat_winter_prod_bu, wheat_prod_bu),
#          wheat_yield = ifelse(is.na(wheat_yield),
#                               wheat_winter_yield, wheat_yield)) %>% 
#   select(-contains("winter"))
# 
# # # Add in a blank holder for next year's prices
# # annual <- data.frame(year = max(annual$year) + 1) %>% 
# #   bind_rows(annual) %>% 
# #   arrange(year)
# 
# 
# write.csv(crops, paste0(local_dir, "/ohio_crops.csv"),
#           row.names = F)
# write_rds(crops, paste0(local_dir, "/ohio_crops.rds"))
