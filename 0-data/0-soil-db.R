# SQL query for soils in Ohio
# soildb?
# https://ncss-tech.github.io/AQP/soilDB/soilDB-Intro.html
# https://sdmdataaccess.sc.egov.usda.gov/Query.aspx
# http://ncss-tech.github.io/stats_for_soil_survey/chapters/
#  0_pre-class-assignment/pre-class-assignment.html

# ---- start --------------------------------------------------------------


library("tidyverse")
library("soilDB")

# Create a directory for the data
local_dir    <- "0-data/soils"
data_source <- paste0(local_dir, "/raw")
if (!file.exists(local_dir)) dir.create(local_dir, recursive = T)
if (!file.exists(data_source)) dir.create(data_source, recursive = T)


# ---- simple -------------------------------------------------------------


q <- paste0("SELECT L.areaname, M.mukey, M.musym, M.muname, ",
            "M.muacres AS mapunit_acres, L.areaacres AS survey_acres ",
            "FROM mapunit M ",
            "INNER JOIN legend L on L.lkey = M.lkey and",
            " L.areasymbol LIKE 'OH%' ")
res <- SDA_query(q)
glimpse(res)

write_csv(res, paste0(local_dir, "/nrcs_county_soils.csv"))
write_rds(res, paste0(local_dir, "/nrcs_county_soils.rds"))

#######
# "SELECT L.areaname, M.mukey, M.musym, M.muname, M.muacres AS mapunit_acres,
#  L.areaacres AS survey_acres FROM mapunit M 
#  INNER JOIN legend L on L.lkey = M.lkey and L.areasymbol LIKE 'OH%' "


# ---- with-pi ------------------------------------------------------------

q2 <- "SELECT l.areaname, musym, muname, muacres, farmlndcl, 
        textsubcat AS PI
       FROM legend AS l
       INNER JOIN mapunit m ON m.lkey = l.lkey AND areasymbol LIKE 'OH%'
       LEFT JOIN mutext AS mt ON mt.mukey = m.mukey 
        AND mapunittextkind LIKE 'miscellaneous notes' AND textcat = 'PI'
       ORDER BY areasymbol, musym"
res2 <- SDA_query(q2)
glimpse(res2)

write_csv(res2, paste0(local_dir, "/nrcs_county_soils_wpi.csv"))
write_rds(res2, paste0(local_dir, "/nrcs_county_soils_wpi.rds"))

# SELECT l.areaname, musym, muname, muacres, farmlndcl, textsubcat AS PI
# FROM legend AS l
# INNER JOIN mapunit m ON m.lkey = l.lkey AND areasymbol LIKE 'OH%'
# LEFT JOIN mutext AS mt ON mt.mukey = m.mukey 
#   AND mapunittextkind LIKE 'miscellaneous notes' AND textcat = 'PI'
# ORDER BY areasymbol, musym


# ---- only-pi ------------------------------------------------------------

# Alternate:

q3 <- "SELECT l.areaname, musym, muname, muacres, farmlndcl, compname,
        nirrcapcl, nirrcapscl, textsubcat AS PI
       FROM legend AS l
       INNER JOIN mapunit m ON m.lkey = l.lkey AND areasymbol LIKE 'OH%'
       INNER JOIN mutext AS mt ON mt.mukey = m.mukey 
        AND mapunittextkind LIKE 'miscellaneous notes' AND textcat = 'PI'
       INNER JOIN component  AS c ON c.mukey = m.mukey
        AND majcompflag LIKE 'Yes'
       ORDER BY areasymbol, musym"
res3 <- SDA_query(q3)
glimpse(res3)

write_csv(res3, paste0(local_dir, "/nrcs_county_soils_alt.csv"))
write_rds(res3, paste0(local_dir, "/nrcs_county_soils_alt.rds"))


# SELECT l.areaname, musym, muname, muacres, farmlndcl, compname,
#         nirrcapcl, nirrcapscl, textsubcat AS PI
# FROM legend AS l
# INNER JOIN mapunit m ON m.lkey = l.lkey AND areasymbol LIKE 'OH%'
# INNER JOIN mutext AS mt ON mt.mukey = m.mukey 
#  AND mapunittextkind LIKE 'miscellaneous notes' AND textcat = 'PI'
# INNER JOIN component  AS c ON c.mukey = m.mukey
#  AND majcompflag LIKE 'Yes'
# ORDER BY areasymbol, musym

#####
