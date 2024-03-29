# Ohio CAUV values:
# http://www.tax.ohio.gov/real_property/cauv.aspx
# Need to manually update the links from above for the cauv_files object for
#  each new tax year. Values typically come out between July and August.

# ---- start --------------------------------------------------------------

library("httr")
library("readxl")
library("rvest")
library("tidyverse")

# Create a directory for the data
local_dir    <- "0-data/soils"
data_source  <- paste0(local_dir, "/raw")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(data_source)) dir.create(data_source, recursive = T)

dot_soils  <- read_csv("0-data/soils/offline/pi_dat_orig84.csv") |> 
  unite("id", soil_series, texture, slope, erosion, drainage,
        remove = F, sep = "", na.rm = T)

# ---- cauv-values --------------------------------------------------------

# Need to update the links, see top of file
base_url   <- "https://tax.ohio.gov/static/"
cauv_files <- c("real_property/cauv_table_ty2009.xls",
                "real_property/cauv_table_ty2010.xls",
                "real_property/cauv_table_ty%202011.xls",
                "personal_property/2012%20cauv%20table%20for%20odt%20web.xls",
                "personal_property/2013_table_for_odt_web.xlsx",
                paste0("personal_property/",
                       "copy%20of%202014%20table%20for%20odt%20web.xlsx"),
                "real_property/2015_table_for_odt_web.xls",
                "real_property/2016cauvtable.xlsx",
                "real_property/2017cauvtable.xlsx",
                "real_property/2018cauvtable.xlsx",
                "real_property/2019cauvtable.xlsx",
                "real_property/2020cauvtable.xlsx",
                "real_property/2021cauvtable2.xlsx",
                "real_property/2022cauvtable.xlsx",
                "real_property/2023cauvtable.xlsx")

cauv_urls <- paste0(base_url, cauv_files)

cauv_files <- c("cauv_2009.xls", "cauv_2010.xls", "cauv_2011.xls",
                "cauv_2012.xls", "cauv_2013.xlsx", "cauv_2014.xlsx",
                "cauv_2015.xls", "cauv_2016.xlsx", "cauv_2017.xlsx",
                "cauv_2018.xlsx", "cauv_2019.xlsx", "cauv_2020.xlsx",
                "cauv_2021.xlsx", "cauv_2022.xlsx", "cauv_2023.xlsx")
# Header to bypass tax.ohio forcing 403 errors
moz_head <- c("user-agent" =
                paste0("Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) ",
                       "Gecko/20100101 Firefox/73.0"))

map2(cauv_urls, cauv_files, function(x, y) {
  file_name <- paste0(data_source, "/", y)
  if (!file.exists(file_name)) download.file(x, file_name, mode = "wb",
                                             headers = moz_head)
})

# Get downloaded CAUV files
cauv_files <- dir(data_source, full.names = T, pattern = "cauv")
cauv_files <- cauv_files[!grepl(".csv", cauv_files)]


