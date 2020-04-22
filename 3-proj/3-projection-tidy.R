# Now we project the future values, post phase-in (2020 and beyond.)

# ---- start --------------------------------------------------------------

library("ggrepel")
library("scales")
library("tidyverse")
library("viridis")
library("zoo")
dollars <- function(x, dig = 0) dollar_format(largest_with_cents = dig)(x)

# Create a directory for the data
local_dir <- "3-proj"
future    <- paste0(local_dir, "/future")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(future)) dir.create(future, recursive = T)

# # Read in all of the projected individual components, then combine.
# forecast_files <- paste0("2-calc/", c("prices/ohio_forecast_prices.rds",
#                                       "yields/ohio_forecast_crops.rds",
#                                       "rot/ohio_forecast_rotate.rds",
#                                       "nonland/ohio_forecast_nonland.rds",
#                                       "cap/ohio_forecast_caprate.rds"))
# ohio_all <- map(forecast_files, read_rds)

ohio <- read_rds("2-calc/prices/ohio_forecast_prices.rds") %>% 
  full_join(read_rds("2-calc/yields/ohio_forecast_crops.rds")) %>% 
  full_join(read_rds("2-calc/rot/ohio_forecast_rotate.rds")) %>% 
  full_join(read_rds("2-calc/nonland/ohio_forecast_nonland.rds")) %>% 
  full_join(read_rds("2-calc/cap/ohio_forecast_caprate.rds"))

# Historical CAUV minimums
cauv_minimum <- tribble(~year, ~minimum_cauv,
                        2008, 100,
                        2009, 170,
                        2010, 200,
                        2011, 300,
                        2012, 350) %>% 
  complete(year = seq(1984, max(ohio$year))) %>% 
  fill(minimum_cauv) %>% 
  fill(minimum_cauv, .direction = "up")

ohio <- left_join(ohio, cauv_minimum)

# Take out what the latest year we are projecting CAUV for is
# next_year <- max(ohio$year[!is.na(ohio$corn_price_exp)]) + 1
next_year = max(ohio$year[!is.na(ohio$corn_price)]) + 1
# next_year = 2020

# Individual soil type data.
soils      <- read_rds("0-data/soils/cauv_soils.rds") %>% 
  filter(!is.na(indx))
unadj      <- read_rds("0-data/soils/cauv_unadj.rds") %>% 
  filter(!is.na(indx))
organic    <- read_csv("3-proj/3-organic.csv")
ohio_soils <- read_rds("3-proj/future/ohio_soils_exp_2019.rds")

old_soils <- soils %>% 
  select(-cropland, -woodland) %>% 
  distinct() %>% 
  left_join(organic)
# proj_soils <- soils %>% 
#   select(-year, -cropland, -woodland) %>% 
#   distinct() %>% 
#   mutate(year = next_year) %>% 
#   left_join(organic) %>% 
#   bind_rows(old_soils)

# Projected soils by the latest year
proj_soils1 <- soils %>% 
  select(-year, -cropland, -woodland) %>% 
  distinct() %>% 
  mutate(year = next_year) %>% 
  left_join(organic) 
# Additional year for projected soils
proj_soils2 <- soils %>% 
  select(-year, -cropland, -woodland) %>% 
  distinct() %>% 
  mutate(year = next_year + 1) %>% 
  left_join(organic)
# And a second additional year for projected soils
proj_soils3 <- soils %>% 
  select(-year, -cropland, -woodland) %>% 
  distinct() %>% 
  mutate(year = next_year + 2) %>% 
  left_join(organic)
# Combined
proj_soils <- proj_soils1 %>% 
  bind_rows(proj_soils2) %>% 
  bind_rows(proj_soils3) %>% 
  bind_rows(old_soils) %>% 
  arrange(year)

# Index labels
indxs     <-  c("indx_100", "indx_99", "indx_89", "indx_79",
                "indx_69", "indx_59", "indx_49", "avg_cauv")
indx_name <- c("100", "90 to 99", "80 to 89", "70 to 79",
               "60 to 69", "50 to 59", "0 to 49", "Average")
