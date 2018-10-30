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


# --- dte93 ---------------------------------------------------------------


dte93 <- folder_create("/dte93", data_source)

# dte93: property tax values
# Real Property Abstract by Taxing District (DTE93)
# Real Property Abstract by School District (DTE93)
# Taxable Property Values by Joint Vocational School District (DTE93)

tax_urls <- read_html(tax_site) %>% 
  html_nodes("ul:nth-child(5) a") %>% 
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
  
  dfile <- paste0(dte93, "/", tolower(basename(dlinks)))
  purrr::map2(dfile, dlinks, function(x, y){
    if (!file.exists(x)) download.file(y, x)
  })
})

######
# SD files - PROBLEM with the 2005 SD excel file... it don't work.
sd_files <- dir(dte93, pattern = "sd_rates", full.names = T)

