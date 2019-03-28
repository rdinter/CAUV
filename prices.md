# Prices

The prices for corn, soybeans, and wheat come from official USDA data which are automatically downloaded with the [0-data/0-ohio-nass.R](0-data/0-ohio-nass.R) script. These data technically come from [NASS Price Program ](https://www.nass.usda.gov/Surveys/Guide_to_NASS_Surveys/Prices/) which are also historically available from [Cornell](https://usda.library.cornell.edu/concern/publications/c821gj76b?locale=en). Data are provided for every month but the year for prices are related to the marketing year, which requires the knowledge of how much volume was sold for each month to calculate the marketing year price. 

| Crop     | Marketing Year |
|:---------|:--------------:|
| Corn     | Sept to Aug    |
| Soybeans | Sept to Aug    |
| Wheat    | June to May    |

USDA will typically release a yearly crop values summary for Ohio in February (can be found [in these press releases](https://www.nass.usda.gov/Statistics_by_State/Ohio/Publications/Current_News_Releases/index.php) and titled "20XX Ohio Crop Values Summary"). These are actually preliminary values for the marketing year in question (ie 2016 values were released on 2017-02-27) as the marketing year is still in progress. The final official values won't be known until after the marketing year is over but the preliminary value from February is used in CAUV calculations for the last year of prices.

Prices used in the CAUV formula are based off of an Olympic average of the previous 7 years. The marketing year depends on the crop, although the for the most recent year's USDA price included in CAUV calculations are based off of projections for what the marketing year will be. By example, the 2018 CAUV values were finalized in June of 2018 yet the marketing year prices for corn, soybeans, and wheat for the 2018 values were not finalized but based off of March mid-year values.

| Tax Year|Prices    |
|--------:|:---------|
|     2005|1997-2003 |
|     2006|1998-2004 |
|     2007|1999-2005 |
|     2008|2000-2006 |
|     2009|2001-2007 |
|     2010|2002-2008 |
|     2011|2003-2009 |
|     2012|2004-2010 |
|     2013|2005-2011 |
|     2014|2006-2012 |
|     2015|2008-2014 |
|     2016|2009-2015 |
|     2017|2010-2016 |
|     2018|2011-2017 |
|     2019|2012-2018 |
|   Future|previous-7 years ago |
|    Years|7 Olympic, one year lag |