indx_size <- c("100" = 0.5, "90 to 99" = 0.5,
               "80 to 89" = 0.5, "70 to 79" = 0.5,
               "60 to 69" = 0.5, "50 to 59" = 0.5,
               "0 to 49" = 0.5, "Average" = 2)

# ---- expected -----------------------------------------------------------

ohio_exp <- ohio %>%
  right_join(proj_soils) %>% 
  # Create projected variables only for years with ODT data unavailable
  mutate(corn_yield_adj_proj = ifelse(is.na(corn_yield_adj_odt),
                                      corn_yield_adj_cauv, corn_yield_adj_odt),
         soy_yield_adj_proj = ifelse(is.na(soy_yield_adj_odt),
                                     soy_yield_adj_cauv, soy_yield_adj_odt),
         wheat_yield_adj_proj = ifelse(is.na(wheat_yield_adj_odt),
                                       wheat_yield_adj_cauv, wheat_yield_adj_odt),
         
         corn_price_proj = ifelse(is.na(corn_price_odt), corn_price_cauv_exp,
                                  corn_price_odt),
         soy_price_proj = ifelse(is.na(soy_price_odt), soy_price_cauv_exp,
                                 soy_price_odt),
         wheat_price_proj = ifelse(is.na(wheat_price_odt), wheat_price_cauv_exp,
                                   wheat_price_odt),
         
         corn_cost_add_cauv_proj = ifelse(is.na(corn_cost_add_odt),
                                          corn_cost_add_cauv,
                                          corn_cost_add_odt),
         soy_cost_add_cauv_proj = ifelse(is.na(soy_cost_add_odt),
                                         soy_cost_add_cauv,
                                         soy_cost_add_odt),
         wheat_cost_add_cauv_proj = ifelse(is.na(wheat_cost_add_odt),
                                           wheat_cost_add_cauv,
                                           wheat_cost_add_odt),
         
         corn_base_cauv_proj = ifelse(is.na(corn_base_odt),
                                      corn_base_cauv, corn_base_odt),
         soy_base_cauv_proj = ifelse(is.na(soy_base_odt),
                                     soy_base_cauv, soy_base_odt),
         wheat_base_cauv_proj = ifelse(is.na(wheat_base_odt),
                                       wheat_base_cauv, wheat_base_odt),
         
         corn_cost_cauv_proj = ifelse(is.na(corn_cost_odt),
                                      corn_cost_cauv,
                                      corn_cost_odt),
         soy_cost_cauv_proj = ifelse(is.na(soy_cost_odt),
                                     soy_cost_cauv,
                                     soy_cost_odt),
         wheat_cost_cauv_proj = ifelse(is.na(wheat_cost_odt),
                                       wheat_cost_cauv,
                                       wheat_cost_odt),
         
         corn_rotate_cauv = ifelse(is.na(corn_rotate_odt),
                                   round(corn_rotate_cauv, 2),
                                   corn_rotate_odt),
         soy_rotate_cauv = ifelse(is.na(soy_rotate_odt),
                                  round(soy_rotate_cauv, 2),
                                  soy_rotate_odt),
         wheat_rotate_cauv = ifelse(is.na(wheat_rotate_odt),
                                    round(wheat_rotate_cauv, 2),
                                    wheat_rotate_odt),
         # Cap Rate
         cap_rate_cauv = ifelse(is.na(cap_rate_odt),
                                cap_rate_cauv_exp,
                                cap_rate_odt)) %>% 
  # Calculating the components for the CAUV calculation
  mutate(corn_yield = round(corn_base*corn_yield_adj_proj),
         soy_yield = round(soy_base*soy_yield_adj_proj),
         wheat_yield = round(wheat_base*wheat_yield_adj_proj),
         
         corn_revenue = corn_yield*corn_price_proj,
         soy_revenue = soy_yield*soy_price_proj,
         wheat_revenue = wheat_yield*wheat_price_proj,
         
         corn_cost = corn_cost_add_cauv_proj*(corn_yield - corn_base_cauv_proj) +
           corn_cost_cauv_proj,
         soy_cost = soy_cost_add_cauv_proj*(soy_yield - soy_base_cauv_proj) +
           soy_cost_cauv_proj,
         wheat_cost = wheat_cost_add_cauv_proj*(wheat_yield -
                                                 wheat_base_cauv_proj) +
           wheat_cost_cauv_proj,
         
         net_corn = corn_revenue - corn_cost,
         net_soy = soy_revenue - soy_cost,
         net_wheat = wheat_revenue - wheat_cost,
         
         net_return = corn_rotate_cauv*net_corn + soy_rotate_cauv*net_soy +
           wheat_rotate_cauv*net_wheat,
         
         organic = 0.5*net_corn + 0.5*net_soy,
         
         raw_val = round(net_return / round(cap_rate_cauv, 3),digits = -1),
         raw_val_o = round(organic / round(cap_rate_cauv, 3),digits = -1),
         
         # Careful, org_soil is supposed to be T/F for if soil is classified
         raw = ifelse(org_soil, raw_val_o, raw_val),
         
         # Pasture for 55 or less productivity index
         #raw = ifelse(prod_index < 56, minimum_cauv, raw),
         unadjusted = ifelse((raw < minimum_cauv) | (prod_index < 56),
                             minimum_cauv, raw)) %>% 
  arrange(id, year)

