# Farm Science Review Extras

# ---- start --------------------------------------------------------------

# devtools::install_github("dgrtwo/gganimate")
# library("gganimate")
# library(maps)
library("scales")
library("tidyverse")
library("viridis")
meann <- function(x) mean(x, na.rm = T)
sumn  <- function(x) sum(x, na.rm = T)
dollars <- function(x, dig = 0) dollar_format(largest_with_cents = dig)(x)

local_dir   <- "4-presentations"
figures     <- paste0(local_dir, "/figures")
if (!file.exists(local_dir)) dir.create(local_dir)
if (!file.exists(figures)) dir.create(figures)

crp     <- read_rds("0-data/fsa/crp/crp_payments.rds")
crp_exp <- read_rds("0-data/fsa/crp/crp_expiring.rds")

price_proj <- read_rds("2-calc/prices/ohio_forecast_prices.rds")

ohio <- read_rds("4-presentations/ohio_cauv.rds") %>% 
  group_by(county) %>% 
  mutate(cauv_all   = sumn(cauv) / sumn(acres_cauv),
         market_all = sumn(market_value) / sumn(acres_cauv))

deflator <- ohio %>% 
  ungroup() %>% 
  select(year, deflator) %>% 
  distinct()

ohio_vals <- read_rds("4-presentations/ohio_state_prices.rds") %>% 
  left_join(deflator)

ohio_vals$tax_cauv <- ifelse(ohio_vals$tax_cauv == 0, NA, ohio_vals$tax_cauv)

ohio_soils <- read_rds("0-data/soils/cauv_soils.rds") %>% 
  mutate(date = as.Date(paste0(year, "-01-01"))) %>% 
  left_join(deflator)

ohio_soils2 <- read_csv("0-data/soils/offline/cauv_index_avg.csv") %>% 
  left_join(deflator)

ohio_soils_exp <- read_rds("3-proj/future/ohio_soils_exp.rds")

unadj <- read_rds("0-data/soils/cauv_unadj.rds")

un2017 <- unadj %>% 
  group_by(year) %>% 
  summarise(cropland = meann(cropland_unadj))

prod_2017 <- unadj %>% 
  filter(year == 2017) %>% 
  mutate(indx = case_when(prod_index < 50  ~ "indx_49",
                          prod_index < 60  ~ "indx_59",
                          prod_index < 70  ~ "indx_69",
                          prod_index < 80  ~ "indx_79",
                          prod_index < 90  ~ "indx_89",
                          prod_index < 100 ~ "indx_99",
                          T ~ "indx_100")) %>% 
  group_by(indx) %>% 
  summarise(cropland = meann(cropland_unadj),
            year = "eventual value") %>% 
  spread(indx, cropland)

prod_2017$avg_cauv <- meann(unadj$cropland_unadj)

prod_2017 <- ohio_soils2 %>% 
  filter(year == 2017) %>% 
  mutate(year = "adjustment") %>% 
  bind_rows(prod_2017)

prod_2017[1,-1] <- prod_2017[1,-1] - prod_2017[2,-1]

ohio_map <- map_data("county", "Ohio") %>%
  rename(county = subregion) %>% 
  right_join(filter(ohio, !is.na(cauv)))

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

# ---- cash-rent-alt ------------------------------------------------------


ohio_vals %>% 
  filter(!is.na(rent_cropland)) %>% 
  select(year, deflator, `Cash Rental Rate` = rent_cropland,
         INDIANA, MICHIGAN, KENTUCKY,
         `Property Tax` = tax_cauv) %>% 
  gather(var, val, -year, -deflator) %>% 
  ggplot() +
  geom_line(aes(year, 111.484*val/deflator, color = var)) +
  geom_point(aes(year, 111.484*val/deflator, color = var)) +
  # geom_rect(data = cash_dates, aes(xmin = xmin, xmax = xmax,
  #                                  ymin = -Inf, ymax = Inf), alpha = 0.3) +
  # geom_text(data = data.frame(), aes(2011.5, 75,
  #                                    label = "Period of Interest")) +
  scale_y_continuous(labels = dollar, limits = c(0, NA)) +
  scale_color_viridis("", discrete = T, option = "C",
                      direction = -1, end = 0.7) +
  labs(x = "", y = "",
       title = "Cash Rent and CAUV Tax Trends in Ohio",
       subtitle = "in 2016 dollars per acre",
       caption = "Sources: USDA-NASS and Ohio Department of Taxation") +
  theme_bw() +
  theme(legend.background = element_blank(),
        legend.position = c(0.2, 0.85))


# ---- agland-70 ----------------------------------------------------------

