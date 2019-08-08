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

# ---- pd31 ---------------------------------------------------------------

pd31 <- folder_create("/pd31", data_source)

# pd31 taxable value by class of property and county
# http://www.tax.ohio.gov/tax_analysis/tax_data_series/
#  tangible_personal_property/pd31/pd31cy85.aspx

tax_urls <- read_html(tax_site) %>% 
  html_nodes("ul:nth-child(17) li:nth-child(4) a") %>% 
  html_attr("href") %>% 
  paste0("http://www.tax.ohio.gov", .)

tax_download <- purrr::map(tax_urls, function(x){
  Sys.sleep(sample(seq(0,1,0.25), 1))
  dlinks <- read_html(x) %>% 
    html_nodes("#dnn_ContentPane a") %>% 
    html_attr("href") %>% 
    na.omit() %>% 
    paste0("http://www.tax.ohio.gov", .)
  dfile <- paste0(pd31, "/", tolower(basename(dlinks)))
  purrr::map2(dfile, dlinks, function(x, y){
    if (!file.exists(x)) download.file(y, x)
  })
})

tax_files <- dir(pd31, pattern = "pd31", full.names = T)

tax_files <- tax_files[!grepl(".pdf", tax_files)]

pd31_vals <- map(tax_files, function(x){
  j5 <- gdata::read.xls(x)
  starts <- which(grepl("adams", tolower(j5[,1])))
  # Problem with a missing start value, hack
  if (length(starts) == 0) j5 <- j5[,-1]
  starts <- which(grepl("adams", tolower(j5[,1])))
  ends   <- which(grepl("wyandot", tolower(j5[,1])))
  
  j5 <- j5[starts:ends,]
  j5 <- j5[, colSums(is.na(j5)) < nrow(j5)]
  j5 <- j5[, !(is.na(j5[1,]))]
  j5 <- mutate_all(j5, list(~gsub("\\%", "", .)))
  j5 <- j5[, !(j5[1,] == "")]
  j5 <- j5[complete.cases(j5),]
  
  # | 1 to 17 are 17 | 18 to 23 are 7 | 24 is 12    |
  # | 25 to 29 are 17 | 30 is 24 | 31 and 32 are 17 |
  if (ncol(j5) > 12) j5 <- j5[,1:12]
  if (ncol(j5) == 12) j5 <- j5[,c(1,2,4,6,8,10,12)]
  names(j5) <- c("county", "residential_taxable_value",
                 "agricultural_taxable_value", "industrial_taxable_value",
                 "commercial_taxable_value", "mineral_taxable_value",
                 "total_taxable_value")
  j5 <- j5 %>% 
    group_by(county) %>% 
    mutate_at(vars(-group_cols()),
              list(~as.numeric(gsub(",", "", gsub("\\$", "", .))))) %>% 
    ungroup()
  j5$county <- tolower(j5$county)
  j5$county <- ifelse(j5$county == "putnum", "putnam", j5$county)
  j5$year <- as.numeric(substr(basename(x), 7, 8))
  # hack for creating a year variable, table comes out in 2018 calendar year
  #  but is for the 2017 tax year so subtract a year
  # j5$tax_year <- ifelse(j5$year < 70, 2000 + j5$year + 1, 1900 + j5$year + 1)
  j5$year     <- ifelse(j5$year < 70, 2000 + j5$year, 1900 + j5$year)
  
  return(j5)
})


pd31_vals <- bind_rows(pd31_vals) %>% 
  mutate(county = ifelse(county == "guernesey", "guernsey", county))

pd31_vals <- arrange(pd31_vals, year, county)

write_csv(pd31_vals, paste0(local_dir, "/pd31.csv"))
write_rds(pd31_vals, paste0(local_dir, "/pd31.rds"))
