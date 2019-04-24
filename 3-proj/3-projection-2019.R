# Now we project the future values

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

ohio <- read_rds("2-calc/prices/ohio_forecast_prices.rds") %>% 
  left_join(read_rds("2-calc/yields/ohio_forecast_crops.rds")) %>% 
  left_join(read_rds("2-calc/rot/ohio_forecast_rotate.rds")) %>% 
  left_join(read_rds("2-calc/nonland/ohio_forecast_nonland.rds")) %>% 
  left_join(read_rds("2-calc/cap/ohio_forecast_caprate.rds"))

# # HACK, cap rate has been finicky so just going to go with 0.08 in all
# #  projections for the moment.
# ohio$cap_rate_cauv[ohio$year %in% c(2018,2019)]     <- 0.08
# ohio$cap_rate_cauv_exp[ohio$year %in% c(2018,2019)] <- 0.08
# ohio$cap_rate_cauv_l[ohio$year %in% c(2018,2019)]   <- 0.081
# ohio$cap_rate_cauv_h[ohio$year %in% c(2018,2019)]   <- 0.079

soils <- read_rds("0-data/soils/cauv_soils.rds")
unadj <- read_rds("0-data/soils/cauv_unadj.rds")
ohio_soils <- read_csv("0-data/soils/offline/cauv_index_avg.csv")

soil2016 <- soils %>% 
  filter(year == 2016) %>% 
  select(id, indx, val_2016 = cropland)

soil2017 <- soils %>% 
  filter(year == 2017) %>% 
  select(id, indx, val_2017 = cropland)

soil2018 <- soils %>% 
  filter(year == 2018) %>% 
  select(id, indx, val_2018 = cropland)


# ---- recreate ----------------------------------------------------------

recreated <- ohio %>%
  select(year, contains("odt")) %>%
  right_join(soils) %>% 
  filter(year == 2017) %>% 
  mutate(corn_yield = round(corn_base*corn_yield_adj_odt),
         soy_yield = round(soy_base*soy_yield_adj_odt),
         wheat_yield = round(wheat_base*wheat_yield_adj_odt),
         
         corn_revenue = corn_yield*corn_price_odt,
         soy_revenue = soy_yield*soy_price_odt,
         wheat_revenue = wheat_yield*wheat_price_odt,
         
         corn_cost = corn_cost_add_odt*(corn_yield - corn_base_odt) +
           corn_cost_odt,
         soy_cost = soy_cost_add_odt*(soy_yield - soy_base_odt) +
           soy_cost_odt,
         wheat_cost = wheat_cost_add_odt*(wheat_yield - wheat_base_odt) +
           wheat_cost_odt,
         
         net_return = corn_rotate_odt*(corn_revenue - corn_cost) +
           soy_rotate_odt*(soy_revenue - soy_cost) +
           wheat_rotate_odt*(wheat_revenue - wheat_cost),
         
         organic = 0.5*(corn_revenue - corn_cost) +
           0.5*(soy_revenue - soy_cost),
         
         raw_val = round(net_return / round(cap_rate_odt,3), digits = -1),
         raw_val_o = round(organic / round(cap_rate_odt,3), digits = -1),
         unadjusted = ifelse(raw_val < 350, 350, raw_val),
         unadjusted_o = ifelse(raw_val_o < 350, 350, raw_val_o)) %>% 
  arrange(id) %>% 
  left_join(unadj) %>% 
  mutate(difference = unadjusted - cropland_unadj,
         difference_o = unadjusted_o - cropland_unadj,
         org_soil = ifelse(raw_val_o == cropland_unadj &
                             difference != 0, T, F)) %>% 
  left_join(soil2016) %>% 
  mutate(raw = ifelse(org_soil, raw_val_o, raw_val),
         unadjusted = ifelse(raw < 350, 350, raw),
         cauv_2017 = ifelse(unadjusted > val_2016, unadjusted,
                            unadjusted + (val_2016 - unadjusted)/2),
         cauv_2017 = round(cauv_2017, -1))

