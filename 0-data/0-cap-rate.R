# Capitalization rate information, mostly from USDA-ERS:
# https://data.ers.usda.gov/reports.aspx?ID=17838

# Can't really download this in any automated way, so a manual update to the
#  "capitalization_rate.csv" file in the cap_rate folder needs to be done.
#  The "Total rate of return on farm equity" entry is what is used for the
#  equity rate variable titled "equity_rate_usda"

# Keep in mind that the values used for capitalization rates may be jumbled!
#  For instance, the rollbacks used in the tax year 2019 formula would be based
#  on the value that ODT has for the tax year 2018! Please read the 
#  documentation for the capitalization rate