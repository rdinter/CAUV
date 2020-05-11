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

ohio_nonland <- read_csv("0-data/osu_budget/osu_budgets - alternate-method.csv") %>% 
  filter(level == "l1_low") %>% 
  select(year, crop, total_less_land) %>% 
  pivot_wider(names_from = crop, names_prefix = "base_cost_",
              id_cols = year, values_from = total_less_land)

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
                                      corn_yield_adj_cauv,
                                      corn_yield_adj_odt),
         soy_yield_adj_proj = ifelse(is.na(soy_yield_adj_odt),
                                     soy_yield_adj_cauv,
                                     soy_yield_adj_odt),
         wheat_yield_adj_proj = ifelse(is.na(wheat_yield_adj_odt),
                                       wheat_yield_adj_cauv,
                                       wheat_yield_adj_odt),
         
         corn_price_proj = ifelse(is.na(corn_price_odt),
                                  corn_price_cauv_exp,
                                  corn_price_odt),
         soy_price_proj = ifelse(is.na(soy_price_odt),
                                 soy_price_cauv_exp,
                                 soy_price_odt),
         wheat_price_proj = ifelse(is.na(wheat_price_odt),
                                   wheat_price_cauv_exp,
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
                                      corn_base_cauv,
                                      corn_base_odt),
         soy_base_cauv_proj = ifelse(is.na(soy_base_odt),
                                     soy_base_cauv,
                                     soy_base_odt),
         wheat_base_cauv_proj = ifelse(is.na(wheat_base_odt),
                                       wheat_base_cauv,
                                       wheat_base_odt),
         
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
         
         corn_cost = corn_cost_add_cauv_proj*(corn_yield -
                                                corn_base_cauv_proj) +
           corn_cost_cauv_proj,
         soy_cost = soy_cost_add_cauv_proj*(soy_yield -
                                              soy_base_cauv_proj) +
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
  mutate(phase2017 = ifelse(unadjusted[year == 2017] > unadjusted[year == 2016],
                            0,
                            -(unadjusted[year == 2017] -
                                unadjusted[year == 2016]) / 2),
         phase2018 = ifelse(unadjusted[year == 2018] >
                              (unadjusted[year == 2017] + phase2017),
                            0,
                            -(unadjusted[year == 2018] -
                                (unadjusted[year == 2017] + phase2017)) / 2),
         phase2019 = ifelse(unadjusted[year == 2019] >
                              (unadjusted[year == 2018] + phase2018),
                            0,
                            -(unadjusted[year == 2019] -
                                (unadjusted[year == 2018] + phase2018)) / 2),
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

# Unadjusted
ohio_soils_exp_unadj <- ohio_exp_adjusted %>% 
  group_by(year) %>% 
  mutate(val = unadjusted,
         num_soils = sum(!is.na(val)),
         avg_cauv = mean(unadjusted, na.rm = T)) %>% 
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
                                      corn_yield_adj_cauv,
                                      corn_yield_adj_odt),
         soy_yield_adj_proj = ifelse(is.na(soy_yield_adj_odt),
                                     soy_yield_adj_cauv,
                                     soy_yield_adj_odt),
         wheat_yield_adj_proj = ifelse(is.na(wheat_yield_adj_odt),
                                       wheat_yield_adj_cauv,
                                       wheat_yield_adj_odt),
         
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
         
         corn_cost = corn_cost_add_cauv_proj*(corn_yield -
                                                corn_base_cauv_proj) +
           corn_cost_cauv_proj,
         soy_cost = soy_cost_add_cauv_proj*(soy_yield -
                                              soy_base_cauv_proj) +
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
  mutate(phase2017 = ifelse(unadjusted[year == 2017] > unadjusted[year == 2016],
                            0,
                            -(unadjusted[year == 2017] -
                                unadjusted[year == 2016]) / 2),
         phase2018 = ifelse(unadjusted[year == 2018] >
                              (unadjusted[year == 2017] + phase2017),
                            0,
                            -(unadjusted[year == 2018] -
                                (unadjusted[year == 2017] + phase2017)) / 2),
         phase2019 = ifelse(unadjusted[year == 2019] >
                              (unadjusted[year == 2018] + phase2018),
                            0,
                            -(unadjusted[year == 2019] -
                                (unadjusted[year == 2018] + phase2018)) / 2),
         
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
                                      corn_yield_adj_cauv,
                                      corn_yield_adj_odt),
         soy_yield_adj_proj = ifelse(is.na(soy_yield_adj_odt),
                                     soy_yield_adj_cauv,
                                     soy_yield_adj_odt),
         wheat_yield_adj_proj = ifelse(is.na(wheat_yield_adj_odt),
                                       wheat_yield_adj_cauv,
                                       wheat_yield_adj_odt),
         
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
         
         corn_cost = corn_cost_add_cauv_proj*(corn_yield -
                                                corn_base_cauv_proj) +
           corn_cost_cauv_proj,
         soy_cost = soy_cost_add_cauv_proj*(soy_yield -
                                              soy_base_cauv_proj) +
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
         
         raw_val = round(net_return / round(cap_rate_cauv, 3), digits = -1),
         raw_val_o = round(organic / round(cap_rate_cauv, 3), digits = -1),
         
         # Careful, org_soil is supposed to be T/F for if soil is classified
         raw = ifelse(org_soil, raw_val_o, raw_val),
         
         # Pasture for 55 or less productivity index
         #raw = ifelse(prod_index < 56, minimum_cauv, raw),
         unadjusted = ifelse((raw < minimum_cauv) | (prod_index < 56),
                             minimum_cauv, raw)) %>% 
  arrange(id, year)