j5 <- map(cauv_files, function(x) {
  # Does the excel file have a newly named sheet? Find it
  find_sheet <- tryCatch(excel_sheets(x),
                         error = function(e){
                           NA
                         })
  find_sheet <- find_sheet[match("Soil Table", find_sheet)]
  # Data are usually the first sheet but if not the above should find it
  temp <- tryCatch(read_excel(x, col_names = FALSE, sheet = find_sheet),
                   error = function(e){
                     # This was previously read in with gdata:: but no longer
                     # maintained. The problem file is 2010, manually re-save
                     read_excel(x)
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

cauv_temp <- j5 |> 
  bind_rows() |> 
  mutate_at(vars(prod_index, cropland, woodland, year), parse_number)

# ---- historical ---------------------------------------------------------
# 
# cauv_2007 <- read_excel("0-data/soils/offline/odt_old/CAUV 2007 Final.xlsx",
#                         col_names = c("soil_series", "texture", "slope",
#                                       "erosion", "drainage",
#                                       "cropland", "woodland")) %>% 
#   mutate(year = 2007)
# cauv_2008 <- read_excel("0-data/soils/offline/odt_old/CAUV 2008 Final.xlsx",
#                         col_names = c("soil_series", "texture", "slope",
#                                       "erosion", "drainage",
#                                       "cropland", "woodland")) %>% 
#   mutate(year = 2008)
# 
# cauv_old <-
#   bind_rows(cauv_2007, cauv_2008) %>%
#   replace(., is.na(.), "")
# %>% 
#   left_join(select(dot_soils, "soil_series", "texture", "slope",
#                    "erosion", "drainage", "prod_index"))


# ---- soil-correction ----------------------------------------------------

# cauv <- bind_rows(cauv_old, cauv_temp)
cauv <- bind_rows(cauv_temp)

# Need to add in corrections here for messed up soils -- this is tedious!
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
cauv_all <- cauv |> 
  complete(nesting(soil_series, texture, slope, erosion, drainage),
           year = seq(min(year), max(year)))
  
cauv_index <- cauv_all |> 
  group_by(soil_series, texture, slope, erosion, drainage) |> 
  arrange(year) |> 
  fill(prod_index) |> 
  fill(prod_index, .direction = "up") |> 
  mutate(indx = case_when(prod_index < 50  ~ "indx_49",
                          prod_index < 60  ~ "indx_59",
                          prod_index < 70  ~ "indx_69",
                          prod_index < 80  ~ "indx_79",
                          prod_index < 90  ~ "indx_89",
                          prod_index < 100 ~ "indx_99",
                          prod_index == 100 ~ "indx_100",
                          T ~ NA_character_),
         indx = factor(indx, c("indx_100", "indx_99",
                               "indx_89", "indx_79",
                               "indx_69", "indx_59", "indx_49"))) |> 
  ungroup()|>
  unite("id", soil_series, texture, slope, erosion, drainage,
        sep = "", na.rm = T)

cauv_full <- cauv_index |> 
  rename(prod = prod_index) |> 
  left_join(dot_soils) |> 
  mutate(prod_index = ifelse(is.na(prod_index), prod, prod_index)) |> 
  select(-prod, soy_base = soybeans_base) |> 
  # A new productivity index based on only corn, soybeans, and wheat
  #  with a max of 15,024
  mutate(prod_index_new = round((56*corn_base + 60*soy_base + 60*wheat_base) /
                                  150),
         indx_new = case_when(prod_index_new < 50  ~ "indx_49",
                              prod_index_new < 60  ~ "indx_59",
                              prod_index_new < 70  ~ "indx_69",
                              prod_index_new < 80  ~ "indx_79",
                              prod_index_new < 90  ~ "indx_89",
                              prod_index_new < 100 ~ "indx_99",
                              prod_index_new == 100 ~ "indx_100",
                              T ~ NA_character_),
         indx_new = factor(indx_new, c("indx_100", "indx_99",
                                       "indx_89", "indx_79",
                                       "indx_69", "indx_59", "indx_49", NA)))

write_csv(cauv_full, paste0(local_dir, "/cauv_soils.csv"))
write_rds(cauv_full, paste0(local_dir, "/cauv_soils.rds"))

# Wide values for cropland CAUV

cauv_full |> 
  select(-woodland) |> 
  spread(year, cropland) |> 
  write_csv(paste0(local_dir, "/ohio_cauv_soils_wide.csv"))

# Now calculate the non-adjusted 2017 values

readjust <- function(x) ifelse((max(x) - min(x)) == 0, max(x),
                               round(min(x) - (max(x) - min(x)), -1))

unadj2017 <- cauv_full |> 
  filter(year %in% c(2016, 2017)) |> 
  group_by(id, soil_series, texture, slope, erosion, drainage,
           prod_index, indx) |> 
  summarise(cropland_unadj = readjust(cropland),
            woodland_unadj = readjust(woodland),
            year = 2017) |> 
  ungroup()

# Then the 2018 ones

unadj2018 <- cauv_full |> 
  filter(year %in% c(2017, 2018)) |> 
  group_by(id, soil_series, texture, slope, erosion, drainage,
           prod_index, indx) |> 
  summarise(cropland_unadj = readjust(cropland),
            woodland_unadj = readjust(woodland),
            year = 2018) |> 
  ungroup()

# And finally 2019 ones
unadj2019 <- cauv_full |> 
  filter(year %in% c(2018, 2019)) |> 
  group_by(id, soil_series, texture, slope, erosion, drainage,
           prod_index, indx) |> 
  summarise(cropland_unadj = readjust(cropland),
            woodland_unadj = readjust(woodland),
            year = 2019) |> 
  ungroup()

unadj <- bind_rows(unadj2017, unadj2018, unadj2019)

write_csv(unadj, paste0(local_dir, "/cauv_unadj.csv"))
write_rds(unadj, paste0(local_dir, "/cauv_unadj.rds"))
