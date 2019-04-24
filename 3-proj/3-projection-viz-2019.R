# Visuals and charts for CAUV values and projections, depends on
#  3-projection.R


# ---- start --------------------------------------------------------------

library("knitr")
library("scales")
library("tidyverse")
library("viridis")
library("ggrepel")
dollars <- function(x, dig = 0) dollar_format(largest_with_cents = dig)(x)

local_dir <- "3-proj"
figures   <- paste0(local_dir, "/figures")
future    <- paste0(local_dir, "/future")
if (!file.exists(local_dir)) dir.create(local_dir)
if (!file.exists(figures)) dir.create(figures)


ohio <- read_rds(paste0(future, "/ohio_2019.rds"))
recreated_2017 <- read_rds(paste0(future, "/ohio_recreated_2017.rds"))
recreated_2018 <- read_rds(paste0(future, "/ohio_recreated_2018.rds"))
ohio_low <- read_rds(paste0(future, "/ohio_low_2019.rds"))
ohio_high <- read_rds(paste0(future, "/ohio_high_2019.rds"))
ohio_exp <- read_rds(paste0(future, "/ohio_exp_2019.rds"))
ohio_soils <- read_rds(paste0(future, "/ohio_soils_2019.rds"))
ohio_soils_low <- read_rds(paste0(future, "/ohio_soils_low_2019.rds"))
ohio_soils_high <- read_rds(paste0(future, "/ohio_soils_high_2019.rds"))
ohio_soils_exp <- read_rds(paste0(future, "/ohio_soils_exp_2019.rds"))

avg_low <- ohio_low %>% 
  summarise(indx = "all",
            eventual = mean(unadjusted),
            adjustment = mean(cauv_projected_low) - eventual) %>% 
  gather(var, val, -indx) 

avg_exp <- ohio_exp %>% 
  summarise(indx = "all",
            eventual = mean(unadjusted),
            adjustment = mean(cauv_projected_exp) - eventual) %>% 
  gather(var, val, -indx)

avg_2017 <- recreated_2017 %>% 
  summarise(indx = "all",
            eventual = mean(unadjusted),
            adjustment = mean(cauv_2017) - eventual) %>% 
  gather(var, val, -indx)

avg_2018 <- recreated_2018 %>% 
  summarise(indx = "all",
            eventual = mean(unadjusted),
            adjustment = mean(cauv_2018) - eventual) %>% 
  gather(var, val, -indx)

caption_proj <- paste0("Source: Dinterman and Katchova projections",
                       "\nbased on ODT/NASS/OSU Extension data")

# ---- viz-cap ------------------------------------------------------------

ohio %>% 
  filter(!is.na(cap_rate_odt)) %>% 
  mutate(`Capitalization Rate` = cap_rate_odt) %>% 
  ggplot(aes(year, `Capitalization Rate`)) +
  geom_line() +
  geom_point() +
  #geom_label(aes(label = percent(cap_rate_odt)), nudge_y = 0.001) +
  geom_text(data = filter(ohio, year == 2019),
            aes(year, cap_rate_cauv_l, label = percent(cap_rate_cauv_l)),
            color = "blue", show.legend = FALSE) +
  geom_text(data = filter(ohio, year == 2019),
            aes(year,cap_rate_cauv_h,label=percent(round(cap_rate_cauv_h,3))),
            color = "red", show.legend = FALSE) +
  scale_y_continuous(labels = percent) +
  scale_x_continuous(breaks = c(2005, 2010, 2015, 2019),
                     limits = c(2003, 2019)) +
  labs(x = "", y = "", color = "", shape = "",
       title = "Capitalization Rate for Ohio",
       subtitle = "projected high/low values labelled in 2019",
       caption = paste0("Source: Dinterman and Katchova projections",
                        "\nbased on ODT data")) +
  theme_bw() +
  theme(legend.position = "bottom", legend.background = element_blank())


# ---- viz-prices ---------------------------------------------------------

odt_price_vals <- ohio %>% 
  select(year, `Corn Price` = corn_price_odt,
         `Soy Price` = soy_price_odt,
         `Wheat Price` = wheat_price_odt) %>% 
  gather(var, val, -year) %>% 
  filter(!is.na(val))