ohio_exp_adjusted <- ohio_exp %>% 
  group_by(id) %>% 
  mutate(phase2017 = ifelse(unadjusted[year == 2017] > unadjusted[year == 2016], 0,
                            -(unadjusted[year == 2017] - unadjusted[year == 2016]) / 2),
         phase2018 = ifelse(unadjusted[year == 2018] > (unadjusted[year == 2017] + phase2017), 0,
                            -(unadjusted[year == 2018] - (unadjusted[year == 2017] + phase2017)) / 2),
         phase2019 = ifelse(unadjusted[year == 2019] > (unadjusted[year == 2018] + phase2018), 0,
                            -(unadjusted[year == 2019] - (unadjusted[year == 2018] + phase2018)) / 2),
         cauv_projected_exp = case_when(year < 2017 ~ unadjusted,
                                        year == 2017 ~ unadjusted + phase2017,
                                        year == 2018 ~ unadjusted + phase2018,
                                        year == 2019 ~ unadjusted + phase2019,
                                        year > 2019 ~ unadjusted))

# ohio_exp %>%
#   filter(year == next_year) %>% 
#   select(year, cauv_projected_exp, soil_series:id) %>%
#   write_csv(paste0(future, "/expected_projections_", next_year, ".csv"))

ohio_soils_exp <- ohio_exp_adjusted %>% 
  group_by(year) %>% 
  mutate(val = cauv_projected_exp,
         num_soils = sum(!is.na(val)),
         avg_cauv = mean(val, na.rm = T)) %>% 
  group_by(year, indx) %>% 
  summarise(val = mean(val),
            avg_cauv = mean(avg_cauv, na.rm = T),
            num_soils = mean(num_soils)) %>% 
  ungroup() %>% 
  spread(indx, val)

# ----- low ---------------------------------------------------------------