# Determine the organic soils for calculating the correct value
organic1 <- recreated %>% 
  mutate(org_soil = ifelse(raw_val_o == cropland_unadj &
                             difference != 0, T, F)) %>% 
  select(id, org_soil)

# write_csv(organic, "3-proj/3-organic-2017.csv")

# dot_soils <- left_join(dot_soils, organic)

# How many of these soils differ in values? Turns out a lot and part of that
#  is because of the organic distinction is most applicable.
# recreated %>%
#   filter(difference != 0) %>%
#   arrange(difference_o) %>%
#   View

# Even correcting for organic soils, there's still about 35 soils off
# recreated %>%
#   filter(difference != 0, difference_o != 0) %>%
#   arrange(difference_o) %>%
#   View


# ---- recreate2 ----------------------------------------------------------

recreated2 <- ohio %>%
  select(year, contains("odt")) %>%
  right_join(soils) %>% 
  filter(year == 2018) %>% 
  mutate(corn_yield = round(corn_base*corn_yield_adj_odt),
         soy_yield = round(soy_base*soy_yield_adj_odt),
         wheat_yield = round(wheat_base*wheat_yield_adj_odt),
         
         corn_revenue = corn_yield*corn_price_odt,
         soy_revenue = soy_yield*soy_price_odt,
         wheat_revenue = wheat_yield*wheat_price_odt,
         
         corn_cost = corn_cost_add_odt*(corn_yield - corn_base_odt) +
           corn_cost_odt,
         soy_cost = soy_cost_add_odt*(soy_yield - soy_base_odt) +
           soy_cost_odt,
         wheat_cost = wheat_cost_add_odt*(wheat_yield - wheat_base_odt) +
           wheat_cost_odt,
         
         net_return = corn_rotate_odt*(corn_revenue - corn_cost) +
           soy_rotate_odt*(soy_revenue - soy_cost) +
           wheat_rotate_odt*(wheat_revenue - wheat_cost),
         
         organic = 0.5*(corn_revenue - corn_cost) +
           0.5*(soy_revenue - soy_cost),
         
         raw_val = round(net_return / round(cap_rate_odt,3), digits = -1),
         raw_val_o = round(organic / round(cap_rate_odt,3), digits = -1),
         unadjusted = ifelse(raw_val < 350, 350, raw_val),
         unadjusted_o = ifelse(raw_val_o < 350, 350, raw_val_o)) %>% 
  arrange(id) %>% 
  left_join(unadj) %>% 
  mutate(difference = unadjusted - cropland_unadj,
         difference_o = unadjusted_o - cropland_unadj,
         org_soil = ifelse(raw_val_o == cropland_unadj &
                             difference != 0, T, F)) %>% 
  left_join(soil2017) %>% 
  mutate(raw = ifelse(org_soil, raw_val_o, raw_val),
         unadjusted = ifelse(raw < 350, 350, raw),
         cauv_2018 = ifelse(unadjusted > val_2017, unadjusted,
                            unadjusted + (val_2017 - unadjusted)/2),
         cauv_2018 = round(cauv_2018, -1))

# Determine the organic soils for calculating the correct value
organic2 <- recreated2 %>% 
  mutate(org_soil = ifelse(raw_val_o == cropland_unadj &
                             difference != 0, T, F)) %>% 
  select(id, org_soil)

organic <- organic1 %>% 
  rename(org_soil_2017 = org_soil) %>% 
  left_join(organic2) %>% 
  rename(org_soil_2018 = org_soil) %>% 
  mutate(org_soil = ifelse(org_soil_2017 | org_soil_2018, TRUE, FALSE))

write_csv(organic, "3-proj/3-organic.csv")


# ---- expected -----------------------------------------------------------


proj_soils <- soils %>% 
  select(-year, -cropland, -woodland) %>% 
  distinct() %>% 
  mutate(year = 2019) %>% 
  left_join(organic)
