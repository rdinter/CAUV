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

ohio <- read_rds("2-calc/prices/ohio_forecast_prices.rds") %>% 
  left_join(read_rds("2-calc/yields/ohio_forecast_crops.rds")) %>% 
  left_join(read_rds("2-calc/rot/ohio_forecast_rotate.rds")) %>% 
  left_join(read_rds("2-calc/nonland/ohio_forecast_nonland.rds")) %>% 
  left_join(read_rds("2-calc/cap/ohio_forecast_caprate.rds"))

# next_year <- max(ohio$year[!is.na(ohio$corn_price_odt)]) + 1
next_year = 2020

# # HACK, cap rate has been finicky so just going to go with 0.08 in all
# #  projections for the moment.
# ohio$cap_rate_cauv[ohio$year %in% c(2018,2019,2020)]     <- 0.08
# ohio$cap_rate_cauv_exp[ohio$year %in% c(2018,2019,2020)] <- 0.08
# ohio$cap_rate_cauv_l[ohio$year %in% c(2018,2019,2020)]   <- 0.081
# ohio$cap_rate_cauv_h[ohio$year %in% c(2018,2019,2020)]   <- 0.079

soils      <- read_rds("0-data/soils/cauv_soils.rds")
unadj      <- read_rds("0-data/soils/cauv_unadj.rds")
organic    <- read_csv("3-proj/3-organic.csv")
ohio_soils <- read_rds("3-proj/future/ohio_soils_exp_2019.rds")

indxs     <-  c("indx_100", "indx_99", "indx_89", "indx_79",
                "indx_69", "indx_59", "indx_49", "avg_cauv")
indx_name <- c("100", "90 to 99", "80 to 89", "70 to 79",
               "60 to 69", "50 to 59", "0 to 49", "Average")
indx_size <- c("100" = 0.5, "90 to 99" = 0.5,
               "80 to 89" = 0.5, "70 to 79" = 0.5,
               "60 to 69" = 0.5, "50 to 59" = 0.5,
               "0 to 49" = 0.5, "Average" = 2)

# ---- expected -----------------------------------------------------------


proj_soils <- soils %>% 
  select(-year, -cropland, -woodland) %>% 
  distinct() %>% 
  mutate(year = next_year) %>% 
  left_join(organic)
ohio_exp <- ohio %>%
  select(year, contains("cauv")) %>%
  filter(year == next_year) %>% 
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
         
         corn_cost = corn_cost_add_cauv_exp*(corn_yield - corn_base_cauv_exp) +
           corn_cost_cauv_exp,
         soy_cost = soy_cost_add_cauv_exp*(soy_yield - soy_base_cauv_exp) +
           soy_cost_cauv_exp,
         wheat_cost = wheat_cost_add_cauv_exp*(wheat_yield -
                                                 wheat_base_cauv_exp) +
           wheat_cost_cauv_exp,
         
         net_corn = corn_revenue - corn_cost,
         net_soy = soy_revenue - soy_cost,
         net_wheat = wheat_revenue - wheat_cost,
         
         net_return = corn_rotate_cauv*net_corn + soy_rotate_cauv*net_soy +
           wheat_rotate_cauv*net_wheat,
         
         organic = 0.5*net_corn + 0.5*net_soy,
         
         raw_val = round(net_return / round(cap_rate_cauv_exp, 3),digits = -1),
         raw_val_o = round(organic / round(cap_rate_cauv_exp, 3),digits = -1),
         raw = ifelse(org_soil, raw_val_o, raw_val),
         unadjusted = ifelse(raw < 350, 350, raw)) %>% 
  arrange(id) %>% 
  mutate(cauv_projected_exp = unadjusted)

ohio_exp %>%
  select(year, cauv_projected_exp, soil_series:id) %>%
  write_csv(paste0(future, "/expected_projections_", next_year, ".csv"))

ohio_soils_exp <- ohio_exp %>% 
  mutate(val = cauv_projected_exp,
         num_soils = n(),
         avg_cauv = mean(val, na.rm = T)) %>% 
  group_by(indx) %>% 
  summarise(val = mean(val),
            avg_cauv = mean(avg_cauv),
            num_soils = mean(num_soils),
            year = next_year) %>% 
  ungroup() %>% 
  spread(indx, val) %>% 
  bind_rows(filter(ohio_soils, year != next_year), .)


# ----- low ---------------------------------------------------------------

ohio_low <- ohio %>%
  select(year, contains("cauv")) %>%
  filter(year == next_year) %>% 
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
         unadjusted = ifelse(raw < 350, 350, raw),
         cauv_projected_low = unadjusted) %>% 
  arrange(id)

ohio_low %>%
  select(year, cauv_projected_low, soil_series:id, indx) %>%
  write_csv(paste0(future, "/low_projections_", next_year, ".csv"))

