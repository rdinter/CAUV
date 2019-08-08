# Gathering tax related data

# ---- start --------------------------------------------------------------

library("tidyverse")

# Create a directory for the data
local_dir <- "1-tidy"
taxes     <- paste0(local_dir, "/taxes")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(taxes)) dir.create(taxes, recursive = T)

odt <- dir(path = "0-data/odt", pattern = "*.rds", full.names = T)

j5 <- odt %>% 
  map(read_rds) %>% 
  Reduce(function(x, y) full_join(x, y), .) %>% 
  filter(!is.na(county)) %>% 
  rename(cauv_taxable = cauv, market_value_taxable = market_value) %>% 
  select(year, county, everything()) %>%
  arrange(year, county)

glimpse(j5)

# For the missing years at the beginning, I'm going to impute the millage rate
#  from the most recent value. Since millage rates tend to increase over time
#  this will result in a higher tax paid than what was likely paid.

j5_filled <- j5 %>% 
  group_by(county) %>% 
  fill(contains("millage"), .direction = "up") %>% 
  # fill(-one_of("appraisal"), .direction = "down") %>% 
  mutate(update_year = max(year[!is.na(appraisal)]))

# ---- noncauv ------------------------------------------------------------

j5_taxes <- 
  j5_filled %>% 
  mutate(noncauv_taxable = agricultural_taxable_value - cauv_taxable,
         cauv_tax = (res_ag_net_millage/1000)*cauv_taxable,
         cauv_tax_acre = cauv_tax / acres_cauv,
         noncauv_tax = (res_ag_net_millage/1000)*noncauv_taxable,
         noncauv_tax_acre = noncauv_tax / acres_cauv)

j5_taxes %>% 
  select(year, appraisal, county, contains("cauv")) %>%
  View

# Save the county taxes
write_csv(j5_taxes, paste0(taxes, "/county_taxes.csv"))

# ---- graphs -------------------------------------------------------------

j5_taxes %>% 
  group_by(year, update_year) %>% 
  summarise(cauv_tax_total = sum(cauv_tax),
            cauv_tax_acre = sum(cauv_tax) / sum(acres_cauv),
            noncauv_tax_total = sum(noncauv_tax),
            noncauv_tax_acre = sum(noncauv_tax) / sum(acres_cauv)) %>%
  select(year, update_year, cauv_tax_acre, noncauv_tax_acre) %>% 
  gather(var, val, -year, -update_year) %>% 
  ggplot(aes(year, val, color = as.factor(update_year),
             group = as.factor(update_year))) +
  geom_line() +
  facet_wrap(~var) +
  theme_minimal() + 
  labs(color = "Update Year:", x = "", y = "") +
  theme(legend.position = "bottom")

j5_taxes %>% 
  group_by(year, update_year) %>% 
  summarise(cauv_tax_total = sum(cauv_tax),
            cauv_tax_acre = sum(cauv_tax) / sum(acres_cauv),
            noncauv_tax_total = sum(noncauv_tax),
            noncauv_tax_acre = sum(noncauv_tax) / sum(acres_cauv)) %>%
  ungroup() %>%
  arrange(update_year) %>%
  mutate(pct_cauv = (cauv_tax_acre - lag(cauv_tax_acre)) / lag(cauv_tax_acre),
         pct_noncauv = (noncauv_tax_acre - lag(noncauv_tax_acre)) /
           lag(noncauv_tax_acre)) %>%
  View

j5_taxes %>% 
  group_by(year, update_year) %>% 
  summarise(cauv_taxable_total = sum(cauv_taxable),
            cauv_taxable_acre = sum(cauv_taxable) / sum(acres_cauv),
            noncauv_taxable_total = sum(noncauv_taxable),
            noncauv_taxable_acre = sum(noncauv_taxable) / sum(acres_cauv)) %>%
  select(year, update_year, cauv_taxable_acre, noncauv_taxable_acre) %>% 
  gather(var, val, -year, -update_year) %>% 
  ggplot(aes(year, val, color = as.factor(update_year),
             group = as.factor(update_year))) +
  geom_line() +
  facet_wrap(~var) +
  theme_minimal() + 
  labs(color = "Update Year:", x = "", y = "") +
  theme(legend.position = "bottom")




j5_filled %>% 
  group_by(year) %>% 
  summarise(cauv_tax_per_acre = sum(cauv_taxable*(res_ag_net_millage/1000))/sum(acres_cauv)) %>%
  write_csv("ohio_property_tax.csv")

j5_filled %>% 
  group_by(update_year, year) %>% 
  summarise(cauv_tax_per_acre = sum(cauv_taxable*(res_ag_net_millage/1000))/sum(acres_cauv)) %>% 
  spread(update_year, cauv_tax_per_acre) %>% 
  write_csv("reassessment_cycle_property_tax.csv")


j5_filled %>% 
  mutate(cauv_tax_per_acre = cauv_taxable*(res_ag_net_millage/1000)/acres_cauv) %>% 
  select(year, county, appraisal, cauv_tax_per_acre, cauv_taxable, acres_cauv, res_ag_net_millage) %>% 
  write_csv("ohio_county_property_tax.csv")
