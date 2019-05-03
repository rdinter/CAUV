# Non-land Costs

The non-land costs are calculated as 7-year Olympic averages for typical costs of producing each commodity (corn, soybeans, and wheat). The [Farm Office](https://farmoffice.osu.edu/farm-management-tools/farm-budgets) at The Ohio State University Extension conducts annual surveys for costs of production which serve as the yearly estimates that are used in the 7-year Olympic average. Budgets for a commodity marketing year are generally released in October of the prior year and then finalized in May of the marketing year -- i.e. the 2019 marketing year was initially released in October 2018 and will likely be finalized sometime after May 2019. There will typically be updates to the budgets throughout the year with a finalized version sometime in May. Due to the complex nature of the budgets, these data must be manually downloaded to each crops respective folder in [0-data/osu_budget/raw](0-data/osu_budget/raw) and the values manually input into the [0-data/osu_budget/osu_budgets - R.csv](0-data/osu_budget/osu_budgets - R.csv) file. These budgets will include both fixed (machinery, equipment, labor, etc.) and variable (seeds, fertilizer, chemicals, hauling, etc.) costs involved in producing corn, wheat, or soybeans and each of these individual components are averaged for use in CAUV calculation.

Prior to 2015, the non-land costs were lagged one year -- i.e. tax year 2014 used the values from budgets in 2007 to 2013. From 2015 onward, the current year values are included in the non-land cost calculations. Because of the nature of an Olympic average, the non-land costs used in 2019 CAUV is bounded between a "high" and a "low" value by averaging the previous 6-years after dropping only the highest or lowest value respectively. In the event that the "high" value of our projected non-land costs occur, then this is where the 2019 non-land costs are all the lowest values in the previous 7-years which causes the CAUV to be a higher value. The opposite is true for the "low" value in that the non-land costs are all 7-year highs.

Data description of each item in the budget can be found [in the README for the folder](0-data/osu_budget/).

| Tax Year|Non-Land Costs |
|--------:|:--------------|
|     2005|1998-2004      |
|     2006|1999-2005      |
|     2007|2000-2006      |
|     2008|2001-2007      |
|     2009|2002-2008      |
|     2010|2003-2009      |
|     2011|2004-2010      |
|     2012|2005-2011      |
|     2013|2006-2012      |
|     2014|2007-2013      |
|     2015|2009-2015      |
|     2016|2010-2016      |
|     2017|2011-2017      |
|     2018|2012-2018      |
|     2019|2013-2019      |
|   Future|current-6 years ago|
|    Years|7 Olympic |
