# Conservation Reserve Program Data
# https://www.fsa.usda.gov/programs-and-services/conservation-programs/
#  reports-and-statistics/conservation-reserve-program-statistics/index
# http://bit.ly/2hcUTNG

library("readxl")
library("tidyverse")

local_dir   <- "0-data/fsa/crp"
data_source <- paste0(local_dir, "/raw")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(data_source)) dir.create(data_source, recursive = T)

# crp_url <- paste0("https://www.fsa.usda.gov/Assets/USDA-FSA-Public/",
#                   "usdafiles/Conservation/Excel/countypayments8616.xlsx")
crp_url <- paste0("https://www.fsa.usda.gov/Assets/USDA-FSA-Public/",
                  "usdafiles/Conservation/Excel/",
                  "CRP%20Rental%20Payment%20History%20By%20County1.xlsx")

crp_file <- paste0(data_source, "/", basename(crp_url))

if (!file.exists(crp_file)) download.file(crp_url, crp_file, method = "wget")

acres <- read_excel(crp_file, "ACRES", skip = 2) %>% 
  filter(!is.na(COUNTY))
rent  <- read_excel(crp_file, "RENT", skip = 2) %>% 
  filter(!is.na(COUNTY))

j5 <- acres %>% 
  gather(YEAR, ACRES_CRP, -STATE, -COUNTY, -FIPS) %>% 
  mutate(YEAR = as.numeric(YEAR))

j6 <- rent %>% 
  gather(YEAR, TOTAL_PAYMENTS_CRP, -STATE, -COUNTY, -FIPS) %>% 
  mutate(YEAR = as.numeric(YEAR) - 1)

crp <- j5 %>% 
  left_join(j6) %>% 
  mutate(RENT_CRP = TOTAL_PAYMENTS_CRP / ACRES_CRP)

write_csv(crp, paste0(local_dir, "/crp_payments.csv"))
write_rds(crp, paste0(local_dir, "/crp_payments.rds"))

# ---- expires ------------------------------------------------------------

exp_url <- paste0("https://www.fsa.usda.gov/Assets/USDA-FSA-Public/",
                  "usdafiles/Conservation/Excel/countyexpired1630.xls")

exp_file <- paste0(data_source, "/", basename(exp_url))

if (!file.exists(exp_file)) download.file(exp_url, exp_file, method = "wget")

general <- read_excel(exp_file, "General", skip = 2) %>% 
  filter(!is.na(COUNTY))
contin  <- read_excel(exp_file, "Contin", skip = 2) %>% 
  filter(!is.na(COUNTY))
total  <- read_excel(exp_file, "Total", skip = 2) %>% 
  filter(!is.na(COUNTY))

j5 <- general %>% 
  gather(YEAR, GENERAL_ACRES_CRP_EXP, -STATE, -COUNTY, -FIPS) %>% 
  mutate(YEAR = as.numeric(YEAR))

j6 <- contin %>% 
  gather(YEAR, CONTIN_ACRES_CRP_EXP, -STATE, -COUNTY, -FIPS) %>% 
  mutate(YEAR = as.numeric(YEAR) - 1)

j7 <- total %>% 
  gather(YEAR, TOTAL_ACRES_CRP_EXP, -STATE, -COUNTY, -FIPS) %>% 
  mutate(YEAR = as.numeric(YEAR) - 1)

exp_crp <- j5 %>% 
  left_join(j6) %>% 
  left_join(j7) 


write_csv(exp_crp, paste0(local_dir, "/crp_expiring.csv"))
write_rds(exp_crp, paste0(local_dir, "/crp_expiring.rds"))


# ---- practices ----------------------------------------------------------

prac_url <- paste0("https://www.fsa.usda.gov/Assets/USDA-FSA-Public/",
                  "usdafiles/Conservation/Excel/CRP_COUNTY_PRACTICE.xlsx")
