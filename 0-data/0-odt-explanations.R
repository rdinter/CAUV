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

# ---- cauv-explainations -------------------------------------------------

explainers   <- folder_create("/explainers", data_source)

# Should have all the explainers downloaded for future use!

cauvexp <- read_html("https://www.tax.ohio.gov/real_property/cauv.aspx")

link1 <- cauvexp %>% 
  html_nodes("a") %>% 
  html_text()

link2 <- cauvexp %>% 
  html_nodes("a") %>% 
  html_attr("href") %>% 
  paste0("http://www.tax.ohio.gov", .)

cauvexp <- data_frame(text = link1, url = link2) %>% 
  filter(grepl("explanation", tolower(text)))

tax_download <- purrr::pmap(cauvexp, function(text, url){
  Sys.sleep(sample(seq(0,1,0.25), 1))
  dfile <- paste0(explainers, "/", tolower(basename(text)), ".pdf")
  if (!file.exists(dfile)) download.file(url, dfile)
})
