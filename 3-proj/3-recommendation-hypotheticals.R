# Recommendation scenarios for different ways of calculating components

# ---- start --------------------------------------------------------------

library("ggrepel")
library("scales")
library("tidyverse")
library("viridis")
library("zoo")
dollars <- function(x, dig = 0) dollar_format(largest_with_cents = dig)(x)

# Create a directory for the data
local_dir <- "3-proj"
recs      <- paste0(local_dir, "/recommendations")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(recs)) dir.create(recs, recursive = T)

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

ohio_alt <- read_rds("2-calc/prices/ohio_forecast_prices.rds") %>% 
  full_join(read_rds("2-calc/yields/ohio_alternate_crops.rds")) %>% 
  full_join(read_rds("2-calc/rot/ohio_alternate_rotate.rds")) %>% 
  full_join(read_rds("2-calc/nonland/ohio_alternate_nonland.rds")) %>% 
  full_join(read_rds("2-calc/cap/ohio_alternate_caprate.rds")) %>% 
  select(year, contains("alt"),
         cap_rate_kansas, cap_rate_dallas, cap_rate_chicago)

ohio <- left_join(ohio, ohio_alt)

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
next_year = max(ohio$year[!is.na(ohio$corn_price_cauv_exp)]) - 1
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
# Combined
proj_soils <- proj_soils1 %>% 
  bind_rows(proj_soils2) %>% 
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

# ---- nonland-alt -----------------------------------------------------------


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
         
         corn_cost_add_cauv_proj = ifelse(is.na(corn_cost_add_alt),
                                          corn_cost_add_odt,
                                          corn_cost_add_alt),
         soy_cost_add_cauv_proj = ifelse(is.na(soy_cost_add_alt),
                                         soy_cost_add_odt,
                                         soy_cost_add_alt),
         wheat_cost_add_cauv_proj = ifelse(is.na(wheat_cost_add_alt),
                                           wheat_cost_add_odt,
                                           wheat_cost_add_alt),
         
         corn_base_cauv_proj = ifelse(is.na(corn_base_odt),
                                      corn_base_yield_alt, corn_base_odt),
         soy_base_cauv_proj = ifelse(is.na(soy_base_odt),
                                     soy_base_yield_alt, soy_base_odt),
         wheat_base_cauv_proj = ifelse(is.na(wheat_base_odt),
                                       wheat_base_yield_alt, wheat_base_odt),
         
         corn_cost_cauv_proj = ifelse(is.na(corn_cost_alt),
                                      corn_cost_odt,
                                      corn_cost_alt),
         soy_cost_cauv_proj = ifelse(is.na(soy_cost_alt),
                                     soy_cost_odt,
                                     soy_cost_alt),
         wheat_cost_cauv_proj = ifelse(is.na(wheat_cost_alt),
                                       wheat_cost_odt,
                                       wheat_cost_alt)) %>% 
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
         
         raw_val = round(net_return / round(cap_rate_cauv_exp, 3),digits = -1),
         raw_val_o = round(organic / round(cap_rate_cauv_exp, 3),digits = -1),
         
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

ohio_nonland_alt <- ohio_exp_adjusted %>% 
  group_by(year) %>% 
  mutate(val = cauv_projected_exp,
         num_soils = sum(!is.na(val)),
         avg_cauv = mean(val, na.rm = T)) %>% 
  group_by(year, indx) %>% 
  summarise(val = dollar(mean(val), accuracy = 1),
            avg_cauv = dollar(mean(avg_cauv, na.rm = T), accuracy = 1)) %>% 
  ungroup() %>% 
  spread(indx, val)

write_rds(ohio_nonland_alt, paste0(recs, "/ohio_nonland_alt.rds"))

# ---- rotations ----------------------------------------------------------

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
                                       wheat_cost_odt)) %>% 
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
         
         net_return = corn_rotate_alt*net_corn + soy_rotate_alt*net_soy +
           wheat_rotate_alt*net_wheat,
         
         organic = 0.5*net_corn + 0.5*net_soy,
         
         raw_val = round(net_return / round(cap_rate_cauv_exp, 3),digits = -1),
         raw_val_o = round(organic / round(cap_rate_cauv_exp, 3),digits = -1),
         
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

