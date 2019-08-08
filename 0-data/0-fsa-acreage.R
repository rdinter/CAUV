# FSA Crop Acreage Data
# https://www.fsa.usda.gov/news-room/efoia/electronic-reading-room/
#  frequently-requested-information/crop-acreage-data/index

# ---- start --------------------------------------------------------------

library("httr")
library("stringr")
library("readxl")
library("rvest")
library("tidyverse")

local_dir   <- "0-data/fsa"
data_source <- paste0(local_dir, "/acreage/raw")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(data_source)) dir.create(data_source, recursive = T)

fsa_base <- paste0("https://www.fsa.usda.gov/news-room/efoia/",
                   "electronic-reading-room/frequently-requested-information/",
                   "crop-acreage-data/index")

j5 <- fsa_base %>% 
  read_html() %>% 
  html_nodes("#temp-region-9 li a") %>% 
  html_attr("href") %>% 
  paste0("https://www.fsa.usda.gov", .)

# ---- download -----------------------------------------------------------


map(j5, function(x){
  Sys.sleep(runif(1, 2, 3))
  file_x <- paste0(data_source, "/", basename(x))
  if (!file.exists(file_x)) download.file(x, file_x, method = "wget")
})


# ---- hack ---------------------------------------------------------------


# HACK
hack_base <- paste0("https://www.fsa.usda.gov/Assets/USDA-FSA-Public/",
                    "usdafiles/NewsRoom/eFOIA/crop-acre-data/zips/")

# 2007-crop-acre-data/2007_fsa_acres_sum_final.zip
# 2008-crop-acre-data/2008_fsa_acres_sum_final.zip
# 2009-crop-acre-data/2009_fsa_acres_detail_final_7.zip
# 2010-crop-acre-data/2010_fsa_acres_detail_final_5.zip
# 2011-crop-acre-data/2011_fsa_acres_detail_jan2012.zip
# 2012-crop-acre-data/2012_fsa_acres_jan_2013.zip
# 2013-crop-acre-data/2013_fsa_acres_jan_2014.zip
# 2014-crop-acre-data/2014_fsa_acres_Jan2014.zip
# 2015-crop-acre-data/2015_fsa_acres_Jan2016_sq19.zip
# 2017-crop-acre-data/2016_fsa_acres_jan2017_edr32.zip
# 2017-crop-acre-data/2017_fsa_acres_jan2018.zip

hack_links <- c("2009-crop-acre-data/2009_fsa_acres_detail_final_7.zip",
                "2010-crop-acre-data/2010_fsa_acres_detail_final_5.zip",
                "2011-crop-acre-data/2011_fsa_acres_detail_jan2012.zip",
                "2012-crop-acre-data/2012_fsa_acres_jan_2013.zip",
                "2013-crop-acre-data/2013_fsa_acres_jan_2014.zip",
                "2014-crop-acre-data/2014_fsa_acres_Jan2014.zip",
                "2015-crop-acre-data/2015_fsa_acres_Jan2016_sq19.zip",
                "2017-crop-acre-data/2016_fsa_acres_jan2017_edr32.zip",
                "2017-crop-acre-data/2017_fsa_acres_jan2018.zip")

hack_files <- tibble(path = paste0(data_source, "/", basename(hack_links)),
                     sheet = c("Sheet1", "Sheet1", "Sheet1", "county_data",
                               "county_data", "county_data", "county_data",
                               "county_data", "county_data"),
                     date = 2009:2017)

file_sheets <- dir(data_source, full.names = T, pattern = ".zip")
temp_dir <- tempdir()

# sheets <- map(file_sheets, function(x) {
#   temp_unz <- unzip(x, exdir = temp_dir)
#   
#   sheets <- excel_sheets(temp_unz)
#   unlink(temp_unz)
#   return(c(x, sheets))
# })