ohio_low <- ohio %>%
  right_join(proj_soils) %>% 
  mutate(corn_yield_adj_proj = ifelse(is.na(corn_yield_adj_odt),
                                      corn_yield_adj_cauv, corn_yield_adj_odt),
         soy_yield_adj_proj = ifelse(is.na(soy_yield_adj_odt),
                                     soy_yield_adj_cauv, soy_yield_adj_odt),
         wheat_yield_adj_proj = ifelse(is.na(wheat_yield_adj_odt),
                                       wheat_yield_adj_cauv, wheat_yield_adj_odt),
         
         corn_price_proj = corn_price_cauv_l,
         soy_price_proj = soy_price_cauv_l,
         wheat_price_proj = wheat_price_cauv_l,
         
         corn_cost_add_cauv_proj = corn_cost_add_cauv_l,
         soy_cost_add_cauv_proj = soy_cost_add_cauv_l,
         wheat_cost_add_cauv_proj = wheat_cost_add_cauv_l,
         
         corn_base_cauv_proj = corn_base_cauv_l,
         soy_base_cauv_proj = soy_base_cauv_l,
         wheat_base_cauv_proj = wheat_base_cauv_l,
         
         corn_cost_cauv_proj = corn_cost_cauv_l,
         soy_cost_cauv_proj = soy_cost_cauv_l,
         wheat_cost_cauv_proj = wheat_cost_cauv_l,
         
         corn_rotate_cauv = ifelse(is.na(corn_rotate_odt),
                                   round(corn_rotate_cauv, 2),
                                   corn_rotate_odt),
         soy_rotate_cauv = ifelse(is.na(soy_rotate_odt),
                                  round(soy_rotate_cauv, 2),
                                  soy_rotate_odt),
         wheat_rotate_cauv = ifelse(is.na(wheat_rotate_odt),
                                    round(wheat_rotate_cauv, 2),
                                    wheat_rotate_odt),
         # Cap Rate
         cap_rate_cauv = ifelse(is.na(cap_rate_odt),
                                cap_rate_cauv_l,
                                cap_rate_odt)) %>% 
  # Calculating the components for the CAUV calculation
  mutate(corn_yield = round(corn_base*corn_yield_adj_proj),
         soy_yield = round(soy_base*soy_yield_adj_proj),
         wheat_yield = round(wheat_base*wheat_yield_adj_proj),
         
         corn_revenue = corn_yield*corn_price_proj,
         soy_revenue = soy_yield*soy_price_proj,
         wheat_revenue = wheat_yield*wheat_price_proj,
         
         corn_cost = corn_cost_add_cauv_proj*(corn_yield - corn_base_cauv_proj) +
           corn_cost_cauv_proj,
         soy_cost = soy_cost_add_cauv_proj*(soy_yield - soy_base_cauv_proj) +
           soy_cost_cauv_proj,
         wheat_cost = wheat_cost_add_cauv_proj*(wheat_yield -
                                                  wheat_base_cauv_proj) +
           wheat_cost_cauv_proj,
         
         net_corn = corn_revenue - corn_cost,
         net_soy = soy_revenue - soy_cost,
         net_wheat = wheat_revenue - wheat_cost,
         
         net_return = corn_rotate_cauv*net_corn + soy_rotate_cauv*net_soy +
           wheat_rotate_cauv*net_wheat,
         
         organic = 0.5*net_corn + 0.5*net_soy,
         
         raw_val = round(net_return / round(cap_rate_cauv, 3),digits = -1),
         raw_val_o = round(organic / round(cap_rate_cauv, 3),digits = -1),
         
         # Careful, org_soil is supposed to be T/F for if soil is classified
         raw = ifelse(org_soil, raw_val_o, raw_val),
         
         # Pasture for 55 or less productivity index
         #raw = ifelse(prod_index < 56, minimum_cauv, raw),
         unadjusted = ifelse((raw < minimum_cauv) | (prod_index < 56),
                             minimum_cauv, raw)) %>% 
  arrange(id, year)

ohio_low_adjusted <- ohio_low %>% 
  group_by(id) %>% 
  mutate(phase2017 = ifelse(unadjusted[year == 2017] > unadjusted[year == 2016], 0,
                            -(unadjusted[year == 2017] - unadjusted[year == 2016]) / 2),
         phase2018 = ifelse(unadjusted[year == 2018] > (unadjusted[year == 2017] + phase2017), 0,
                            -(unadjusted[year == 2018] - (unadjusted[year == 2017] + phase2017)) / 2),
         phase2019 = ifelse(unadjusted[year == 2019] > (unadjusted[year == 2018] + phase2018), 0,
                            -(unadjusted[year == 2019] - (unadjusted[year == 2018] + phase2018)) / 2),
         
         cauv_projected_low = case_when(year < 2017 ~ unadjusted,
                                year == 2017 ~ unadjusted + phase2017,
                                year == 2018 ~ unadjusted + phase2018,
                                year == 2019 ~ unadjusted + phase2019,
                                year > 2019 ~ unadjusted))

# ohio_low_adjusted %>%
#   filter(year == next_year) %>% 
#   select(year, cauv_projected_low, soil_series:id, indx) %>%
#   write_csv(paste0(future, "/low_projections_", next_year, ".csv"))

