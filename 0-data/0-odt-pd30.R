# Ohio Taxation statistics:
# New:
# https://bit.ly/2VnMQjQ
# https://tax.ohio.gov/wps/portal/gov/tax/researcher/tax-analysis/tax-data-series/property%2Btax%2B-%2Ball%2Bproperty%2Btaxes
#
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

# ---- pd30 ---------------------------------------------------------------

pd30 <- folder_create("/pd30", data_source)

# # pd30 assessed value and taxes levied
# # https://www.tax.ohio.gov/tax_analysis/tax_data_series/
# #  tangible_personal_property/pd30/pd30cy87.aspx
# 
# tax_urls <- paste0("https://www.tax.ohio.gov/tax_analysis/tax_data_series/",
#                    "tangible_personal_property/pd30/pd30cy",
#                    str_pad(c(87:99, 0:10), width = 2, side = "left", pad = "0"),
#                    ".aspx")

# http://www.tax.ohio.gov/tax_analysis/tax_data_series/
#  publications_tds_property/PD30CY11.aspx

tax_urls <- read_html(tax_site) %>% 
  html_nodes("ul+ ul li:nth-child(2) a") %>% 
  html_attr("href") %>% 
  paste0(tax_site, .)

tax_download <- purrr::map(tax_urls, function(x){
  Sys.sleep(sample(seq(0,1,0.25), 1))
  dlinks <- read_html(x) %>% 
    html_nodes("#js-odx-content__body a") %>% 
    html_attr("href") %>% 
    na.omit() %>% 
    paste0(tax_site, .)
  dfile <- paste0(pd30, "/", tolower(basename(dlinks)))
  purrr::map2(dfile, dlinks, function(x, y){
    if (!file.exists(x)) download.file(y, x)
  })
})

tax_files <- dir(pd30, pattern = "pd30", full.names = T)

tax_files <- tax_files[!grepl(".pdf", tax_files)]

pd30_vals <- map(tax_files, function(x){
  j5 <- gdata::read.xls(x)
  starts <- which(grepl("adams", tolower(j5[,1])))
  ends   <- which(grepl("wyandot", tolower(j5[,1])))
  j5 <- j5[starts:ends,]
  j5 <- j5[, colSums(is.na(j5)) < nrow(j5)]
  j5 <- j5[, !(is.na(j5[1,]))]
  j5 <- j5[, !(j5[1,] == "")]
  if (ncol(j5) == 10) {
    names(j5) <- c("county", "real_property_value",
                   "public_utility_property_value", "tangible_property_value",
                   "total_property_value", "real_property_tax",
                   "public_utility_property_tax", "tangible_property_tax",
                   "total_property_tax", "special_assessments")
  } else if (ncol(j5) == 14) {
    j5 <- j5[,1:10]
    names(j5) <- c("county", "real_property_value",
                   "public_utility_property_value", "tangible_property_value",
                   "total_property_value", "real_property_tax",
                   "public_utility_property_tax", "tangible_property_tax",
                   "total_property_tax", "special_assessments")
  } else {
    j5 <- j5[,1:8]
    names(j5) <- c("county", "real_property_value",
                   "public_utility_property_value", "total_property_value",
                   "real_property_tax", "public_utility_property_tax",
                   "total_property_tax", "special_assessments")
  }
  j5 <- mutate_at(j5, vars(real_property_value:special_assessments),
                  list(~1000*as.numeric(gsub(",", "", gsub("\\$", "", .)))))
  j5$county <- tolower(j5$county)
  j5$county <- ifelse(j5$county == "putnum", "putnam", j5$county)
  j5$year <- as.numeric(substr(basename(x), 7, 8))
  # hack for creating a year variable, table comes out in 2018 calendar year
  #  but is for the 2017 tax year so subtract a year
  # j5$tax_year <- ifelse(j5$year < 70, 2000 + j5$year + 1, 1900 + j5$year + 1)
  j5$year     <- ifelse(j5$year < 70, 2000 + j5$year, 1900 + j5$year)
  
  return(j5)
})

pd30_vals <- bind_rows(pd30_vals) %>% 
  mutate(county = ifelse(county == "guernesey", "guernsey", county)) %>% 
  # Problem between tax year 1995 and 2012 where values are off by $1,000
  mutate_at(vars(real_property_value:special_assessments),
            ~case_when(year > 1994 & year < 2013 ~ 1000*.,
                       T ~ .))

pd30_vals <- arrange(pd30_vals, year, county)

write_csv(pd30_vals, paste0(local_dir, "/pd30.csv"))
write_rds(pd30_vals, paste0(local_dir, "/pd30.rds"))