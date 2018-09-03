# Ohio CAUV values:
# http://www.tax.ohio.gov/real_property/cauv.aspx

library("httr")
library("readxl")
library("rvest")
library("tidyverse")

# Create a directory for the data
local_dir    <- "0-data/soils"
data_source  <- paste0(local_dir, "/raw")
if (!file.exists(local_dir)) dir.create(local_dir)
if (!file.exists(data_source)) dir.create(data_source)

base_url <- "http://www.tax.ohio.gov/portals/0/"
cauv_files <- c("real_property/cauv_table_ty2009.xls",
                "real_property/cauv_table_ty2010.xls",
                "real_property/cauv_table_ty%202011.xls",
                "personal_property/2012%20CAUV%20table%20for%20ODT%20WEB.xls",
                "personal_property/2013_Table_for_ODT_Web.xlsx",
                paste0("personal_property/",
                       "Copy%20of%202014%20Table%20for%20ODT%20Web.xlsx"),
                "real_property/2015_Table_for_ODT_Web.xls",
                "real_property/CAUV2016Table.xlsx",
                "real_property/CAUV2017Table.xlsx",
                "real_property/CAUV2018Table.xlsx")

cauv_urls <- paste0(base_url, cauv_files)

cauv_files <- c("cauv_2009.xls", "cauv_2010.xls", "cauv_2011.xls",
                "cauv_2012.xls", "cauv_2013.xlsx", "cauv_2014.xlsx",
                "cauv_2015.xls", "cauv_2016.xlsx", "cauv_2017.xlsx",
                "cauv_2018.xlsx")

map2(cauv_urls, cauv_files, function(x, y) {
  file_name <- paste0(data_source, "/", y)
  if (!file.exists(file_name)) download.file(x, file_name)
})

cauv_files <- dir(data_source, full.names = T, pattern = "cauv")
cauv_files <- cauv_files[!grepl(".csv", cauv_files)]

# for (i in cauv_files) {
#   print(i)
#   temp <- read_excel(i, col_names = FALSE)
# }

j5 <- map(cauv_files, function(x) {
  temp <- tryCatch(read_excel(x, col_names = FALSE),
                   error = function(e){
                     gdata::read.xls(x)
                   })
  temp <- as.data.frame(temp)
  strt <- grep("SOIL SERIES", temp[,1]) - 1
  
  temp <- temp[-(1:strt),]
  temp <- temp[-1, !(is.na(temp[1,]))]
  
  if (ncol(temp) == 8) {
    names(temp) <- c("soil_series", "texture", "slope", "erosion",
                     "drainage", "prod_index", "cropland", "woodland")
  } else {
    names(temp) <- c("soil_series", "texture", "slope", "erosion",
                     "drainage", "cropland", "woodland")
  }
  temp$year <- substr(basename(x), 6, 9)
  temp[is.na(temp)] <- ""
  return(temp)
})

cauv <- j5 %>% 
  bind_rows() %>% 
  mutate_at(vars(prod_index, cropland, woodland, year), as.numeric)

# Need to add in corrections here for messed up soils.
x <- cauv$soil_series == "DRUMMER,GR-SUBST"
cauv$slope[x]       <- "0-2"

x <- cauv$soil_series == "LOBDELL-MLOAN,C,OF-PH"
cauv$soil_series[x] <- "LOBDELL-SLOAN,C,OF-PH"

x <- cauv$soil_series == "DUNBRIDGE-SPINKS,C,DEEP TO L"
cauv$texture[x]     <- "LFS"
cauv$soil_series[x] <- "DUNBRIDGE-SPINKS,C,DEEP TO LM"

x <- cauv$soil_series == "FRANKSTOWN,V-MERTZ,C,VERY ST"
cauv$texture[x]     <- ""
cauv$soil_series[x] <- "FRANKSTOWN,V-MERTZ,C,VERY STON"
x <- cauv$soil_series == "FRANKSTOWN,V-MERTZ,C,VERY STON"
cauv$soil_series[x] <- "FRANKSTOWN,V-MERTZ,C,VERY STONY"