ohio_soils_low <- ohio_low_adjusted %>% 
  group_by(year) %>% 
  mutate(val = cauv_projected_low,
         num_soils = n(),
         avg_cauv = mean(val)) %>% 
  group_by(year, indx) %>% 
  summarise(val = mean(val),
            avg_cauv = mean(avg_cauv),
            num_soils = mean(num_soils)) %>% 
  ungroup() %>% 
  spread(indx, val)

# ---- high ---------------------------------------------------------------


ohio_high <- ohio %>%
  right_join(proj_soils) %>% 
  mutate(corn_yield_adj_proj = ifelse(is.na(corn_yield_adj_odt),
                                      corn_yield_adj_cauv, corn_yield_adj_odt),
         soy_yield_adj_proj = ifelse(is.na(soy_yield_adj_odt),
                                     soy_yield_adj_cauv, soy_yield_adj_odt),
         wheat_yield_adj_proj = ifelse(is.na(wheat_yield_adj_odt),
                                       wheat_yield_adj_cauv, wheat_yield_adj_odt),
         
         corn_price_proj = corn_price_cauv_h,
         soy_price_proj = soy_price_cauv_h,
         wheat_price_proj = wheat_price_cauv_h,
         
         corn_cost_add_cauv_proj = corn_cost_add_cauv_h,
         soy_cost_add_cauv_proj = soy_cost_add_cauv_h,
         wheat_cost_add_cauv_proj = wheat_cost_add_cauv_h,
         
         corn_base_cauv_proj = corn_base_cauv_h,
         soy_base_cauv_proj = soy_base_cauv_h,
         wheat_base_cauv_proj = wheat_base_cauv_h,
         
         corn_cost_cauv_proj = corn_cost_cauv_h,
         soy_cost_cauv_proj = soy_cost_cauv_h,
         wheat_cost_cauv_proj = wheat_cost_cauv_h,
         
         corn_rotate_cauv = ifelse(is.na(corn_rotate_odt),
                                   round(corn_rotate_cauv, 2),
                                   corn_rotate_odt),
         soy_rotate_cauv = ifelse(is.na(soy_rotate_odt),
                                  round(soy_rotate_cauv, 2),
                                  soy_rotate_odt),
         wheat_rotate_cauv = ifelse(is.na(wheat_rotate_odt),
                                    round(wheat_rotate_cauv, 2),
                                    wheat_rotate_odt),
         # Cap Rate
         cap_rate_cauv = ifelse(is.na(cap_rate_odt),
                                cap_rate_cauv_h,
                                cap_rate_odt)) %>% 
  # Calculating the components for the CAUV calculation
  mutate(corn_yield = round(corn_base*corn_yield_adj_proj),
         soy_yield = round(soy_base*soy_yield_adj_proj),
         wheat_yield = round(wheat_base*wheat_yield_adj_proj),
         
         corn_revenue = corn_yield*corn_price_proj,
         soy_revenue = soy_yield*soy_price_proj,
         wheat_revenue = wheat_yield*wheat_price_proj,
         
         corn_cost = corn_cost_add_cauv_proj*(corn_yield - corn_base_cauv_proj) +
           corn_cost_cauv_proj,
         soy_cost = soy_cost_add_cauv_proj*(soy_yield - soy_base_cauv_proj) +
           soy_cost_cauv_proj,
         wheat_cost = wheat_cost_add_cauv_proj*(wheat_yield -
                                                  wheat_base_cauv_proj) +
           wheat_cost_cauv_proj,
         
         net_corn = corn_revenue - corn_cost,
         net_soy = soy_revenue - soy_cost,
         net_wheat = wheat_revenue - wheat_cost,
         
         net_return = corn_rotate_cauv*net_corn + soy_rotate_cauv*net_soy +
           wheat_rotate_cauv*net_wheat,
         
         organic = 0.5*net_corn + 0.5*net_soy,
         
         raw_val = round(net_return / round(cap_rate_cauv, 3),digits = -1),
         raw_val_o = round(organic / round(cap_rate_cauv, 3),digits = -1),
         
         # Careful, org_soil is supposed to be T/F for if soil is classified
         raw = ifelse(org_soil, raw_val_o, raw_val),
         
         # Pasture for 55 or less productivity index
         #raw = ifelse(prod_index < 56, minimum_cauv, raw),
         unadjusted = ifelse((raw < minimum_cauv) | (prod_index < 56),
                             minimum_cauv, raw)) %>% 
  arrange(id, year)