cauv_price_h <- ohio %>% 
  filter(year == 2019) %>% 
  select(year, `Corn Price` = corn_price_cauv_h,
         `Soy Price` = soy_price_cauv_h,
         `Wheat Price` = wheat_price_cauv_h) %>% 
  gather(var, val, -year) %>% 
  mutate(label = dollar(val),
         pos = ifelse(var == "Corn Price", val -0.4, val))

cauv_price_l <- ohio %>% 
  filter(year == 2019) %>% 
  select(year, `Corn Price` = corn_price_cauv_l,
         `Soy Price` = soy_price_cauv_l,
         `Wheat Price` = wheat_price_cauv_l) %>% 
  gather(var, val, -year) %>% 
  mutate(label = dollar(val),
         pos = ifelse(var == "Corn Price", val -0.5, val))

ohio %>% 
  filter(year > 1990) %>% 
  select(year, `Corn Price` = corn_price, `Soy Price` = soy_price,
         `Wheat Price` = wheat_price) %>% 
  gather(var, val, -year) %>% 
  ggplot(aes(year, val, color = var)) +
  geom_line(linetype = 2) +
  geom_line(data = odt_price_vals, size = 1) +
  geom_text(data = cauv_price_h, aes(y = pos, label = label),
            show.legend = FALSE) +
  geom_text(data = cauv_price_l, aes(y = pos, label = label),
            show.legend = FALSE) +
  geom_point(aes(shape = var), size = 2) +
  scale_y_continuous(labels = dollar, limits = c(0, 16)) +
  scale_x_continuous(breaks = c(1990, 2000, 2010, 2019),
                     limits = c(1990, 2019)) +
  scale_color_viridis(option = "C", end = 0.9, discrete = T) +
  labs(x = "", y = "", color = "", shape = "",
       title = "Commodity Prices in Ohio",
       subtitle = "solid lines are values used in CAUV calculation",
       caption = paste0("Source: Dinterman and Katchova projections",
                        "\nbased on ODT and NASS data")) +
  theme_bw() +
  theme(legend.position = "bottom", legend.background = element_blank())


# ---- viz-yields ---------------------------------------------------------

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
  geom_text(data = filter(cauv_yield_vals, year == 2019),
            aes(label = round(val)),
            show.legend = FALSE) +
  geom_point(aes(shape = var), size = 2) +
  scale_y_continuous(labels = comma, limits = c(0, 200)) +
  scale_x_continuous(breaks = c(1990, 2000, 2010, 2019),
                     limits = c(1990, 2019)) +
  scale_color_viridis(option = "C", end = 0.9, discrete = T) +
  labs(x = "", y = "", color = "", shape = "",
       title = "Commodity Yields in Ohio",
       subtitle = "solid lines are values used in CAUV calculation",
       caption = paste0("Source: Dinterman and Katchova projections",
                        "\nbased on ODT and NASS data")) +
  theme_bw() +
  theme(legend.position = "bottom", legend.background = element_blank())

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
  geom_text(data = filter(cauv_rotate_vals, year == 2019),
            aes(label = percent(val)),
            show.legend = FALSE) +
  geom_point(aes(shape = var), size = 2) +
  scale_y_continuous(labels = percent, limits = c(0, .75)) +
  scale_color_viridis(option = "C", end = 0.9, discrete = T) +
  scale_x_continuous(breaks = c(2005, 2010, 2015, 2019),
                     limits = c(2005, 2019)) +
  labs(x = "", y = "", color = "", shape = "",
       title = "Rotation Percentage in Ohio",
       subtitle = "Hay was used in calculation prior to 2010",
       caption = paste0("Source: Dinterman and Katchova projections",
                        "\nbased on ODT and NASS data")) +
  theme_bw() +
  theme(legend.position = "bottom", legend.background = element_blank())

# ---- viz-nonland --------------------------------------------------------

cauv_nl_h <- ohio %>% 
  filter(year == 2019) %>% 
  select(year, `Corn Costs` = corn_cost_cauv_h,
         `Soy Costs` = soy_cost_cauv_h,
         `Wheat Costs` = wheat_cost_cauv_h) %>% 
  gather(var, val, -year) %>% 
  mutate(pos = ifelse(var == "Wheat Costs", val - 15, val),
         pos = ifelse(var == "Soy Costs", pos + 15, pos))

