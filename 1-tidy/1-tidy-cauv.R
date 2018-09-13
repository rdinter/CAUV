# Gathering the raw data and the official ODT values for each component:
#  - prices
#  - yields
#  - rotation
#  - non-land costs
#  - capitalization rate

# ---- start --------------------------------------------------------------

library("lubridate")
library("tidyverse")
library("zoo")

# Create a directory for the data
local_dir <- "1-tidy"
if (!file.exists(local_dir)) dir.create(local_dir)

odt     <- read_csv("0-data/odt/odt_values_used.csv")
cap_odt <- read_csv("0-data/cap_rate/capitalization_rate.csv") %>% 
  rename(year = tax_year)

ohio <- c("0-data/ohio/ohio_prices_annual.rds",
          "0-data/ohio/ohio_state_crops.rds",
          "0-data/ohio/ohio_forecast_crops.rds") %>% 
  map(read_rds) %>% 
  reduce(full_join)

# ---- prices -------------------------------------------------------------

prices    <- paste0(local_dir, "/prices")
if (!file.exists(prices)) dir.create(prices)

ohio_prices <- odt %>% 
  mutate(year = tax_year) %>% 
  right_join(ohio) %>% 
  select(year, contains("price"), contains("prod_bu")) %>% 
  arrange(year)

price_month <- read_rds("0-data/ohio/ohio_prices_monthly.rds") %>% 
  mutate(month = month(date, label = T))

price_month %>% 
  filter(year > 2001) %>% 
  select(month, corn_sales, hay_sales, soy_sales, wheat_sales) %>% 
  gather(var, val, -month) %>% 
  ggplot(aes(month, val, color = var)) + geom_violin()

# How to give a projection of prices? Use the same weights as the last year?
#  Recalibrate the weights to historical averages?

huh <- price_month %>%
  arrange(date) %>% 
  mutate(corn_roll = rollapplyr(corn_price*(corn_sales/100), 12, sum,
                                fill = NA),
         korn_roll = rollapplyr(corn_price*(lag(corn_sales,12)/100), 12, sum,
                                fill = NA),
         soy_roll = rollapplyr(soy_price*(soy_sales/100), 12, sum,
                               fill = NA),
         wheat_roll = rollapplyr(wheat_price*(wheat_sales/100), 12, sum,
                                 fill = NA))


write_csv(ohio_prices, paste0(prices, "/ohio_prices.csv"))
write_rds(ohio_prices, paste0(prices, "/ohio_prices.rds"))


# ---- yields -------------------------------------------------------------

yields    <- paste0(local_dir, "/yields")
if (!file.exists(yields)) dir.create(yields)

ohio_yields <- odt %>% 
  mutate(year = tax_year) %>% 
  right_join(ohio) %>% 
  select(year, contains("yield")) %>% 
  arrange(year)

write_csv(ohio_yields, paste0(yields, "/ohio_yields.csv"))
write_rds(ohio_yields, paste0(yields, "/ohio_yields.rds"))


# ---- rotation -----------------------------------------------------------

rot       <- paste0(local_dir, "/rot")
if (!file.exists(rot)) dir.create(rot)

ohio_rot <- odt %>% 
  mutate(year = tax_year) %>% 
  right_join(ohio) %>% 
  select(year, contains("rotate"), contains("harvest")) %>% 
  arrange(year)

write_csv(ohio_rot, paste0(rot, "/ohio_rot.csv"))
write_rds(ohio_rot, paste0(rot, "/ohio_rot.rds"))


# ---- nonland ------------------------------------------------------------

nonland   <- paste0(local_dir, "/nonland")
if (!file.exists(nonland)) dir.create(nonland)

osu_budget <- read_csv("0-data/osu_budget/osu_budgets - R.csv")

ohio_nonland <- odt %>% 
  select(year = tax_year, contains("cost"), contains("base")) %>% 
  right_join(osu_budget) %>% 
  arrange(year)

write_csv(ohio_nonland, paste0(nonland, "/ohio_nonland.csv"))
write_rds(ohio_nonland, paste0(nonland, "/ohio_nonland.rds"))


# ---- cap ----------------------------------------------------------------

cap       <- paste0(local_dir, "/cap")
if (!file.exists(cap)) dir.create(cap)

# Not much to do here, just place the cap rate saved into the folder.
#  Still searching for a better way to download interest rate information.

write_csv(cap_odt, paste0(cap, "/ohio_caprate.csv"))
write_rds(cap_odt, paste0(cap, "/ohio_caprate.rds"))


# ---- all ----------------------------------------------------------------

# Let's not grab the cost one because it is the most complex.

ohio_all <- cap_odt %>% 
  full_join(ohio_prices) %>% 
  full_join(ohio_yields) %>% 
  full_join(ohio_rot) %>% 
  arrange(year)

write_csv(ohio_all, paste0(local_dir, "/ohio_cauv_all.csv"))
write_rds(ohio_all, paste0(local_dir, "/ohio_cauv_all.rds"))
