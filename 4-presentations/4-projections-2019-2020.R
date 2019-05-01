# Visuals and charts for CAUV values and projections, depends on
#  3-preliminary.R

# THING TO DO: change up how the trends are displayed (remove "black")
#  get the projections for components to include future years

# ---- start --------------------------------------------------------------

library("knitr")
library("scales")
library("tidyverse")
library("viridis")
library("ggrepel")

local_dir   <- "4-presentations/projections"
figures     <- paste0(local_dir, "/figures")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(figures)) dir.create(figures)

projections <- "3-proj/future"
next_year   <- 2019

ohio            <- read_rds(paste0(projections, "/ohio_", next_year, ".rds"))
recreated       <- read_rds(paste0(projections, "/ohio_recreated_",
                                   next_year - 1, ".rds"))
ohio_low        <- read_rds(paste0(projections, "/ohio_low_",
                                   next_year, ".rds"))
ohio_high       <- read_rds(paste0(projections, "/ohio_high_",
                                   next_year, ".rds"))
ohio_exp        <- read_rds(paste0(projections, "/ohio_exp_",
                                   next_year, ".rds"))
ohio_soils_low  <- read_rds(paste0(projections, "/ohio_soils_low_",
                                   next_year, ".rds"))
ohio_soils_high <- read_rds(paste0(projections, "/ohio_soils_high_",
                                   next_year, ".rds"))
ohio_soils_exp  <- read_rds(paste0(projections, "/ohio_soils_exp_",
                                   next_year, ".rds"))

ohio_soils_low2 <- read_rds(paste0(projections, "/ohio_soils_low_",
                                   next_year + 1, ".rds"))
ohio_soils_high2 <- read_rds(paste0(projections, "/ohio_soils_high_",
                                    next_year + 1, ".rds"))
ohio_soils_exp2 <- read_rds(paste0(projections, "/ohio_soils_exp_",
                                   next_year + 1, ".rds"))

avg_low <- ohio_low %>% 
  summarise(indx = "avg_cauv",
            eventual = mean(unadjusted),
            adjustment = mean(cauv_projected_low) - eventual) %>% 
  gather(var, val, -indx) 

avg_high <- ohio_high %>% 
  summarise(indx = "avg_cauv",
            eventual = mean(unadjusted),
            adjustment = mean(cauv_projected_high) - eventual) %>% 
  gather(var, val, -indx) 

avg_exp <- ohio_exp %>% 
  summarise(indx = "avg_cauv",
            eventual = mean(unadjusted),
            adjustment = mean(cauv_projected_exp) - eventual) %>% 
  gather(var, val, -indx)

avg_2018 <- recreated %>% 
  summarise(indx = "avg_cauv",
            eventual = mean(unadjusted),
            adjustment = mean(cauv_2018) - eventual) %>% 
  gather(var, val, -indx)

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

# ---- viz-cap ------------------------------------------------------------

ohio %>% 
  filter(!is.na(cap_rate_odt)) %>% 
  mutate(`Capitalization Rate` = cap_rate_odt) %>% 
  ggplot(aes(year, `Capitalization Rate`)) +
  geom_line() +
  geom_point() +
  # geom_label(aes(label = percent(cap_rate_odt)), nudge_y = 0.001) +
  # geom_text(data = filter(ohio, year >= 2019),
  #           aes(year, cap_rate_cauv_l, label = percent(cap_rate_cauv_l,
  #                                                      accuracy = 0.1)),
  #           color = "blue", show.legend = FALSE) +
  # geom_text(data = filter(ohio, year >= 2019),
  #           aes(year, cap_rate_cauv_h,
  #               label = percent(cap_rate_cauv_h, accuracy = 0.1)),
  #           color = "red", show.legend = FALSE) +
  scale_y_continuous(labels = percent_format(accuracy = 0.1)) +
  scale_x_continuous(breaks = c(2005, 2010, 2015, 2020),
                     limits = c(2003, 2020)) +
  labs(x = "", y = "", color = "", shape = "",
       title = "Capitalization Rate for Ohio",
       subtitle = "projected high/low values labelled",
       caption = paste0("Source: Dinterman and Katchova projections",
                        "\nbased on ODT data")) +
  theme_bw() +
  theme(legend.position = "bottom", legend.background = element_blank())

# ---- cap-table ------------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  select("Year" = year, "ODT Value" = cap_rate_odt,
         "Projected" = cap_rate_cauv_exp, #"Maybe" = cap_rate_cauv_exp,
         "Low" = cap_rate_cauv_l, "High" = cap_rate_cauv_h) %>% 
  mutate_at(vars(-Year), ~percent(., accuracy = 0.1)) %>% 
  kable(caption = "Historical Capitalization Rates")

# ---- viz-prices ---------------------------------------------------------

odt_price_vals <- ohio %>% 
  select(year, `Corn Price` = corn_price_odt,
         `Soy Price` = soy_price_odt,
         `Wheat Price` = wheat_price_odt) %>% 
  gather(var, val, -year) %>% 
  filter(!is.na(val))