ohio_rot_alt <- ohio_exp_adjusted %>% 
  group_by(year) %>% 
  mutate(val = cauv_projected_exp,
         num_soils = sum(!is.na(val)),
         avg_cauv = mean(val, na.rm = T)) %>% 
  group_by(year, indx) %>% 
  summarise(val = dollar(mean(val), accuracy = 1),
            avg_cauv = dollar(mean(avg_cauv, na.rm = T), 1)) %>% 
  ungroup() %>% 
  spread(indx, val)

write_rds(ohio_rot_alt, paste0(recs, "/ohio_rot_alt.rds"))

# ---- yields -------------------------------------------------------------

ohio_exp <- ohio %>%
  right_join(proj_soils) %>% 
  # Create projected variables only for years with ODT data unavailable
  mutate(corn_yield_adj_proj = ifelse(is.na(corn_yield_adj_alt),
                                      corn_yield_adj_odt, corn_yield_adj_alt),
         soy_yield_adj_proj = ifelse(is.na(soy_yield_adj_alt),
                                     soy_yield_adj_odt, soy_yield_adj_alt),
         wheat_yield_adj_proj = ifelse(is.na(wheat_yield_adj_alt),
                                       wheat_yield_adj_odt, wheat_yield_adj_alt),
         
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
         
         raw_val = round(net_return / round(cap_rate_cauv_exp, 3),digits = -1),
         raw_val_o = round(organic / round(cap_rate_cauv_exp, 3),digits = -1),
         
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

ohio_yield_alt <- ohio_exp_adjusted %>% 
  group_by(year) %>% 
  mutate(val = cauv_projected_exp,
         num_soils = sum(!is.na(val)),
         avg_cauv = mean(val, na.rm = T)) %>% 
  group_by(year, indx) %>% 
  summarise(val = dollar(mean(val), accuracy = 1),
            avg_cauv = dollar(mean(avg_cauv, na.rm = T), 1)) %>% 
  ungroup() %>% 
  spread(indx, val)

write_rds(ohio_yield_alt, paste0(recs, "/ohio_yield_alt.rds"))

# ---- rotations-yields ---------------------------------------------------


ohio_exp <- ohio %>%
  right_join(proj_soils) %>% 
  # Create projected variables only for years with ODT data unavailable
  mutate(corn_yield_adj_proj = ifelse(is.na(corn_yield_adj_alt),
                                      corn_yield_adj_odt, corn_yield_adj_alt),
         soy_yield_adj_proj = ifelse(is.na(soy_yield_adj_alt),
                                     soy_yield_adj_odt, soy_yield_adj_alt),
         wheat_yield_adj_proj = ifelse(is.na(wheat_yield_adj_alt),
                                       wheat_yield_adj_odt, wheat_yield_adj_alt),
         
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
         
         net_return = corn_rotate_alt*net_corn + soy_rotate_alt*net_soy +
           wheat_rotate_alt*net_wheat,
         
         organic = 0.5*net_corn + 0.5*net_soy,
         
         raw_val = round(net_return / round(cap_rate_cauv_exp, 3),digits = -1),
         raw_val_o = round(organic / round(cap_rate_cauv_exp, 3),digits = -1),
         
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

ohio_rot_yield_alt <- ohio_exp_adjusted %>% 
  group_by(year) %>% 
  mutate(val = cauv_projected_exp,
         num_soils = sum(!is.na(val)),
         avg_cauv = mean(val, na.rm = T)) %>% 
  group_by(year, indx) %>% 
  summarise(val = dollar(mean(val), accuracy = 1),
            avg_cauv = dollar(mean(avg_cauv, na.rm = T), 1)) %>% 
  ungroup() %>% 
  spread(indx, val)

write_rds(ohio_rot_yield_alt, paste0(recs, "/ohio_rot_yield_alt.rds"))

# ---- cap-rate-kc --------------------------------------------------------


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
                                       wheat_cost_odt)) %>% 
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
         
         raw_val = round(net_return / round(cap_rate_kansas, 3),digits = -1),
         raw_val_o = round(organic / round(cap_rate_kansas, 3),digits = -1),
         
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