cauv_nl_l <- ohio %>% 
  filter(year == 2019) %>% 
  select(year, `Corn Costs` = corn_cost_cauv_l,
         `Soy Costs` = soy_cost_cauv_l,
         `Wheat Costs` = wheat_cost_cauv_l) %>% 
  gather(var, val, -year) %>% 
  mutate(pos = ifelse(var == "Wheat Costs", val - 15, val),
         pos = ifelse(var == "Soy Costs", pos + 15, pos))

ohio %>% 
  filter(year > 2005) %>% 
  select(year, `Corn Costs` = corn_cost_odt, `Soy Costs` = soy_cost_odt,
         `Wheat Costs` = wheat_cost_odt) %>% 
  gather(var, val, -year) %>% 
  ggplot(aes(year, val, color = var)) +
  geom_line() +
  geom_text(data = cauv_nl_h, aes(y = pos, label = dollar(val)),
            show.legend = FALSE) +
  geom_text(data = cauv_nl_l, aes(y = pos, label = dollar(val)),
            show.legend = FALSE) +
  # geom_line(data = odt_vals, size = 1) +
  geom_point(aes(shape = var), size = 2) +
  scale_y_continuous(labels = dollar) +
  scale_x_continuous(breaks = c(2005, 2010, 2015, 2019),
                     limits = c(2005, 2019)) +
  scale_color_viridis(option = "C", end = 0.9, discrete = T) +
  labs(x = "", y = "", color = "", shape = "",
       title = "Commodity Base Costs in Ohio",
       subtitle = "projected high/low values labelled in 2019",
       caption = paste0("Source: Dinterman and Katchova projections",
                        "\nbased on ODT and OSU Extension data")) +
  theme_bw() +
  theme(legend.position = "bottom", legend.background = element_blank())


# ---- cropland-trend -----------------------------------------------------

ohio_soils %>%
  select(-avg_cauv, -num_soils) %>%
  gather(var, val, -year) %>%
  mutate(var = factor(var,
                      levels =  c("indx_100", "indx_99", "indx_89", "indx_79",
                                  "indx_69", "indx_59", "indx_49"),
                      labels = c("100", "90 to 99", "80 to 89", "70 to 79",
                                 "60 to 69", "50 to 59", "0 to 49"))) %>% 
  {
    ggplot(., aes(year, val)) +
      geom_line(aes(color = var)) +
      geom_point(aes(color = var)) +
      geom_text_repel(data = filter(., year == 2018),
                      aes(color = var,
                          label = dollars(val)),
                      nudge_x = 1.75, show.legend = FALSE,
                      segment.alpha = 0.5) +
      geom_line(data = ohio_soils, aes(year, avg_cauv), size = 2) +
      geom_text_repel(data = filter(ohio_soils, year == 2018),
                      aes(year, avg_cauv,
                          label = dollars(avg_cauv)),
                      nudge_x = 1.75, nudge_y = 100,
                      show.legend = FALSE, segment.alpha = 0.5) +
      scale_x_continuous(breaks = c(1990, 2000, 2010, 2018),
                         limits = c(1991, 2019)) +
      scale_y_continuous(labels = dollar) +
      scale_color_viridis(option = "C", direction = -1,
                          end = 0.9, discrete = T) +
      labs(x = "", y = "", color = "Soil Productivity Index",
           title = "Official CAUV Values of Cropland through 2018",
           subtitle = "in dollars per acre, average value in black",
           caption = "Source: Ohio Department of Taxation") +
      theme_bw() +
      theme(legend.position = c(0.2, 0.7),
            legend.background = element_blank())
  }
ggsave(filename = paste0(figures, "/cauv_2018.png"),
       width = 7, height = 5.25)

# ---- phase-in -----------------------------------------------------------

recreated_2018 %>% 
  group_by(indx) %>% 
  summarise(eventual = mean(unadjusted),
            adjustment = mean(cauv_2018) - eventual) %>% 
  gather(var, val, -indx) %>% 
  bind_rows(avg_2018) %>% 
  mutate(indx = factor(indx,
                       levels =  c("indx_100", "indx_99", "indx_89", "indx_79",
                                   "indx_69", "indx_59", "indx_49", "all"),
                       labels = c("100", "90 to 99", "80 to 89",
                                  "70 to 79", "60 to 69", "50 to 59",
                                  "0 to 49", "All")),
         var = factor(var, levels = c("adjustment", "eventual"),
                      labels = c("Adjustment", "Eventual Value"))) %>% 
  ggplot(aes(indx, val, fill = var)) +
  geom_col() +
  scale_y_continuous(labels = dollar, limits = c(0, 5000)) +
  scale_fill_viridis(discrete = T, option = "C", direction = -1, end = 0.9) + 
  labs(x = "", y = "",
       title = "Phase-In for 2018 CAUV Values",
       subtitle = "by Productivity Indexes, phased-in value is full bar",
       caption = caption_proj,
       fill = "") +
  theme_bw() +
  theme(legend.position = c(0.85, 0.85), legend.background = element_blank())