ohio_high_adjusted <- ohio_high %>% 
  group_by(id) %>% 
  mutate(phase2017 = ifelse(unadjusted[year == 2017] > unadjusted[year == 2016], 0,
                            -(unadjusted[year == 2017] - unadjusted[year == 2016]) / 2),
         phase2018 = ifelse(unadjusted[year == 2018] > (unadjusted[year == 2017] + phase2017), 0,
                            -(unadjusted[year == 2018] - (unadjusted[year == 2017] + phase2017)) / 2),
         phase2019 = ifelse(unadjusted[year == 2019] > (unadjusted[year == 2018] + phase2018), 0,
                            -(unadjusted[year == 2019] - (unadjusted[year == 2018] + phase2018)) / 2),
         
         cauv_projected_high = case_when(year < 2017 ~ unadjusted,
                                        year == 2017 ~ unadjusted + phase2017,
                                        year == 2018 ~ unadjusted + phase2018,
                                        year == 2019 ~ unadjusted + phase2019,
                                        year > 2019 ~ unadjusted))

# ohio_high_adjusted %>%
#   filter(year == next_year) %>% 
#   select(year, cauv_projected_high, soil_series:id, indx) %>%
#   write_csv(paste0(future, "/high_projections_", next_year, ".csv"))

ohio_soils_high <- ohio_high_adjusted %>% 
  group_by(year) %>% 
  mutate(val = cauv_projected_high,
         num_soils = n(),
         avg_cauv = mean(val)) %>% 
  group_by(year, indx) %>% 
  summarise(val = mean(val),
            avg_cauv = mean(avg_cauv),
            num_soils = mean(num_soils)) %>% 
  ungroup() %>% 
  spread(indx, val)

# ---- projections --------------------------------------------------------

projections <- select(ohio_low, year,
                      soil_series:id, indx, cauv_projected_low = unadjusted)

projections <- ohio_high %>% 
  select(year, id, cauv_projected_high = unadjusted) %>% 
  right_join(projections)

projections <- ohio_exp %>% 
  select(year, id, cauv_projected_exp = unadjusted) %>% 
  right_join(projections) %>% 
  select(year, id, soil_series:indx,
         "Projection Expected" = cauv_projected_exp,
         "Projection Low" = cauv_projected_low,
         "Projection High" = cauv_projected_high)

# Aggregate Projections
j1 <- ohio_soils_exp %>% 
  select(year, expected = avg_cauv)
j2 <- ohio_soils_low %>% 
  select(year, low = avg_cauv)
j3 <- ohio_soils_high %>% 
  select(year, high = avg_cauv)
(ohio_soils_all <- j1 %>% 
  full_join(j2) %>% 
  full_join(j3))

# write_csv(projections, paste0(future, "/projections_", next_year, ".csv"))

# ---- save ---------------------------------------------------------------

# write_rds(ohio, paste0(future, "/ohio_", next_year, ".rds"))
# write_rds(ohio_low, paste0(future, "/ohio_low_", next_year, ".rds"))
# write_rds(ohio_high, paste0(future, "/ohio_high_", next_year, ".rds"))
# write_rds(ohio_exp, paste0(future, "/ohio_exp_", next_year, ".rds"))
# write_rds(ohio_soils, paste0(future, "/ohio_soils_", next_year, ".rds"))
# write_rds(ohio_soils_low,
#           paste0(future, "/ohio_soils_low_", next_year, ".rds"))
# write_rds(ohio_soils_high,
#           paste0(future, "/ohio_soils_high_", next_year, ".rds"))
# write_rds(ohio_soils_exp,
#           paste0(future, "/ohio_soils_exp_", next_year, ".rds"))


# ---- huh ----------------------------------------------------------------

# write_rds(ohio_exp, paste0(future, "/recreated_through_2020.rds"))

