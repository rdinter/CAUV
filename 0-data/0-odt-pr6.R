# Ohio Taxation statistics:
# New:
# https://tax.ohio.gov/wps/portal/gov/tax/researcher/tax-analysis/tax-data-series/property%2Btax%2B-%2Ball%2Bproperty%2Btaxes
# https://tax.ohio.gov/wps/portal/gov/tax/researcher/tax-data-series/other-tax-statistics-archive/tds-archives-property

# Old:
# http://www.tax.ohio.gov/tax_analysis/tax_data_series/
#  publications_tds_property.aspx

# ---- start --------------------------------------------------------------

library("httr")
library("readxl")
library("rvest")
library("tidyverse")

folder_create <- function(x, y = "") {
  temp <- paste0(y, x)
  if (!file.exists(temp)) dir.create(temp, recursive = T)
  return(temp)
}

# Create a directory for the data
local_dir    <- folder_create("0-data/odt")
data_source  <- folder_create("/raw", local_dir)

tax_site <- paste0("https://tax.ohio.gov/wps/portal/gov/tax/researcher/",
                   "tax-analysis/tax-data-series/",
                   "property%2Btax%2B-%2Ball%2Bproperty%2Btaxes")
tax_site_archive <- paste0("https://tax.ohio.gov/wps/portal/gov/tax/",
                           "researcher/tax-data-series/",
                           "other-tax-statistics-archive/tds-archives-property")

# ---- pr6 ----------------------------------------------------------------

pr6 <- folder_create("/pr6", data_source)

# pr6 tax rates by county
# https://www.tax.ohio.gov/tax_analysis/tax_data_series/
#  all_property_taxes/pr6/pr6cy88.aspx
# 
# tax_urls <- read_html(tax_site_archive) %>%
#   html_nodes("strong+ ul li:nth-child(3) u") %>%
#   html_attr("href") %>%
#   paste0(tax_site_archive, .)

tax_urls <- paste0("https://tax.ohio.gov/wps/portal/gov/tax/researcher/",
                   "tax-analysis/tax-data-series/all-property-taxes/pr6/pr6cy",
                   str_pad(c(88:99, 0:10), width = 2, side = "left", pad = "0"))

# http://www.tax.ohio.gov/tax_analysis/tax_data_series/
#  all_property_taxes/pr6/pr6cy09.aspx

tax_urls <- read_html(tax_site) %>%
  html_nodes("#js-odx-content__body li:nth-child(4) a") %>%
  html_attr("href") %>%
  paste0(tax_site, .) %>%
  c(tax_urls, .)

# HACK\ for a screwup
# tax_urls <- str_remove(tax_urls, "/tax.ohio.gov/")

tax_download <- purrr::map(tax_urls, function(x){
  Sys.sleep(sample(seq(0,1,0.25), 1))
  dlinks <- read_html(x) %>%
    html_nodes("#js-odx-content__body a") %>% 
    html_attr("href") %>% 
    na.omit() %>% 
    paste0(tax_site, .)
  dfile <- paste0(pr6, "/", tolower(basename(dlinks)))
  purrr::map2(dfile, dlinks, function(x, y){
    if (!file.exists(x)) download.file(y, x)
  })
})

tax_files <- dir(pr6, pattern = "pr6", full.names = T)

tax_files <- tax_files[!grepl(".pdf", tax_files)]

pr6_vals <- map(tax_files, function(x){
  j5 <- gdata::read.xls(x)
  starts <- which(grepl("adams", tolower(j5[,1])))
  # Problem with a missing start value, hack
  if (length(starts) == 0) j5 <- j5[,-1]
  starts <- which(grepl("adams", tolower(j5[,1])))
  ends   <- which(grepl("wyandot", tolower(j5[,1])))
  
  j5 <- j5[starts:ends,]
  j5 <- j5[, colSums(is.na(j5)) < nrow(j5)]
  j5 <- j5[, !(is.na(j5[1,]))]
  j5 <- mutate_all(j5, funs(gsub("\\%", "", .)))
  j5 <- j5[, !(j5[1,] == "")]
  names(j5) <- c("county", "res_ag_gross_millage", "res_ag_net_millage",
                 "public_gross_millage", "public_net_millage",
                 "tangible_millage")
  j5 <- j5 %>% 
    group_by(county) %>% 
    mutate_at(vars(-group_cols()),
              list(~as.numeric(gsub(",", "", gsub("\\$", "", .))))) %>% 
    ungroup()
  j5$county <- tolower(j5$county)
  j5$county <- ifelse(j5$county == "putnum", "putnam", j5$county)
  j5$year <- as.numeric(substr(basename(x), 6, 7))
  # hack for creating a year variable, table comes out in 2018 calendar year
  #  but is for the 2017 tax year so subtract a year
  # j5$tax_year <- ifelse(j5$year < 70, 2000 + j5$year + 1, 1900 + j5$year + 1)
  j5$year     <- ifelse(j5$year < 70, 2000 + j5$year - 1, 1900 + j5$year - 1)
  
  return(j5)
})

pr6_vals <- bind_rows(pr6_vals) %>% 
  mutate(county = ifelse(county == "guernesey", "guernsey", county))

pr6_vals <- arrange(pr6_vals, year, county)

write_csv(pr6_vals, paste0(local_dir, "/pr6.csv"))
write_rds(pr6_vals, paste0(local_dir, "/pr6.rds"))