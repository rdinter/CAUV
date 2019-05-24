# Providing a calculation/projection of the Nonland Costs in Ohio

# ---- start --------------------------------------------------------------

library("tidyverse")
library("zoo")

# Create a directory for the data
local_dir <- "2-calc"
nonland   <- paste0(local_dir, "/nonland")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(nonland)) dir.create(nonland, recursive = T)

# Take the vector of costs that are averaged and replaced the most recent with
#  a 0 for high and Inf for low -- these reference the CAUV projection
mean_high <- function(x, ...) {
  n    <- length(x)
  x[n] <- 0
  mean(x, ...)
}
mean_low <- function(x, ...) {
  n    <- length(x)
  x[n] <- Inf
  mean(x, ...)
}


# ---- data ---------------------------------------------------------------


j5 <- read_rds("1-tidy/nonland/ohio_nonland.rds")

# Add on an additional year for Nonland Costs:
nonland_proj <- j5 %>% 
  arrange(year) %>% 
  select(-contains("odt"))

odt_nonland <- tibble(year = max(j5$year) + 1) %>% 
  bind_rows(j5) %>% 
  arrange(year) %>% 
  select(year, contains("odt")) %>% 
  distinct()

# For a tax year, Ohio will use state-wide costs for the previous 6 to current
#  year of official Ohio State Extension values. For example, the 2019 tax year
#  will use cost data from 2013 to 2019.

# Olympic average for each component in costs over a seven-year average without
#  any lags since 2015 (it was a 1 year lag before). This is a very involved
#  calculation! But one thing we need to do is carry forward the last year's
#  budget values for our projections if no preliminary estimates exist yet.

# Last year of an official ODT value
last_odt <- max(j5$year[!is.na(j5$corn_cost_odt)])

# Potentially adding on the most recent "official" values from extension
#  if there exists extension values after an ODT year then they are
#  preliminary extimates for costs
extra <- nonland_proj %>% 
  filter(year == last_odt) %>% 
  mutate(year = max(year) + 1)

if (!((last_odt + 1) %in% nonland_proj$year)) {
  nonland_proj <- nonland_proj %>% 
    bind_rows(extra) %>% 
    arrange(year)
} else if (!((last_odt + 2) %in% nonland_proj$year)) {
  extra$year   <- extra$year + 1
  nonland_proj <- nonland_proj %>%
    bind_rows(extra) %>%
    arrange(year)
}

non_exp <- nonland_proj %>% 
  select(year, item, crop, level, val) %>% 
  spread(item, val) %>% 
  group_by(crop, level) %>% 
  arrange(year) %>% 
  mutate(fixed_miscellaneous1 = rollapplyr(fixed_miscellaneous, 5, mean,
                                           na.rm = T, fill = NA),
         variable_miscellaneous = ifelse(level == "cost",
                                         1, variable_miscellaneous)) %>% 
  ungroup()


# ---- calc-components -----------------------------------------------------

# Calculate the 7 year olympic average, except for fixed misc because there 
#  are not enough observations. Do not do for fixed misc as it started in 2015
non_land_costs <- non_exp %>% 
  group_by(crop, level) %>% 
  arrange(year) %>% 
  mutate_at(vars(-fixed_miscellaneous1, -year, -crop, -level),
            list(~ifelse(year > 2014,
                        rollapplyr(., width = 7, FUN =  mean,
                                   trim = 1/7, na.rm = T, fill = NA),
                        rollapplyr(lag(.), width = 7, FUN =  mean,
                                   trim = 1/7, na.rm = T, fill = NA))))

# # And repeat for high and low projections

