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

# ---- dte27 --------------------------------------------------------------

dte27 <- folder_create("/dte27", data_source)

# dte27: property tax rates
# Property Tax Rate Abstract by Taxing District 
# Aggregate Property Tax Rate Abstract 
# Millage Rates by School District
# Millage Rates by Joint Vocational School District
# http://www.tax.ohio.gov/tax_analysis/tax_data_series/
#  all_property_taxes/dte27/dte27cy87.aspx
# http://www.tax.ohio.gov/tax_analysis/tax_data_series/
#  publications_tds_property/dte27CY11.aspx

tax_urls <- read_html(tax_site) %>% 
  html_nodes("ul:nth-child(7) a") %>% 
  #html_nodes("ul:nth-child(7) li:nth-child(2) a") %>% 
  html_attr("href") %>% 
  paste0("http://www.tax.ohio.gov", .)


tax_download <- purrr::map(tax_urls, function(x){
  Sys.sleep(sample(seq(0,1,0.25), 1))
  dlinks <- read_html(x) %>% 
    html_nodes("#dnn_ContentPane a") %>% 
    html_attr("href") %>% 
    na.omit() %>% 
    paste0("http://www.tax.ohio.gov", .)
  # Hack, remove the email addresses
  dlinks <- dlinks[!grepl("mailto", dlinks)]
  
  dfile <- paste0(dte27, "/", tolower(basename(dlinks)))
  purrr::map2(dfile, dlinks, function(x, y){
    if (!file.exists(x)) download.file(y, x)
  })
})

######
# SD files - PROBLEM with the 2005 SD excel file... it don't work.
sd_files <- dir(dte27, pattern = "sd_rates", full.names = T)
sd_files <- sd_files[!grepl(".pdf", sd_files)]
sd_files <- sd_files[!grepl("2005", sd_files)]