cauv_price_h <- ohio %>% 
  filter(year >= 2019) %>% 
  select(year, `Corn Price` = corn_price_cauv_h,
         `Soy Price` = soy_price_cauv_h,
         `Wheat Price` = wheat_price_cauv_h) %>% 
  gather(var, val, -year) %>% 
  mutate(label = dollar(val, accuracy = 0.01),
         color = "blue")

cauv_price_l <- ohio %>% 
  filter(year >= 2019) %>% 
  select(year, `Corn Price` = corn_price_cauv_l,
         `Soy Price` = soy_price_cauv_l,
         `Wheat Price` = wheat_price_cauv_l) %>% 
  gather(var, val, -year) %>% 
  mutate(label = dollar(val, accuracy = 0.01),
         color = "red")

cauv_price <- bind_rows(cauv_price_h, cauv_price_l) %>% 
  distinct(year, var, val, .keep_all = TRUE)

ohio %>% 
  filter(year > 1990) %>% 
  select(year, `Corn Price` = corn_price, `Soy Price` = soy_price,
         `Wheat Price` = wheat_price) %>% 
  gather(var, val, -year) %>% 
  ggplot(aes(year, val, color = var)) +
  geom_line(linetype = 2) +
  geom_line(data = odt_price_vals, size = 1) +
  # geom_text_repel(data = cauv_price, aes(label = label),
  #                 direction = "y") +
  # geom_text_repel(data = cauv_price_h, aes(label = label), direction = "y",
  #           show.legend = FALSE) +
  # geom_text(data = cauv_price_l, aes(label = label), direction = "y",
  #           show.legend = FALSE) +
  geom_point(aes(shape = var), size = 2) +
  scale_y_continuous(labels = dollar, limits = c(0, 16)) +
  scale_x_continuous(breaks = c(1990, 2000, 2010, 2019),
                     limits = c(1990, 2021)) +
  scale_color_viridis(option = "C", end = 0.9, discrete = T) +
  labs(x = "", y = "", color = "", shape = "",
       title = "Commodity Prices in Ohio",
       subtitle = "solid lines are official values \nused in CAUV calculation",
       caption = paste0("Source: Dinterman and Katchova projections",
                        "\nbased on ODT and NASS data")) +
  theme_bw() +
  theme(legend.position = "bottom", legend.background = element_blank())

# ---- corn-price ---------------------------------------------------------


ohio %>%
  filter(year > 2005) %>%
  select(
    "Year" = year,
    "ODT Price" = corn_price_odt,
    "USDA Price" = corn_price,
    "Projection" = corn_price_cauv_exp,
    "Low Projection" = corn_price_cauv_l,
    "High Projection" = corn_price_cauv_h
  ) %>%
  mutate_at(vars(-Year), ~dollar(., accuracy = 0.01)) %>% 
  kable(caption = "Historical Corn Prices")

# ---- soy-price ----------------------------------------------------------


ohio %>%
  filter(year > 2005) %>%
  select(
    "Year" = year,
    "ODT Price" = soy_price_odt,
    "USDA Price" = soy_price,
    "Projection" = soy_price_cauv_exp,
    "Low Projection" = soy_price_cauv_l,
    "High Projection" = soy_price_cauv_h
  ) %>%
  mutate_at(vars(-Year), ~dollar(., accuracy = 0.01)) %>% 
  kable(caption = "Historical Soybean Prices")


# ---- wheat-price --------------------------------------------------------


ohio %>%
  filter(year > 2005) %>%
  select(
    "Year" = year,
    "ODT Price" = wheat_price_odt,
    "USDA Price" = wheat_price,
    "Projection" = wheat_price_cauv_exp,
    "Low Projection" = wheat_price_cauv_l,
    "High Projection" = wheat_price_cauv_h
  ) %>%
  mutate_at(vars(-Year), ~dollar(., accuracy = 0.01)) %>% 
  kable(caption = "Historical Wheat Prices")


# ---- viz-yields ---------------------------------------------------------

# No Olympic average, so no need to have a low/high just use trend

odt_yield_vals <- ohio %>% 
  select(year,
         `Corn Yield` = corn_yield_odt,
         `Soy Yield` = soy_yield_odt,
         `Wheat Yield` = wheat_yield_odt) %>% 
  replace_na(list(`Corn Yield` = 118, `Soy Yield` = 36.5,
                  `Wheat Yield` = 44)) %>% 
  gather(var, val, -year) %>% 
  filter(year > 1990, year < 2018)

cauv_yield_vals <- ohio %>% 
  select(year,
         `Corn Yield` = corn_yield_cauv,
         `Soy Yield` = soy_yield_cauv,
         `Wheat Yield` = wheat_yield_cauv) %>% 
  gather(var, val, -year) %>% 
  filter(year > 2006)