ohio_high_adjusted <- ohio_high %>% 
  group_by(id) %>% 
  mutate(phase2017 = ifelse(unadjusted[year == 2017] > unadjusted[year == 2016],
                            0,
                            -(unadjusted[year == 2017] -
                                unadjusted[year == 2016]) / 2),
         phase2018 = ifelse(unadjusted[year == 2018] >
                              (unadjusted[year == 2017] + phase2017),
                            0,
                            -(unadjusted[year == 2018] -
                                (unadjusted[year == 2017] + phase2017)) / 2),
         phase2019 = ifelse(unadjusted[year == 2019] >
                              (unadjusted[year == 2018] + phase2018),
                            0,
                            -(unadjusted[year == 2019] -
                                (unadjusted[year == 2018] + phase2018)) / 2),
         
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

# Year values for projections
proj_years <- unique(projections$year)

map(proj_years, function(x) {
  projections %>% 
    filter(year == x) %>% 
    write_csv(paste0(future, "/projections_tidy_", x, ".csv"))
})

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

# ---- update-map ---------------------------------------------------------

ohio_updates <- read_csv("0-data/odt/tax_reappraisals.csv") %>% 
  rowwise() %>% 
  mutate(new_values = max(update, reappraisal)) %>% 
  mutate(new_values = case_when(new_values == 2015 ~ 2021,
                                new_values == 2016 ~ 2022,
                                new_values == 2017 ~ 2020))

ohio_map <- map_data("county", "Ohio") %>%
  rename(county = subregion) %>% 
  right_join(ohio_updates)

# add in county names as a lat/long object ?
county_poly      <- maps::map("county", "ohio", plot = FALSE, fill = TRUE)
county_centroids <- maps:::apply.polygon(county_poly, maps:::centroid.polygon)
county_centroids <- county_centroids[!is.na(names(county_centroids))]
centroid_array   <- Reduce(rbind, county_centroids)
dimnames(centroid_array) <- list(gsub("[^,]*,", "", names(county_centroids)),
                                 c("long", "lat"))
cnames <- as.data.frame(centroid_array)
cnames$county <- rownames(cnames)


ohio_theme <-    theme(axis.line = element_blank(),
                       axis.text.x = element_blank(),
                       axis.text.y = element_blank(),
                       axis.ticks = element_blank(),
                       axis.title.x = element_blank(),
                       axis.title.y = element_blank(),
                       panel.grid.major = element_blank(),
                       panel.grid.minor = element_blank(),
                       panel.border = element_blank(),
                       panel.background = element_blank(),
                       legend.position = "right")


ohio_map %>% 
  ggplot(aes(long, lat)) +
  geom_polygon(aes(group = group, fill = as.factor(new_values))) +
  geom_path(aes(group = group), size = 0.05) +
  geom_text(data = cnames, aes(label = county), size = 3, color = "black") +
  scale_fill_viridis(option = "C", discrete = T, begin = 0.35) +
  labs(fill = "", title = "Schedule for CAUV Update",
       caption = paste0("Source: Dinterman and Kathocva projections",
                        "\nbased on ODT data")) +
  ohio_theme + 
  theme(legend.position = c(0.15, 0.95), legend.direction = "horizontal")


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



# ---- cauv-expected ------------------------------------------------------

caption_proj <- paste0("Source: Dinterman and Kathocva projections",
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
                      nudge_x = 1.75, show.legend = FALSE, direction = "y",
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

# ---- cauv-unadj ------------------------------------------------------

caption_proj <- paste0("Source: Dinterman and Kathocva projections",
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

ohio_soils_exp_unadj %>%
  filter(year >= 2017) %>% 
  bind_rows((filter(ohio_soils, year < 2017)), .) %>% 
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
                      nudge_x = 1.75, show.legend = FALSE, direction = "y",
                      segment.alpha = 0.5) +
      scale_x_continuous(breaks = c(1990, 2000, 2010, 2020),
                         limits = c(1991, next_year + 3)) +
      scale_y_continuous(labels = dollar) +
      scale_color_viridis(option = "C", direction = -1,
                          end = 0.9, discrete = T) +
      scale_size_manual(values = indx_size) +
      labs(y = "per acre", x = "", size = "Soil Productivity Index",
           color = "Soil Productivity Index",
           title = "Projections for CAUV Values of Cropland Without Phase-In",
           # subtitle = "official ODT values at black line and previous",
           caption = caption_proj) +
      theme_bw() +
      theme(legend.position = c(0.2, 0.65),
            legend.background = element_blank())
  }

# ---- cauv-high ------------------------------------------------------

caption_proj <- paste0("Source: Dinterman and Kathocva projections",
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

ohio_soils_high %>%
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
                      nudge_x = 1.75, show.legend = FALSE, direction = "y",
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
           title = "High Projections for CAUV Values of Cropland",
           subtitle = "official ODT values at black line and previous",
           caption = caption_proj) +
      theme_bw() +
      theme(legend.position = c(0.2, 0.65),
            legend.background = element_blank())
  }

