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
            state_name = "OHIO", numeric_vals = T)
  })

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

write_csv(annual, paste0(local_dir, "/ohio_prices_annual.csv"))
write_rds(annual, paste0(local_dir, "/ohio_prices_annual.rds"))

write_csv(monthly, paste0(local_dir, "/ohio_prices_monthly.csv"))
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
            sector = "CROPS", source_desc = "SURVEY",
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

write_csv(crops, paste0(local_dir, "/ohio_state_crops.csv"))
write_rds(crops, paste0(local_dir, "/ohio_state_crops.rds"))

# Gather up the forecasted values
not_all_na <- function(x) any(!is.na(x))

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

write_csv(forecast_crops, paste0(local_dir, "/ohio_forecast_crops.csv"))
write_rds(forecast_crops, paste0(local_dir, "/ohio_forecast_crops.rds"))


# ---- county -------------------------------------------------------------

county_crops <- map(c(corn_vals, soy_vals, wheat_vals), function(x){
  nass_data(short_desc = x, agg_level_desc = "COUNTY", state_name = "OHIO",
            sector = "CROPS", source_desc = "SURVEY",
            numeric_vals = T)
})


crops <- county_crops %>% 
  bind_rows() %>% 
  mutate(county = tolower(county_name),
         year = as.numeric(year),
         short_desc = plyr::mapvalues(short_desc,
                                      from = c(corn_vals, soy_vals, wheat_vals),
                                      to = c(corn_names, soy_names, wheat_names))) %>% 
  select(year, county, county_code, asd_desc, val = Value, short_desc) %>% 
  spread(short_desc, val)

# Livestock
## DO WE NEED ADDITIONAL?
cattle <- c("CATTLE, COWS, MILK - INVENTORY",
            "CATTLE, INCL CALVES - INVENTORY")
cattle_names <- c("cattle_milk_inventory", "cattle_inventory")
ohio_livestock <- map(cattle, function(x){
  nass_data(short_desc = x, agg_level_desc = "COUNTY", state_name = "OHIO",
            source_desc = "SURVEY", numeric_vals = T)
})

livestock <- ohio_livestock %>% 
  bind_rows() %>% 
  mutate(county = tolower(county_name),
         year = as.numeric(year),
         short_desc = plyr::mapvalues(short_desc,
                                      from = cattle,
                                      to = cattle_names)) %>% 
  select(year, county, county_code, asd_desc, val = Value, short_desc) %>% 
  spread(short_desc, val)

crops <- crops %>%
  full_join(livestock) %>% 
  expand(nesting(county, county_code, asd_desc), year) %>% 
  left_join(crops) %>% 
  left_join(livestock)

crops <- crops %>% 
  group_by(year, asd_desc) %>% 
  mutate_at(vars(corn_acres_planted:cattle_milk_inventory),
            list(impute = ~ifelse(is.na(.), .[county_code == "998"], .))) %>% 
  filter(county_code != "998")

# Drop out winter wheat, just have wheat
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

write_csv(crops, paste0(local_dir, "/ohio_county_crops.csv"))
write_rds(crops, paste0(local_dir, "/ohio_county_crops.rds"))


# --- rents ---------------------------------------------------------------

ohio_rent <- nass_data(commodity_desc = "RENT", agg_level_desc = "COUNTY",
                       state_name = "OHIO", numeric_vals = T)

from_rent <- c("RENT, CASH, CROPLAND, IRRIGATED - EXPENSE, MEASURED IN $ / ACRE",
               "RENT, CASH, CROPLAND, NON-IRRIGATED - EXPENSE, MEASURED IN $ / ACRE",
               "RENT, CASH, LAND & BUILDINGS - EXPENSE, MEASURED IN $",
               "RENT, CASH, LAND & BUILDINGS - OPERATIONS WITH EXPENSE",
               "RENT, CASH, PASTURELAND - EXPENSE, MEASURED IN $ / ACRE",
               "RENT, PER HEAD OR ANIMAL UNIT MONTH - OPERATIONS WITH EXPENSE")
to_rent   <- c("rent_irrigated", "rent_nonirrigated", "rent_expense",
               "operations_with_rent", "rent_pasture", "operations_head")

ohio <- ohio_rent %>% 
  mutate(year = as.numeric(year),
         #location_desc = gsub("OHIO, ", "", location_desc),
         short_desc = plyr::mapvalues(short_desc,
                                      from = from_rent,
                                      to = to_rent)) %>% 
  select(year, val = Value, short_desc,
         county_code, county_name, asd_desc) %>% 
  spread(short_desc, val)