ohio_exp <- ohio %>%
  select(year, contains("cauv")) %>%
  filter(year == 2019) %>% 
  right_join(proj_soils) %>% 
  rename(corn_base_cauv_exp = corn_base_cauv,
         corn_cost_cauv_exp = corn_cost_cauv,
         corn_cost_add_cauv_exp = corn_cost_add_cauv,
         soy_base_cauv_exp = soy_base_cauv,
         soy_cost_cauv_exp = soy_cost_cauv,
         soy_cost_add_cauv_exp = soy_cost_add_cauv,
         wheat_base_cauv_exp = wheat_base_cauv,
         wheat_cost_cauv_exp = wheat_cost_cauv,
         wheat_cost_add_cauv_exp = wheat_cost_add_cauv) %>% 
  mutate(corn_yield = round(corn_base*corn_yield_adj_cauv),
         soy_yield = round(soy_base*soy_yield_adj_cauv),
         wheat_yield = round(wheat_base*wheat_yield_adj_cauv),
         
         corn_revenue = corn_yield*corn_price_cauv_exp,
         soy_revenue = soy_yield*soy_price_cauv_exp,
         wheat_revenue = wheat_yield*wheat_price_cauv_exp,
         
         corn_cost = corn_cost_add_cauv_exp*(corn_yield-corn_base_cauv_exp) +
           corn_cost_cauv_exp,
         soy_cost = soy_cost_add_cauv_exp*(soy_yield - soy_base_cauv_exp) +
           soy_cost_cauv_exp,
         wheat_cost = wheat_cost_add_cauv_exp*(wheat_yield -
                                                 wheat_base_cauv_exp) +
           wheat_cost_cauv_exp,
         
         net_return = corn_rotate_cauv*(corn_revenue - corn_cost) +
           soy_rotate_cauv*(soy_revenue - soy_cost) +
           wheat_rotate_cauv*(wheat_revenue - wheat_cost),
         
         organic = 0.5*(corn_revenue - corn_cost) +
           0.5*(soy_revenue - soy_cost),
         
         raw_val = round(net_return / round(cap_rate_cauv_exp, 3),digits=-1),
         raw_val_o = round(organic / round(cap_rate_cauv_exp, 3),digits=-1),
         raw = ifelse(org_soil, raw_val_o, raw_val),
         unadjusted = ifelse(raw < 350, 350, raw)) %>% 
  arrange(id) %>% 
  left_join(soil2018) %>% 
  mutate(cauv_projected_exp = ifelse(unadjusted > val_2018, unadjusted,
                                     unadjusted + (val_2018 - unadjusted)/2))


ohio_exp %>%
  select(year, cauv_projected_exp, soil_series:id,
         indx, val_2018, unadjusted) %>%
  write_csv(paste0(future, "/expected_projections_2018.csv"))

ohio_soils_exp <- ohio_exp %>% 
  mutate(val = ifelse(unadjusted > val_2018, unadjusted,
                      unadjusted + (val_2018 - unadjusted)/2),
         num_soils = n(),
         avg_cauv = mean(val)) %>% 
  group_by(indx) %>% 
  summarise(val = mean(val),
            avg_cauv = mean(avg_cauv),
            num_soils = mean(num_soils),
            year = 2019) %>% 
  ungroup() %>% 
  spread(indx, val) %>% 
  bind_rows(filter(ohio_soils, year != 2019), .)


# ----- low ---------------------------------------------------------------