# ---- cauv-low ------------------------------------------------------

caption_proj <- paste0("Source: Dinterman and Kathocva projections",
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

ohio_soils_low %>%
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
                      nudge_x = 1.75, show.legend = FALSE, direction = "y",
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
           title = "Low Projections for CAUV Values of Cropland",
           subtitle = "official ODT values at black line and previous",
           caption = caption_proj) +
      theme_bw() +
      theme(legend.position = c(0.2, 0.65),
            legend.background = element_blank())
  }


# ---- corn-rot -----------------------------------------------------------

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
  knitr::kable(caption = "Historical Corn Rotation")

# ---- soy-rot ------------------------------------------------------------

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
  knitr::kable(caption = "Historical Soybean Rotation")

# ---- wheat-rot ----------------------------------------------------------

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
  knitr::kable(caption = "Historical Wheat Rotation")


# ---- viz-nonland --------------------------------------------------------

# Actual base costs?
osu_nonland <- ohio_nonland %>%
  select(year, `Corn Costs` = base_cost_corn,
         `Soy Costs` = base_cost_soy,
         `Wheat Costs` = base_cost_wheat) %>%
  gather(var, val, -year) %>%
  filter(!is.na(val), year != 2020)

ohio %>% 
  filter(year > 2005) %>% 
  select(year, `Corn Costs` = corn_cost_cauv, `Soy Costs` = soy_cost_cauv,
         `Wheat Costs` = wheat_cost_cauv) %>% 
  gather(var, val, -year) %>% 
  mutate(indicator = year > 2019) %>% 
  ggplot(aes(year, val, color = var, linetype = indicator)) +
  geom_line() +
  geom_point(data = osu_nonland, aes(shape = var, linetype = NULL), size = 2) +
  scale_y_continuous(labels = dollar) +
  scale_linetype(guide = "none") +
  # scale_x_continuous(breaks = c(2005, 2010, 2015, 2019),
  #                    limits = c(2005, 2019)) +
  scale_color_viridis(option = "C", end = 0.9, discrete = T) +
  labs(x = "", y = "", color = "", shape = "",
       title = "Commodity Base Costs in Ohio",
       subtitle = paste0("points are marketing year costs per OSU",
                         "\nsolid lines are values used in CAUV calculation",
                         "\ndashed lines are projected values"),
       caption = paste0("Source: Dinterman and Kathocva projections",
                        "\nbased on ODT and OSU Extension data")) +
  theme_bw() +
  theme(legend.position = "bottom", legend.background = element_blank())


