# Providing a calculation/projection of the Nonland Costs in Ohio

# Recommendation

# ---- start --------------------------------------------------------------

library("tidyverse")
library("zoo")

# Create a directory for the data
local_dir <- "2-calc"
nonland   <- paste0(local_dir, "/nonland")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(nonland)) dir.create(nonland, recursive = T)

# Take the vector of costs that are averaged and replaced the most recent with
#  a 0 for high and Inf for low -- these reference the CAUV projection
mean_high <- function(x, ...) {
  n    <- length(x)
  x[n] <- 0
  mean(x, ...)
}
mean_low <- function(x, ...) {
  n    <- length(x)
  x[n] <- Inf
  mean(x, ...)
}


# ---- data ---------------------------------------------------------------


j5_odt <- read_rds("1-tidy/nonland/ohio_nonland.rds") %>% 
  select(year, contains("odt")) %>% 
  distinct()

j5_alt <- read_csv("0-data/osu_budget/osu_budgets - alternate-method.csv")

j5_long <- j5_alt %>% 
  mutate(total_cost = total_cost_acre - rent - management) %>% 
  select(year, crop, level, yield = production, total_cost) %>% 
  pivot_longer(c(yield, total_cost),
               names_to = "item", values_to = "val") %>% 
  arrange(year)


# ---- olympic ------------------------------------------------------------

j5_olympic <- j5_long %>% 
  select(year, item, crop, level, val) %>% 
  spread(item, val) %>% 
  group_by(crop, level) %>% 
  arrange(year) %>% 
  mutate_at(vars(-year, -crop, -level),
            list(~ifelse(year > 2014,
                         rollapplyr(., width = 7, FUN =  mean,
                                    trim = 1/7, na.rm = T, fill = NA),
                         rollapplyr(lag(.), width = 7, FUN =  mean,
                                    trim = 1/7, na.rm = T, fill = NA))))

# ---- calc ---------------------------------------------------------------

non_land <- j5_olympic %>% 
  ungroup() %>% 
  group_by(year, crop) %>% 
  summarise(base_yield = yield[level == "l1_low"],
            cost = total_cost[level == "l1_low"],
            cost_add = ((total_cost[level == "l2_med"] -
                          cost) / (yield[level == "l2_med"] -
              yield[level == "l1_low"]))) %>% 
  arrange(year) %>%
  gather(var, val, -year, -crop) %>% 
  unite(temp, crop, var) %>% 
  spread(temp, val) %>% 
  ungroup() %>% 
  rename_at(vars(-year), ~paste0(., "_alt"))

### Bring them together
non_land_costs <- non_land %>% 
  left_join(j5_odt) %>% 
  mutate_at(vars(contains("base")), round) %>% 
  mutate_at(vars(-group_cols()), round, 2)

write.csv(non_land_costs, paste0(nonland, "/ohio_alternate_nonland.csv"),
          row.names = F)
write_rds(non_land_costs, paste0(nonland, "/ohio_alternate_nonland.rds"))

# 
# # ---- corn-base ----------------------------------------------------------
# 
# non_land_costs %>% 
#   filter(year > 2005) %>% 
#   select("Year" = year, "ODT Base Cost" = corn_cost_odt,
#          "Alternate" = corn_cost_alt,) %>% 
#   mutate_at(vars(-Year), ~scales::dollar(., accuracy = 0.01)) %>% 
#   knitr::kable()
# 
# # ---- corn-add -----------------------------------------------------------
# 
# non_land_costs %>% 
#   filter(year > 2005) %>% 
#   select("Year" = year, "ODT Add Cost" = corn_cost_add_odt,
#          "Low Projection" = corn_cost_add_cauv_l,
#          "Expected Projection" = corn_cost_add_cauv,
#          "High Projection" = corn_cost_add_cauv_h) %>% 
#   mutate_at(vars(-Year), ~scales::dollar(., accuracy = 0.01)) %>% 
#   knitr::kable()
# 
# # ---- soy-base ----------------------------------------------------------
# 
# non_land_costs %>% 
#   filter(year > 2005) %>% 
#   select("Year" = year, "ODT Base Cost" = soy_cost_odt,
#          "Low Projection" = soy_cost_cauv_l,
#          "Expected Projection" = soy_cost_cauv,
#          "High Projection" = soy_cost_cauv_h) %>% 
#   mutate_at(vars(-Year), ~scales::dollar(., accuracy = 0.01)) %>% 
#   knitr::kable()
# 
# # ---- soy-add -----------------------------------------------------------
# 
# non_land_costs %>% 
#   filter(year > 2005) %>% 
#   select("Year" = year, "ODT Add Cost" = soy_cost_add_odt,
#          "Low Projection" = soy_cost_add_cauv_l,
#          "Expected Projection" = soy_cost_add_cauv,
#          "High Projection" = soy_cost_add_cauv_h) %>% 
#   mutate_at(vars(-Year), ~scales::dollar(., accuracy = 0.01)) %>% 
#   knitr::kable()
# 
# # ---- wheat-base ----------------------------------------------------------
# 
# non_land_costs %>% 
#   filter(year > 2005) %>% 
#   select("Year" = year, "ODT Base Cost" = wheat_cost_odt,
#          "Low Projection" = wheat_cost_cauv_l,
#          "Expected Projection" = wheat_cost_cauv,
#          "High Projection" = wheat_cost_cauv_h) %>% 
#   mutate_at(vars(-Year), ~scales::dollar(., accuracy = 0.01)) %>% 
#   knitr::kable()
# 
# # ---- wheat-add -----------------------------------------------------------
# 
# non_land_costs %>% 
#   filter(year > 2005) %>% 
#   select("Year" = year, "ODT Add Cost" = wheat_cost_add_odt,
#          "Low Projection" = wheat_cost_add_cauv_l,
#          "Expected Projection" = wheat_cost_add_cauv,
#          "High Projection" = wheat_cost_add_cauv_h) %>% 
#   mutate_at(vars(-Year), ~scales::dollar(., accuracy = 0.01)) %>% 
#   knitr::kable()
# 
# 