x <- cauv$soil_series == "MONTGOMERY (MINSTER)"
cauv$soil_series[x] <- "MONTGOMERY"

x <- cauv$soil_series == "OLMSTED-VALLEY"
cauv$erosion[x] <- "S"
cauv$texture[x] <- "SOILS"

x <- cauv$soil_series == "ROCKMILL" | cauv$soil_series == "ROCKMILL,OF-PH"
cauv$texture[x]     <- "SICL"

x <- cauv$soil_series == "ROSSBURG,MOD.WET,S-SUBST,OF-"
cauv$texture[x]     <- "SIL"
cauv$soil_series[x] <- "ROSSBURG,MOD.WET,S-SUBST,OF-PH"

x <- cauv$soil_series == "SHOALS-SLOAN,C,MOD TO LM,FF-"
cauv$texture[x]     <- ""
cauv$soil_series[x] <- "SHOALS-SLOAN,C,MOD TO LM,FF-PH"

x <- cauv$soil_series == "TILSIT-COOLVILLE,AS,UNDULATI"
cauv$texture[x]     <- ""
cauv$soil_series[x] <- "TILSIT-COOLVILLE,AS,UNDULATING"

x <- cauv$soil_series == "GILPIN-COSHOCTON,C" & cauv$slope == "6-15"
cauv$prod_index[x] <- 60

x <- cauv$soil_series == "UPSHUR-BERKS,C" & cauv$slope == "6-15"
cauv$prod_index[x] <- 43

x <- cauv$soil_series == "WELLSTON-CRUZE,C"
cauv$prod_index[x] <- 67

x <- cauv$soil_series == "CARLISLE" & cauv$texture != "SICL"
cauv$prod_index[x] <- 86

x <- cauv$soil_series == "CARLISLE" & cauv$texture == "SICL"
cauv$prod_index[x] <- 84

x <- cauv$soil_series == "CARLISLE,DRAINED"
cauv$prod_index[x] <- 86

# Fill in the productivity index for these values
cauv <- cauv %>% 
  group_by(soil_series, texture, slope, erosion, drainage) %>% 
  arrange(year) %>% 
  fill(prod_index) %>% 
  mutate(indx = case_when(prod_index < 50  ~ "indx_49",
                          prod_index < 60  ~ "indx_59",
                          prod_index < 70  ~ "indx_69",
                          prod_index < 80  ~ "indx_79",
                          prod_index < 90  ~ "indx_89",
                          prod_index < 100 ~ "indx_99",
                          T ~ "indx_100")) %>% 
  ungroup()

cauv$indx <- factor(cauv$indx, c("indx_100", "indx_99", "indx_89", "indx_79",
                                 "indx_69", "indx_59", "indx_49"))

cauv <- mutate(cauv,
               id = paste0(soil_series, texture, slope, erosion, drainage))

write_csv(cauv, paste0(local_dir, "/cauv_soils.csv"))
write_rds(cauv, paste0(local_dir, "/cauv_soils.rds"))

# Now calculate the non-adjusted 2017 values

readjust <- function(x) ifelse((max(x) - min(x)) == 0, max(x),
                               min(x) - (max(x) - min(x)))

unadj2017 <- cauv %>% 
  filter(year %in% c(2016, 2017)) %>% 
  group_by(id, soil_series, texture, slope, erosion, drainage,
           prod_index, indx) %>% 
  summarise(cropland_unadj = readjust(cropland),
            woodland_unadj = readjust(woodland),
            year = 2017) %>% 
  ungroup()

# Then the 2018 ones

unadj2018 <- cauv %>% 
  filter(year %in% c(2017, 2018)) %>% 
  group_by(id, soil_series, texture, slope, erosion, drainage,
           prod_index, indx) %>% 
  summarise(cropland_unadj = readjust(cropland),
            woodland_unadj = readjust(woodland),
            year = 2018) %>% 
  ungroup()