ohio %>% 
  filter(year > 1990) %>% 
  select(year, `Corn Yield` = corn_grain_yield,
         `Soy Yield` = soy_yield,
         `Wheat Yield` = wheat_yield) %>% 
  gather(var, val, -year) %>% 
  ggplot(aes(year, val, color = var)) +
  geom_line(linetype = 2) +
  geom_line(data = odt_yield_vals, size = 1) +
  # geom_line(data = cauv_vals, linetype = 4) +
  # geom_text_repel(data = filter(cauv_yield_vals, year >= 2019),
  #           aes(label = round(val, digits = 1)),
  #           show.legend = FALSE) +
  geom_point(aes(shape = var), size = 2) +
  scale_y_continuous(labels = comma, limits = c(0, 200)) +
  scale_x_continuous(breaks = c(1990, 2000, 2010, 2019),
                     limits = c(1990, 2021)) +
  scale_color_viridis(option = "C", end = 0.9, discrete = T) +
  labs(x = "", y = "", color = "", shape = "",
       title = "Commodity Yields in Ohio",
       subtitle = "solid lines are values used in CAUV calculation",
       caption = paste0("Source: Dinterman and Katchova projections",
                        "\nbased on ODT and NASS data")) +
  theme_bw() +
  theme(legend.position = "bottom", legend.background = element_blank())

# ---- corn-yield ---------------------------------------------------------

ohio %>% 
  filter(year > 2005) %>% 
  mutate(corn_yield_cauv = round(corn_yield_cauv, digits = 1)) %>% 
  select("Year" = year, "ODT Yield" = corn_yield_odt,
         "USDA Yield" = corn_grain_yield,
         "Projected Yield" = corn_yield_cauv) %>% 
  kable(caption = "Historical Corn Yields")

# ---- soy-yield ----------------------------------------------------------

ohio %>% 
  filter(year > 2005) %>% 
  mutate(soy_yield_cauv = round(soy_yield_cauv, digits = 1)) %>% 
  select("Year" = year, "ODT Yield" = soy_yield_odt,
         "USDA Yield" = soy_yield, "Projected Yield" = soy_yield_cauv) %>% 
  kable(caption = "Historical Soybean Yields")

# ---- wheat-yield --------------------------------------------------------

ohio %>% 
  filter(year > 2005) %>% 
  mutate(wheat_yield_cauv = round(wheat_yield_cauv, digits = 1)) %>% 
  select("Year" = year, "ODT Yield" = wheat_yield_odt,
         "USDA Yield" = wheat_yield,
         "Projected Yield" = wheat_yield_cauv) %>% 
  kable(caption = "Historical Wheat Yields")


# ---- viz-rotate ---------------------------------------------------------

cauv_rotate_vals <- ohio %>% 
  filter(year > 2005) %>% 
  select(year,
         `Corn Rotation` = corn_rotate_cauv,
         `Soy Rotation` = soy_rotate_cauv,
         `Wheat Rotation` = wheat_rotate_cauv) %>% 
  gather(var, val, -year) %>% 
  mutate(val = round(val, 3))

ohio %>% 
  filter(year > 2005) %>% 
  select(year, `Corn Rotation` = corn_rotate_odt,
         #`Hay Rotation` = hay_rotate_odt,
         `Soy Rotation` = soy_rotate_odt,
         `Wheat Rotation` = wheat_rotate_odt) %>% 
  gather(var, val, -year) %>% 
  # mutate(var = factor(var, levels = c("Corn Rotation", "Soy Rotation",
  #                                     "Wheat Rotation", "Hay Rotation")))%>% 
  ggplot(aes(year, val, color = var)) +
  geom_line() +
  # geom_line(data = odt_yield_vals, size = 1) +
  # geom_line(data = cauv_vals, linetype = 4) +
  # geom_text(data = filter(cauv_rotate_vals, year >= 2019),
  #           aes(label = percent(val)),
  #           show.legend = FALSE) +
  geom_point(aes(shape = var), size = 2) +
  scale_y_continuous(labels = percent, limits = c(0, .75)) +
  scale_color_viridis(option = "C", end = 0.9, discrete = T) +
  scale_x_continuous(breaks = c(2005, 2010, 2015, 2019),
                     limits = c(2005, 2021)) +
  labs(x = "", y = "", color = "", shape = "",
       title = "Rotation Percentage in Ohio",
       subtitle = "Hay was used in calculation prior to 2010",
       caption = paste0("Source: Dinterman and Katchova projections",
                        "\nbased on ODT and NASS data")) +
  theme_bw() +
  theme(legend.position = "bottom", legend.background = element_blank())


# ---- corn-rot -----------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  mutate(corn_rotate_cauv = percent(corn_rotate_cauv, accuracy = 0.1),
         corn_rotate_odt = percent(corn_rotate_odt, accuracy = 0.1),
         corn_grain_acres_harvest = comma(corn_grain_acres_harvest),
         corn_harvest_cauv = comma(corn_harvest_cauv)) %>% 
  select("Year" = year, "ODT Value" = corn_rotate_odt,
         "USDA Acres Harvested" = corn_grain_acres_harvest,
         "AVG Acres Harvested" = corn_harvest_cauv,
         "Projected" = corn_rotate_cauv) %>% 
  kable(caption = "Historical Corn Rotation", label = "\\label{tab:corn-rot}")