# Add on acreage from Census on rented land: these are only for part-owners
ohio_rent <- map(c("AG LAND, OWNED, IN FARMS - ACRES",
                   "AG LAND, RENTED FROM OTHERS, IN FARMS - ACRES",
                   "AG LAND, CROPLAND - ACRES",
                   "AG LAND, PASTURELAND, (EXCL CROPLAND & WOODLAND) - ACRES",
                   "AG LAND, WOODLAND - ACRES",
                   "AG LAND, WOODLAND, PASTURED - ACRES"),
                 function(x){
                   nass_data(commodity_desc = "AG LAND",
                             agg_level_desc = "COUNTY",
                             state_name = "OHIO", #domain_desc = "TOTAL",
                             #source_desc = "SURVEY", 
                             short_desc = x, numeric_vals = T)
                 })

ohio_rent <- ohio_rent %>% 
  bind_rows() %>% 
  filter(domain_desc != "IRRIGATION STATUS") %>% 
  mutate(year = as.numeric(year),
         short_desc = plyr::mapvalues(short_desc,
                                      from = c("AG LAND, OWNED, IN FARMS - ACRES",
                                               "AG LAND, CROPLAND - ACRES",
                                               "AG LAND, PASTURELAND, (EXCL CROPLAND & WOODLAND) - ACRES",
                                               "AG LAND, WOODLAND - ACRES",
                                               "AG LAND, WOODLAND, PASTURED - ACRES",
                                               "AG LAND, RENTED FROM OTHERS, IN FARMS - ACRES"),
                                      to = c("acres_part_owned", "cropland_acres", "pasture_acres",
                                             "woodland_acres", "woodland_pastured_acres", "acres_part_rented"))) %>% 
  select(year, val = Value, short_desc,
         county_code, county_name, asd_desc) %>% 
  spread(short_desc, val)

ohio <- left_join(ohio, ohio_rent)

# Now for the other general all categories:
ohio_rent <- nass_data(commodity_desc = "FARM OPERATIONS",
                       agg_level_desc = "COUNTY", state_name = "OHIO",
                       source_desc = "CENSUS", domain_desc = "TENURE",
                       short_desc = "FARM OPERATIONS - ACRES OPERATED",
                       numeric_vals = T)

ohio_rent <- ohio_rent %>% 
  bind_rows() %>% 
  #filter(domain_desc != "IRRIGATION STATUS") %>% 
  mutate(year = as.numeric(year),
         domaincat_desc = plyr::mapvalues(domaincat_desc,
                                          from = c("TENURE: (FULL OWNER)",
                                                   "TENURE: (PART OWNER)",
                                                   "TENURE: (TENANT)"),
                                          to = c("acres_owned", "acres_part",
                                                 "acres_tenant_rented"))) %>% 
  select(year, val = Value, domaincat_desc,
         county_code, county_name, asd_desc) %>% 
  spread(domaincat_desc, val)

ohio <- left_join(ohio, ohio_rent)

####
# NOW ADD IN THOSE RENTED AND OWNED ACRES
#####
ohio$owned_acres  <- ohio$acres_owned + ohio$acres_part_owned
ohio$rented_acres <- ohio$acres_part_rented + ohio$acres_tenant_rented

# Correct for missing values in the "other" but call these imputed
ohio <- ohio %>% 
  expand(year, nesting(county_code, county_name, asd_desc)) %>% 
  left_join(ohio) %>% 
  group_by(year, asd_desc) %>% 
  mutate_at(vars(rent_irrigated, rent_nonirrigated, rent_pasture),
            list(impute = ~ifelse(is.na(.), .[county_code == "998"], .))) %>% 
  filter(county_code != "998")

ohio_tax <- nass_data(commodity_desc = "TAXES", agg_level_desc = "COUNTY",
                      state_name = "OHIO", numeric_vals = T)

from_tax <- c("TAXES, PROPERTY, REAL ESTATE & NON-REAL ESTATE, (EXCL PAID BY LANDLORD) - EXPENSE, MEASURED IN $",
              "TAXES, PROPERTY, REAL ESTATE & NON-REAL ESTATE, (EXCL PAID BY LANDLORD) - OPERATIONS WITH EXPENSE")