ohio_low <- ohio %>%
  select(year, contains("cauv")) %>%
  filter(year == 2019) %>% 
  right_join(proj_soils) %>% 
  mutate(corn_yield = round(corn_base*corn_yield_adj_cauv),
         soy_yield = round(soy_base*soy_yield_adj_cauv),
         wheat_yield = round(wheat_base*wheat_yield_adj_cauv),
         
         corn_revenue = corn_yield*corn_price_cauv_l,
         soy_revenue = soy_yield*soy_price_cauv_l,
         wheat_revenue = wheat_yield*wheat_price_cauv_l,
         
         corn_cost = corn_cost_add_cauv_l*(corn_yield - corn_base_cauv_l) +
           corn_cost_cauv_l,
         soy_cost = soy_cost_add_cauv_l*(soy_yield - soy_base_cauv_l) +
           soy_cost_cauv_l,
         wheat_cost = wheat_cost_add_cauv_l*(wheat_yield - wheat_base_cauv_l) +
           wheat_cost_cauv_l,
         
         net_return = corn_rotate_cauv*(corn_revenue - corn_cost) +
           soy_rotate_cauv*(soy_revenue - soy_cost) +
           wheat_rotate_cauv*(wheat_revenue - wheat_cost),
         
         organic = 0.5*(corn_revenue - corn_cost) +
           0.5*(soy_revenue - soy_cost),
         
         raw_val = round(net_return / round(cap_rate_cauv_l, 3), digits = -1),
         raw_val_o = round(organic / round(cap_rate_cauv_l, 3), digits = -1),
         raw = ifelse(org_soil, raw_val_o, raw_val),
         unadjusted = ifelse(raw < 350, 350, raw)) %>% 
  arrange(id) %>% 
  left_join(soil2018) %>% 
  mutate(cauv_projected_low = ifelse(unadjusted > val_2018, unadjusted,
                                     unadjusted + (val_2018 - unadjusted)/2))

ohio_low %>%
  select(year, cauv_projected_low, soil_series:id,
         indx, val_2018, unadjusted) %>%
  write_csv(paste0(future, "/low_projections_2019.csv"))

ohio_soils_low <- ohio_low %>% 
  mutate(val = ifelse(unadjusted > val_2018, unadjusted,
                      unadjusted + (val_2018 - unadjusted)/2),
         num_soils = n(),
         avg_cauv = mean(val)) %>% 
  group_by(indx) %>% 
  summarise(val = mean(val),
            avg_cauv = mean(avg_cauv),
            num_soils = mean(num_soils),
            year = 2019) %>% 
  ungroup() %>% 
  spread(indx, val) %>% 
  bind_rows(filter(ohio_soils, year != 2019), .)


# ---- high ---------------------------------------------------------------


ohio_high <- ohio %>%
  select(year, contains("cauv")) %>%
  filter(year == 2019) %>% 
  right_join(proj_soils) %>% 
  mutate(corn_yield = round(corn_base*corn_yield_adj_cauv),
         soy_yield = round(soy_base*soy_yield_adj_cauv),
         wheat_yield = round(wheat_base*wheat_yield_adj_cauv),
         
         corn_revenue = corn_yield*corn_price_cauv_h,
         soy_revenue = soy_yield*soy_price_cauv_h,
         wheat_revenue = wheat_yield*wheat_price_cauv_h,
         
         corn_cost = corn_cost_add_cauv_h*(corn_yield - corn_base_cauv_h) +
           corn_cost_cauv_h,
         soy_cost = soy_cost_add_cauv_h*(soy_yield - soy_base_cauv_h) +
           soy_cost_cauv_h,
         wheat_cost = wheat_cost_add_cauv_h*(wheat_yield - wheat_base_cauv_h) +
           wheat_cost_cauv_h,
         
         net_return = corn_rotate_cauv*(corn_revenue - corn_cost) +
           soy_rotate_cauv*(soy_revenue - soy_cost) +
           wheat_rotate_cauv*(wheat_revenue - wheat_cost),
         
         organic = 0.5*(corn_revenue - corn_cost) +
           0.5*(soy_revenue - soy_cost),
         
         raw_val = round(net_return / round(cap_rate_cauv_h, 3), digits = -1),
         raw_val_o = round(organic / round(cap_rate_cauv_h, 3), digits = -1),
         raw = ifelse(org_soil, raw_val_o, raw_val),
         unadjusted = ifelse(raw < 350, 350, raw)) %>% 
  arrange(id) %>% 
  left_join(soil2018) %>% 
  mutate(cauv_projected_high = ifelse(unadjusted > val_2018, unadjusted,
                                      unadjusted + (val_2018 - unadjusted)/2))

ohio_high %>%
  select(year, cauv_projected_high, soil_series:id,
         indx, val_2018, unadjusted) %>%
  write_csv(paste0(future, "/high_projections_2019.csv"))