ohio_cap_kansas <- ohio_exp_adjusted %>% 
  group_by(year) %>% 
  mutate(val = cauv_projected_exp,
         num_soils = sum(!is.na(val)),
         avg_cauv = mean(val, na.rm = T)) %>% 
  group_by(year, indx) %>% 
  summarise(val = dollar(mean(val), accuracy = 1),
            avg_cauv = dollar(mean(avg_cauv, na.rm = T), 1)) %>% 
  ungroup() %>% 
  spread(indx, val)

write_rds(ohio_cap_kansas, paste0(recs, "/ohio_cap_kansas.rds"))

# ---- cap-rate-dallas --------------------------------------------------------


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
                                       wheat_cost_odt)) %>% 
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
         
         raw_val = round(net_return / round(cap_rate_dallas, 3),digits = -1),
         raw_val_o = round(organic / round(cap_rate_dallas, 3),digits = -1),
         
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

ohio_cap_dallas <- ohio_exp_adjusted %>% 
  group_by(year) %>% 
  mutate(val = cauv_projected_exp,
         num_soils = sum(!is.na(val)),
         avg_cauv = mean(val, na.rm = T)) %>% 
  group_by(year, indx) %>% 
  summarise(val = dollar(mean(val), accuracy = 1),
            avg_cauv = dollar(mean(avg_cauv, na.rm = T), 1)) %>% 
  ungroup() %>% 
  spread(indx, val)

write_rds(ohio_cap_dallas, paste0(recs, "/ohio_cap_dallas.rds"))


# ---- cap-rate-chicago --------------------------------------------------------


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
                                       wheat_cost_odt)) %>% 
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
         
         raw_val = round(net_return / round(cap_rate_chicago, 3),digits = -1),
         raw_val_o = round(organic / round(cap_rate_chicago, 3),digits = -1),
         
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

ohio_cap_chicago <- ohio_exp_adjusted %>% 
  group_by(year) %>% 
  mutate(val = cauv_projected_exp,
         num_soils = sum(!is.na(val)),
         avg_cauv = mean(val, na.rm = T)) %>% 
  group_by(year, indx) %>% 
  summarise(val = dollar(mean(val), accuracy = 1),
            avg_cauv = dollar(mean(avg_cauv, na.rm = T), 1)) %>% 
  ungroup() %>% 
  spread(indx, val)

write_rds(ohio_cap_chicago, paste0(recs, "/ohio_cap_chicago.rds"))

# ---- same-dates ---------------------------------------------------------