ohio_tax <- ohio_tax %>% 
  mutate(year = as.numeric(year),
         short_desc = plyr::mapvalues(short_desc,
                                      from = from_tax,
                                      to = c("taxes", "taxes_operations"))) %>% 
  select(year, val = Value, short_desc,
         county_code, county_name, asd_desc) %>% 
  spread(short_desc, val)

ohio_income <- map(c("INCOME, FARM-RELATED - OPERATIONS WITH RECEIPTS",
                     "INCOME, FARM-RELATED - RECEIPTS, MEASURED IN $",
                     "INCOME, NET CASH FARM, OF OPERATIONS - NET INCOME, MEASURED IN $",
                     "INCOME, NET CASH FARM, OF OPERATIONS - OPERATIONS WITH NET INCOME"),
                   function(x){
                     nass_data(agg_level_desc = "COUNTY",
                               state_name = "OHIO", domain_desc = "TOTAL",
                               #source_desc = "SURVEY", 
                               short_desc = x, numeric_vals = T)
                   })

ohio_income <- ohio_income %>% 
  bind_rows() %>% 
  mutate(year = as.numeric(year),
         short_desc = plyr::mapvalues(short_desc,
                                      from = c("INCOME, FARM-RELATED - OPERATIONS WITH RECEIPTS",
                                               "INCOME, FARM-RELATED - RECEIPTS, MEASURED IN $",
                                               "INCOME, NET CASH FARM, OF OPERATIONS - NET INCOME, MEASURED IN $",
                                               "INCOME, NET CASH FARM, OF OPERATIONS - OPERATIONS WITH NET INCOME"),
                                      to = c("receipt_operations", "receipts", "net_cash_total", "net_cash_operations"))) %>% 
  select(year, val = Value, short_desc,
         county_code, county_name, asd_desc) %>% 
  spread(short_desc, val)

ohio_land <- nass_data(commodity_desc = "AG LAND", agg_level_desc = "COUNTY",
                       state_name = "OHIO", domain_desc = "TOTAL",
                       statisticcat_desc = "ASSET VALUE", numeric_vals = T)

ohio_land <- ohio_land %>% 
  mutate(year = as.numeric(year),
         short_desc = plyr::mapvalues(short_desc,
                                      from = c("AG LAND, INCL BUILDINGS - ASSET VALUE, MEASURED IN $",
                                               "AG LAND, INCL BUILDINGS - ASSET VALUE, MEASURED IN $ / ACRE",
                                               "AG LAND, INCL BUILDINGS - ASSET VALUE, MEASURED IN $ / OPERATION",
                                               "AG LAND, INCL BUILDINGS - OPERATIONS WITH ASSET VALUE"),
                                      to = c("agland", "agland_per_acre",
                                             "agland_per_operation", "agland_operations"))) %>% 
  select(year, val = Value, short_desc,
         county_code, county_name, asd_desc) %>% 
  spread(short_desc, val)

ohio_farms <- map(c("FARM OPERATIONS - NUMBER OF OPERATIONS",
                    "FARM OPERATIONS - ACRES OPERATED"), function(x){
                      nass_data(commodity_desc = "FARM OPERATIONS",
                                agg_level_desc = "COUNTY",
                                state_name = "OHIO", domain_desc = "TOTAL",
                                #source_desc = "SURVEY", 
                                short_desc = x, numeric_vals = T)
                    })

ohio_farms <- ohio_farms %>% 
  bind_rows() %>% 
  mutate(year = as.numeric(year),
         short_desc = plyr::mapvalues(short_desc,
                                      from = c("FARM OPERATIONS - NUMBER OF OPERATIONS",
                                               "FARM OPERATIONS - ACRES OPERATED"),
                                      to = c("farms", "acres"))) %>% 
  filter(!(year %in% c(1997, 2002, 2007) & source_desc == "SURVEY")) %>% 
  select(year, val = Value, short_desc,
         county_code, county_name, asd_desc) %>% 
  spread(short_desc, val)

ohio <- ohio_farms %>% 
  full_join(ohio) %>% 
  full_join(ohio_tax) %>% 
  full_join(ohio_income) %>% 
  full_join(ohio_land)
ohio$fips <- 39000 + as.numeric(ohio$county_code)

# Let's add in that pesky 2015 with NA values ...
blerg <- ohio %>%
  select(fips, county_code:asd_desc) %>%
  distinct() %>% 
  mutate(year = 2015)

ohio <- full_join(ohio, blerg)

write_csv(ohio, paste0(local_dir, "/ohio_econ_county.csv"))
write_rds(ohio, paste0(local_dir, "/ohio_econ_county.rds"))
