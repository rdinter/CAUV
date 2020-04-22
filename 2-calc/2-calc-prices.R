# Providing a calculation/projection of the Prices in Ohio

# ---- start --------------------------------------------------------------

library("lubridate")
library("tidyverse")
library("zoo")

# Create a directory for the data
local_dir <- "2-calc"
prices    <- paste0(local_dir, "/prices")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(prices)) dir.create(prices, recursive = T)

j5 <- read_rds("1-tidy/prices/ohio_prices.rds")

# Add on two additional years for prices:
price_proj <- tibble(year = c(max(j5$year) + 1, max(j5$year) + 2)) %>% 
  bind_rows(j5) %>% 
  arrange(year)


# ---- calc ---------------------------------------------------------------

# For a tax year, Ohio will use state-wide prices for the previous 8 to 1 years
#  of official USDA data. For example, the 2019 tax year will use price data 
#  from 2012 to 2018.

# Olympic average based on weighted prices over a seven-year average with
#  one year lag since ODT adjusted in 2015 (it was a 2 year lag). This is kinda
#  involved in calculation! But here's one way to produce a function for it:

olympic.mean <- function(x, w, exp = "") {
  n = length(x)
  if (exp == "") {
    x = x # no change in the most recent value
  } else if (exp == "high") {
    x[n] = Inf # if it is the high projection, replace the most recent with Inf
  } else if (exp == "low") {
    x[n] = 0  # if it is the low projection, replace the most recent with 0
  }
  dat      = data.frame(x, w)
  sort_dat <- dat[order(dat$x, dat$w),]
  
  # There's a 95% adjustment cost
  0.95*weighted.mean(sort_dat[-c(1, n), 1], sort_dat[-c(1, n), 2])
}
projection_price <- function(x, w, exp = "") {
  rollapplyr(data.frame(x, w), width = 7,
             FUN = function(x) olympic.mean(x[,1], x[,2], exp = exp),
             fill = NA, by.column = FALSE)
}

price_projection <- price_proj %>% 
  select(year, c_p = corn_price, c_w = corn_grain_prod_bu,
         s_p = soy_price, s_w = soy_prod_bu,
         w_p = wheat_price, w_w = wheat_prod_bu) %>% 
  # This step passes current price and production forward, better way? Maybe.
  fill(c_p:w_w) %>% 
  mutate(corn_price_cauv = ifelse(year > 2014,
                                  projection_price(lag(c_p), lag(c_w)),
                                  projection_price(lag(c_p, 2), lag(c_w, 2))),
         corn_price_cauv_exp = corn_price_cauv,
         corn_price_cauv_l = ifelse(year > 2014,
                                  projection_price(lag(c_p),
                                                   lag(c_w), exp = "low"),
                                  projection_price(lag(c_p, 2),
                                                   lag(c_w, 2), exp = "low")),
         corn_price_cauv_h = ifelse(year > 2014,
                                  projection_price(lag(c_p),
                                                   lag(c_w), exp = "high"),
                                  projection_price(lag(c_p, 2),
                                                   lag(c_w, 2), exp = "high")),
         soy_price_cauv = ifelse(year > 2014,
                                  projection_price(lag(s_p),
                                                   lag(s_w)),
                                  projection_price(lag(s_p, 2),
                                                   lag(s_w, 2))),
         soy_price_cauv_exp = soy_price_cauv,
         soy_price_cauv_l = ifelse(year > 2014,
                                    projection_price(lag(s_p),
                                                     lag(s_w), exp = "low"),
                                    projection_price(lag(s_p, 2),
                                                     lag(s_w, 2), exp = "low")),
         soy_price_cauv_h = ifelse(year > 2014,
                                    projection_price(lag(s_p),
                                                     lag(s_w), exp = "high"),
                                    projection_price(lag(s_p, 2),
                                                     lag(s_w, 2), exp = "high")),
         wheat_price_cauv = ifelse(year > 2014,
                                  projection_price(lag(w_p),
                                                   lag(w_w)),
                                  projection_price(lag(w_p, 2),
                                                   lag(w_w, 2))),
         wheat_price_cauv_exp = wheat_price_cauv,
         wheat_price_cauv_l = ifelse(year > 2014,
                                    projection_price(lag(w_p),
                                                     lag(w_w), exp = "low"),
                                    projection_price(lag(w_p, 2),
                                                     lag(w_w, 2), exp = "low")),
         wheat_price_cauv_h = ifelse(year > 2014,
                                    projection_price(lag(w_p),
                                                     lag(w_w), exp = "high"),
                                    projection_price(lag(w_p, 2),
                                                     lag(w_w, 2), exp = "high"))) %>% 
  select(year, contains("cauv"))

price_proj <- left_join(price_proj, price_projection)


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
  mutate_at(vars(-Year), ~replace(scales::dollar(., accuracy = 0.01),
                                  is.na(.), "-")) %>% 
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
  mutate_at(vars(-Year), ~replace(scales::dollar(., accuracy = 0.01),
                                  is.na(.), "-")) %>% 
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
  mutate_at(vars(-Year), ~replace(scales::dollar(., accuracy = 0.01),
                                  is.na(.), "-")) %>% 
  knitr::kable()

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