ohio_exp <- ohio %>%
  # Adjust the years to be correct, this is twice lagged cap rate
  mutate(cap_rate_cauv_exp_lag = ifelse(year > 2014, lag(cap_rate_cauv_exp),
                                        lag(cap_rate_cauv_exp, 2)),
         corn_cost_add_odt_lag = lag(corn_cost_add_odt),
         soy_cost_add_odt_lag = lag(soy_cost_add_odt),
         wheat_cost_add_odt_lag = lag(wheat_cost_add_odt),
         
         corn_cost_add_cauv_lag = lag(corn_cost_add_cauv),
         soy_cost_add_cauv_lag = lag(soy_cost_add_cauv),
         wheat_cost_add_cauv_lag = lag(wheat_cost_add_cauv),
         
         corn_cost_odt_lag = lag(corn_cost_odt),
         soy_cost_odt_lag = lag(soy_cost_odt),
         wheat_cost_odt_lag = lag(wheat_cost_odt),
         
         corn_cost_cauv_lag = lag(corn_cost_cauv),
         soy_cost_cauv_lag = lag(soy_cost_cauv),
         wheat_cost_cauv_lag = lag(wheat_cost_cauv)) %>% 
  right_join(proj_soils) %>% 
  # Create projected variables only for years with ODT data unavailable
  mutate(corn_yield_adj_proj = ifelse(is.na(corn_yield_adj_alt),
                                      corn_yield_adj_odt, corn_yield_adj_alt),
         soy_yield_adj_proj = ifelse(is.na(soy_yield_adj_alt),
                                     soy_yield_adj_odt, soy_yield_adj_alt),
         wheat_yield_adj_proj = ifelse(is.na(wheat_yield_adj_alt),
                                       wheat_yield_adj_odt, wheat_yield_adj_alt),
         
         corn_price_proj = ifelse(is.na(corn_price_odt), corn_price_cauv_exp,
                                  corn_price_odt),
         soy_price_proj = ifelse(is.na(soy_price_odt), soy_price_cauv_exp,
                                 soy_price_odt),
         wheat_price_proj = ifelse(is.na(wheat_price_odt), wheat_price_cauv_exp,
                                   wheat_price_odt),
         
         corn_cost_add_cauv_proj = ifelse(is.na(corn_cost_add_odt_lag),
                                          corn_cost_add_cauv_lag,
                                          corn_cost_add_odt_lag),
         soy_cost_add_cauv_proj = ifelse(is.na(soy_cost_add_odt_lag),
                                         soy_cost_add_cauv_lag,
                                         soy_cost_add_odt_lag),
         wheat_cost_add_cauv_proj = ifelse(is.na(wheat_cost_add_odt_lag),
                                           wheat_cost_add_cauv_lag,
                                           wheat_cost_add_odt_lag),
         
         corn_base_cauv_proj = ifelse(is.na(corn_base_odt),
                                      corn_base_cauv, corn_base_odt),
         soy_base_cauv_proj = ifelse(is.na(soy_base_odt),
                                     soy_base_cauv, soy_base_odt),
         wheat_base_cauv_proj = ifelse(is.na(wheat_base_odt),
                                       wheat_base_cauv, wheat_base_odt),
         
         corn_cost_cauv_proj = ifelse(is.na(corn_cost_odt_lag),
                                      corn_cost_cauv_lag,
                                      corn_cost_odt_lag),
         soy_cost_cauv_proj = ifelse(is.na(soy_cost_odt_lag),
                                     soy_cost_cauv_lag,
                                     soy_cost_odt_lag),
         wheat_cost_cauv_proj = ifelse(is.na(wheat_cost_odt_lag),
                                       wheat_cost_cauv_lag,
                                       wheat_cost_odt_lag)) %>% 
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
         
         net_return = corn_rotate_alt*net_corn + soy_rotate_alt*net_soy +
           wheat_rotate_alt*net_wheat,
         
         organic = 0.5*net_corn + 0.5*net_soy,
         
         raw_val = round(net_return / round(cap_rate_cauv_exp_lag, 3),digits = -1),
         raw_val_o = round(organic / round(cap_rate_cauv_exp_lag, 3),digits = -1),
         
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

ohio_same_dates <- ohio_exp_adjusted %>% 
  group_by(year) %>% 
  mutate(val = cauv_projected_exp,
         num_soils = sum(!is.na(val)),
         avg_cauv = mean(val, na.rm = T)) %>% 
  group_by(year, indx) %>% 
  summarise(val = dollar(mean(val), accuracy = 1),
            avg_cauv = dollar(mean(avg_cauv, na.rm = T), 1)) %>% 
  ungroup() %>% 
  spread(indx, val)

write_rds(ohio_same_dates, paste0(recs, "/ohio_same_dates.rds"))

# ---- all-implemented ----------------------------------------------------