dte27_sd_vals <- map(sd_files, function(x){
  print(x)
  j5 <- tryCatch(read_xls(x),
                 error = function(e) gdata::read.xls(e))
  starts2 <- apply(j5, 2, function(x) which(grepl("adams", tolower(x))))
  starts <- min(unlist(starts2))
  j5 <- tryCatch(read_xls(x, skip = starts, col_names = F),
                 error = function(e) gdata::read.xls(e, skip = starts,
                                                     header = F))
  # starts <- which(grepl("adams", tolower(j5[[1]])))
  # if (is_empty(starts))
  ends2 <- apply(j5, 2, function(x) which(grepl("wyandot", tolower(x))))
  ends  <- max(unlist(ends2))
  # ends   <- which(grepl("wyandot", tolower(j5[[1]])))
  
  
  # TIBBLE PROBLEMS?
  j5 <- j5[1:max(ends),]
  j5 <- j5[, colSums(is.na(j5)) < nrow(j5)]
  # j5 <- j5[, !(is.na(j5[1,]))]
  # j5 <- mutate_all(j5, funs(gsub("\\%", "", .)))
  # j5 <- j5[, !(j5[1,] == "")]
  
  if (ncol(j5) == 29) {
    names(j5) <- c("county", "school_district", "political_unit", "info_number",
                   "total_rate_gross", "total_rate_class1", "total_rate_class2",
                   "qualifying_nonbusiness_class1", "emergency_rate",
                   "sub_levy_rate", "current_expense_rate_gross",
                   "current_expense_rate_class1", "current_expense_rate_class2",
                   "bond_rate", "general_fund_millage", "recreation_rate_gross",
                   "recreation_rate_class1", "recreation_rate_class2",
                   "improvement_rate_gross", "improvement_rate_class1",
                   "improvement_rate_class2", "library_rate_gross",
                   "library_rate_class1", "library_rate_class2",
                   "safety_rate_gross", "safety_rate_class1",
                   "safety_rate_class2", "mill_floor_rate_class1",
                   "mill_floor_rate_class2")
  } else if (ncol(j5) == 27) {
    names(j5) <- c("political_unit", "county", "school_district", "total_rate_gross",
                   "total_rate_class1", "total_rate_class2",
                   "emergency_rate",
                   "current_expense_rate_gross", "current_expense_rate_class1",
                   "current_expense_rate_class2", "bond_rate",
                   "general_fund_millage", "recreation_rate_gross",
                   "recreation_rate_class1", "recreation_rate_class2",
                   "improvement_rate_gross", "improvement_rate_class1",
                   "improvement_rate_class2", "library_rate_millage",
                   "acquisition_rate", "sub_levy_rate",
                   "safety_rate_gross", "safety_rate_class1",
                   "safety_rate_class2", "mill_floor_rate_class1",
                   "mill_floor_rate_class2", "credit_qualify_rate_class1")
  } else if (ncol(j5) == 25) {
    names(j5) <- c("political_unit", "county", "school_district", "total_rate_gross",
                   "total_rate_class1", "total_rate_class2",
                   "mill_floor_rate_class1", "mill_floor_rate_class2",
                   "emergency_rate",
                   "current_expense_rate_gross", "current_expense_rate_class1",
                   "current_expense_rate_class2", "bond_rate",
                   "general_fund_millage", "recreation_rate_gross",
                   "recreation_rate_class1", "recreation_rate_class2",
                   "improvement_rate_gross", "improvement_rate_class1",
                   "improvement_rate_class2", "library_rate_gross",
                   "library_rate_class1", "library_rate_class2",
                   "acquisition_rate", "sub_levy_rate")
  } else if (ncol(j5) == 23) {
    names(j5) <- c("political_unit", "county", "school_district", "total_rate_gross",
                   "total_rate_class1", "total_rate_class2",
                   "mill_floor_rate_class1", "mill_floor_rate_class2",
                   "emergency_rate",
                   "current_expense_rate_gross", "current_expense_rate_class1",
                   "current_expense_rate_class2", "bond_rate",
                   "general_fund_millage", "recreation_rate_gross",
                   "recreation_rate_class1", "recreation_rate_class2",
                   "improvement_rate_gross", "improvement_rate_class1",
                   "improvement_rate_class2", "library_millage",
                   "acquisition_rate", "sub_levy_rate")
  } else if (ncol(j5) == 22) {
    names(j5) <- c("political_unit", "county", "school_district", "total_rate_gross",
                   "total_rate_class1", "total_rate_class2",
                   "mill_floor_rate_class1", "mill_floor_rate_class2",
                   "emergency_rate",
                   "current_expense_rate_gross", "current_expense_rate_class1",
                   "current_expense_rate_class2", "bond_rate",
                   "general_fund_millage", "recreation_rate_gross",
                   "recreation_rate_class1", "recreation_rate_class2",
                   "improvement_rate_gross", "improvement_rate_class1",
                   "improvement_rate_class2", "library_millage",
                   "acquisition_rate")
  } else if (ncol(j5) == 21) {
    names(j5) <- c("county", "school_district", "total_rate_gross",
                   "total_rate_class1", "total_rate_class2", "emergency_rate",
                   "current_expense_rate_gross", "current_expense_rate_class1",
                   "current_expense_rate_class2", "bond_rate",
                   "general_fund_millage", "recreation_rate_gross",
                   "recreation_rate_class1", "recreation_rate_class2",
                   "improvement_rate_gross", "improvement_rate_class1",
                   "improvement_rate_class2", "library_millage",
                   "library_rate_gross", "library_rate_class1",
                   "library_rate_class2")
  } else if (ncol(j5) == 20 & !is.numeric(unlist(j5[1,1]))) {
    names(j5) <- c("county", "sd_number", "school_district", "total_rate_gross",
                   "total_rate_class1", "total_rate_class2", "emergency_rate",
                   "current_expense_rate_gross", "current_expense_rate_class1",
                   "current_expense_rate_class2", "bond_rate",
                   "general_fund_millage", "recreation_rate_gross",
                   "recreation_rate_class1", "recreation_rate_class2",
                   "improvement_rate_gross", "improvement_rate_class1",
                   "improvement_rate_class2", "library_millage",
                   "acquisition_rate")
  } else if (ncol(j5) == 20 & is.numeric(unlist(j5[1,1]))) {
    names(j5) <- c("sd_number", "county", "school_district", "total_rate_gross",
                   "total_rate_class1", "total_rate_class2", "emergency_rate",
                   "current_expense_rate_gross", "current_expense_rate_class1",
                   "current_expense_rate_class2", "bond_rate",
                   "general_fund_millage", "recreation_rate_gross",
                   "recreation_rate_class1", "recreation_rate_class2",
                   "improvement_rate_gross", "improvement_rate_class1",
                   "improvement_rate_class2", "library_millage",
                   "acquisition_rate")
  } else if (ncol(j5) == 19) {
    names(j5) <- c("county", "sd_number", "school_district", "total_rate_gross",
                   "total_rate_class1", "total_rate_class2", "emergency_rate",
                   "current_expense_rate_gross", "current_expense_rate_class1",
                   "current_expense_rate_class2", "bond_rate",
                   "general_fund_millage", "recreation_rate_gross",
                   "recreation_rate_class1", "recreation_rate_class2",
                   "improvement_rate_gross", "improvement_rate_class1",
                   "improvement_rate_class2", "library_millage")
  }
  
  j5 <- j5 %>% 
    mutate_at(vars(-county, -school_district), parse_number) %>% 
    mutate(county = tolower(county),
           school_district = tolower(school_district),
           county = if_else(county == "putnum", "putnam", county),
           year = parse_number(basename(x))) %>% 
    mutate(year = case_when(year > 1900 ~ year,
                            year > 80 ~ 1900 + year,
                            year < 80 ~ 2000 + year))
  
  return(j5)
})

