# Providing a calculation/projection of the Capitalization Rate in Ohio

# Recommendation

# ---- start --------------------------------------------------------------

library("tidyverse")
library("zoo")

# Create a directory for the data
local_dir <- "2-calc"
cap       <- paste0(local_dir, "/cap")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(cap)) dir.create(cap, recursive = T)

j5 <- read_rds("1-tidy/cap/ohio_caprate.rds")

# Add on an additional year for Capitalization Rate:
cap_proj <- tibble(year = max(j5$year) + 1, mortgage_pct_odt = 0.8,
                   mortgage_years_odt = 25, sinking_years_odt = 25) %>% 
  bind_rows(j5) %>% 
  arrange(year)

# For a tax year, Ohio will use state-wide production for the previous 5 to 1
#  years of official USDA data. For example, the 2019 tax year will use
#  production from 2014 to 2018.

debt_service <- function(r, n) (r*(1 + r)^n) / ((1 + r)^n - 1)
sinking_fund <- function(r, n) (r) / ((1 + r)^n - 1)

# Slightly more complicated for percentage of mortgage remaining...
pmt <- function(r, n) r / (1 - 1 / (1 + r)^n)
rem <- function(r, n, pmt) pmt * (1 - 1 / (1 + r)^n) / r
mortgage_rem <- function(r, n, x) {
  1 - rem(r, n - x, pmt(r, n))
}
mortgage_alt <- function(r, n) {
  x = (1 - 1 / (1 + r)^n)
  y = (1 - 1 / (1 + r)^(n - 5))
  return((x - y) / x)
}
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


# ---- calc ---------------------------------------------------------------

