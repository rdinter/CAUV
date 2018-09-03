# Ohio Taxation statistics:
# http://www.tax.ohio.gov/tax_analysis/tax_data_series/
#  publications_tds_property.aspx

library("httr")
library("readxl")
library("rvest")
library("tidyverse")

# Create a directory for the data
local_dir    <- "0-data/odt"
data_source  <- paste0(local_dir, "/raw")
if (!file.exists(local_dir)) dir.create(local_dir)
if (!file.exists(data_source)) dir.create(data_source)

tax_site <- paste0("http://www.tax.ohio.gov/tax_analysis/tax_data_series/",
                   "publications_tds_property.aspx")


# ---- pd30 ---------------------------------------------------------------

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
  dfile <- paste0(data_source, "/", tolower(basename(dlinks)))
  purrr::map2(dfile, dlinks, function(x, y){
    if (!file.exists(x)) download.file(y, x)
  })
})

tax_files <- dir(data_source, pattern = "pd30", full.names = T)

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
                  funs(1000*as.numeric(gsub(",", "", gsub("\\$", "", .)))))
  j5$county <- tolower(j5$county)
  j5$county <- ifelse(j5$county == "putnum", "putnam", j5$county)
  j5$year <- as.numeric(substr(basename(x), 7, 8))
  # hack for creating a year variable
  j5$year <- ifelse(j5$year < 80, 2000 + j5$year, 1900 + j5$year)
  return(j5)
})

pd30_vals <- bind_rows(pd30_vals) %>% 
  mutate(county = ifelse(county == "guernesey", "guernsey", county))

pd30_vals <- arrange(pd30_vals, year, county)

write_csv(pd30_vals, paste0(local_dir, "/pd30.csv"))
write_rds(pd30_vals, paste0(local_dir, "/pd30.rds"))

# ---- pd31 ---------------------------------------------------------------

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
  dfile <- paste0(data_source, "/", tolower(basename(dlinks)))
  purrr::map2(dfile, dlinks, function(x, y){
    if (!file.exists(x)) download.file(y, x)
  })
})

tax_files <- dir(data_source, pattern = "pd31", full.names = T)

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
  j5 <- mutate_all(j5, funs(gsub("\\%", "", .)))
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
    mutate_all(funs(as.numeric(gsub(",", "", gsub("\\$", "", .))))) %>% 
    ungroup()
  j5$county <- tolower(j5$county)
  j5$county <- ifelse(j5$county == "putnum", "putnam", j5$county)
  j5$year <- as.numeric(substr(basename(x), 7, 8))
  # hack for creating a year variable
  j5$year <- ifelse(j5$year < 80, 2000 + j5$year, 1900 + j5$year)
  return(j5)
})


pd31_vals <- bind_rows(pd31_vals) %>% 
  mutate(county = ifelse(county == "guernesey", "guernsey", county))

pd31_vals <- arrange(pd31_vals, year, county)

write_csv(pd31_vals, paste0(local_dir, "/pd31.csv"))
write_rds(pd31_vals, paste0(local_dir, "/pd31.rds"))

# ---- pr6 ----------------------------------------------------------------

# pr6 tax rates by county
# http://www.tax.ohio.gov/tax_analysis/tax_data_series/
#  all_property_taxes/pr6/pr6cy88.aspx
# http://www.tax.ohio.gov/tax_analysis/tax_data_series/
#  all_property_taxes/pr6/pr6cy09.aspx

tax_urls <- read_html(tax_site) %>%
  html_nodes("ul:nth-child(11) li:nth-child(3) a") %>%
  html_attr("href") %>%
  paste0("http://www.tax.ohio.gov", .)

tax_urls <- read_html(tax_site) %>%
  html_nodes("ul:nth-child(19) li:nth-child(5) a") %>%
  html_attr("href") %>%
  paste0("http://www.tax.ohio.gov", .) %>%
  c(tax_urls, .)

# HACK\ for a screwup
tax_urls[28] <- paste0("http://www.tax.ohio.gov/tax_analysis/tax_data_series/",
                       "publications_tds_property/PR6CY15.aspx")

tax_download <- purrr::map(tax_urls, function(x){
  Sys.sleep(sample(seq(0,1,0.25), 1))
  dlinks <- read_html(x) %>%
    html_nodes("#dnn_ContentPane a") %>%
    html_attr("href") %>%
    na.omit() %>%
    paste0("http://www.tax.ohio.gov", .)
  dfile <- paste0(data_source, "/", tolower(basename(dlinks)))
  purrr::map2(dfile, dlinks, function(x, y){
    if (!file.exists(x)) download.file(y, x)
  })
})

tax_files <- dir(data_source, pattern = "pr6", full.names = T)

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
    mutate_all(funs(as.numeric(gsub(",", "", gsub("\\$", "", .))))) %>% 
    ungroup()
  j5$county <- tolower(j5$county)
  j5$county <- ifelse(j5$county == "putnum", "putnam", j5$county)
  j5$year <- as.numeric(substr(basename(x), 6, 7))
  # hack for creating a year variable
  j5$year <- ifelse(j5$year < 80, 2000 + j5$year, 1900 + j5$year)
  return(j5)
})

pr6_vals <- bind_rows(pr6_vals) %>% 
  mutate(county = ifelse(county == "guernesey", "guernsey", county))

pr6_vals <- arrange(pr6_vals, year, county)

write_csv(pr6_vals, paste0(local_dir, "/pr6.csv"))
write_rds(pr6_vals, paste0(local_dir, "/pr6.rds"))

# ---- td1 ----------------------------------------------------------------

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
  dfile <- paste0(data_source, "/", tolower(basename(dlinks)))
  purrr::map2(dfile, dlinks, function(x, y){
    if (!file.exists(x)) download.file(y, x)
  })
})

tax_files <- dir(data_source, pattern = "td1", full.names = T)

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
  j5 <- mutate_all(j5, funs(gsub("\\%", "", .)))
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
    mutate_all(funs(as.numeric(gsub(",", "", gsub("\\$", "", .))))) %>% 
    ungroup()
  j5$county <- tolower(j5$county)
  j5$county <- ifelse(j5$county == "putnum", "putnam", j5$county)
  j5$year <- as.numeric(substr(basename(x), 6, 7))
  # hack for creating a year variable
  j5$year <- ifelse(j5$year < 80, 2000 + j5$year, 1900 + j5$year)
  return(j5)
})

td1_vals <- bind_rows(td1_vals) %>% 
  mutate(county = ifelse(county == "guernesey", "guernsey", county))

td1_vals <- arrange(td1_vals, year, county)

write_csv(td1_vals, paste0(local_dir, "/td1.csv"))
write_rds(td1_vals, paste0(local_dir, "/td1.rds"))