ggsave(filename = paste0(figures, "/cauv_phase_in_2018.png"),
       width = 7, height = 5.25)

# ---- high-trend ---------------------------------------------------------

ohio_soils_high %>%
  select(-avg_cauv, -num_soils) %>%
  gather(var, val, -year) %>%
  mutate(var = factor(var,
                      levels =  c("indx_100", "indx_99", "indx_89", "indx_79",
                                  "indx_69", "indx_59", "indx_49"),
                      labels = c("100", "90 to 99", "80 to 89", "70 to 79",
                                 "60 to 69", "50 to 59", "0 to 49"))) %>% 
  {
    ggplot(.,aes(year, val)) +
      geom_line(aes(color = var)) +
      geom_point(aes(color = var)) +
      geom_text_repel(data = filter(., year == 2019),
                      aes(color = var,
                          label = dollars(val)),
                      nudge_x = 1.75, show.legend = FALSE,
                      segment.alpha = 0.5) +
      geom_line(data = ohio_soils_high, aes(year, avg_cauv), size = 2) +
      geom_text_repel(data = filter(ohio_soils_high, year == 2019),
                      aes(year, avg_cauv,
                          label = dollars(avg_cauv)),
                      nudge_x = 1.75, nudge_y = -50,
                      show.legend = FALSE, segment.alpha = 0.5) +
      geom_vline(xintercept = 2018) +
      scale_x_continuous(breaks = c(1990, 2000, 2010, 2018),
                         limits = c(1991, 2020)) +
      scale_y_continuous(labels = dollar) +
      scale_color_viridis(option = "C", direction = -1,
                          end = 0.9, discrete = T) +
      labs(x = "", y = "", color = "Soil Productivity Index",
           title = "2019 High Projection for CAUV Values of Cropland",
           subtitle = "in dollars per acre, average value in black",
           caption = caption_proj) +
      theme_bw() +
      theme(legend.position = c(0.2, 0.7),
            legend.background = element_blank())
  }
ggsave(filename = paste0(figures, "/cauv_high_projections_2019.png"),
       width = 7, height = 5.25)

# ---- low-trend ----------------------------------------------------------

ohio_soils_low %>%
  select(-avg_cauv, -num_soils) %>%
  gather(var, val, -year) %>%
  mutate(var = factor(var,
                      levels =  c("indx_100", "indx_99", "indx_89", "indx_79",
                                  "indx_69", "indx_59", "indx_49"),
                      labels = c("100", "90 to 99", "80 to 89", "70 to 79",
                                 "60 to 69", "50 to 59", "0 to 49"))) %>% 
  {
    ggplot(.,aes(year, val)) +
      geom_line(aes(color = var)) +
      geom_point(aes(color = var)) +
      geom_text_repel(data = filter(., year == 2019),
                      aes(color = var,
                          label = dollars(val)),
                      nudge_x = 1.75, show.legend = FALSE,
                      segment.alpha = 0.5)+
      geom_line(data = ohio_soils_low, aes(year, avg_cauv), size = 2) +
      geom_text_repel(data = filter(ohio_soils_low, year == 2019),
                      aes(year, avg_cauv + 50,
                          label = dollars(avg_cauv)),
                      nudge_x = 1.75, nudge_y = 150,
                      show.legend = FALSE, segment.alpha = 0.5) +
      geom_vline(xintercept = 2018) +
      scale_x_continuous(breaks = c(1990, 2000, 2010, 2018),
                         limits = c(1991, 2020)) +
      scale_y_continuous(labels = dollar) +
      scale_color_viridis(option = "C", direction = -1,
                          end = 0.9, discrete = T) +
      labs(x = "", y = "", color = "Soil Productivity Index",
           title = "2019 Low Projection for CAUV Values of Cropland",
           subtitle = "in dollars per acre, average value in black",
           caption = caption_proj) +
      theme_bw() +
      theme(legend.position = c(0.2, 0.7),
            legend.background = element_blank())
  }