ohio_soils_high <- ohio_high %>% 
  mutate(val = ifelse(unadjusted > val_2018, unadjusted,
                      unadjusted + (val_2018 - unadjusted)/2),
         num_soils = n(),
         avg_cauv = mean(val)) %>% 
  group_by(indx) %>% 
  summarise(val = mean(val),
            avg_cauv = mean(avg_cauv),
            num_soils = mean(num_soils),
            year = 2019) %>% 
  ungroup() %>% 
  spread(indx, val) %>% 
  bind_rows(filter(ohio_soils, year != 2019), .)


# ---- projections --------------------------------------------------------

projections <- select(ohio_low,
                      soil_series:id, indx, val_2018, cauv_projected_low)

projections <- ohio_high %>% 
  select(id, cauv_projected_high) %>% 
  right_join(projections)

projections <- ohio_exp %>% 
  select(id, cauv_projected_exp) %>% 
  right_join(projections) %>% 
  select(id, soil_series:indx, `CAUV 2018` = val_2018,
         `Projected Expected 2019` = cauv_projected_exp,
         `Projected Low 2019` = cauv_projected_low,
         `Projected High 2019` = cauv_projected_high)

write_csv(projections, paste0(future, "/projections_2019.csv"))

# ---- save ---------------------------------------------------------------

write_rds(ohio, paste0(future, "/ohio_2019.rds"))
write_rds(recreated, paste0(future, "/ohio_recreated_2017.rds"))
write_rds(recreated2, paste0(future, "/ohio_recreated_2018.rds"))
write_rds(ohio_low, paste0(future, "/ohio_low_2019.rds"))
write_rds(ohio_high, paste0(future, "/ohio_high_2019.rds"))
write_rds(ohio_exp, paste0(future, "/ohio_exp_2019.rds"))
write_rds(ohio_soils, paste0(future, "/ohio_soils_2019.rds"))
write_rds(ohio_soils_low, paste0(future, "/ohio_soils_low_2019.rds"))
write_rds(ohio_soils_high, paste0(future, "/ohio_soils_high_2019.rds"))
write_rds(ohio_soils_exp, paste0(future, "/ohio_soils_exp_2019.rds"))


# ---- huh ----------------------------------------------------------------

caption_proj <- paste0("Source: Dinterman and Katchova projections",
                       "\nbased on ODT/NASS/OSU Extension data")

ohio_soils_exp %>%
  select(-avg_cauv, -num_soils) %>%
  gather(var, val, -year) %>%
  mutate(var = factor(var,
                      levels =  c("indx_100", "indx_99", "indx_89", "indx_79",
                                  "indx_69", "indx_59", "indx_49"),
                      labels = c("100", "90 to 99", "80 to 89", "70 to 79",
                                 "60 to 69", "50 to 59", "0 to 49"))) %>% 
  {ggplot(.,aes(year, val)) +
      geom_line(aes(color = var)) +
      geom_point(aes(color = var)) +
      geom_text_repel(data = filter(., year == 2019),
                      aes(color = var, label = dollars(val)),
                      nudge_x = 1.75, show.legend = FALSE,
                      segment.alpha = 0.5) +
      geom_line(data = ohio_soils_exp, aes(year, avg_cauv), size = 2) +
      geom_text_repel(data = filter(ohio_soils_exp, year == 2019),
                      aes(year, avg_cauv + 50, label = dollars(avg_cauv)),
                      nudge_x = 1.75, nudge_y = 100,
                      show.legend = FALSE, segment.alpha = 0.5) +
      geom_vline(xintercept = 2018) +
      scale_x_continuous(breaks = c(1990, 2000, 2010, 2018),
                         limits = c(1991, 2020)) +
      scale_y_continuous(labels = dollar) +
      scale_color_viridis(option = "C", direction = -1,
                          end = 0.9, discrete = T) +
      labs(x = "", y = "", color = "Soil Productivity Index",
           title = "2019 Projection for CAUV Values of Cropland",
           subtitle = "in dollars per acre, average value in black",
           caption = caption_proj) +
      theme_bw() +
      theme(legend.position = c(0.2, 0.7),
            legend.background = element_blank())
    }
# ggsave(filename = paste0(figures, "/cauv_expected_projections_2018.png"),
#        width = 10, height = 7)

