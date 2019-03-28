# Providing a calculation/projection of the Prices in Ohio

# ---- start --------------------------------------------------------------

library("lubridate")
library("tidyverse")
library("zoo")

# Create a directory for the data
local_dir <- "2-calc"
prices    <- paste0(local_dir, "/prices")
if (!file.exists(local_dir)) dir.create(local_dir)
if (!file.exists(prices)) dir.create(prices)

j5 <- read_rds("1-tidy/prices/ohio_prices.rds")

# Add on an additional year for prices:
price_proj <- tibble(year = max(j5$year) + 1) %>% 
  bind_rows(j5) %>% 
  arrange(year)


# ---- prediction ---------------------------------------------------------


# Marketing years:
# Corn and Soybeans: September through August
# Wheat: June through May

price_month <- read_rds("0-data/ohio/ohio_prices_monthly.rds") %>% 
  mutate(month = month(date, label = T))

price_month %>% 
  filter(year > 2001) %>% 
  select(month, corn_sales, soy_sales, wheat_sales) %>% 
  gather(var, val, -month) %>% 
  ggplot(aes(month, val, color = var, fill = var)) + geom_violin()

# How to give a projection of prices? Use the same weights as the last year?
#  Recalibrate the weights to historical averages?

# Going to go with previous years' sales weights then new prices
roll_prices <- function(x, y, l = 12) {
  y = replace_na(y, 0)
  rollapplyr(tibble(x, y), l,
             function(z)(weighted_mean = weighted.mean(z[,"x"],z[,"y"])),
             by.column = FALSE, fill = NA)
}

iffy_prices <- price_month %>%
  arrange(date) %>%
  mutate(corn_roll = roll_prices(corn_price, lag(corn_sales, 12)),
         soy_roll = roll_prices(soy_price, lag(soy_sales, 12)),
         wheat_roll = roll_prices(wheat_price, lag(wheat_sales, 12)),
         corn_mark = roll_prices(corn_price, corn_sales),
         soy_mark = roll_prices(soy_price, soy_sales),
         wheat_mark = roll_prices(wheat_price, wheat_sales),
         month = month(date),
         mkt_year1 = year + 1*(month(date) > 5) - 1,
         mkt_year2 = year + 1*(month(date) > 8) - 1)

iffy_prices %>%
  filter(!is.na(corn_roll)) %>%
  select(date, corn_roll, soy_roll, wheat_roll) %>% 
  gather(var, val, -date) %>% 
  ggplot(aes(date, val, color = var)) + geom_line()

derp <- iffy_prices[nrow(iffy_prices),
            c("year", "mkt_year1", "mkt_year2",
              "corn_roll", "soy_roll", "wheat_roll")]

# ADD INTO marketing year values for price_proj

##


# ---- calc ---------------------------------------------------------------

# For a tax year, Ohio will use state-wide prices for the previous 8 to 1 years
#  of official USDA data. For example, the 2019 tax year will use price data 
#  from 2012 to 2018.

# Olympic average based on weighted prices over a seven-year average with
#  one year lag since ODT adjusted in 2015 (it was a 2 year lag). This is kinda
#  involved in calculation! But here's one way to produce a function for it:


price_ave <- function(x, w, lags = 1, adj = 0.95){
  # x is the price and w is the production
  # lags is number of lags for beginning the 7 year Olympic average
  # adj is the management adjustment to the price, set at 5% and hasn't changed
  # Drop the highest and lowest price, then average based on production
  min_p  <- rollapplyr(lag(x, lags), 7, min, fill = NA)
  max_p  <- rollapplyr(lag(x, lags), 7, max, fill = NA)
  
  
  value <- function(i) ifelse(lag(x, i) == min_p | lag(x, i) == max_p, 0,
                              lag(x, i)*lag(w, i))
  lag1   <- value(lags)
  lag2   <- value(lags + 1)
  lag3   <- value(lags + 2)
  lag4   <- value(lags + 3)
  lag5   <- value(lags + 4)
  lag6   <- value(lags + 5)
  lag7   <- value(lags + 6)
  
  prod  <- function(i) ifelse(lag(x, i) == min_p | lag(x, i) == max_p, 0,
                              lag(w, i))
  g1   <- prod(lags)
  g2   <- prod(lags + 1)
  g3   <- prod(lags + 2)
  g4   <- prod(lags + 3)
  g5   <- prod(lags + 4)
  g6   <- prod(lags + 5)
  g7   <- prod(lags + 6)
  
  # Adjust for the 5% management allowance
  price <- adj*(lag1 + lag2 + lag3 + lag4 + lag5 + lag6 + lag7) /
    (g1 + g2 + g3 + g4 + g5 + g6 + g7)
  return(price)
}