ohio %>% 
  filter(year > 1970) %>% 
  group_by(year) %>% 
  summarise(`Ohio Assessed Market Value of Land` =
              sumn(111.484*market_value/deflator) / sumn(acres_cauv),
            `Ohio CAUV` = sumn(111.484*cauv/deflator) /
              sumn(acres_cauv),
            `NASS Ohio Average Land Value` = 
              meann(111.484*agland_ohio/deflator),
            `NASS National Average Land Value` =
              meann(111.484*agland_us/deflator)) %>% 
  gather(var, val, -year) %>% 
  mutate(var = factor(var,
                      levels = c("NASS Ohio Average Land Value",
                                 "Ohio Assessed Market Value of Land",
                                 "NASS National Average Land Value",
                                 "Ohio CAUV"))) %>% 
  filter(!is.na(val)) %>% 
  ggplot() +
  geom_line(aes(year, val, color = var)) +
  # geom_rect(data = cash_dates, aes(xmin = xmin, xmax = xmax,
  #                                  ymin = -Inf, ymax = Inf), alpha = 0.3) +
  # geom_text(data = data.frame(), aes(2011.5, 10,
  #                                    label = "Period of Interest")) +
  scale_y_continuous(labels = dollar, limits = c(0,6000)) +
  scale_color_viridis(option = "C", end = 0.9, discrete = T) +
  labs(x = "", y = "",
       title = "Agricultural Land Value Trends",
       subtitle = "in 2016 dollars per acre",
       color = "",
       caption = "Sources: USDA-NASS and Ohio Department of Taxation") +
  theme_bw() +
  theme(legend.position = c(0.25, 0.87),
        legend.background = element_blank())

# ---- table-assessed -----------------------------------------------------

ohio %>%
  filter(!is.na(cauv)) %>% 
  group_by(year) %>% 
  summarise(`Ohio Assessed Market Value of Land` =
              sumn(market_value) / sumn(acres_cauv),
            `Ohio CAUV` = sumn(cauv) /
              sumn(acres_cauv),
            `Ratio` = sumn(cauv) / sumn(market_value)) %>% 
  left_join(select(ohio_vals, year, `Property Tax` = tax_cauv)) %>% 
  mutate_at(vars("Ohio Assessed Market Value of Land",
                 "Ohio CAUV", "Property Tax"), funs(dollars(., 1e2))) %>% 
  knitr::kable()

# ---- map-update ---------------------------------------------------------

ohio_map %>% 
  filter(year == 2016) %>% 
  ggplot(aes(long, lat)) +
  geom_polygon(aes(group = group, fill = as.factor(update))) +
  geom_path(aes(group = group), size = 0.05) +
  geom_text(data = cnames, aes(label = county), size = 3, color = "black") +
  scale_fill_viridis(option = "C", discrete = T, begin = 0.35) +
  labs(fill = "", title = "Schedule for updating CAUV",
       caption = "Source: Ohio Department of Taxation") +
  ohio_theme + 
  theme(legend.position = c(0.15, 0.95), legend.direction = "horizontal")

# ---- cropland-trend -----------------------------------------------------

ohio_soils2 %>%
  select(-avg_cauv, -num_soils) %>%
  gather(var, val, -year, -deflator) %>%
  mutate(var = factor(var,
                      levels =  c("indx_100", "indx_99", "indx_89", "indx_79",
                                  "indx_69", "indx_59", "indx_49"),
                      labels = c("100", "90 to 99", "80 to 89", "70 to 79",
                                 "60 to 69", "50 to 59", "0 to 49"))) %>% 
  ggplot(aes(year, val)) +
  geom_line(aes(color = var)) +
  geom_point(aes(color = var)) +
  geom_line(data = ohio_soils2, aes(year, avg_cauv),
            size = 2) +
  scale_y_continuous(labels = dollar) +
  scale_color_viridis(option = "C", direction = -1,
                      end = 0.9, discrete = T) +
  labs(x = "", y = "", color = "",
       title = "CAUV for Cropland by Productivity Index",
       subtitle = "in 2016 dollars per acre, average value in black",
       caption = "Source: Ohio Department of Taxation") +
  theme_bw() +
  theme(legend.position = c(0.1, 0.75), legend.background = element_blank())

# ---- by-soil-types ------------------------------------------------------

ohio_soils_exp %>% 
  mutate(avg_change = percent(((avg_cauv - lag(avg_cauv)) /
                                  lag(avg_cauv)), 1e-2)) %>% 
  select(-num_soils) %>% 
  mutate_at(vars(-year, -avg_change), funs(dollars(., 1e2))) %>% 
  knitr::kable()

# ---- cash-rent-map ------------------------------------------------------

ohio_map %>% 
  filter(year > 2007, year != 2015, year < 2018) %>% 
  ggplot(aes(long, lat, group = group, fill = rent_nonirrigated)) +
  geom_polygon() +
  geom_path(size = 0.05) +
  scale_fill_gradient("", low = "white", high = "green", labels = dollar) +
  # scale_fill_viridis(option = "C", labels = dollar) +
  labs(title = "Cash Rent for Cropland",
       fill = "Dollars \nper acre",
       caption = "Source: USDA-NASS") +
  facet_wrap(~year) +
  ohio_theme


# ---- property-tax-map ---------------------------------------------------