unadj <- bind_rows(unadj2017, unadj2018)

write_csv(unadj2018, paste0(local_dir, "/cauv_unadj.csv"))
write_rds(unadj2018, paste0(local_dir, "/cauv_unadj.rds"))


# ---- pd32 ---------------------------------------------------------------

# http://www.tax.ohio.gov/portals/0/tax_analysis/tax_data_series/
#  tangible_personal_property/pd32/pd32cy85.xls
# http://www.tax.ohio.gov/portals/0/tax_analysis/tax_data_series/
#  tangible_personal_property/pd32/pd32cy86.xls
# http://www.tax.ohio.gov/Portals/0/tax_analysis/tax_data_series/
#  tangible_personal_property/pd32/PD32CY15.xls

tax_site <- paste0("http://www.tax.ohio.gov/tax_analysis/tax_data_series/",
                   "publications_tds_property.aspx")

tax_urls <- read_html(tax_site) %>% 
  html_nodes("ul:nth-child(17) li:nth-child(5) a") %>% 
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

tax_files <- dir(data_source, pattern = "pd32", full.names = T)

tax_files <- tax_files[!grepl(".pdf", tax_files)]

# cauv_vals <- map(tax_files, function(x){
#   j5 <- read_excel(x, col_names = F)
#   starts <- which(grepl("adams", tolower(j5$X__1)))
#   ends   <- which(grepl("wyandot", tolower(j5$X__1)))
#   j5 <- j5[starts:ends,]
#   j5 <- j5[, !(is.na(j5[1,]))]
#   return(j5)
# })

cauv_vals <- map(tax_files, function(x){
  j5 <- gdata::read.xls(x)
  
  # Remove the first column if it is the county number
  if (any(grepl("county number", tolower(j5[,1])))) j5 <- j5[,-1]
  
  starts <- which(grepl("adams", tolower(j5[,1])))
  ends   <- which(grepl("wyandot", tolower(j5[,1])))
  j5 <- j5[starts:ends,]
  j5 <- j5[, !(is.na(j5[1,]))]
  j5 <- j5[, !(j5[1,] == "")]
  names(j5) <- c("county", "parcels", "acres_cauv", "cauv", "market_value")
  j5$year <- as.numeric(substr(basename(x), 7, 8))
  
  # hack for creating a year variable
  j5$year <- ifelse(j5$year < 70, 2000 + j5$year, 1900 + j5$year)
  return(j5)
})

cauv_vals <- bind_rows(cauv_vals)

cauv_vals <- cauv_vals %>% 
  mutate(county = tolower(county),
         county = ifelse(county == "putnum", "putnam", county),
         parcels = as.numeric(gsub(",", "", parcels)),
         acres_cauv = as.numeric(gsub(",", "", acres_cauv)),
         cauv = gsub(",", "", cauv),
         cauv = gsub("\\$", "", cauv),
         cauv = as.numeric(cauv),
         market_value = gsub(",", "", market_value),
         market_value = gsub("\\$", "", market_value),
         market_value = as.numeric(market_value))

# # Add in temp blanks for next year:
# temp <- data.frame(county = unique(cauv_vals$county),
#                    year = max(cauv_vals$year) + 1)
# cauv_vals <- bind_rows(cauv_vals, temp)

# Reappraisals:
reap <- read_csv("0-data/soils/offline/tax_reappraisals.csv") %>% 
  gather(appraisal, year, -county)
j5 <- map(-1:5, function(x){
  temp <- reap
  temp$year <- reap$year - 6*x
  return(temp)
})
j5 <- bind_rows(j5)

cauv_vals <- cauv_vals %>% 
  left_join(j5) %>% 
  arrange(year)

write_csv(cauv_vals, paste0(local_dir, "/cauv_county.csv"))
write_rds(cauv_vals, paste0(local_dir, "/cauv_county.rds"))