# ---- corn-base ----------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  select("Year" = year, "ODT Base Cost" = corn_cost_odt,
         "Low Projection" = corn_cost_cauv_l,
         "Expected Projection" = corn_cost_cauv,
         "High Projection" = corn_cost_cauv_h) %>% 
  mutate_at(vars(-Year), ~replace(scales::dollar(., accuracy = 0.01),
                                  is.na(.), "-")) %>% 
  knitr::kable(caption = "Historical Corn Base Costs")

# ---- corn-add -----------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  select("Year" = year, "ODT Add Cost" = corn_cost_add_odt,
         "Low Projection" = corn_cost_add_cauv_l,
         "Expected Projection" = corn_cost_add_cauv,
         "High Projection" = corn_cost_add_cauv_h) %>% 
  mutate_at(vars(-Year), ~replace(scales::dollar(., accuracy = 0.01),
                                  is.na(.), "-")) %>% 
  knitr::kable(caption = "Historical Corn Additional Costs")

# ---- soy-base ----------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  select("Year" = year, "ODT Base Cost" = soy_cost_odt,
         "Low Projection" = soy_cost_cauv_l,
         "Expected Projection" = soy_cost_cauv,
         "High Projection" = soy_cost_cauv_h) %>% 
  mutate_at(vars(-Year), ~replace(scales::dollar(., accuracy = 0.01),
                                  is.na(.), "-")) %>% 
  knitr::kable(caption = "Historical Soybean Base Costs")

# ---- soy-add -----------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  select("Year" = year, "ODT Add Cost" = soy_cost_add_odt,
         "Low Projection" = soy_cost_add_cauv_l,
         "Expected Projection" = soy_cost_add_cauv,
         "High Projection" = soy_cost_add_cauv_h) %>% 
  mutate_at(vars(-Year), ~replace(replace(scales::dollar(., accuracy = 0.01),
                                          is.na(.), "-"), is.na(.), "-")) %>% 
  knitr::kable(caption = "Historical Soybean Additional Costs")

# ---- wheat-base ----------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  select("Year" = year, "ODT Base Cost" = wheat_cost_odt,
         "Low Projection" = wheat_cost_cauv_l,
         "Expected Projection" = wheat_cost_cauv,
         "High Projection" = wheat_cost_cauv_h) %>% 
  mutate_at(vars(-Year), ~replace(scales::dollar(., accuracy = 0.01),
                                  is.na(.), "-")) %>% 
  knitr::kable(caption = "Historical Wheat Base Costs")

# ---- wheat-add -----------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  select("Year" = year, "ODT Add Cost" = wheat_cost_add_odt,
         "Low Projection" = wheat_cost_add_cauv_l,
         "Expected Projection" = wheat_cost_add_cauv,
         "High Projection" = wheat_cost_add_cauv_h) %>% 
  mutate_at(vars(-Year), ~replace(scales::dollar(., accuracy = 0.01),
                                  is.na(.), "-")) %>% 
  knitr::kable(caption = "Historical Wheat Additional Costs")


# ---- viz-prices ---------------------------------------------------------

odt_price_vals <- ohio %>% 
  select(year, `Corn Price` = corn_price_cauv,
         `Soy Price` = soy_price_cauv,
         `Wheat Price` = wheat_price_cauv) %>% 
  gather(var, val, -year) %>% 
  filter(!is.na(val), year > 2005) %>% 
  mutate(indicator = year > 2019)