# ---- soy-rot ------------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  mutate(soy_rotate_cauv = percent(soy_rotate_cauv, accuracy = 0.1),
         soy_rotate_odt = percent(soy_rotate_odt, accuracy = 0.1),
         soy_acres_harvest = comma(soy_acres_harvest),
         soy_harvest_cauv = comma(soy_harvest_cauv)) %>% 
  select("Year" = year, "ODT Value" = soy_rotate_odt,
         "USDA Acres Harvested" = soy_acres_harvest,
         "AVG Acres Harvested" = soy_harvest_cauv,
         "Projected" = soy_rotate_cauv) %>% 
  kable(caption = "Historical Soy Rotation", label = "\\label{tab:soy-rot}")

# ---- wheat-rot ----------------------------------------------------------

ohio %>% 
  filter(year > 2009) %>% 
  mutate(wheat_rotate_cauv = percent(wheat_rotate_cauv, accuracy = 0.1),
         wheat_rotate_odt = percent(wheat_rotate_odt, accuracy = 0.1),
         wheat_acres_harvest = comma(wheat_acres_harvest),
         wheat_harvest_cauv = comma(wheat_harvest_cauv)) %>% 
  select("Year" = year, "ODT Value" = wheat_rotate_odt,
         "USDA Acres Harvested" = wheat_acres_harvest,
         "AVG Acres Harvested" = wheat_harvest_cauv,
         "Projected" = wheat_rotate_cauv) %>% 
  kable(caption = "Historical Wheat Rotation", label = "\\label{tab:wheat-rot}")

# ---- viz-nonland --------------------------------------------------------

cauv_nl_h <- ohio %>% 
  filter(year >= 2019) %>% 
  select(year, `Corn Costs` = corn_cost_cauv_h,
         `Soy Costs` = soy_cost_cauv_h,
         `Wheat Costs` = wheat_cost_cauv_h) %>% 
  gather(var, val, -year) %>% 
  mutate(label = dollar(val, accuracy = 0.01))

cauv_nl_l <- ohio %>% 
  filter(year >= 2019) %>% 
  select(year, `Corn Costs` = corn_cost_cauv_l,
         `Soy Costs` = soy_cost_cauv_l,
         `Wheat Costs` = wheat_cost_cauv_l) %>% 
  gather(var, val, -year) %>% 
  mutate(label = dollar(val, accuracy = 0.01))

cauv_nl <- bind_rows(cauv_nl_h, cauv_nl_l) %>% 
  distinct(year, var, val, .keep_all = TRUE)

ohio %>% 
  filter(year > 2005) %>% 
  select(year, `Corn Costs` = corn_cost_odt, `Soy Costs` = soy_cost_odt,
         `Wheat Costs` = wheat_cost_odt) %>% 
  gather(var, val, -year) %>% 
  ggplot(aes(year, val, color = var)) +
  geom_line() +
  # geom_text_repel(data = cauv_nl, aes(label = label),
  #                 direction = "y") +
  # geom_text(data = cauv_nl_h, aes(y = pos, label = dollar(val)),
  #           show.legend = FALSE) +
  # geom_text(data = cauv_nl_l, aes(y = pos, label = dollar(val)),
  #           show.legend = FALSE) +
  # geom_line(data = odt_vals, size = 1) +
  geom_point(aes(shape = var), size = 2) +
  scale_y_continuous(labels = dollar) +
  scale_x_continuous(breaks = c(2005, 2010, 2015, 2019),
                     limits = c(2005, 2021)) +
  scale_color_viridis(option = "C", end = 0.9, discrete = T) +
  labs(x = "", y = "", color = "", shape = "",
       title = "Commodity Base Costs in Ohio",
       subtitle = "projected high/low values labelled",
       caption = paste0("Source: Dinterman and Katchova projections",
                        "\nbased on ODT and OSU Extension data")) +
  theme_bw() +
  theme(legend.position = "bottom", legend.background = element_blank())

# ---- viz-nonland-add ----------------------------------------------------

cauv_nl_add_h <- ohio %>% 
  filter(year >= 2019) %>% 
  select(year, `Corn Costs` = corn_cost_add_cauv_h,
         `Soy Costs` = soy_cost_add_cauv_h,
         `Wheat Costs` = wheat_cost_add_cauv_h) %>% 
  gather(var, val, -year) %>% 
  mutate(label = dollar(val, accuracy = 0.01))

cauv_nl_add_l <- ohio %>% 
  filter(year >= 2019) %>% 
  select(year, `Corn Costs` = corn_cost_add_cauv_l,
         `Soy Costs` = soy_cost_add_cauv_l,
         `Wheat Costs` = wheat_cost_add_cauv_l) %>% 
  gather(var, val, -year) %>% 
  mutate(label = dollar(val, accuracy = 0.01))