non_high_costs <- non_exp %>%
  group_by(crop, level) %>%
  arrange(year) %>%
  mutate_at(vars(-fixed_miscellaneous1, -yield, -year, -crop, -level),
            list(~ifelse(year > 2014,
                        rollapplyr(., width = 7, FUN =  mean_high,
                                   trim = 1/7, na.rm = T, fill = NA),
                        rollapplyr(lag(.), width = 7, FUN =  mean_high,
                                   trim = 1/7, na.rm = T, fill = NA)))) %>% 
  # Yield affects the additive portion, need this to be the inverse
  mutate(yield = ifelse(year > 2014,
                        rollapplyr(yield, width = 7, FUN =  mean_low,
                                   trim = 1/7, na.rm = T, fill = NA),
                        rollapplyr(lag(yield), width = 7, FUN =  mean_low,
                                   trim = 1/7, na.rm = T, fill = NA)))

non_low_costs <- non_exp %>%
  group_by(crop, level) %>%
  arrange(year) %>%
  mutate_at(vars(-fixed_miscellaneous1, -yield, -year, -crop, -level),
            list(~ifelse(year > 2014,
                         rollapplyr(., width = 7, FUN =  mean_low,
                                    trim = 1/7, na.rm = T, fill = NA),
                         rollapplyr(lag(.), width = 7, FUN =  mean_low,
                                    trim = 1/7, na.rm = T, fill = NA)))) %>% 
  # Yield affects the additive portion, need this to be the inverse
  mutate(yield = ifelse(year > 2014,
                        rollapplyr(yield, width = 7, FUN =  mean_high,
                                   trim = 1/7, na.rm = T, fill = NA),
                        rollapplyr(lag(yield), width = 7, FUN =  mean_high,
                                   trim = 1/7, na.rm = T, fill = NA)))


# ---- calc-costs ---------------------------------------------------------

# Function for computing the costs based on level
base_value <- function(var, lev) var[lev == "l1_low"]*var[lev == "cost"]
add_value  <- function(var, lev) {
  (var[lev == "l2_med"] - var[lev == "l1_low"])*var[lev == "cost"]
}

non_land <- non_land_costs %>% 
  ungroup() %>% 
  group_by(year, crop) %>% 
  summarise(yield_adj = yield[level == "l2_med"] - yield[level == "l1_low"],
            base_yield = yield[level == "l1_low"],
            # Variable Costs except interest
            base1 = base_value(seed, level) + base_value(n, level) +
              base_value(p2o5, level) + base_value(k2o, level) +
              base_value(lime, level) + chemicals[level == "cost"] +
              fuel_oil_grease[level == "l1_low"] +
              repairs[level == "l1_low"] +
              crop_insurance[level == "l2_med"] +
              variable_miscellaneous[level == "l1_low"] +
              drying[level == "cost"]*yield[level == "l1_low"] +
              trucking[level == "cost"]*yield[level == "l1_low"],
            # Interest on variable costs except drying, hauling, crop insurance
            interest_rate = round(interest[level == "cost"]*months[level == "cost"]/12, digits = 4),
            interest_cost = interest_rate*(base1 - crop_insurance[level == "l2_med"] -
                                             drying[level == "cost"]*yield[level == "l1_low"] -
                                             trucking[level == "cost"]*yield[level == "l1_low"]),
            # Add in fixed costs
            base = base1 + interest_cost +
              labor[level == "cost"] + machine[level == "cost"] +
              ifelse(is.na(fixed_miscellaneous1[level == "l1_low"]), 0,
                     fixed_miscellaneous1[level == "l1_low"]),
            add1 = add_value(seed, level)/yield_adj +
              add_value(n, level)/yield_adj +
              add_value(p2o5, level)/yield_adj +
              add_value(k2o, level)/yield_adj +
              add_value(lime, level)/yield_adj +
              add_value(variable_miscellaneous, level)/yield_adj +
              drying[level == "cost"] + trucking[level == "cost"],
            add = (1 + interest_rate*(add1 - drying[level == "cost"] - trucking[level == "cost"]))*add1) %>% 
  arrange(desc(year)) %>%
  select(year, crop, cost_cauv = base, cost_add_cauv = add,
         base_cauv = base_yield) %>% 
  gather(var, val, -year, -crop) %>% 
  unite(temp, crop, var) %>% 
  spread(temp, val)