ohio <- cap_proj %>%
  # Olympic average the interest rates
  mutate(tax_additur_cauv = tax_additur_odt,
         dallas_fed_re = rollapplyr(dallas_fed_re_q1,  width = 7, FUN =  mean,
                                    trim = 1/7, na.rm = T, fill = NA),
         kansas_fed_re = rollapplyr(kansas_fed_re_q1,  width = 7, FUN =  mean,
                                    trim = 1/7, na.rm = T, fill = NA),
         chicago_fed_re = rollapplyr(chicago_fed_re_q1,  width = 7, FUN =  mean,
                                     trim = 1/7, na.rm = T, fill = NA)) %>% 
  fill(tax_additur_cauv) %>% 
  mutate(equity_rate_cauv = ifelse(year > 2016,
                                   rollapplyr(lag(equity_rate_usda, 2),
                                              25, mean, na.rm = T, fill = NA),
                                   rollapplyr(equity_rate_bankrate, width = 7,
                                              FUN =  mean, trim = 1/7,
                                              na.rm = T, fill = NA)),
         interest_rate_cauv = ifelse(year > 2014,
                                     (rollapplyr(interest_rate_25_odt,
                                                 width = 7, FUN =  mean,
                                                 trim = 1/7, na.rm = T,
                                                 fill = NA)),
                                     (rollapplyr(interest_rate_15_odt,
                                                 width = 7, FUN =  mean,
                                                 trim = 1/7, na.rm = T,
                                                 fill = NA))),
         interest_rate_dallas = ifelse(year > 2014,
                                     (rollapplyr(dallas_fed_re,
                                                 width = 7, FUN =  mean,
                                                 trim = 1/7, na.rm = T,
                                                 fill = NA)),
                                     (rollapplyr(dallas_fed_re,
                                                 width = 7, FUN =  mean,
                                                 trim = 1/7, na.rm = T,
                                                 fill = NA))),
         interest_rate_kansas = ifelse(year > 2014,
                                     (rollapplyr(kansas_fed_re,
                                                 width = 7, FUN =  mean,
                                                 trim = 1/7, na.rm = T,
                                                 fill = NA)),
                                     (rollapplyr(kansas_fed_re,
                                                 width = 7, FUN =  mean,
                                                 trim = 1/7, na.rm = T,
                                                 fill = NA))),
         interest_rate_chicago = ifelse(year > 2014,
                                     (rollapplyr(chicago_fed_re,
                                                 width = 7, FUN =  mean,
                                                 trim = 1/7, na.rm = T,
                                                 fill = NA)),
                                     (rollapplyr(chicago_fed_re,
                                                 width = 7, FUN =  mean,
                                                 trim = 1/7, na.rm = T,
                                                 fill = NA))),
         
         mortgage_equity_cauv = debt_service(interest_rate_cauv,
                                             mortgage_years_odt),
         mortgage_equity_dallas = debt_service(interest_rate_dallas,
                                             mortgage_years_odt),
         mortgage_equity_kansas = debt_service(interest_rate_kansas,
                                             mortgage_years_odt),
         mortgage_equity_chicago = debt_service(interest_rate_chicago,
                                             mortgage_years_odt),
         
         cap_intermediate_cauv = (mortgage_pct_odt)*mortgage_equity_cauv +
           ((1 - mortgage_pct_odt))*equity_rate_cauv,
         cap_intermediate_dallas = (mortgage_pct_odt)*mortgage_equity_dallas +
           ((1 - mortgage_pct_odt))*equity_rate_cauv,
         cap_intermediate_kansas = (mortgage_pct_odt)*mortgage_equity_kansas +
           ((1 - mortgage_pct_odt))*equity_rate_cauv,
         cap_intermediate_chicago = (mortgage_pct_odt)*mortgage_equity_chicago +
           ((1 - mortgage_pct_odt))*equity_rate_cauv,
         
         
         cap_less_cauv = ifelse(year > 2016,
                                mortgage_pct_odt *
                                  sinking_fund(equity_rate_cauv,
                                               sinking_years_odt),
                                # Pre 2016 has a mortgage paid off adjustment
                                0.05*sinking_fund(equity_rate_cauv,
                                                  sinking_years_odt) +
                                  mortgage_pct_odt * 
                                  mortgage_rem(interest_rate_cauv,
                                               mortgage_years_odt,
                                               sinking_years_odt) *
                                  sinking_fund(equity_rate_cauv,
                                               sinking_years_odt)),
         cap_less_dallas = ifelse(year > 2016,
                                mortgage_pct_odt *
                                  sinking_fund(equity_rate_cauv,
                                               sinking_years_odt),
                                # Pre 2016 has a mortgage paid off adjustment
                                0.05*sinking_fund(equity_rate_cauv,
                                                  sinking_years_odt) +
                                  mortgage_pct_odt * 
                                  mortgage_rem(interest_rate_dallas,
                                               mortgage_years_odt,
                                               sinking_years_odt) *
                                  sinking_fund(equity_rate_cauv,
                                               sinking_years_odt)),
         cap_less_kansas = ifelse(year > 2016,
                                mortgage_pct_odt *
                                  sinking_fund(equity_rate_cauv,
                                               sinking_years_odt),
                                # Pre 2016 has a mortgage paid off adjustment
                                0.05*sinking_fund(equity_rate_cauv,
                                                  sinking_years_odt) +
                                  mortgage_pct_odt * 
                                  mortgage_rem(interest_rate_kansas,
                                               mortgage_years_odt,
                                               sinking_years_odt) *
                                  sinking_fund(equity_rate_cauv,
                                               sinking_years_odt)),
         cap_less_chicago = ifelse(year > 2016,
                                mortgage_pct_odt *
                                  sinking_fund(equity_rate_cauv,
                                               sinking_years_odt),
                                # Pre 2016 has a mortgage paid off adjustment
                                0.05*sinking_fund(equity_rate_cauv,
                                                  sinking_years_odt) +
                                  mortgage_pct_odt * 
                                  mortgage_rem(interest_rate_chicago,
                                               mortgage_years_odt,
                                               sinking_years_odt) *
                                  sinking_fund(equity_rate_cauv,
                                               sinking_years_odt)),
         
         cap_rate_cauv = cap_intermediate_cauv - cap_less_cauv +
           tax_additur_cauv,
         cap_rate_dallas = cap_intermediate_dallas - cap_less_dallas +
           tax_additur_cauv,
         cap_rate_kansas = cap_intermediate_kansas - cap_less_kansas +
           tax_additur_cauv,
         cap_rate_chicago = cap_intermediate_chicago - cap_less_chicago +
           tax_additur_cauv)

# HACK for cap rate
ohio$cap_rate_cauv_exp <- ohio$cap_rate_cauv



write.csv(ohio, paste0(cap, "/ohio_alternate_caprate.csv"),
          row.names = F)
write_rds(ohio, paste0(cap, "/ohio_alternate_caprate.rds"))

# ---- values -------------------------------------------------------------

ohio %>% 
  filter(year > 2008, !is.na(interest_rate_odt)) %>% 
  select(Year = year, "FCS (ODT)" = interest_rate_odt,
         Chicago = chicago_fed_re, "Kansas City" = kansas_fed_re,
         Dallas = dallas_fed_re) %>% 
  mutate_at(vars(-Year), ~scales::percent(., accuracy = 0.01)) %>% 
  knitr::kable()

ohio %>% 
  filter(year > 2009) %>% 
  select("Year" = year, "ODT Value" = cap_rate_odt,
         "Dallas" = cap_rate_dallas,
         "Kansas City" = cap_rate_kansas,
         "Chicago" = cap_rate_chicago) %>% 
  mutate_at(vars(-Year), ~scales::percent(., accuracy = 0.1)) %>% 
  knitr::kable()