ohio %>% 
  filter(year > 2000) %>% 
  select(year, `Corn Price` = corn_price, `Soy Price` = soy_price,
         `Wheat Price` = wheat_price) %>% 
  gather(var, val, -year) %>% 
  ggplot(aes(year, val, color = var)) +
  # geom_line(linetype = 2) +
  geom_line(data = odt_price_vals, aes(linetype = indicator), size = 1) +
  geom_point(aes(shape = var), size = 2) +
  scale_y_continuous(labels = dollar, limits = c(0, 16)) +
  scale_linetype(guide = "none") +
  # scale_x_continuous(breaks = c(1990, 2000, 2010, 2019),
  #                    limits = c(1990, 2019)) +
  scale_color_viridis(option = "C", end = 0.9, discrete = T) +
  labs(x = "", y = "", color = "", shape = "",
       title = "Commodity Prices in Ohio",
       subtitle = paste0("points are marketing year prices per USDA",
                         "\nsolid lines are values used in CAUV calculation",
                         "\ndashed lines are projected values"),
       caption = paste0("Source: Dinterman and Kathocva projections",
                        "\nbased on ODT and NASS data")) +
  theme_bw() +
  theme(legend.position = "bottom", legend.background = element_blank())

# ---- corn-price ---------------------------------------------------------

ohio %>%
  filter(year > 2009) %>%
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
  knitr::kable(caption = "Historical Corn Price")

# ---- soy-price ----------------------------------------------------------

ohio %>%
  filter(year > 2009) %>%
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
  knitr::kable(caption = "Historical Soybean Price")

# ---- wheat-price --------------------------------------------------------

ohio %>%
  filter(year > 2009) %>%
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
  knitr::kable(caption = "Historical Wheat Price")

# ---- viz-yields ---------------------------------------------------------

cauv_yield_vals <- ohio %>% 
  select(year,
         `Corn Yield` = corn_yield_cauv,
         `Soy Yield` = soy_yield_cauv,
         `Wheat Yield` = wheat_yield_cauv) %>% 
  gather(var, val, -year) %>% 
  filter(year > 2019)

odt_yield_vals <- ohio %>% 
  select(year,
         `Corn Yield` = corn_yield_odt,
         `Soy Yield` = soy_yield_odt,
         `Wheat Yield` = wheat_yield_odt) %>% 
  replace_na(list(`Corn Yield` = 118, `Soy Yield` = 36.5,
                  `Wheat Yield` = 44)) %>% 
  gather(var, val, -year) %>% 
  filter(year > 1990, year < 2020) %>% 
  bind_rows(cauv_yield_vals) %>% 
  mutate(indicator = year > 2019)


ohio %>% 
  filter(year > 1990) %>% 
  select(year, `Corn Yield` = corn_grain_yield,
         `Soy Yield` = soy_yield,
         `Wheat Yield` = wheat_yield) %>% 
  gather(var, val, -year) %>% 
  ggplot(aes(year, val, color = var)) +
  # geom_line(linetype = 2) +
  geom_line(data = odt_yield_vals, aes(linetype = indicator), size = 1) +
  # geom_line(data = cauv_vals, linetype = 4) +
  # geom_text(data = filter(cauv_yield_vals, year == 2019),
  #           aes(label = round(val)),
  #           show.legend = FALSE) +
  geom_point(aes(shape = var), size = 2) +
  scale_y_continuous(labels = comma, limits = c(0, 200)) +
  scale_linetype(guide = "none") +
  # scale_x_continuous(breaks = c(1990, 2000, 2010, 2019),
  #                    limits = c(1990, 2019)) +
  scale_color_viridis(option = "C", end = 0.9, discrete = T) +
  labs(x = "", y = "", color = "", shape = "",
       title = "Commodity Yields in Ohio",
       subtitle = paste0("points are harvested yields per USDA",
                         "\nsolid lines are values used in CAUV calculation",
                         "\ndashed lines are projected values"),
       caption = paste0("Source: Dinterman and Kathocva projections",
                        "\nbased on ODT and NASS data")) +
  theme_bw() +
  theme(legend.position = "bottom", legend.background = element_blank())