ggsave(filename = paste0(figures, "/cauv_low_projections_2019.png"),
       width = 7, height = 5.25)

# ---- low-2019 -----------------------------------------------------------

ohio_low %>% 
  group_by(indx) %>% 
  summarise(eventual = mean(unadjusted),
            adjustment = mean(cauv_projected_low) - eventual) %>% 
  gather(var, val, -indx) %>% 
  bind_rows(avg_low) %>% 
  mutate(indx = factor(indx,
                       levels =  c("indx_100", "indx_99", "indx_89", "indx_79",
                                   "indx_69", "indx_59", "indx_49", "all"),
                       labels = c("100", "90 to 99", "80 to 89",
                                  "70 to 79", "60 to 69", "50 to 59",
                                  "0 to 49", "All")),
         var = factor(var, levels = c("adjustment", "eventual"),
                      labels = c("Adjustment", "Eventual Value"))) %>% 
  ggplot(aes(indx, val, fill = var)) +
  geom_col() +
  scale_y_continuous(labels = dollar, limits = c(0, 4000)) +
  scale_fill_viridis(discrete = T, option = "C", direction = -1, end = 0.9) + 
  labs(x = "", y = "",
       title = "Phase-In for Low Projection of 2019 CAUV Values",
       subtitle = "by Productivity Indexes, phased-in value is full bar",
       caption = caption_proj,
       fill = "") +
  theme_bw() +
  theme(legend.position = c(0.85, 0.85), legend.background = element_blank())
ggsave(filename = paste0(figures, "/cauv_low_phase_in_2019.png"),
       width = 7, height = 5.25)

# ---- exp-trend ----------------------------------------------------------

ohio_soils_exp %>%
  select(-avg_cauv, -num_soils) %>%
  gather(var, val, -year) %>%
  mutate(var = factor(var,
                      levels =  c("indx_100", "indx_99", "indx_89", "indx_79",
                                  "indx_69", "indx_59", "indx_49"),
                      labels = c("100", "90 to 99", "80 to 89", "70 to 79",
                                 "60 to 69", "50 to 59", "0 to 49"))) %>% 
  {
    ggplot(.,aes(year, val)) +
      geom_line(aes(color = var)) +
      geom_point(aes(color = var)) +
      geom_text_repel(data = filter(., year == 2019),
                      aes(color = var,
                          label = dollars(val)),
                      nudge_x = 1.75, show.legend = FALSE,
                      segment.alpha = 0.5) +
      geom_line(data = ohio_soils_exp, aes(year, avg_cauv), size = 2) +
      geom_text_repel(data = filter(ohio_soils_exp, year == 2019),
                      aes(year, avg_cauv + 50,
                          label = dollars(avg_cauv)),
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
ggsave(filename = paste0(figures, "/cauv_expected_projections_2019.png"),
       width = 7, height = 5.25)

# ---- exp-2019 -----------------------------------------------------------

ohio_exp %>% 
  group_by(indx) %>% 
  summarise(eventual = mean(unadjusted),
            adjustment = mean(cauv_projected_exp) - eventual) %>% 
  gather(var, val, -indx) %>% 
  bind_rows(avg_exp) %>% 
  mutate(indx = factor(indx,
                       levels =  c("indx_100", "indx_99", "indx_89", "indx_79",
                                   "indx_69", "indx_59", "indx_49", "all"),
                       labels = c("100", "90 to 99", "80 to 89",
                                  "70 to 79", "60 to 69", "50 to 59",
                                  "0 to 49", "All")),
         var = factor(var, levels = c("adjustment", "eventual"),
                      labels = c("Adjustment", "Eventual Value"))) %>% 
  ggplot(aes(indx, val, fill = var)) +
  geom_col() +
  scale_y_continuous(labels = dollar, limits = c(0, 4000)) +
  scale_fill_viridis(discrete = T, option = "C", direction = -1, end = 0.9) + 
  labs(x = "", y = "",
       title = "Phase-In for Projection of 2019 CAUV Values",
       subtitle = "by Productivity Indexes, phased-in value is full bar",
       caption = caption_proj,
       fill = "") +
  theme_bw() +
  theme(legend.position = c(0.85, 0.85), legend.background = element_blank())
ggsave(filename = paste0(figures, "/cauv_expected_phase_in_2019.png"),
       width = 7, height = 5.25)