ohio_map %>% 
  mutate(Update = ifelse(!is.na(appraisal), "Yes", "No")) %>% 
  filter(year > 2008) %>% 
  ggplot(aes(long, lat, group = group, fill = tax_cauv)) +
  geom_polygon() +
  geom_path(color = "black", size = 0.05) +
  geom_path(data = . %>% filter(Update == "Yes"),
            color = "black", size = 0.5) +
  scale_fill_gradient("", low = "white", high = "red", labels = dollar,
                      limits = c(0, 80), oob = squish) +
  # scale_fill_viridis(option = "C", labels = dollar,
  #                    limits = c(0, 80), oob = squish) +
  labs(title = "Average CAUV Tax Collected (bolded counties that update)",
       #subtitle = "Bolded outline represents reappraisal year for county",
       fill = "Dollars \nper Acre",
       caption = "Source: Ohio Department of Taxation") +
  facet_wrap(~year) +
  ohio_theme


# ---- odt-table ----------------------------------------------------------

ohio_vals %>% 
  filter(year > 2005, year < 2018) %>% 
  group_by(year) %>% 
  summarise(`Cap. Rate` = percent(cap_rate_odt),
            `Corn Yield` = corn_yield_odt,
            `Corn Price` = dollar(corn_price_odt),
            `Corn Cost` = dollar(corn_cost_odt),
            `Soy Yield` = soy_yield_odt,
            `Soy Price` = dollar(soy_price_odt),
            `Soy Cost` = dollar(soy_cost_odt),
            `Wheat Yield` = wheat_yield_odt,
            `Wheat Price` = dollar(wheat_price_odt),
            `Wheat Cost` = dollar(wheat_cost_odt)) %>% 
  rename(Year = year) %>% 
  knitr::kable()


# ---- prices -------------------------------------------------------------

price_proj %>% 
  filter(year > 2005) %>% 
  select(year, corn_price, corn_price_odt, corn_price_cauv_exp,
         soy_price, soy_price_odt, soy_price_cauv_exp,
         wheat_price, wheat_price_odt, wheat_price_cauv_exp) %>% 
  mutate_at(vars(-year), funs(dollars(., 1e2))) %>% 
  knitr::kable()


# ---- corn ---------------------------------------------------------------

price_proj %>% 
  filter(year > 2005) %>% 
  select("Year" = year, "ODT Price" = corn_price_odt,
         "USDA Price" = corn_price,
         "Low Projection" = corn_price_cauv_l,
         "Expected Projection" = corn_price_cauv_exp,
         "High Projection" = corn_price_cauv_h) %>% 
  knitr::kable()

# ---- soy ----------------------------------------------------------------

price_proj %>% 
  filter(year > 2005) %>% 
  select("Year" = year, "ODT Price" = soy_price_odt,
         "USDA Price" = soy_price,
         "Low Projection" = soy_price_cauv_l,
         "Expected Projection" = soy_price_cauv_exp,
         "High Projection" = soy_price_cauv_h) %>% 
  knitr::kable()


# ---- wheat --------------------------------------------------------------

price_proj %>% 
  filter(year > 2005) %>% 
  select("Year" = year, "ODT Price" = wheat_price_odt,
         "USDA Price" = wheat_price,
         "Low Projection" = wheat_price_cauv_l,
         "Expected Projection" = wheat_price_cauv_exp,
         "High Projection" = wheat_price_cauv_h) %>% 
  knitr::kable()

# ---- crp-history --------------------------------------------------------

ohio_crp <- crp %>%
  filter(STATE == "OHIO") %>%
  group_by(YEAR) %>%
  summarise(OHIO = sumn(ACRES_CRP))
crp %>% 
  group_by(YEAR) %>% 
  summarise(US = sumn(ACRES_CRP)) %>% 
  left_join(ohio_crp) %>% 
  mutate(fraction = percent(OHIO / US),
         OHIO = comma(OHIO),
         US = comma(US)) %>% 
  knitr::kable()

# ---- crp-expiring -------------------------------------------------------

crp_both <- crp %>% 
  full_join(crp_exp) %>% 
  arrange(FIPS, YEAR) %>% 
  filter(YEAR > 2016) %>% 
  group_by(FIPS) %>% 
  mutate(ACRES_EXPIRING = if_else(YEAR == 2017, ACRES_CRP,
                                  ACRES_CRP[YEAR == 2017] -
                                    lag(cumsum(replace_na(TOTAL_ACRES_CRP_EXP, 0)))))

crp_both <- crp_both %>% 
  full_join(crp) %>% 
  mutate(ACRES_EXPIRING = if_else(is.na(ACRES_EXPIRING),
                                  ACRES_CRP, ACRES_EXPIRING))

crp_both %>% 
  filter(STATE == "OHIO") %>% 
  group_by(YEAR) %>% 
  summarise(ACRES_EXPIRING = sumn(ACRES_EXPIRING)) %>% 
  ggplot(aes(YEAR, ACRES_EXPIRING)) +
  geom_line() +
  scale_y_continuous(labels = comma, limits = c(0, NA)) +
  labs(x = "", y = "",
       title = "CRP Acreage in Ohio",
       subtitle = "if no land is enrolled into the program") +
  theme_bw()
