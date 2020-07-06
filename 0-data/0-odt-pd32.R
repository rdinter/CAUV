# Ohio Taxation statistics:
# New:
# https://bit.ly/2BEyq8b
# https://tax.ohio.gov/wps/portal/gov/tax/researcher/tax-analysis/
#  tax-data-series/property%2Btax%2B-%2Breal%2Bestate%2Band%2Bpublic%2Butility

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
                   "tax-analysis/tax-data-series/property%2Btax%2B-",
                   "%2Breal%2Bestate%2Band%2Bpublic%2Butility")

# ---- pd32 ---------------------------------------------------------------

pd32 <- folder_create("/pd32", data_source)


# http://www.tax.ohio.gov/portals/0/tax_analysis/tax_data_series/
#  tangible_personal_property/pd32/pd32cy85.xls
# http://www.tax.ohio.gov/portals/0/tax_analysis/tax_data_series/
#  tangible_personal_property/pd32/pd32cy86.xls
# http://www.tax.ohio.gov/Portals/0/tax_analysis/tax_data_series/
#  tangible_personal_property/pd32/PD32CY15.xls

tax_urls <- read_html(tax_site) %>% 
  html_nodes("#js-odx-content__body li:nth-child(5) a") %>% 
  html_attr("href") %>% 
  paste0(tax_site, .)

tax_download <- purrr::map(tax_urls, function(x){
  Sys.sleep(sample(seq(0,1,0.25), 1))
  dlinks <- read_html(x) %>% 
    html_nodes("#js-odx-content__body a") %>% 
    html_attr("href") %>% 
    na.omit() %>% 
    paste0(tax_site, .)
  dfile <- paste0(pd32, "/", tolower(basename(dlinks)))
  purrr::map2(dfile, dlinks, function(x, y){
    if (!file.exists(x)) download.file(y, x)
  })
})


tax_files <- dir(pd32, pattern = "pd32", full.names = T)

tax_files <- tax_files[!grepl(".pdf", tax_files)]

# cauv_vals <- map(tax_files, function(x){
#   j5 <- read_excel(x, col_names = F)
#   starts <- which(grepl("adams", tolower(j5$X__1)))
#   ends   <- which(grepl("wyandot", tolower(j5$X__1)))
#   j5 <- j5[starts:ends,]
#   j5 <- j5[, !(is.na(j5[1,]))]
#   return(j5)
# })

cauv_vals_map <- map(tax_files, function(x){
  print(x)
  j5 <- gdata::read.xls(x)
  
  # Remove the first column if it is the county number
  if (any(grepl("county number", tolower(j5[,1])))) j5 <- j5[,-1]
  # Remove if there are more than 1 row with numbers in them
  if (sum(grepl("[[:digit:]]", tolower(j5[,1]))) > 10) j5 <- j5[,-1]
  
  starts <- which(grepl("adams", tolower(j5[,1])))
  ends   <- which(grepl("wyandot", tolower(j5[,1])))
  j5 <- j5[starts:ends,]
  j5 <- j5[, !(is.na(j5[1,]))]
  j5 <- j5[, !(j5[1,] == "")]
  names(j5) <- c("county", "parcels", "acres_cauv", "cauv", "market_value")
  j5$year <- as.numeric(substr(basename(x), 7, 8))
  
  # hack for creating a year variable
  # j5$tax_year <- ifelse(j5$year < 70, 2000 + j5$year + 1, 1900 + j5$year + 1)
  j5$year     <- ifelse(j5$year < 70, 2000 + j5$year, 1900 + j5$year)
  
  return(j5)
})

cauv_vals <- bind_rows(cauv_vals_map) %>% 
  mutate(county = tolower(county),
         county = ifelse(county == "putnum", "putnam", county),
         parcels = as.numeric(gsub(",", "", parcels)),
         acres_cauv = as.numeric(gsub(",", "", acres_cauv)),
         cauv = gsub(",", "", cauv),
         cauv = gsub("\\$", "", cauv),
         cauv = as.numeric(cauv),
         market_value = gsub(",", "", market_value),
         market_value = gsub("\\$", "", market_value),
         market_value = as.numeric(market_value)) %>% 
  arrange(year, county)

# 2019 Hack: 
hack_2019 <- "https://tax.ohio.gov/Portals/0/real_property/cauv19-allco.xlsx"
hack_file <- paste0(pd32, "/", basename(hack_2019))
if (!file.exists(hack_file)) download.file(hack_2019, hack_file)

hack <- read_excel(hack_file)
hack_vals <- hack %>% 
  rename_all(~str_remove_all(., "[[:punct:]]")) %>% 
  filter(!is.na(CNTY)) %>% 
  group_by(`COUNTY NAME`) %>% 
  summarise(parcels = sum(PARCELS, na.rm = T),
            acres_cauv = sum(ACRES, na.rm = T),
            cauv = sum(`CAUV TAXVAL`, na.rm = T),
            market_value = sum(`MARKET TAXVAL`, na.rm = T)) %>% 
  mutate(county = str_to_lower(`COUNTY NAME`), year = 2019) %>% 
  ungroup() %>% 
  select(-`COUNTY NAME`)

# Reappraisals:
reap <- read_csv("0-data/odt/tax_reappraisals.csv") %>% 
  gather(appraisal, year, -county)
j5 <- map(-1:5, function(x){
  temp <- reap
  temp$year <- reap$year - 6*x
  return(temp)
})
j5 <- bind_rows(j5)

cauv_vals <- cauv_vals %>% 
  bind_rows(hack_vals) %>% 
  left_join(j5) %>% 
  arrange(year)

write_csv(cauv_vals, paste0(local_dir, "/pd32.csv"))
write_rds(cauv_vals, paste0(local_dir, "/pd32.rds"))