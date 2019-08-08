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

# ---- td1 ----------------------------------------------------------------

td1 <- folder_create("/td1", data_source)

# td1 delinquent property taxes by county
# http://www.tax.ohio.gov/tax_analysis/tax_data_series/
#  all_property_taxes/td1/td1cy87.aspx
# http://www.tax.ohio.gov/tax_analysis/tax_data_series/
#  publications_tds_property/TD1CY11.aspx

tax_urls <- read_html(tax_site) %>% 
  html_nodes("ul:nth-child(11) li:nth-child(4) a") %>% 
  html_attr("href") %>% 
  paste0("http://www.tax.ohio.gov", .)

tax_urls <- read_html(tax_site) %>% 
  html_nodes("ul:nth-child(19) li:nth-child(6) a") %>% 
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
  dfile <- paste0(td1, "/", tolower(basename(dlinks)))
  purrr::map2(dfile, dlinks, function(x, y){
    if (!file.exists(x)) download.file(y, x)
  })
})

tax_files <- dir(td1, pattern = "td1", full.names = T)

tax_files <- tax_files[!grepl(".pdf", tax_files)]

# need to double check the varaibles across years and the names but seems
# to be OK

td1_vals <- map(tax_files, function(x){
  j5 <- gdata::read.xls(x)
  starts <- which(grepl("adams", tolower(j5[,1])))
  ends   <- which(grepl("wyandot", tolower(j5[,1])))
  j5 <- j5[starts:ends,]
  j5 <- j5[, colSums(is.na(j5)) < nrow(j5)]
  j5 <- j5[, !(is.na(j5[1,]))]
  j5 <- mutate_all(j5, list(~gsub("\\%", "", .)))
  j5 <- j5[, !(j5[1,] == "")]
  
  if (ncol(j5) == 5) {
    names(j5) <- c("county", "tangible_property_delinquent",
                   "real_property_delinquent",
                   "special_delinquent", "total_delinquent")
  } else if (ncol(j5) == 4) {
    names(j5) <- c("county", "real_property_delinquent",
                   "special_delinquent", "total_delinquent")
  }
  # else {
  #   names(j5) <- c("county", "residential_tax_value", "ag_tax_value",
  #                  "indstr_tax_value", "commercial_tax_value",
  #                  "mineral_tax_value","total_tax_value")
  # }
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

td1_vals <- bind_rows(td1_vals) %>% 
  mutate(county = ifelse(county == "guernesey", "guernsey", county))

td1_vals <- arrange(td1_vals, year, county)

write_csv(td1_vals, paste0(local_dir, "/td1.csv"))
write_rds(td1_vals, paste0(local_dir, "/td1.rds"))