# ---- corn-yield ---------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  mutate(corn_yield_odt = replace(round(corn_yield_odt, digits = 1),
                                  is.na(corn_yield_odt), "-"),
         corn_yield_cauv = replace(round(corn_yield_cauv, digits = 1),
                                   is.na(corn_yield_cauv), "-"),
         corn_trend = replace(round(corn_trend, digits = 1),
                              is.na(corn_trend), "-"),
         corn_grain_yield = replace(round(corn_grain_yield, digits = 1),
                                    is.na(corn_grain_yield), "-")) %>% 
  select("Year" = year, "ODT Yield" = corn_yield_odt,
         "USDA Yield" = corn_grain_yield,
         "Trend Yield" = corn_trend,
         "Projected Yield" = corn_yield_cauv) %>% 
  knitr::kable(caption = "Historical Corn Yield")

# ---- soy-yield ----------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  mutate(soy_yield_odt = replace(round(soy_yield_odt, digits = 1),
                                 is.na(soy_yield_odt), "-"),
         soy_yield_cauv = replace(round(soy_yield_cauv, digits = 1),
                                  is.na(soy_yield_cauv), "-"),
         soy_trend = replace(round(soy_trend, digits = 1),
                             is.na(soy_trend), "-"),
         soy_yield = replace(round(soy_yield, digits = 1),
                             is.na(soy_yield), "-")) %>% 
  select("Year" = year, "ODT Yield" = soy_yield_odt,
         "USDA Yield" = soy_yield,
         "Trend Yield" = soy_trend,
         "Projected Yield" = soy_yield_cauv) %>% 
  knitr::kable(caption = "Historical Soybean Yield")

# ---- wheat-yield --------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  mutate(wheat_yield_odt = replace(round(wheat_yield_odt, digits = 1),
                                   is.na(wheat_yield_odt), "-"),
         wheat_yield_cauv = replace(round(wheat_yield_cauv, digits = 1),
                                    is.na(wheat_yield_cauv), "-"),
         wheat_trend = replace(round(wheat_trend, digits = 1),
                               is.na(wheat_trend), "-"),
         wheat_yield = replace(round(wheat_yield, digits = 1),
                               is.na(wheat_yield), "-")) %>% 
  select("Year" = year, "ODT Yield" = wheat_yield_odt,
         "USDA Yield" = wheat_yield,
         "Trend Yield" = wheat_trend,
         "Projected Yield" = wheat_yield_cauv) %>% 
  knitr::kable(caption = "Historical Wheat Yield")


# ---- viz-cap ------------------------------------------------------------

ohio %>% 
  filter(year > 2004) %>% 
  mutate(`Capitalization Rate` = cap_rate_cauv,
         indicator = year > 2019) %>% 
  ggplot(aes(year, `Capitalization Rate`, linetype = indicator)) +
  geom_line() +
  geom_point() +
  scale_y_continuous(labels = percent) +
  scale_linetype(guide = "none") +
  # scale_x_continuous(breaks = c(2005, 2010, 2015, 2020),
  #                    limits = c(2003, 2020)) +
  labs(x = "", y = "", color = "", shape = "",
       title = "Capitalization Rate for Ohio",
       subtitle = paste0("actual value used in ODT in solid line",
                         "\nprojected values are dashed line"),
       caption = paste0("Source: Dinterman and Kathocva projections",
                        "\nbased on ODT data")) +
  theme_bw() +
  theme(legend.position = "bottom", legend.background = element_blank())

# ---- cap-table -------------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  select("Year" = year, "ODT Value" = cap_rate_odt,
         "Expected" = cap_rate_cauv_exp, #"Maybe" = cap_rate_cauv_exp,
         "Low" = cap_rate_cauv_l, "High" = cap_rate_cauv_h) %>% 
  mutate_at(vars(-Year), ~replace(scales::percent(., accuracy = 0.1),
                                  is.na(.), "-")) %>% 
  knitr::kable(caption = "Historical Capitalization Rate")

# ---- etc ----------------------------------------------------------------

