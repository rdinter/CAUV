# Providing a calculation/projection of the Rotation in Ohio
# Suggested alternate

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
         rollapplyr(lag(crop), width = 7, FUN =  mean,
                    trim = 1/7, na.rm = T, fill = NA),
         rollapplyr(lag(crop, 2), width = 7, FUN =  mean,
                    trim = 1/7, na.rm = T, fill = NA))
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


ohio_rot <-
  rot_proj %>% 
  arrange(year) %>% 
  left_join(acre_trends) %>% 
  mutate(corn_grain_acres_harvest = if_else(is.na(corn_grain_acres_harvest),
                                            corn_trend, corn_grain_acres_harvest),
         soy_acres_harvest = if_else(is.na(soy_acres_harvest),
                                     soy_trend, soy_acres_harvest),
         wheat_acres_harvest = if_else(is.na(wheat_acres_harvest),
                                       wheat_trend, wheat_acres_harvest)) %>% 
  # fill(corn_grain_acres_harvest, soy_acres_harvest, wheat_acres_harvest) %>% 
  mutate(corn_harvest_alt    = rotate_calc(corn_grain_acres_harvest, year),
         soy_harvest_alt     = rotate_calc(soy_acres_harvest, year),
         wheat_harvest_alt   = rotate_calc(wheat_acres_harvest, year),
         total_harvest_alt   = corn_harvest_alt + soy_harvest_alt +
           wheat_harvest_alt,
         corn_rotate_alt  = corn_harvest_alt / total_harvest_alt,
         soy_rotate_alt   = soy_harvest_alt / total_harvest_alt,
         wheat_rotate_alt = wheat_harvest_alt / total_harvest_alt) %>% 
  select(year, corn_harvest_alt:wheat_rotate_alt)

ohio <- left_join(rot_proj, ohio_rot)

write.csv(ohio, paste0(rot, "/ohio_alternate_rotate.csv"),
          row.names = F)
write_rds(ohio, paste0(rot, "/ohio_alternate_rotate.rds"))

# ---- corn ---------------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  mutate(corn_rotate_alt = scales::percent(corn_rotate_alt, accuracy = 0.1),
         corn_rotate_odt = scales::percent(corn_rotate_odt, accuracy = 0.1)) %>% 
  select("Year" = year, "ODT Value" = corn_rotate_odt,
         "USDA Acres Harvested" = corn_grain_acres_harvest,
         "AVG Acres Harvested" = corn_harvest_alt,
         "Alternate" = corn_rotate_alt) %>% 
  knitr::kable()

# ---- soy ----------------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  mutate(soy_rotate_alt = scales::percent(soy_rotate_alt, accuracy = 0.1),
         soy_rotate_odt = scales::percent(soy_rotate_odt, accuracy = 0.1)) %>% 
  select("Year" = year, "ODT Value" = soy_rotate_odt,
         "USDA Acres Harvested" = soy_acres_harvest,
         "AVG Acres Harvested" = soy_harvest_alt,
         "Alternate" = soy_rotate_alt) %>% 
  knitr::kable()

# ---- wheat --------------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  mutate(wheat_rotate_alt = scales::percent(wheat_rotate_alt, accuracy = 0.1),
         wheat_rotate_odt = scales::percent(wheat_rotate_odt, accuracy = 0.1)) %>% 
  select("Year" = year, "ODT Value" = wheat_rotate_odt,
         "USDA Acres Harvested" = wheat_acres_harvest,
         "AVG Acres Harvested" = wheat_harvest_alt,
         "Alternate" = wheat_rotate_alt) %>% 
  knitr::kable()

# ---- recommendation -----------------------------------------------------


ohio %>% 
  filter(year > 2009) %>% 
  mutate(corn_rotate_alt = scales::percent(corn_rotate_alt, accuracy = 0.1),
         corn_rotate_odt = scales::percent(corn_rotate_odt, accuracy = 0.1),
         soy_rotate_alt = scales::percent(soy_rotate_alt, accuracy = 0.1),
         soy_rotate_odt = scales::percent(soy_rotate_odt, accuracy = 0.1),
         wheat_rotate_alt = scales::percent(wheat_rotate_alt, accuracy = 0.1),
         wheat_rotate_odt = scales::percent(wheat_rotate_odt, accuracy = 0.1)) %>% 
  select("Year" = year,
         "ODT Corn" = corn_rotate_odt,
         "Alt Corn" = corn_rotate_alt,
         "ODT Soybeans" = soy_rotate_odt,
         "Alt Soybeans" = soy_rotate_alt,
         "ODT Wheat" = wheat_rotate_odt,
         "Alt Wheat" = wheat_rotate_alt) %>% 
  knitr::kable()
