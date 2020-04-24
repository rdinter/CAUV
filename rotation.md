Rotations
================

<!-- rotation.md is generated from rotation.Rmd. Please edit rotation.Rmd for corrections file -->

# Rotation

The rotation between corn, soybeans, and wheat come from official USDA
data which are automatically downloaded with the
[0-data/0-ohio-nass.R](0-data/0-ohio-nass.R) script. These data
technically come from [Crop Production
Reports](https://usda.mannlib.cornell.edu/MannUsda/viewDocumentInfo.do?documentID=1046).
Typically there is an August, September, October, and November forecast.
Then [finalized
values](https://usda.mannlib.cornell.edu/MannUsda/viewDocumentInfo.do?documentID=1047)
occur in January of the following year. The USDA Quick Stats API will
incorrectly place the most recent forecast value for the current year in
the “YEAR” reference period. This needs to be accounted for when looking
at projections.

Rotation is one of the components which does not use Olympic averaging,
which makes projecting the component forward more sensitive to new
values.

| Tax Year | Rotation                |
| -------: | :---------------------- |
|     2005 | ad hoc                  |
|     2006 | ad hoc                  |
|     2007 | ad hoc                  |
|     2008 | ad hoc                  |
|     2009 | ad hoc                  |
|     2010 | 2004-2008               |
|     2011 | 2005-2009               |
|     2012 | 2006-2010               |
|     2013 | 2007-2011               |
|     2014 | 2008-2012               |
|     2015 | 2010-2014               |
|     2016 | 2011-2015               |
|     2017 | 2012-2016               |
|     2018 | 2013-2017               |
|     2019 | 2014-2018               |
|     2020 | 2015-2019               |
|   Future | previous-5 years ago    |
|    Years | 5 Average, one year lag |

## Current Projections

The rotation values are based on the harvested acreage of each crop from
USDA. USDA provides updates for each of the crops in the Summer time
until they denote their official estimates in January or February of the
following year. In calculating projections, the most recent value for
harvested acreage is carried forward to future years to create the
projection. There is no “high” or “low” value in projections for
rotations.

Our current expectations for the rotation of corn, soybeans, and wheat
in the CAUV formula as of
2020-04-24.

### Corn

| Year | ODT Value | USDA Acres Harvested | AVG Acres Harvested | Projected |
| ---: | :-------- | :------------------- | :------------------ | :-------- |
| 2010 | 39.0%     | 3,270,000            | 3,210,000           | 37.5%     |
| 2011 | 38.6%     | 3,200,000            | 3,216,000           | 37.4%     |
| 2012 | 38.6%     | 3,650,000            | 3,220,000           | 37.5%     |
| 2013 | 38.7%     | 3,740,000            | 3,268,000           | 38.0%     |
| 2014 | 38.6%     | 3,480,000            | 3,276,000           | 38.0%     |
| 2015 | 40.0%     | 3,260,000            | 3,468,000           | 39.9%     |
| 2016 | 40.2%     | 3,300,000            | 3,466,000           | 40.0%     |
| 2017 | 40.0%     | 3,150,000            | 3,486,000           | 40.1%     |
| 2018 | 39.0%     | 3,300,000            | 3,386,000           | 39.0%     |
| 2019 | 38.0%     | 2,570,000            | 3,298,000           | 38.0%     |
| 2020 | \-        | \-                   | 3,116,000           | 37.2%     |
| 2021 | \-        | \-                   | 3,103,568           | 37.0%     |
| 2022 | \-        | \-                   | 3,082,338           | 36.9%     |

### Soybeans

| Year | ODT Value | USDA Acres Harvested | AVG Acres Harvested | Projected |
| ---: | :-------- | :------------------- | :------------------ | :-------- |
| 2010 | 51.0%     | 4,590,000            | 4,448,000           | 52.0%     |
| 2011 | 50.9%     | 4,540,000            | 4,470,000           | 52.0%     |
| 2012 | 51.1%     | 4,590,000            | 4,492,000           | 52.2%     |
| 2013 | 51.2%     | 4,490,000            | 4,476,000           | 52.0%     |
| 2014 | 52.0%     | 4,690,000            | 4,546,000           | 52.7%     |
| 2015 | 52.6%     | 4,740,000            | 4,580,000           | 52.7%     |
| 2016 | 53.0%     | 4,840,000            | 4,610,000           | 53.2%     |
| 2017 | 54.0%     | 5,090,000            | 4,670,000           | 53.7%     |
| 2018 | 55.0%     | 5,020,000            | 4,770,000           | 54.9%     |
| 2019 | 56.0%     | 4,270,000            | 4,876,000           | 56.2%     |
| 2020 | \-        | \-                   | 4,792,000           | 57.2%     |
| 2021 | \-        | \-                   | 4,825,122           | 57.5%     |
| 2022 | \-        | \-                   | 4,844,583           | 58.0%     |

### Wheat

| Year | ODT Value | USDA Acres Harvested | AVG Acres Harvested | Projected |
| ---: | :-------- | :------------------- | :------------------ | :-------- |
| 2010 | 10.0%     | 700,000              | 900,000             | 10.5%     |
| 2011 | 10.5%     | 850,000              | 912,000             | 10.6%     |
| 2012 | 10.3%     | 450,000              | 886,000             | 10.3%     |
| 2013 | 10.1%     | 640,000              | 864,000             | 10.0%     |
| 2014 | 9.4%      | 545,000              | 808,000             | 9.4%      |
| 2015 | 7.4%      | 480,000              | 637,000             | 7.3%      |
| 2016 | 6.8%      | 560,000              | 593,000             | 6.8%      |
| 2017 | 6.0%      | 460,000              | 535,000             | 6.2%      |
| 2018 | 6.0%      | 450,000              | 537,000             | 6.2%      |
| 2019 | 6.0%      | 385,000              | 499,000             | 5.8%      |
| 2020 | \-        | \-                   | 467,000             | 5.6%      |
| 2021 | \-        | \-                   | 458,917             | 5.5%      |
| 2022 | \-        | \-                   | 429,210             | 5.1%      |