price_proj_high <- price_proj_low <- price_proj

price_proj_low[is.na(price_proj_low)] <- 0
price_proj_high[is.na(price_proj_high)] <- Inf

price_proj$corn_price_cauv <- ifelse(price_proj$year > 2014,
                               price_ave(price_proj$corn_price,
                                         price_proj$corn_grain_prod_bu),
                               price_ave(price_proj$corn_price,
                                         price_proj$corn_grain_prod_bu, 2))
price_proj$soy_price_cauv <- ifelse(price_proj$year > 2014,
                              price_ave(price_proj$soy_price,
                                        price_proj$soy_prod_bu),
                              price_ave(price_proj$soy_price,
                                        price_proj$soy_prod_bu, 2))
price_proj$wheat_price_cauv <- ifelse(price_proj$year > 2014,
                                price_ave(price_proj$wheat_price,
                                          price_proj$wheat_prod_bu),
                                price_ave(price_proj$wheat_price,
                                          price_proj$wheat_prod_bu, 2))

# Fill forward the previous price values to get an estimate for future
#  values in the CAUV projections!!!

# This is where the monthly data might come in handy.
price_proj$corn_price_cauv_exp <-
  price_ave(
    fill(price_proj, corn_price)$corn_price,
    fill(price_proj, corn_grain_prod_bu)$corn_grain_prod_bu
  )
price_proj$soy_price_cauv_exp <-
  price_ave(fill(price_proj, soy_price)$soy_price,
            fill(price_proj, soy_prod_bu)$soy_prod_bu)
price_proj$wheat_price_cauv_exp <-
  price_ave(
    fill(price_proj, wheat_price)$wheat_price,
    fill(price_proj, wheat_prod_bu)$wheat_prod_bu
  )

# Fill in the missing CAUV values with the expected ones!
price_proj <- price_proj %>% 
  mutate(corn_price_cauv = if_else(is.na(corn_price_cauv), corn_price_cauv_exp,
                                   corn_price_cauv),
         soy_price_cauv = if_else(is.na(soy_price_cauv), soy_price_cauv_exp,
                                   soy_price_cauv),
         wheat_price_cauv = if_else(is.na(wheat_price_cauv),
                                    wheat_price_cauv_exp, wheat_price_cauv))

# highest and lowest possible values
price_proj$corn_price_cauv_h <- price_ave(price_proj_high$corn_price,
                                    price_proj_high$corn_grain_prod_bu)
price_proj$corn_price_cauv_l <- price_ave(price_proj_low$corn_price,
                                    price_proj_low$corn_grain_prod_bu)

price_proj$soy_price_cauv_h <- price_ave(price_proj_high$soy_price,
                                   price_proj_high$soy_prod_bu)
price_proj$soy_price_cauv_l <- price_ave(price_proj_low$soy_price,
                                   price_proj_low$soy_prod_bu)

price_proj$wheat_price_cauv_h <- price_ave(price_proj_high$wheat_price,
                                     price_proj_high$wheat_prod_bu)
price_proj$wheat_price_cauv_l <- price_ave(price_proj_low$wheat_price,
                                     price_proj_low$wheat_prod_bu)


write.csv(price_proj, paste0(prices, "/ohio_forecast_prices.csv"),
          row.names = F)
write_rds(price_proj, paste0(prices, "/ohio_forecast_prices.rds"))

# ---- corn ---------------------------------------------------------------


price_proj %>%
  filter(year > 2005) %>%
  select(
    "Year" = year,
    "ODT Price" = corn_price_odt,
    "USDA Price" = corn_price,
    "Low Projection" = corn_price_cauv_l,
    "Expected Projection" = corn_price_cauv_exp,
    "High Projection" = corn_price_cauv_h
  ) %>%
  knitr::kable()

# ---- soy ----------------------------------------------------------------


price_proj %>%
  filter(year > 2005) %>%
  select(
    "Year" = year,
    "ODT Price" = soy_price_odt,
    "USDA Price" = soy_price,
    "Low Projection" = soy_price_cauv_l,
    "Expected Projection" = soy_price_cauv_exp,
    "High Projection" = soy_price_cauv_h
  ) %>%
  knitr::kable()


# ---- wheat --------------------------------------------------------------


price_proj %>%
  filter(year > 2005) %>%
  select(
    "Year" = year,
    "ODT Price" = wheat_price_odt,
    "USDA Price" = wheat_price,
    "Low Projection" = wheat_price_cauv_l,
    "Expected Projection" = wheat_price_cauv_exp,
    "High Projection" = wheat_price_cauv_h
  ) %>%
  knitr::kable()