# Now the projections...
non_high <- non_high_costs %>% 
  ungroup() %>% 
  group_by(year, crop) %>% 
  summarise(yield_adj = yield[level == "l2_med"] - yield[level == "l1_low"],
            base_yield = yield[level == "l1_low"],
            # Variable Costs except interest
            base1 = base_value(seed, level) + base_value(n, level) +
              base_value(p2o5, level) + base_value(k2o, level) +
              base_value(lime, level) + chemicals[level == "cost"] +
              fuel_oil_grease[level == "l1_low"] +
              repairs[level == "l1_low"] +
              crop_insurance[level == "l2_med"] +
              variable_miscellaneous[level == "l1_low"] +
              drying[level == "cost"]*yield[level == "l1_low"] +
              trucking[level == "cost"]*yield[level == "l1_low"],
            # Interest on variable costs except drying, hauling, crop insurance
            interest_rate = round(interest[level == "cost"]*months[level == "cost"]/12, digits = 4),
            interest_cost = interest_rate*(base1 - crop_insurance[level == "l2_med"] -
                                             drying[level == "cost"]*yield[level == "l1_low"] -
                                             trucking[level == "cost"]*yield[level == "l1_low"]),
            # Add in fixed costs
            base = base1 + interest_cost +
              labor[level == "cost"] + machine[level == "cost"] +
              ifelse(is.na(fixed_miscellaneous1[level == "l1_low"]), 0,
                     fixed_miscellaneous1[level == "l1_low"]),
            add1 = add_value(seed, level)/yield_adj +
              add_value(n, level)/yield_adj +
              add_value(p2o5, level)/yield_adj +
              add_value(k2o, level)/yield_adj +
              add_value(lime, level)/yield_adj +
              add_value(variable_miscellaneous, level)/yield_adj +
              drying[level == "cost"] + trucking[level == "cost"],
            add = (1 + interest_rate*(add1 - drying[level == "cost"] - trucking[level == "cost"]))*add1) %>% 
  arrange(desc(year)) %>%
  select(year, crop, cost_cauv_h = base, cost_add_cauv_h = add,
         base_cauv_h = base_yield) %>% 
  gather(var, val, -year, -crop) %>% 
  unite(temp, crop, var) %>% 
  spread(temp, val)

non_low <- non_low_costs %>% 
  ungroup() %>% 
  group_by(year, crop) %>% 
  summarise(yield_adj = yield[level == "l2_med"] - yield[level == "l1_low"],
            base_yield = yield[level == "l1_low"],
            # Variable Costs except interest
            base1 = base_value(seed, level) + base_value(n, level) +
              base_value(p2o5, level) + base_value(k2o, level) +
              base_value(lime, level) + chemicals[level == "cost"] +
              fuel_oil_grease[level == "l1_low"] +
              repairs[level == "l1_low"] +
              crop_insurance[level == "l2_med"] +
              variable_miscellaneous[level == "l1_low"] +
              drying[level == "cost"]*yield[level == "l1_low"] +
              trucking[level == "cost"]*yield[level == "l1_low"],
            # Interest on variable costs except drying, hauling, crop insurance
            interest_rate = round(interest[level == "cost"]*months[level == "cost"]/12, digits = 4),
            interest_cost = interest_rate*(base1 - crop_insurance[level == "l2_med"] -
                                             drying[level == "cost"]*yield[level == "l1_low"] -
                                             trucking[level == "cost"]*yield[level == "l1_low"]),
            # Add in fixed costs
            base = base1 + interest_cost +
              labor[level == "cost"] + machine[level == "cost"] +
              ifelse(is.na(fixed_miscellaneous1[level == "l1_low"]), 0,
                     fixed_miscellaneous1[level == "l1_low"]),
            add1 = add_value(seed, level)/yield_adj +
              add_value(n, level)/yield_adj +
              add_value(p2o5, level)/yield_adj +
              add_value(k2o, level)/yield_adj +
              add_value(lime, level)/yield_adj +
              add_value(variable_miscellaneous, level)/yield_adj +
              drying[level == "cost"] + trucking[level == "cost"],
            add = (1 + interest_rate*(add1 - drying[level == "cost"] - trucking[level == "cost"]))*add1) %>% 
  arrange(desc(year)) %>%
  select(year, crop, cost_cauv_l = base, cost_add_cauv_l = add,
         base_cauv_l = base_yield) %>% 
  gather(var, val, -year, -crop) %>% 
  unite(temp, crop, var) %>% 
  spread(temp, val)