ohio_exp %>% 
  group_by(year) %>% 
  mutate(val = unadjusted,
         num_soils = n(),
         avg_cauv = mean(val, na.rm = T)) %>% 
  group_by(year, indx) %>% 
  summarise(net_corn = mean(net_corn / round(cap_rate_cauv_exp, 3)),
            avg_cauv = mean(avg_cauv)) %>% 
  spread(indx, net_corn)
# 
ohio_exp %>% 
  group_by(year) %>% 
  mutate(val = unadjusted,
         num_soils = n(),
         avg_cauv = mean(val)) %>% 
  group_by(year, indx) %>% 
  summarise(net_soy = mean(net_soy / round(cap_rate_cauv_exp, 3)),
            avg_cauv = mean(avg_cauv)) %>% 
  spread(indx, net_soy)
# 
ohio_exp %>% 
  group_by(year) %>% 
  mutate(val = unadjusted,
         num_soils = n(),
         avg_cauv = mean(val)) %>% 
  group_by(year, indx) %>% 
  summarise(net_wheat = mean(net_wheat / round(cap_rate_cauv_exp, 3)),
            avg_cauv = mean(avg_cauv)) %>% 
  spread(indx, net_wheat)
# 
ohio_exp %>% 
  group_by(year) %>% 
  mutate(val = unadjusted,
         num_soils = n(),
         avg_cauv = mean(val)) %>% 
  group_by(year, indx) %>% 
  summarise(raw = mean(raw)) %>% 
  ggplot(aes(year, raw, group = indx, color = indx)) +
  geom_line() +
  geom_line(data = filter(cauv_minimum, year > min(ohio_exp$year) - 1),
            aes(year, minimum_cauv, group = NULL, color = NULL),
            size = 2, color = "black") +
  geom_point() +
  scale_y_continuous(labels = dollar) +
  scale_color_viridis(option = "C", direction = -1,
                      end = 0.9, discrete = T) +
  scale_size_manual(values = indx_size) +
  labs(x = "", y = "", size = "Soil Productivity Index",
       color = "Soil Productivity Index",
       title = "Raw CAUV Values unadjusted for minimum") +
  theme_bw() +
  theme(legend.position = "bottom",
        legend.background = element_blank())
#
ggplot(ohio_exp, aes(year, raw, group = year)) +
  geom_jitter(aes(color = indx)) +
  geom_violin(alpha = 0.25) +
  geom_line(data = filter(cauv_minimum, year > min(ohio_exp$year) - 1),
            aes(year, minimum_cauv, group = NULL, color = NULL),
            size = 2, color = "black") +
  scale_y_continuous(labels = dollar) +
  scale_color_viridis(option = "C", direction = -1,
                      end = 0.9, discrete = T) +
  # scale_size_manual(values = indx_size) +
  labs(x = "", y = "", size = "Soil Productivity Index",
       color = "Soil Productivity Index",
       title = "Raw CAUV Values unadjusted for minimum") +
  theme_bw() +
  theme(legend.position = "bottom",
        legend.background = element_blank())



caption_proj <- paste0("Source: Dinterman and Katchova projections",
                       "\nbased on ODT/NASS/OSU Extension data",
                       "\nas of ", Sys.Date())

indxs     <-  c("indx_100", "indx_99", "indx_89", "indx_79",
                "indx_69", "indx_59", "indx_49", "avg_cauv")
indx_name <- c("100", "90 to 99", "80 to 89", "70 to 79",
               "60 to 69", "50 to 59", "0 to 49", "Average")
indx_size <- c("100" = 0.5, "90 to 99" = 0.5,
               "80 to 89" = 0.5, "70 to 79" = 0.5,
               "60 to 69" = 0.5, "50 to 59" = 0.5,
               "0 to 49" = 0.5, "Average" = 2)