cauv_nl_add <- bind_rows(cauv_nl_add_h, cauv_nl_add_l) %>% 
  distinct(year, var, val, .keep_all = TRUE)

ohio %>% 
  filter(year > 2005) %>% 
  select(year, `Corn Costs` = corn_cost_add_odt, `Soy Costs` = soy_cost_add_odt,
         `Wheat Costs` = wheat_cost_add_odt) %>% 
  gather(var, val, -year) %>% 
  ggplot(aes(year, val, color = var)) +
  geom_line() +
  # geom_text_repel(data = cauv_nl_add, aes(label = label),
  #                 direction = "y") +
  # geom_text(data = cauv_nl_h, aes(y = pos, label = dollar(val)),
  #           show.legend = FALSE) +
  # geom_text(data = cauv_nl_l, aes(y = pos, label = dollar(val)),
  #           show.legend = FALSE) +
  # geom_line(data = odt_vals, size = 1) +
  geom_point(aes(shape = var), size = 2) +
  scale_y_continuous(labels = dollar) +
  scale_x_continuous(breaks = c(2005, 2010, 2015, 2019),
                     limits = c(2005, 2021)) +
  scale_color_viridis(option = "C", end = 0.9, discrete = T) +
  labs(x = "", y = "", color = "", shape = "",
       title = "Commodity Additional Costs in Ohio",
       subtitle = "projected high/low values labelled",
       caption = paste0("Source: Dinterman and Katchova projections",
                        "\nbased on ODT and OSU Extension data")) +
  theme_bw() +
  theme(legend.position = "bottom", legend.background = element_blank())

# ---- corn-base ----------------------------------------------------------

ohio %>% 
  filter(year > 2012) %>% 
  select("Year" = year, "ODT Base Cost" = corn_cost_odt,
         "Projection" = corn_cost_cauv,
         "Low Projection" = corn_cost_cauv_l,
         "High Projection" = corn_cost_cauv_h) %>% 
  mutate_at(vars(-Year), ~dollar(., accuracy = 0.01)) %>% 
  kable(caption = "Historical Corn Base Costs", label = "\\label{tab:corn-base}")

# ---- corn-add -----------------------------------------------------------

ohio %>% 
  filter(year > 2012) %>% 
  select("Year" = year, "ODT Add Cost" = corn_cost_add_odt,
         "Projection" = corn_cost_add_cauv,
         "Low Projection" = corn_cost_add_cauv_l,
         "High Projection" = corn_cost_add_cauv_h) %>% 
  mutate_at(vars(-Year), ~dollar(., accuracy = 0.01)) %>% 
  kable(caption = "Historical Corn Additional Costs", label = "\\label{tab:corn-add}")

# ---- soy-base ----------------------------------------------------------

ohio %>% 
  filter(year > 2012) %>% 
  select("Year" = year, "ODT Base Cost" = soy_cost_odt,
         "Projection" = soy_cost_cauv,
         "Low Projection" = soy_cost_cauv_l,
         "High Projection" = soy_cost_cauv_h) %>% 
  mutate_at(vars(-Year), ~dollar(., accuracy = 0.01)) %>% 
  kable(caption = "Historical Soybeans Base Costs", label = "\\label{tab:soy-base}")

# ---- soy-add -----------------------------------------------------------

ohio %>% 
  filter(year > 2012) %>% 
  select("Year" = year, "ODT Add Cost" = soy_cost_add_odt,
         "Projection" = soy_cost_add_cauv,
         "Low Projection" = soy_cost_add_cauv_l,
         "High Projection" = soy_cost_add_cauv_h) %>% 
  mutate_at(vars(-Year), ~dollar(., accuracy = 0.01)) %>% 
  kable(caption = "Historical Soybeans Additional Costs", label = "\\label{tab:soy-add}")

# ---- wheat-base ----------------------------------------------------------

ohio %>% 
  filter(year > 2012) %>% 
  select("Year" = year, "ODT Base Cost" = wheat_cost_odt,
         "Projection" = wheat_cost_cauv,
         "Low Projection" = wheat_cost_cauv_l,
         "High Projection" = wheat_cost_cauv_h) %>% 
  mutate_at(vars(-Year), ~dollar(., accuracy = 0.01)) %>% 
  kable(caption = "Historical Wheat Base Costs", label = "\\label{tab:wheat-base}")

# ---- wheat-add -----------------------------------------------------------

ohio %>% 
  filter(year > 2012) %>% 
  select("Year" = year, "ODT Add Cost" = wheat_cost_add_odt,
         "Projection" = wheat_cost_add_cauv,
         "Low Projection" = wheat_cost_add_cauv_l,
         "High Projection" = wheat_cost_add_cauv_h) %>% 
  mutate_at(vars(-Year), ~dollar(., accuracy = 0.01)) %>% 
  kable(caption = "Historical Wheat Additional Costs", label = "\\label{tab:wheat-add}")