prac_exp_url <- paste0("https://www.fsa.usda.gov/Assets/USDA-FSA-Public/",
                       "usdafiles/Conservation/Excel/",
                       "CRP_COUNTY_PRACTICE_EXPIRE_2017_2021.xlsx")

prac_file <- paste0(data_source, "/", basename(prac_url))
prac_exp_file <- paste0(data_source, "/", basename(prac_exp_url))

if (!file.exists(prac_file)) download.file(prac_url, prac_file,
                                           method = "wget")
if (!file.exists(prac_exp_file)) download.file(prac_exp_url, prac_exp_file,
                                           method = "wget")

prac <- read_excel(prac_file, skip = 3) %>% 
  filter(!is.na(COUNTY))

prac_names <- c("FIPS", "STATE", "COUNTY", "GRASS_PLANTINGS_INTRO",
                "GRASS_PLANTINGS_NATIVE", "TREE_PLANTINGS_SOFT",
                "TREE_PLANTINGS_LONG", "TREE_PLANTINGS_HARD",
                "WILDLIFE_HABITAT", "WILDLIFE_CORRIDORS",
                "FIELD_WINDBREAKS", "DIVERSIONS_EROSION_CONTROL_STRUC",
                "GRASS_WATERWAYS", "SHALLOW_WATER_FOR_WILDLIFE",
                "EXISTING_GRASS", "EXISTING_TREES", "WILDLIFE_FOOD_PLOTS",
                "CONTOUR_GRASS_STRIPS", "SHELTER_BELTS", "LIVING_SNOW_FENCES",
                "SALINITY_REDUCING_VEGETATION", "FILTER_STRIPS",
                "RIPARIAN_BUFFERS", "WETLAND_RESTORATION",
                "WETLAND_RESTORATION_FLOOD", "WETLAND_RESTORATION_NONFLOOD",
                "CROSS_WINDTRAP_STRIPS", "RARE_AND_DECLINING_HABITAT",
                "FARMABLE_WETLAND_PROGRAM", "FARMABLE_WETLAND_PROGRAM_BUFFER",
                "MARGINAL_PASTURE_BUFFERS", "MARGINAL_PASTURE_BUFFERS_WET",
                "BOTTOMLAND_HARDWOOD_TREES", "EXPIRED_HARDWOOD_TREES",
                "UPLAND_BIRD_HABITAT_BUFFERS", "LONGLEAF_PINE",
                "DUCK_NESTING_HABITAT", "STATE_ACRES_FOR_WILDLIFE_ENHANCEMENT",
                "FARMABLE_WETLAND_PROGRAM_CONSTRUCTED",
                "FARMABLE_WETLAND_PROGRAM_AQUA",
                "FARMABLE_WETLAND_PROGRAM_FLOOD", "POLLINATOR_HABITAT",
                "CRP_GRASSLANDS_INTRODUCED", "CRP_GRASSLANDS_NATIVE", "TOTAL")

names(prac) <- prac_names

prac <- mutate_at(prac, vars(-STATE, -COUNTY),
                  funs(as.integer(as.character(.))))


write_csv(prac, paste0(local_dir, "/crp_practices.csv"))
write_rds(prac, paste0(local_dir, "/crp_practices.rds"))

# Practices expiring
expires <- excel_sheets(prac_exp_file)

prac_exp_list <- map(expires, function(x) {
  temp <- read_excel(prac_exp_file, sheet = x, skip = 3) %>% 
    filter(!is.na(COUNTY))
  
  names(temp) <- prac_names
  
  temp <- temp %>% 
    mutate_at(vars(-STATE, -COUNTY),
              funs(as.integer(as.character(.)))) %>% 
    mutate(EXP_YEAR = parse_number(str_sub(x, -4)))
  return(temp)
})

prac_exp <- bind_rows(prac_exp_list)


write_csv(prac_exp, paste0(local_dir, "/crp_practices_expiring.csv"))
write_rds(prac_exp, paste0(local_dir, "/crp_practices_expiring.rds"))