ohio_soils_exp %>%
  filter(year >= next_year) %>% 
  bind_rows((filter(ohio_soils, year < next_year)), .) %>% 
  select(-num_soils) %>%
  gather(var, val, -year) %>%
  mutate(var = factor(var, levels = indxs, labels = indx_name)) %>% 
  {
    ggplot(., aes(year, val)) +
      geom_line(aes(color = var, size = var)) +
      geom_point(aes(color = var)) +
      geom_text_repel(data = filter(., year == next_year + 2),
                      aes(color = var,
                          label = dollar(val, accuracy = 1)),
                      nudge_x = 1.75, show.legend = FALSE,
                      segment.alpha = 0.5) +
      geom_vline(xintercept = next_year - 1) +
      scale_x_continuous(breaks = c(1990, 2000, 2010, 2020),
                         limits = c(1991, next_year + 3)) +
      scale_y_continuous(labels = dollar) +
      scale_color_viridis(option = "C", direction = -1,
                          end = 0.9, discrete = T) +
      scale_size_manual(values = indx_size) +
      labs(y = "per acre", x = "", size = "Soil Productivity Index",
           color = "Soil Productivity Index",
           title = "Projections for CAUV Values of Cropland",
           subtitle = "official ODT values at black line and previous",
           caption = caption_proj) +
      theme_bw() +
      theme(legend.position = c(0.2, 0.65),
            legend.background = element_blank())
  }
ggsave(filename = "3-proj/figures/cauv_expected_projections_currently.png",
      width = 10, height = 7)

# ---- etc ----------------------------------------------------------------

ohio %>%
  mutate(corn_yield_adj_proj = ifelse(is.na(corn_yield_adj_odt),
                                      corn_yield_adj_cauv, corn_yield_adj_odt),
         soy_yield_adj_proj = ifelse(is.na(soy_yield_adj_odt),
                                     soy_yield_adj_cauv, soy_yield_adj_odt),
         wheat_yield_adj_proj = ifelse(is.na(wheat_yield_adj_odt),
                                       wheat_yield_adj_cauv, wheat_yield_adj_odt),
         
         corn_price_proj = ifelse(is.na(corn_price_odt), corn_price_cauv_exp,
                                  corn_price_odt),
         soy_price_proj = ifelse(is.na(soy_price_odt), soy_price_cauv_exp,
                                 soy_price_odt),
         wheat_price_proj = ifelse(is.na(wheat_price_odt), wheat_price_cauv_exp,
                                   wheat_price_odt),
         
         corn_cost_add_cauv_proj = ifelse(is.na(corn_cost_add_odt),
                                          corn_cost_add_cauv,
                                          corn_cost_add_odt),
         soy_cost_add_cauv_proj = ifelse(is.na(soy_cost_add_odt),
                                         soy_cost_add_cauv,
                                         soy_cost_add_odt),
         wheat_cost_add_cauv_proj = ifelse(is.na(wheat_cost_add_odt),
                                           wheat_cost_add_cauv,
                                           wheat_cost_add_odt),
         
         corn_base_cauv_proj = ifelse(is.na(corn_base_odt),
                                      corn_base_cauv, corn_base_odt),
         soy_base_cauv_proj = ifelse(is.na(soy_base_odt),
                                     soy_base_cauv, soy_base_odt),
         wheat_base_cauv_proj = ifelse(is.na(wheat_base_odt),
                                       wheat_base_cauv, wheat_base_odt),
         
         corn_cost_cauv_proj = ifelse(is.na(corn_cost_odt),
                                      corn_cost_cauv,
                                      corn_cost_odt),
         soy_cost_cauv_proj = ifelse(is.na(soy_cost_odt),
                                     soy_cost_cauv,
                                     soy_cost_odt),
         wheat_cost_cauv_proj = ifelse(is.na(wheat_cost_odt),
                                       wheat_cost_cauv,
                                       wheat_cost_odt)) %>% 
  select(year, cap_rate_cauv_exp, 
         corn_rotate_cauv, corn_yield_cauv, corn_yield_adj_proj, corn_price_proj,
         corn_cost_add_cauv_proj, corn_base_cauv_proj, corn_cost_cauv_proj,
         
         soy_rotate_cauv, soy_yield_cauv, soy_yield_adj_proj, soy_price_proj,
         soy_cost_add_cauv_proj, soy_base_cauv_proj, soy_cost_cauv_proj,
         
         wheat_rotate_cauv, wheat_yield_cauv, wheat_yield_adj_proj, wheat_price_proj,
         wheat_cost_add_cauv_proj, wheat_base_cauv_proj, wheat_cost_cauv_proj) %>% 
  View()