# ---- cropland-trend -----------------------------------------------------

ohio_soils_exp %>%
  filter(year < 2019) %>% 
  select(-num_soils) %>%
  gather(var, val, -year) %>%
  mutate(var = factor(var, levels = indxs, labels = indx_name)) %>% 
  {
    ggplot(., aes(year, val)) +
      geom_line(aes(color = var, size = var)) +
      geom_point(aes(color = var)) +
      geom_text_repel(data = filter(., year == 2018),
                      aes(color = var,
                          label = dollar(val, accuracy = 1)),
                      nudge_x = 1.75, show.legend = FALSE,
                      segment.alpha = 0.5) +
      scale_x_continuous(breaks = c(1990, 2000, 2010, 2018),
                         limits = c(1991, 2020)) +
      scale_y_continuous(labels = dollar) +
      scale_color_viridis(option = "C", direction = -1,
                          end = 0.9, discrete = T) +
      scale_size_manual(values = indx_size) +
      labs(x = "", y = "", color = "Soil Productivity Index",
           size = "Soil Productivity Index",
           title = "Official CAUV Values of Cropland through 2018",
           subtitle = "in dollars per acre",
           caption = "Source: Ohio Department of Taxation") +
      theme_bw() +
      theme(legend.position = c(0.2, 0.65),
            legend.background = element_blank())
  }
# ggsave(filename = paste0(figures, "/cauv_2018.png"),
#        width = 10, height = 7)

# ---- phase-in -----------------------------------------------------------

recreated %>% 
  group_by(indx) %>% 
  summarise(eventual = mean(unadjusted),
            adjustment = mean(cauv_2018) - eventual) %>% 
  gather(var, val, -indx) %>% 
  bind_rows(avg_2018) %>% 
  mutate(indx = factor(indx, levels = indxs, labels = indx_name),
         var = factor(var, levels = c("adjustment", "eventual"),
                      labels = c("Adjustment", "Eventual Value"))) %>% 
  ggplot(aes(indx, val, fill = var)) +
  geom_col() +
  scale_y_continuous(labels = dollar, limits = c(0, 5000)) +
  scale_fill_viridis(discrete = T, option = "C", direction = -1, end = 0.9) + 
  labs(x = "", y = "",
       title = "Phase-In for 2018 CAUV Values",
       subtitle = "by Productivity Indexes, actual value is full bar",
       caption = caption_proj,
       fill = "") +
  theme_bw() +
  theme(legend.position = c(0.85, 0.85), legend.background = element_blank())
# ggsave(filename = paste0(figures, "/cauv_phase_in_2018.png"),
#        width = 10, height = 7)

# ---- high-trend ---------------------------------------------------------

ohio_soils_high %>%
  select(-num_soils) %>%
  gather(var, val, -year) %>%
  mutate(var = factor(var, levels = indxs, labels = indx_name)) %>% 
  {
    ggplot(.,aes(year, val)) +
      geom_line(aes(color = var, size = var)) +
      geom_point(aes(color = var)) +
      geom_text_repel(data = filter(., year == 2019),
                      aes(color = var,
                          label = dollar(val, accuracy = 1)),
                      nudge_x = 1.75, show.legend = FALSE,
                      segment.alpha = 0.5) +
      geom_vline(xintercept = 2018) +
      scale_x_continuous(breaks = c(1990, 2000, 2010, 2018),
                         limits = c(1991, 2020)) +
      scale_y_continuous(labels = dollar) +
      scale_color_viridis(option = "C", direction = -1,
                          end = 0.9, discrete = T) +
      scale_size_manual(values = indx_size) +
      labs(x = "", y = "", color = "Soil Productivity Index",
           size = "Soil Productivity Index",
           title = "2019 High Projection for CAUV Values of Cropland",
           subtitle = "in dollars per acre",
           caption = caption_proj) +
      theme_bw() +
      theme(legend.position = c(0.2, 0.65),
            legend.background = element_blank())
  }
# ggsave(filename = paste0(figures, "/cauv_high_projections_2019.png"),
#        width = 10, height = 7)

# ---- high-2019 -----------------------------------------------------------

ohio_high %>% 
  group_by(indx) %>% 
  summarise(eventual = mean(unadjusted),
            adjustment = mean(cauv_projected_high) - eventual) %>% 
  gather(var, val, -indx) %>% 
  bind_rows(avg_high) %>% 
  mutate(indx = factor(indx, levels = indxs, labels = indx_name),
         var = factor(var, levels = c("adjustment", "eventual"),
                      labels = c("Adjustment", "Eventual Value"))) %>% 
  ggplot(aes(indx, val, fill = var)) +
  geom_col() +
  scale_y_continuous(labels = dollar, limits = c(0, 4000)) +
  scale_fill_viridis(discrete = T, option = "C", direction = -1, end = 0.9) + 
  labs(x = "", y = "",
       title = "Phase-In for High Projection of 2019 CAUV Values",
       subtitle = "by Productivity Indexes, actual value is full bar",
       caption = caption_proj,
       fill = "") +
  theme_bw() +
  theme(legend.position = c(0.85, 0.85), legend.background = element_blank())