ohio_soils_low <- ohio_low %>% 
  mutate(val = cauv_projected_low,
         num_soils = n(),
         avg_cauv = mean(val)) %>% 
  group_by(indx) %>% 
  summarise(val = mean(val),
            avg_cauv = mean(avg_cauv),
            num_soils = mean(num_soils),
            year = next_year) %>% 
  ungroup() %>% 
  spread(indx, val) %>% 
  bind_rows(filter(ohio_soils, year != next_year), .)


# ---- high ---------------------------------------------------------------


ohio_high <- ohio %>%
  select(year, contains("cauv")) %>%
  filter(year == next_year) %>% 
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
         unadjusted = ifelse(raw < 350, 350, raw),
         cauv_projected_high = unadjusted) %>% 
  arrange(id)

ohio_high %>%
  select(year, cauv_projected_high, soil_series:id, indx) %>%
  write_csv(paste0(future, "/high_projections_", next_year, ".csv"))

ohio_soils_high <- ohio_high %>% 
  mutate(val = cauv_projected_high,
         num_soils = n(),
         avg_cauv = mean(val)) %>% 
  group_by(indx) %>% 
  summarise(val = mean(val),
            avg_cauv = mean(avg_cauv),
            num_soils = mean(num_soils),
            year = next_year) %>% 
  ungroup() %>% 
  spread(indx, val) %>% 
  bind_rows(filter(ohio_soils, year != next_year), .)


# ---- projections --------------------------------------------------------

projections <- select(ohio_low,
                      soil_series:id, indx, cauv_projected_low)

projections <- ohio_high %>% 
  select(id, cauv_projected_high) %>% 
  right_join(projections)

projections <- ohio_exp %>% 
  select(id, cauv_projected_exp) %>% 
  right_join(projections) %>% 
  select(id, soil_series:indx,
         `Projected Expected 2020` = cauv_projected_exp,
         `Projected Low 2020` = cauv_projected_low,
         `Projected High 2020` = cauv_projected_high)

write_csv(projections, paste0(future, "/projections_", next_year, ".csv"))

# ---- save ---------------------------------------------------------------

write_rds(ohio, paste0(future, "/ohio_", next_year, ".rds"))
write_rds(ohio_low, paste0(future, "/ohio_low_", next_year, ".rds"))
write_rds(ohio_high, paste0(future, "/ohio_high_", next_year, ".rds"))
write_rds(ohio_exp, paste0(future, "/ohio_exp_", next_year, ".rds"))
write_rds(ohio_soils, paste0(future, "/ohio_soils_", next_year, ".rds"))
write_rds(ohio_soils_low,
          paste0(future, "/ohio_soils_low_", next_year, ".rds"))
write_rds(ohio_soils_high,
          paste0(future, "/ohio_soils_high_", next_year, ".rds"))
write_rds(ohio_soils_exp,
          paste0(future, "/ohio_soils_exp_", next_year, ".rds"))


# ---- huh ----------------------------------------------------------------

caption_proj <- paste0("Source: Dinterman and Katchova projections",
                       "\nbased on ODT/NASS/OSU Extension data")

indxs     <-  c("indx_100", "indx_99", "indx_89", "indx_79",
                "indx_69", "indx_59", "indx_49", "avg_cauv")
indx_name <- c("100", "90 to 99", "80 to 89", "70 to 79",
               "60 to 69", "50 to 59", "0 to 49", "Average")
indx_size <- c("100" = 0.5, "90 to 99" = 0.5,
               "80 to 89" = 0.5, "70 to 79" = 0.5,
               "60 to 69" = 0.5, "50 to 59" = 0.5,
               "0 to 49" = 0.5, "Average" = 2)

ohio_soils_exp %>%
  select(-num_soils) %>%
  gather(var, val, -year) %>%
  mutate(var = factor(var, levels = indxs, labels = indx_name)) %>% 
  {
    ggplot(., aes(year, val)) +
      geom_line(aes(color = var, size = var)) +
      geom_point(aes(color = var)) +
      geom_text_repel(data = filter(., year == 2020),
                      aes(color = var,
                          label = dollar(val, accuracy = 1)),
                      nudge_x = 1.75, show.legend = FALSE,
                      segment.alpha = 0.5) +
      geom_vline(xintercept = 2019) +
      scale_x_continuous(breaks = c(1990, 2000, 2010, 2018),
                         limits = c(1991, 2021)) +
      scale_y_continuous(labels = dollar) +
      scale_color_viridis(option = "C", direction = -1,
                          end = 0.9, discrete = T) +
      scale_size_manual(values = indx_size) +
      labs(x = "", y = "", size = "Soil Productivity Index",
           color = "Soil Productivity Index",
           title = "2020 Projection for CAUV Values of Cropland",
           subtitle = "in dollars per acre",
           caption = caption_proj) +
      theme_bw() +
      theme(legend.position = c(0.2, 0.65),
            legend.background = element_blank())
  }
ggsave(filename = "3-proj/figures/cauv_expected_projections_2020.png",
       width = 10, height = 7)