excels <- pmap(hack_files, function(path, sheet, date){
  temp_unz <- unzip(path, exdir = temp_dir)
  
  temp <- read_excel(temp_unz, sheet)
  
  temp <- temp %>% 
    rename_all(~str_replace_all(str_to_lower(.), "\\s", "_")) %>% 
    rename_all(~str_replace_all(., "plant_and_fail", "planted_and_failed"))
  
  if (date == 2010) {
    temp <- rename(temp, state_code = state)
  }
  
  if (date == 2011) {
    temp2 <- temp %>% 
      gather(var, val, contains("__")) %>% 
      separate(var, c("var", "irr"), "__") %>% 
      mutate(var = paste0(var, "_acres")) %>% 
      spread(var, val)
    
    temp <- temp2 %>% 
      mutate(irrigation_practice = case_when(irr == "irrigated" ~ "I",
                                             irr == "nonirrigated" ~ "N",
                                             irr == "total" ~ "T",
                                             T ~ "O")) %>% 
      select(-irr)
  }
  
  if (date == 2012) {
    temp <- rename(temp, failed_acres = failded_acres)
  }
  if (date == 2017) {
    temp <- filter(temp, !is.na(state_code))
  }
  
  
  temp$file = path
  temp$year = date
  
  unlink(temp_unz)
  return(temp)
})

excels_df <- bind_rows(excels)
glimpse(excels_df)

df <- excels_df %>% 
  mutate(crop = if_else(is.na(crop), crop_name, crop),
         crop_type_alt = str_remove_all(str_to_upper(crop_type), "[:punct:]"),
         crop_alt = str_remove_all(str_to_upper(crop), "[:punct:]"),
         irrigation_practice = if_else(is.na(irrigation_practice),
                                       "T", irrigation_practice),
         fips = 1000*parse_number(state_code) + parse_number(county_code)) %>% 
  mutate(crop = str_squish(crop_alt),
         crop_type = str_squish(crop_type_alt)) %>% 
  select(year, fips, state_code, county_code,
         crop_code, crop, crop_type,
         irrigation_practice, contains("acres"))

# Totals for the 2012+ irrigations status
df_all <- df %>%
  filter(year > 2011) %>%
  group_by(year, fips, state_code, county_code, crop_code, crop, crop_type) %>%
  summarise_at(vars(planted_acres, prevented_acres, failed_acres,
                    not_planted_acres, planted_and_failed_acres),
               function(x) sum(x, na.rm = T)) %>% 
  mutate(irrigation_practice = "T") %>% 
  bind_rows(df) %>% 
  arrange(year, fips, crop_code) %>% 
  ungroup()

df_all <- df_all %>% 
  mutate(crop = case_when(crop_code == "0019" ~ "KAMUT",
                          crop_code == "0097" ~
                            "CONSERVATION STEWARDSHIP PROGRAM",
                          crop_code == "0105" ~ "IDLE",
                          crop_code == "0127" ~ "GROUND CHERRY",
                          crop_code == "0131" ~ "SPELTZ",
                          crop_code == "0311" ~ "WILLOW SHRUB",
                          crop_code == "0380" ~ "PITAYA DRAGON FRUIT",
                          crop_code == "0381" ~ "PAWPAW",
                          crop_code == "0421" ~ "NONI",
                          crop_code == "0427" ~ "WOLFBERRY GOJI",
                          crop_code == "0772" ~ "HOME GARDEN",
                          crop_code == "0773" ~ "COMMERCIAL GARDEN",
                          crop_code == "2007" ~
                            "WILDLIFE HABITAT INCENTIVE PROGRAM",
                          T ~ crop)) %>% 
  # Remove the observation if it is just all 0s
  filter_at(vars(contains("acres")), any_vars(. != 0))

df_summary <- df_all %>% 
  group_by(year, fips, state_code, county_code,
           crop_code, crop, irrigation_practice) %>%
  summarise_at(vars(planted_acres, prevented_acres, failed_acres,
                    not_planted_acres, planted_and_failed_acres), sum) %>% 
  ungroup()

write_csv(df_summary, paste0(local_dir, "/acreage/fsa_acreage.csv"))
write_rds(df_summary, paste0(local_dir, "/acreage/fsa_acreage.rds"))