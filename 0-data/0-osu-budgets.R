# Downloading the data for Ohio Budgets

## NOT CURRENTLY HELPFUL!

# ---- start --------------------------------------------------------------

#library(lubridate)
library("httr")
library("rvest")
library("stringr")
library("tidyverse")

local_dir   <- "0-data/osu_budget"
data_source <- "0-data/osu_budget/raw"
if (!file.exists(local_dir)) dir.create(local_dir)
if (!file.exists(data_source)) dir.create(data_source)

# Current values:
# https://farmoffice.osu.edu/farm-management-tools/farm-budgets

c_budgets <- "https://farmoffice.osu.edu/farm-management-tools/farm-budgets"
c_node    <- "#block-system-main li a"

budget_links <- c_budgets %>% 
  read_html() %>% 
  html_nodes(c_node) %>% 
  html_attr("href")

bad <- !grepl("http:", budget_links)
budget_links <- ifelse(bad, paste0("http://farmoffice.osu.edu", budget_links),
                       budget_links)
budget_names <- paste0(data_source, "/",
                       str_replace_all(basename(budget_links), "%20", ""))

map2(budget_names, budget_links, function(x, y){
  Sys.sleep(runif(1))
  temp <- GET(y)
  if (temp$status > 400) return()
  if (!file.exists(x)) download.file(y, x)
})