ohio_exp <-
  ohio %>%
  # Adjust the years to be correct, this is twice lagged cap rate
  mutate(cap_rate_cauv_exp_lag = ifelse(year > 2014, lag(cap_rate_kansas),
                                        lag(cap_rate_kansas, 2)),
         corn_cost_add_odt_lag = lag(corn_cost_add_alt),
         soy_cost_add_odt_lag = lag(soy_cost_add_alt),
         wheat_cost_add_odt_lag = lag(wheat_cost_add_alt),

         corn_cost_add_cauv_lag = lag(corn_cost_add_alt),
         soy_cost_add_cauv_lag = lag(soy_cost_add_alt),
         wheat_cost_add_cauv_lag = lag(wheat_cost_add_alt),

         corn_cost_odt_lag = lag(corn_cost_alt),
         soy_cost_odt_lag = lag(soy_cost_alt),
         wheat_cost_odt_lag = lag(wheat_cost_alt),

         corn_cost_cauv_lag = lag(corn_cost_alt),
         soy_cost_cauv_lag = lag(soy_cost_alt),
         wheat_cost_cauv_lag = lag(wheat_cost_alt)) %>%
  right_join(proj_soils) %>%
  # Create projected variables only for years with ODT data unavailable
  mutate(corn_yield_adj_proj = ifelse(is.na(corn_yield_adj_alt),
                                      corn_yield_adj_odt, corn_yield_adj_alt),
         soy_yield_adj_proj = ifelse(is.na(soy_yield_adj_alt),
                                     soy_yield_adj_odt, soy_yield_adj_alt),
         wheat_yield_adj_proj = ifelse(is.na(wheat_yield_adj_alt),
                                       wheat_yield_adj_odt, wheat_yield_adj_alt),

         corn_price_proj = ifelse(is.na(corn_price_odt), corn_price_cauv_exp,
                                  corn_price_odt),
         soy_price_proj = ifelse(is.na(soy_price_odt), soy_price_cauv_exp,
                                 soy_price_odt),
         wheat_price_proj = ifelse(is.na(wheat_price_odt), wheat_price_cauv_exp,
                                   wheat_price_odt),

         corn_cost_add_cauv_proj = ifelse(is.na(corn_cost_add_odt_lag),
                                          corn_cost_add_cauv_lag,
                                          corn_cost_add_odt_lag),
         soy_cost_add_cauv_proj = ifelse(is.na(soy_cost_add_odt_lag),
                                         soy_cost_add_cauv_lag,
                                         soy_cost_add_odt_lag),
         wheat_cost_add_cauv_proj = ifelse(is.na(wheat_cost_add_odt_lag),
                                           wheat_cost_add_cauv_lag,
                                           wheat_cost_add_odt_lag),
         
         corn_base_cauv_proj = ifelse(is.na(corn_base_odt),
                                      corn_base_yield_alt, corn_base_odt),
         soy_base_cauv_proj = ifelse(is.na(soy_base_odt),
                                     soy_base_yield_alt, soy_base_odt),
         wheat_base_cauv_proj = ifelse(is.na(wheat_base_odt),
                                       wheat_base_yield_alt, wheat_base_odt),
         
         corn_cost_cauv_proj = ifelse(is.na(corn_cost_odt_lag),
                                      corn_cost_cauv_lag,
                                      corn_cost_odt_lag),
         soy_cost_cauv_proj = ifelse(is.na(soy_cost_odt_lag),
                                     soy_cost_cauv_lag,
                                     soy_cost_odt_lag),
         wheat_cost_cauv_proj = ifelse(is.na(wheat_cost_odt_lag),
                                       wheat_cost_cauv_lag,
                                       wheat_cost_odt_lag)) %>%
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

         net_return = corn_rotate_alt*net_corn + soy_rotate_alt*net_soy +
           wheat_rotate_alt*net_wheat,

         organic = 0.5*net_corn + 0.5*net_soy,

         raw_val = round(net_return / round(cap_rate_cauv_exp_lag, 3),digits = -1),
         raw_val_o = round(organic / round(cap_rate_cauv_exp_lag, 3),digits = -1),

         # Careful, org_soil is supposed to be T/F for if soil is classified
         raw = ifelse(org_soil, raw_val_o, raw_val),

         # Pasture for 55 or less productivity index
         #raw = ifelse(prod_index < 56, minimum_cauv, raw),
         unadjusted = ifelse((raw < minimum_cauv) | (prod_index < 56),
                             minimum_cauv, raw)) %>%
  arrange(id, year)

ohio_exp_adjusted <-
  ohio_exp %>%
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

ohio_all_implemented <-
  ohio_exp_adjusted %>%
  group_by(year) %>%
  mutate(val = cauv_projected_exp,
         num_soils = sum(!is.na(val)),
         avg_cauv = mean(val, na.rm = T)) %>%
  group_by(year, indx) %>%
  summarise(val = dollar(mean(val), accuracy = 1),
            avg_cauv = dollar(mean(avg_cauv, na.rm = T), 1)) %>%
  ungroup() %>%
  spread(indx, val)