# 2003 to 2007 the sd_number is actually the political_unit
sd_vals <- dte27_sd_vals %>% 
  bind_rows() %>% 
  mutate(political_unit = if_else(year %in% 2003:2007, sd_number,
                                  political_unit),
         sd_number = if_else(year > 2002, NA_real_, sd_number),
         county = ifelse(county == "guernesey", "guernsey", county)) %>% 
  select(year, county, school_district, sd_number,
         political_unit, info_number, everything()) %>% 
  arrange(year, county)


write_csv(sd_vals, paste0(local_dir, "/dte27_sd.csv"))
write_rds(sd_vals, paste0(local_dir, "/dte27_sd.rds"))


######
# tdrate files - PROBLEM with the 2005 SD excel file... it don't work.
td_files <- dir(dte27, pattern = "tdrate", full.names = T)
td_files <- td_files[!grepl(".exe", td_files)]
td_files <- td_files[!grepl("zip", td_files)]

dte27_td_vals <- map(td_files, function(x){
  print(x)
  j5 <- tryCatch(read_xls(x),
                 error = function(e) gdata::read.xls(e))
  starts2 <- apply(j5, 2, function(x) which(grepl("county", tolower(x))))
  starts <- min(unlist(starts2))
  j5 <- tryCatch(read_xls(x, skip = starts + 1, col_names = F),
                 error = function(e) gdata::read.xls(e, skip = starts + 1,
                                                     header = F))
  ends2 <- apply(j5, 2, function(x) which(grepl("wyandot", tolower(x))))
  ends  <- max(unlist(ends2))
  
  # j5 <- j5[1:max(ends),]
  j5 <- j5[, colSums(is.na(j5)) < nrow(j5)]
  
  if (ncol(j5) == 12) {
    names(j5) <- c("county", "countno", "distno", "distname",
                   "gross", "class1_rate", "class2_rate", "tax50k", "tax75k",
                   "tax100k", "tax150k", "tax200k")
  } else if (ncol(j5) == 11) {
    names(j5) <- c("countno", "distno", "distname",
                   "gross", "class1_rate", "class2_rate", "tax50k", "tax75k",
                   "tax100k", "tax150k", "tax200k")
  }  else if (ncol(j5) == 7) {
    names(j5) <- c("countno", "distno", "distname", "gross",
                   "class1_rate", "class2_rate", "tax100k")
  }
  
  j5 <- j5 %>% 
    mutate(year = parse_number(basename(x))) %>% 
    mutate(year = case_when(year > 1900 ~ year,
                            year > 80 ~ 1900 + year,
                            year < 80 ~ 2000 + year))
  
  return(j5)
})