### Bring them together
non_land_costs <- non_land %>% 
  left_join(non_low) %>% 
  left_join(non_high) %>% 
  left_join(odt_nonland) %>% 
  mutate_at(vars(contains("base")), round) %>% 
  mutate_at(vars(-group_cols()), round, 2)

write.csv(non_land_costs, paste0(nonland, "/ohio_forecast_nonland.csv"),
          row.names = F)
write_rds(non_land_costs, paste0(nonland, "/ohio_forecast_nonland.rds"))


# ---- corn-base ----------------------------------------------------------

non_land_costs %>% 
  filter(year > 2005) %>% 
  select("Year" = year, "ODT Base Cost" = corn_cost_odt,
         "Low Projection" = corn_cost_cauv_l,
         "Expected Projection" = corn_cost_cauv,
         "High Projection" = corn_cost_cauv_h) %>% 
  mutate_at(vars(-Year), ~scales::dollar(., accuracy = 0.01)) %>% 
  knitr::kable()

# ---- corn-add -----------------------------------------------------------

non_land_costs %>% 
  filter(year > 2005) %>% 
  select("Year" = year, "ODT Add Cost" = corn_cost_add_odt,
         "Low Projection" = corn_cost_add_cauv_l,
         "Expected Projection" = corn_cost_add_cauv,
         "High Projection" = corn_cost_add_cauv_h) %>% 
  mutate_at(vars(-Year), ~scales::dollar(., accuracy = 0.01)) %>% 
  knitr::kable()

# ---- soy-base ----------------------------------------------------------

non_land_costs %>% 
  filter(year > 2005) %>% 
  select("Year" = year, "ODT Base Cost" = soy_cost_odt,
         "Low Projection" = soy_cost_cauv_l,
         "Expected Projection" = soy_cost_cauv,
         "High Projection" = soy_cost_cauv_h) %>% 
  mutate_at(vars(-Year), ~scales::dollar(., accuracy = 0.01)) %>% 
  knitr::kable()

# ---- soy-add -----------------------------------------------------------

non_land_costs %>% 
  filter(year > 2005) %>% 
  select("Year" = year, "ODT Add Cost" = soy_cost_add_odt,
         "Low Projection" = soy_cost_add_cauv_l,
         "Expected Projection" = soy_cost_add_cauv,
         "High Projection" = soy_cost_add_cauv_h) %>% 
  mutate_at(vars(-Year), ~scales::dollar(., accuracy = 0.01)) %>% 
  knitr::kable()

# ---- wheat-base ----------------------------------------------------------

non_land_costs %>% 
  filter(year > 2005) %>% 
  select("Year" = year, "ODT Base Cost" = wheat_cost_odt,
         "Low Projection" = wheat_cost_cauv_l,
         "Expected Projection" = wheat_cost_cauv,
         "High Projection" = wheat_cost_cauv_h) %>% 
  mutate_at(vars(-Year), ~scales::dollar(., accuracy = 0.01)) %>% 
  knitr::kable()

# ---- wheat-add -----------------------------------------------------------

non_land_costs %>% 
  filter(year > 2005) %>% 
  select("Year" = year, "ODT Add Cost" = wheat_cost_add_odt,
         "Low Projection" = wheat_cost_add_cauv_l,
         "Expected Projection" = wheat_cost_add_cauv,
         "High Projection" = wheat_cost_add_cauv_h) %>% 
  mutate_at(vars(-Year), ~scales::dollar(., accuracy = 0.01)) %>% 
  knitr::kable()