# ggsave(filename = paste0(figures, "/cauv_high_phase_in_2019.png"),
#        width = 10, height = 7)

# ---- low-trend ----------------------------------------------------------

ohio_soils_low %>%
  select(-num_soils) %>%
  gather(var, val, -year) %>%
  mutate(var = factor(var, levels = indxs, labels = indx_name)) %>% 
  {
    ggplot(.,aes(year, val)) +
      geom_line(aes(color = var, size = var)) +
      geom_point(aes(color = var)) +
      geom_text_repel(data = filter(., year == 2019),
                      aes(color = var,
                          label = dollar(val, accuracy = 1)),
                      nudge_x = 1.75, show.legend = FALSE,
                      segment.alpha = 0.5) +
      geom_vline(xintercept = 2018) +
      scale_x_continuous(breaks = c(1990, 2000, 2010, 2018),
                         limits = c(1991, 2020)) +
      scale_y_continuous(labels = dollar) +
      scale_color_viridis(option = "C", direction = -1,
                          end = 0.9, discrete = T) +
      scale_size_manual(values = indx_size) +
      labs(x = "", y = "", color = "Soil Productivity Index",
           size = "Soil Productivity Index",
           title = "2019 Low Projection for CAUV Values of Cropland",
           subtitle = "in dollars per acre",
           caption = caption_proj) +
      theme_bw() +
      theme(legend.position = c(0.2, 0.65),
            legend.background = element_blank())
  }
# ggsave(filename = paste0(figures, "/cauv_low_projections_2019.png"),
#        width = 10, height = 7)

# ---- low-2019 -----------------------------------------------------------

ohio_low %>% 
  group_by(indx) %>% 
  summarise(eventual = mean(unadjusted),
            adjustment = mean(cauv_projected_low) - eventual) %>% 
  gather(var, val, -indx) %>% 
  bind_rows(avg_low) %>% 
  mutate(indx = factor(indx, levels = indxs, labels = indx_name),
         var = factor(var, levels = c("adjustment", "eventual"),
                      labels = c("Adjustment", "Eventual Value"))) %>% 
  ggplot(aes(indx, val, fill = var)) +
  geom_col() +
  scale_y_continuous(labels = dollar, limits = c(0, 4000)) +
  scale_fill_viridis(discrete = T, option = "C", direction = -1, end = 0.9) + 
  labs(x = "", y = "",
       title = "Phase-In for Low Projection of 2019 CAUV Values",
       subtitle = "by Productivity Indexes, actual value is full bar",
       caption = caption_proj,
       fill = "") +
  theme_bw() +
  theme(legend.position = c(0.85, 0.85), legend.background = element_blank())
# ggsave(filename = paste0(figures, "/cauv_low_phase_in_2019.png"),
#        width = 10, height = 7)

# ---- exp-trend ----------------------------------------------------------

ohio_soils_exp %>%
  select(-num_soils) %>%
  gather(var, val, -year) %>%
  mutate(var = factor(var, levels = indxs, labels = indx_name)) %>% 
  {
    ggplot(., aes(year, val)) +
      geom_line(aes(color = var, size = var)) +
      geom_point(aes(color = var)) +
      geom_text_repel(data = filter(., year == 2019),
                      aes(color = var,
                          label = dollar(val, accuracy = 1)),
                      nudge_x = 1.75, show.legend = FALSE,
                      segment.alpha = 0.5) +
      geom_vline(xintercept = 2018) +
      scale_x_continuous(breaks = c(1990, 2000, 2010, 2018),
                         limits = c(1991, 2020)) +
      scale_y_continuous(labels = dollar) +
      scale_color_viridis(option = "C", direction = -1,
                          end = 0.9, discrete = T) +
      scale_size_manual(values = indx_size) +
      labs(x = "", y = "", size = "Soil Productivity Index",
           color = "Soil Productivity Index",
           title = "2019 Projection for CAUV Values of Cropland",
           subtitle = "in dollars per acre",
           caption = caption_proj) +
      theme_bw() +
      theme(legend.position = c(0.2, 0.65),
            legend.background = element_blank())
  }
# ggsave(filename = paste0(figures, "/cauv_expected_projections_2019.png"),
#        width = 10, height = 7)

# ---- exp-2019 -----------------------------------------------------------

ohio_exp %>% 
  group_by(indx) %>% 
  summarise(eventual = mean(unadjusted),
            adjustment = mean(cauv_projected_exp) - eventual) %>% 
  gather(var, val, -indx) %>% 
  bind_rows(avg_exp) %>% 
  mutate(indx = factor(indx, levels = indxs, labels = indx_name),
         var = factor(var, levels = c("adjustment", "eventual"),
                      labels = c("Adjustment", "Eventual Value"))) %>% 
  ggplot(aes(indx, val, fill = var)) +
  geom_col() +
  scale_y_continuous(labels = dollar, limits = c(0, 4000)) +
  scale_fill_viridis(discrete = T, option = "C", direction = -1, end = 0.9) + 
  labs(x = "", y = "",
       title = "Phase-In for Projection of 2019 CAUV Values",
       subtitle = "by Productivity Indexes, actual value is full bar",
       caption = caption_proj,
       fill = "") +
  theme_bw() +
  theme(legend.position = c(0.85, 0.85), legend.background = element_blank())
