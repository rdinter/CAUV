# Ohio Taxation statistics:
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

tax_site <- paste0("http://www.tax.ohio.gov/tax_analysis/tax_data_series/",
                   "publications_tds_property.aspx")

# ---- pd30 ---------------------------------------------------------------

pd30 <- folder_create("/pd30", data_source)

# pd30 assessed value and taxes levied
# http://www.tax.ohio.gov/tax_analysis/tax_data_series/
#  tangible_personal_property/pd30/pd30cy87.aspx
# http://www.tax.ohio.gov/tax_analysis/tax_data_series/
#  publications_tds_property/PD30CY11.aspx

tax_urls <- read_html(tax_site) %>% 
  html_nodes("ul:nth-child(11) li:nth-child(1) a") %>% 
  html_attr("href") %>% 
  paste0("http://www.tax.ohio.gov", .)

tax_urls <- read_html(tax_site) %>% 
  html_nodes("ul:nth-child(19) li:nth-child(3) a") %>% 
  html_attr("href") %>% 
  paste0("http://www.tax.ohio.gov", .) %>% 
  c(tax_urls, .)

tax_download <- purrr::map(tax_urls, function(x){
  Sys.sleep(sample(seq(0,1,0.25), 1))
  dlinks <- read_html(x) %>% 
    html_nodes("#dnn_ContentPane a") %>% 
    html_attr("href") %>% 
    na.omit() %>% 
    paste0("http://www.tax.ohio.gov", .)
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
  j5$year <- ifelse(j5$year < 80, 2000 + j5$year - 1, 1900 + j5$year - 1)
  
  return(j5)
})

pd30_vals <- bind_rows(pd30_vals) %>% 
  mutate(county = ifelse(county == "guernesey", "guernsey", county))

pd30_vals <- arrange(pd30_vals, year, county)

write_csv(pd30_vals, paste0(local_dir, "/pd30.csv"))
write_rds(pd30_vals, paste0(local_dir, "/pd30.rds"))
