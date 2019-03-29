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

# Add on an additional year for Rotation:
rot_proj <- tibble(year = max(j5$year) + 1) %>% 
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

ohio_rot <- rot_proj %>% 
  arrange(year) %>% 
  fill(corn_grain_acres_harvest, soy_acres_harvest, wheat_acres_harvest) %>% 
  mutate(corn_harvest_cauv    = rotate_calc(corn_grain_acres_harvest, year),
         soy_harvest_cauv     = rotate_calc(soy_acres_harvest, year),
         wheat_harvest_cauv   = rotate_calc(wheat_acres_harvest, year),
         total_harvest_cauv   = rollapplyr(corn_harvest_cauv +
                                             soy_harvest_cauv +
                                             wheat_harvest_cauv, 5, mean,
                                           fill = NA),
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
  select("Year" = year, "ODT Value" = corn_rotate_odt,
         "USDA Acres Harvested" = corn_grain_acres_harvest,
         "AVG Acres Harvested" = corn_harvest_cauv,
         "Projected" = corn_rotate_cauv) %>% 
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