# ggsave(filename = paste0(figures, "/cauv_expected_phase_in_2019.png"),
#        width = 10, height = 7)

# ---- exp-trend-2020 -------------------------------------------------------

ohio_soils_exp2 %>%
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
      geom_vline(xintercept = 2018) +
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
# ggsave(filename = paste0(figures, "/cauv_expected_projections_2019.png"),
#        width = 10, height = 7)

# ---- low-trend-2020 ------------------------------------------------------

ohio_soils_low2 %>%
  select(-num_soils) %>%
  gather(var, val, -year) %>%
  mutate(var = factor(var, levels = indxs, labels = indx_name)) %>% 
  {
    ggplot(.,aes(year, val)) +
      geom_line(aes(color = var, size = var)) +
      geom_point(aes(color = var)) +
      geom_text_repel(data = filter(., year == 2020),
                      aes(color = var,
                          label = dollar(val, accuracy = 1)),
                      nudge_x = 1.75, show.legend = FALSE,
                      segment.alpha = 0.5) +
      geom_vline(xintercept = 2018) +
      scale_x_continuous(breaks = c(1990, 2000, 2010, 2018),
                         limits = c(1991, 2021)) +
      scale_y_continuous(labels = dollar) +
      scale_color_viridis(option = "C", direction = -1,
                          end = 0.9, discrete = T) +
      scale_size_manual(values = indx_size) +
      labs(x = "", y = "", color = "Soil Productivity Index",
           size = "Soil Productivity Index",
           title = "2020 Low Projection for CAUV Values of Cropland",
           subtitle = "in dollars per acre",
           caption = caption_proj) +
      theme_bw() +
      theme(legend.position = c(0.2, 0.65),
            legend.background = element_blank())
  }
# ggsave(filename = paste0(figures, "/cauv_low_projections_2020.png"),
#        width = 10, height = 7)

# ---- high-trend-2020 -----------------------------------------------------

ohio_soils_high2 %>%
  select(-num_soils) %>%
  gather(var, val, -year) %>%
  mutate(var = factor(var, levels = indxs, labels = indx_name)) %>% 
  {
    ggplot(.,aes(year, val)) +
      geom_line(aes(color = var, size = var)) +
      geom_point(aes(color = var)) +
      geom_text_repel(data = filter(., year == 2020),
                      aes(color = var,
                          label = dollar(val, accuracy = 1)),
                      nudge_x = 1.75, show.legend = FALSE,
                      segment.alpha = 0.5) +
      geom_vline(xintercept = 2018) +
      scale_x_continuous(breaks = c(1990, 2000, 2010, 2018),
                         limits = c(1991, 2021)) +
      scale_y_continuous(labels = dollar) +
      scale_color_viridis(option = "C", direction = -1,
                          end = 0.9, discrete = T) +
      scale_size_manual(values = indx_size) +
      labs(x = "", y = "", color = "Soil Productivity Index",
           size = "Soil Productivity Index",
           title = "2020 High Projection for CAUV Values of Cropland",
           subtitle = "in dollars per acre",
           caption = caption_proj) +
      theme_bw() +
      theme(legend.position = c(0.2, 0.65),
            legend.background = element_blank())
  }
# ggsave(filename = paste0(figures, "/cauv_high_projections_2019.png"),
#        width = 10, height = 7)


# ---- update-map ---------------------------------------------------------

ohio_map_data <- read_rds("4-presentations/ohio_cauv.rds") %>% 
  group_by(county) %>% 
  mutate(cauv_all   = sum(cauv) / sum(acres_cauv),
         market_all = sum(market_value) / sum(acres_cauv),
         update = if_else(update == 2017, 2020, update))

ohio_map <- map_data("county", "Ohio") %>%
  rename(county = subregion) %>% 
  right_join(filter(ohio_map_data, !is.na(cauv)))

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
  filter(year == 2016) %>% 
  ggplot(aes(long, lat)) +
  geom_polygon(aes(group = group, fill = as.factor(update))) +
  geom_path(aes(group = group), size = 0.05) +
  geom_text(data = cnames, aes(label = county), size = 3, color = "black") +
  scale_fill_viridis(option = "C", discrete = T, begin = 0.35) +
  labs(fill = "", title = "Schedule for CAUV Update",
       caption = paste0("Source: Dinterman and Katchova projections",
                        "\nbased on ODT data")) +
  ohio_theme + 
  theme(legend.position = c(0.15, 0.95), legend.direction = "horizontal")

