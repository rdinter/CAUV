# Data

Scripts that scrape online data from websites related to the CAUV program. There are some folders which contain data not found elsewhere on the internet related to the CAUV program. The `0-data` folder serves as an area where all raw data related to the CAUV calculations exist.

There are scripts which download information:

- [0-ohio-cauv.R](0-ohio-cauv.R) - downloads the CAUV values for each soil types since 2009 as well as county level averages for taxes collected related to CAUV.
- [0-ohio-nass.R](0-ohio-nass.R) - uses the [usdarnass package](https://rdinter.github.io/usdarnass) to download official USDA statistics for prices, yields,and harvested acreage in Ohio.
- [0-ohio-taxation.R](0-ohio-taxation.R) - property tax related datasets for Ohio.

In addition, there are folders which have data that are not available to download from websites. At this moment, these files are ignored but can easily be opened up. Here are brief descriptions of the folders:

<!--- - `ODT` - data related to taxation on different types of properties across counties in Ohio. --->
- [ohio](ohio/) - data related to agricultural prices, yields, and acreage related to crops in Ohio.
- [osu_budget](osu_budget/) - data on costs of operation from the extension offices at The Ohio State University. Due to the structure of the [website hosting](https://farmoffice.osu.edu/farm-management-tools/farm-budgets) these files, it is not feasible to automate downloading and therefore these are manually downloaded with the file naming convention of "crop-YEAR.xls" under the raw/crop/consistent folder. And because the format of each excel file changes randomly, the values must be manually put together into the "osu_budgets.csv" file.
    - For future years, the format of the [osu_budgets - R.csv](osu_budget/osu_budgets - R.csv) and [osu_budgets - odt values.csv](osu_budget/osu_budgets - odt values.csv) files should be followed for filling out information on each crop -- see below.
    - Description of each variable used can be found in the [README](osu_budget) file and used as a guideline for adding new data for future budgets.
- [soils](soils/) - previous official values for CAUV across every soil type and downloaded data from ODT
    - [offline](soils/offline/) - data not available for downloading online (currently ignored)
    - [raw](soils/raw/) - data that has been downloaded through R scripts