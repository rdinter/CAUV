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
res <- SDA_query(q) |> 
  arrange(areaname, desc(mapunit_acres))
glimpse(res)

write_csv(res, paste0(local_dir, "/nrcs_county_soils.csv"))
write_rds(res, paste0(local_dir, "/nrcs_county_soils.rds"))

#######
# "SELECT L.areaname, M.mukey, M.musym, M.muname, M.muacres AS mapunit_acres,
#  L.areaacres AS survey_acres FROM mapunit M 
#  INNER JOIN legend L on L.lkey = M.lkey and L.areasymbol LIKE 'OH%' "


# ---- with-pi ------------------------------------------------------------

q2 <- "SELECT l.areaname, m.*, musym, muname, muacres, farmlndcl, 
        textsubcat AS PI
       FROM legend AS l
       INNER JOIN mapunit m ON m.lkey = l.lkey AND areasymbol LIKE 'OH%'
       LEFT JOIN mutext AS mt ON mt.mukey = m.mukey 
        AND mapunittextkind LIKE 'miscellaneous notes' AND textcat = 'PI'
       ORDER BY areasymbol, musym"
res2 <- SDA_query(q2) |> 
  arrange(areaname, desc(muacres))
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

q3 <- "SELECT l.areaname, musym, muname, muacres, farmlndcl, c.*, 
        textsubcat AS PI, m.muacres * (c.comppct_r / 100.0) AS acres_estimate
       FROM legend AS l
       INNER JOIN mapunit m ON m.lkey = l.lkey AND areasymbol LIKE 'OH%'
       LEFT JOIN mutext AS mt ON mt.mukey = m.mukey 
        AND mapunittextkind LIKE 'miscellaneous notes' AND textcat = 'PI'
       LEFT JOIN component  AS c ON c.mukey = m.mukey
       ORDER BY areasymbol, musym"
res3 <- SDA_query(q3) |> 
  arrange(areaname, desc(muacres))
glimpse(res3)

write_csv(res3, paste0(local_dir, "/nrcs_county_soils_alt.csv"))
write_rds(res3, paste0(local_dir, "/nrcs_county_soils_alt.rds"))

crops_q <- "SELECT cyield.*, m.*, l.*
            FROM cocropyld AS cyield
            INNER JOIN component AS c on c.cokey = cyield.cokey
            INNER JOIN mapunit m ON m.mukey = c.mukey
            INNER JOIN legend l on m.lkey = l.lkey 
            WHERE l.areasymbol LIKE 'OH%' AND cyield.cropname LIKE 'corn%'"
crops <- SDA_query(crops_q)

wot = SDA_query("SELECT DISTINCT cropname FROM cocropyld")


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