ohio %>%
  mutate(corn_yield_adj_proj = ifelse(is.na(corn_yield_adj_odt),
                                      corn_yield_adj_cauv,
                                      corn_yield_adj_odt),
         soy_yield_adj_proj = ifelse(is.na(soy_yield_adj_odt),
                                     soy_yield_adj_cauv,
                                     soy_yield_adj_odt),
         wheat_yield_adj_proj = ifelse(is.na(wheat_yield_adj_odt),
                                       wheat_yield_adj_cauv,
                                       wheat_yield_adj_odt),
         
         corn_price_proj = ifelse(is.na(corn_price_odt),
                                  corn_price_cauv_exp,
                                  corn_price_odt),
         soy_price_proj = ifelse(is.na(soy_price_odt),
                                 soy_price_cauv_exp,
                                 soy_price_odt),
         wheat_price_proj = ifelse(is.na(wheat_price_odt),
                                   wheat_price_cauv_exp,
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
         corn_rotate_cauv, corn_yield_cauv, corn_yield_adj_proj,
         corn_price_proj, corn_cost_add_cauv_proj, corn_base_cauv_proj,
         corn_cost_cauv_proj,
         
         soy_rotate_cauv, soy_yield_cauv, soy_yield_adj_proj,
         soy_price_proj, soy_cost_add_cauv_proj, soy_base_cauv_proj,
         soy_cost_cauv_proj,
         
         wheat_rotate_cauv, wheat_yield_cauv, wheat_yield_adj_proj,
         wheat_price_proj, wheat_cost_add_cauv_proj, wheat_base_cauv_proj,
         wheat_cost_cauv_proj) %>% 
  View()



# ---- typo ---------------------------------------------------------------


ohio_exp_typo <- ohio %>%
  right_join(proj_soils) %>% 
  # Create projected variables only for years with ODT data unavailable
  mutate(corn_yield_adj_proj = ifelse(is.na(corn_yield_adj_odt),
                                      corn_yield_adj_cauv,
                                      corn_yield_adj_odt),
         soy_yield_adj_proj = ifelse(is.na(soy_yield_adj_odt),
                                     soy_yield_adj_cauv,
                                     soy_yield_adj_odt),
         wheat_yield_adj_proj = ifelse(is.na(wheat_yield_adj_odt),
                                       wheat_yield_adj_cauv,
                                       wheat_yield_adj_odt),
         
         corn_price_proj = ifelse(is.na(corn_price_odt),
                                  corn_price_cauv_exp,
                                  corn_price_odt),
         soy_price_proj = ifelse(is.na(soy_price_odt),
                                 soy_price_cauv_exp,
                                 soy_price_odt),
         wheat_price_proj = ifelse(is.na(wheat_price_odt),
                                   wheat_price_cauv_exp,
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
                                      140,
                                      corn_base_odt),
         soy_base_cauv_proj = ifelse(is.na(soy_base_odt),
                                     43,
                                     soy_base_odt),
         wheat_base_cauv_proj = ifelse(is.na(wheat_base_odt),
                                       60,
                                       wheat_base_odt),
         
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
         
         corn_cost = corn_cost_add_cauv_proj*(corn_yield -
                                                corn_base_cauv_proj) +
           corn_cost_cauv_proj,
         soy_cost = soy_cost_add_cauv_proj*(soy_yield -
                                              soy_base_cauv_proj) +
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

ohio_exp_adjusted_typo <- ohio_exp_typo %>% 
  group_by(id) %>% 
  mutate(phase2017 = ifelse(unadjusted[year == 2017] > unadjusted[year == 2016],
                            0,
                            -(unadjusted[year == 2017] -
                                unadjusted[year == 2016]) / 2),
         phase2018 = ifelse(unadjusted[year == 2018] >
                              (unadjusted[year == 2017] + phase2017),
                            0,
                            -(unadjusted[year == 2018] -
                                (unadjusted[year == 2017] + phase2017)) / 2),
         phase2019 = ifelse(unadjusted[year == 2019] >
                              (unadjusted[year == 2018] + phase2018),
                            0,
                            -(unadjusted[year == 2019] -
                                (unadjusted[year == 2018] + phase2018)) / 2),
         cauv_projected_exp = case_when(year < 2017 ~ unadjusted,
                                        year == 2017 ~ unadjusted + phase2017,
                                        year == 2018 ~ unadjusted + phase2018,
                                        year == 2019 ~ unadjusted + phase2019,
                                        year > 2019 ~ unadjusted))

# ohio_exp %>%
#   filter(year == next_year) %>% 
#   select(year, cauv_projected_exp, soil_series:id) %>%
#   write_csv(paste0(future, "/expected_projections_", next_year, ".csv"))

ohio_soils_exp_typo <- ohio_exp_adjusted_typo %>% 
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

ohio_soils_exp
ohio_soils_exp_typo
