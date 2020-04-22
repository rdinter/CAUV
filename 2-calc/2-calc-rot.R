# Providing a calculation/projection of the Rotation in Ohio


# ---- start --------------------------------------------------------------

library("tidyverse")
library("zoo")

# Create a directory for the data
local_dir <- "2-calc"
rot    <- paste0(local_dir, "/rot")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(rot)) dir.create(rot, recursive = T)

j5 <- read_rds("1-tidy/rot/ohio_rot.rds")

# Add on two additional years for Rotation:
rot_proj <- tibble(year = c(max(j5$year) + 1, max(j5$year) + 2)) %>% 
  bind_rows(j5) %>% 
  arrange(year)

# For a tax year, Ohio will use state-wide production for the previous 5 to 1
# years of official USDA data. For example, the 2019 tax year will use
# production from 2014 to 2018.

# Simple averages based on production over a five-year average with one year lag
# since ODT adjusted in 2015 (it was a 2 year lag). Fairly straightforward, but
# since Hay was dropped in 2009 we will ignore that value.
rotate_calc <- function(crop, year) {
  ifelse(year > 2014,
         rollapplyr(lag(crop), 5, mean, fill = NA),
         rollapplyr(lag(crop, 2), 5, mean, fill = NA))
}

# ---- calc ---------------------------------------------------------------

# Trends for acreage, give the 30-year trend harvested acres for the most
#  recent data we have available on each component
acre_trends <-
  rot_proj %>% 
  select(year, corn_trend = corn_grain_acres_harvest,
         soy_trend = soy_acres_harvest, wheat_trend = wheat_acres_harvest) %>% 
  gather(var, val, -year) %>% 
  group_by(var) %>% 
  filter(year > max(year[!is.na(val)]) - 30) %>% 
  nest() %>% 
  mutate(model = data %>% map(~lm(val ~ year, data = .)),
         trend = map2(model, data, predict)) %>% 
  unnest(c(trend, data)) %>% 
  filter(is.na(val)) %>% # Only keep the missing values
  select(-val, -model) %>% 
  spread(var, trend)


ohio_rot <- rot_proj %>% 
  arrange(year) %>% 
  left_join(acre_trends) %>% 
  mutate(corn_grain_acres_harvest = if_else(is.na(corn_grain_acres_harvest),
                                    corn_trend, corn_grain_acres_harvest),
         soy_acres_harvest = if_else(is.na(soy_acres_harvest),
                                     soy_trend, soy_acres_harvest),
         wheat_acres_harvest = if_else(is.na(wheat_acres_harvest),
                                       wheat_trend, wheat_acres_harvest)) %>% 
  # fill(corn_grain_acres_harvest, soy_acres_harvest, wheat_acres_harvest) %>% 
  mutate(corn_harvest_cauv    = rotate_calc(corn_grain_acres_harvest, year),
         soy_harvest_cauv     = rotate_calc(soy_acres_harvest, year),
         wheat_harvest_cauv   = rotate_calc(wheat_acres_harvest, year),
         total_harvest_cauv   = corn_harvest_cauv + soy_harvest_cauv +
           wheat_harvest_cauv,
         corn_rotate_cauv  = corn_harvest_cauv / total_harvest_cauv,
         soy_rotate_cauv   = soy_harvest_cauv / total_harvest_cauv,
         wheat_rotate_cauv = wheat_harvest_cauv / total_harvest_cauv) %>% 
  select(year, corn_harvest_cauv:wheat_rotate_cauv)

ohio <- left_join(rot_proj, ohio_rot)

write.csv(ohio, paste0(rot, "/ohio_forecast_rotate.csv"),
          row.names = F)
write_rds(ohio, paste0(rot, "/ohio_forecast_rotate.rds"))

# ---- corn ---------------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  mutate(corn_rotate_cauv = scales::percent(corn_rotate_cauv, accuracy = 0.1),
         corn_rotate_odt = scales::percent(corn_rotate_odt, accuracy = 0.1),
         corn_grain_acres_harvest = scales::comma(corn_grain_acres_harvest),
         corn_harvest_cauv = scales::comma(corn_harvest_cauv)) %>% 
  select("Year" = year, "ODT Value" = corn_rotate_odt,
         "USDA Acres Harvested" = corn_grain_acres_harvest,
         "AVG Acres Harvested" = corn_harvest_cauv,
         "Projected" = corn_rotate_cauv) %>% 
  replace(is.na(.), "-") %>% 
  knitr::kable()

# ---- soy ----------------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  mutate(soy_rotate_cauv = scales::percent(soy_rotate_cauv, accuracy = 0.1),
         soy_rotate_odt = scales::percent(soy_rotate_odt, accuracy = 0.1),
         soy_acres_harvest = scales::comma(soy_acres_harvest),
         soy_harvest_cauv = scales::comma(soy_harvest_cauv)) %>% 
  select("Year" = year, "ODT Value" = soy_rotate_odt,
         "USDA Acres Harvested" = soy_acres_harvest,
         "AVG Acres Harvested" = soy_harvest_cauv,
         "Projected" = soy_rotate_cauv) %>% 
  replace(is.na(.), "-") %>% 
  knitr::kable()

# ---- wheat --------------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  mutate(wheat_rotate_cauv = scales::percent(wheat_rotate_cauv, accuracy = 0.1),
         wheat_rotate_odt = scales::percent(wheat_rotate_odt, accuracy = 0.1),
         wheat_acres_harvest = scales::comma(wheat_acres_harvest),
         wheat_harvest_cauv = scales::comma(wheat_harvest_cauv)) %>% 
  select("Year" = year, "ODT Value" = wheat_rotate_odt,
         "USDA Acres Harvested" = wheat_acres_harvest,
         "AVG Acres Harvested" = wheat_harvest_cauv,
         "Projected" = wheat_rotate_cauv) %>% 
  replace(is.na(.), "-") %>% 
  knitr::kable()