write_rds(ohio_all_implemented, paste0(recs, "/ohio_all_implemented.rds"))


# ---- all-withoutdates ----------------------------------------------------

ohio_exp <-
  ohio %>%
  right_join(proj_soils) %>%
  # Create projected variables only for years with ODT data unavailable
  mutate(corn_yield_adj_proj = ifelse(is.na(corn_yield_adj_alt),
                                      corn_yield_adj_odt, corn_yield_adj_alt),
         soy_yield_adj_proj = ifelse(is.na(soy_yield_adj_alt),
                                     soy_yield_adj_odt, soy_yield_adj_alt),
         wheat_yield_adj_proj = ifelse(is.na(wheat_yield_adj_alt),
                                       wheat_yield_adj_odt, wheat_yield_adj_alt),
         
         corn_price_proj = ifelse(is.na(corn_price_odt), corn_price_cauv_exp,
                                  corn_price_odt),
         soy_price_proj = ifelse(is.na(soy_price_odt), soy_price_cauv_exp,
                                 soy_price_odt),
         wheat_price_proj = ifelse(is.na(wheat_price_odt), wheat_price_cauv_exp,
                                   wheat_price_odt),
         
         corn_cost_add_cauv_proj = ifelse(is.na(corn_cost_add_alt),
                                          corn_cost_add_odt,
                                          corn_cost_add_alt),
         soy_cost_add_cauv_proj = ifelse(is.na(soy_cost_add_alt),
                                         soy_cost_add_odt,
                                         soy_cost_add_alt),
         wheat_cost_add_cauv_proj = ifelse(is.na(wheat_cost_add_alt),
                                           wheat_cost_add_odt,
                                           wheat_cost_add_alt),
         
         corn_base_cauv_proj = ifelse(is.na(corn_base_odt),
                                      corn_base_yield_alt, corn_base_odt),
         soy_base_cauv_proj = ifelse(is.na(soy_base_odt),
                                     soy_base_yield_alt, soy_base_odt),
         wheat_base_cauv_proj = ifelse(is.na(wheat_base_odt),
                                       wheat_base_yield_alt, wheat_base_odt),
         
         corn_cost_cauv_proj = ifelse(is.na(corn_cost_alt),
                                      corn_cost_odt,
                                      corn_cost_alt),
         soy_cost_cauv_proj = ifelse(is.na(soy_cost_alt),
                                     soy_cost_odt,
                                     soy_cost_alt),
         wheat_cost_cauv_proj = ifelse(is.na(wheat_cost_alt),
                                       wheat_cost_odt,
                                       wheat_cost_alt)) %>%
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
         
         net_return = corn_rotate_alt*net_corn + soy_rotate_alt*net_soy +
           wheat_rotate_alt*net_wheat,
         
         organic = 0.5*net_corn + 0.5*net_soy,
         
         raw_val = round(net_return / round(cap_rate_kansas, 3),digits = -1),
         raw_val_o = round(organic / round(cap_rate_kansas, 3),digits = -1),
         
         # Careful, org_soil is supposed to be T/F for if soil is classified
         raw = ifelse(org_soil, raw_val_o, raw_val),
         
         # Pasture for 55 or less productivity index
         #raw = ifelse(prod_index < 56, minimum_cauv, raw),
         unadjusted = ifelse((raw < minimum_cauv) | (prod_index < 56),
                             minimum_cauv, raw)) %>%
  arrange(id, year)

ohio_exp_adjusted <-
  ohio_exp %>%
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

ohio_all_withoutdates <-
  ohio_exp_adjusted %>%
  group_by(year) %>%
  mutate(val = cauv_projected_exp,
         num_soils = sum(!is.na(val)),
         avg_cauv = mean(val, na.rm = T)) %>%
  group_by(year, indx) %>%
  summarise(val = dollar(mean(val), accuracy = 1),
            avg_cauv = dollar(mean(avg_cauv, na.rm = T), 1)) %>%
  ungroup() %>%
  spread(indx, val)

write_rds(ohio_all_withoutdates, paste0(recs, "/ohio_all_withoutdates.rds"))
