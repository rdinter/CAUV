# Ohio Taxation statistics:
# https://tax.ohio.gov/government/real-state/cauv

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
explainers   <- folder_create("/explainers", local_dir)

# Header to bypass tax.ohio forcing 403 errors
moz_head <- c("user-agent" =
                paste0("Mozilla/5.0 (Windows NT 10.0; Win64; x64; rv:73.0) ",
                       "Gecko/20100101 Firefox/73.0"))


# ---- kinda-automated ----------------------------------------------------

cauv_site <- session("https://tax.ohio.gov/government/real-state/cauv",
                     add_headers(moz_head))

cauv_href <- cauv_site |> 
  html_elements("li:nth-child(2) :nth-child(1)") |> 
  html_attr("href")  

cauv_text <- cauv_site |> 
  html_elements("li:nth-child(2) :nth-child(1)") |> 
  html_text2()

df <- tibble(
  text = cauv_text,
  href = cauv_href
) |> 
  filter(grepl("Explanation", text) & !is.na(href))

pmap(df, function(text, href) {
  file_name <- paste0(explainers, "/", text, ".pdf")
  cauv_url  <- paste0("https://tax.ohio.gov", href)
  
  if (!file.exists(file_name)) download.file(cauv_url, file_name,
                                             mode = "wb", headers = moz_head)
  
})

# ---- brute-force --------------------------------------------------------


# Need to update the links, see top of file
base_url   <- "https://tax.ohio.gov/static/"

expl_files <- c(paste0("real_property/cauv_2009_explanation_of_",
                       "the_cauv_calculation.pdf"),
                "real_property/cauv_memorandum_2010.pdf",
                paste0("real_property/explanation%20of%202011%20cauv",
                       "%20calculation%20-%20final.pdf"),
                "personal_property/cauv%202012%20revised%20explanation.pdf",
                "personal_property/explanation_of_2013_calculations.pdf",
                "personal_property/explanation%202014.pdf",
                "personal_property/explanation2015.pdf",
                "personal_property/explanation2016.pdf",
                "personal_property/explanation2017.pdf",
                "personal_property/explanation2018.pdf",
                "personal_property/explanation2019.pdf",
                "real_property/2020explanationwithexhibits.pdf",
                "real_property/2021explanationwithexhibits.pdf",
                "real_property/2022Explanationwithexhibts.pdf",
                "real_property/2023explanationwithexhibts.pdf")
expl_urls <- paste0(base_url, expl_files)

cauv_exp_files <- str_replace_all(basename(expl_files), "%20", " ")


map2(expl_urls, cauv_exp_files, function(x, y) {
  file_name <- paste0(explainers, "/", y)
  if (!file.exists(file_name)) download.file(x, file_name, mode = "wb",
                                             headers = moz_head)
})


