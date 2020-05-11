Non-Land Costs
================

<!-- nonland.md is generated from nonland.Rmd. Please edit nonland.Rmd for corrections file -->

# Non-land Costs

The non-land costs are calculated as 7-year Olympic averages for typical
costs of producing each commodity (corn, soybeans, and wheat). The [Farm
Office](https://farmoffice.osu.edu/farm-management-tools/farm-budgets)
at The Ohio State University Extension conducts annual surveys for costs
of production which serve as the yearly estimates that are used in the
7-year Olympic average. Budgets for a commodity marketing year are
generally released in October of the prior year and then finalized in
May of the marketing year – i.e. the 2019 marketing year was initially
released in October 2018 and will likely be finalized sometime after May
2019. There will typically be updates to the budgets throughout the year
with a finalized version sometime in May. Due to the complex nature of
the budgets, these data must be manually downloaded to each crops
respective folder in [0-data/osu\_budget/raw](0-data/osu_budget/raw) and
the values manually input into the [0-data/osu\_budget/osu\_budgets -
R.csv](0-data/osu_budget/osu_budgets%20-%20R.csv) file. These budgets
will include both fixed (machinery, equipment, labor, etc.) and variable
(seeds, fertilizer, chemicals, hauling, etc.) costs involved in
producing corn, wheat, or soybeans and each of these individual
components are averaged for use in CAUV calculation.

Prior to 2015, the non-land costs were lagged one year – i.e. tax year
2014 used the values from budgets in 2007 to 2013. From 2015 onward, the
current year values are included in the non-land cost calculations.
Because of the nature of an Olympic average, the non-land costs used in
2019 CAUV is bounded between a “high” and a “low” value by averaging the
previous 6-years after dropping only the highest or lowest value
respectively. In the event that the “high” value of our projected
non-land costs occur, then this is where the 2019 non-land costs are all
the lowest values in the previous 7-years which causes the CAUV to be a
higher value. The opposite is true for the “low” value in that the
non-land costs are all 7-year highs.

Data description of each item in the budget can be found [in the README
for the folder](0-data/osu_budget/).

## Timing of Values

The non-land costs years of OSU Crop Budgets used to calculate a tax
year’s non-land cost are as follows:

| Tax Year | Non-Land Costs      |
| -------: | :------------------ |
|     2005 | 1998-2004           |
|     2006 | 1999-2005           |
|     2007 | 2000-2006           |
|     2008 | 2001-2007           |
|     2009 | 2002-2008           |
|     2010 | 2003-2009           |
|     2011 | 2004-2010           |
|     2012 | 2005-2011           |
|     2013 | 2006-2012           |
|     2014 | 2007-2013           |
|     2015 | 2009-2015           |
|     2016 | 2010-2016           |
|     2017 | 2011-2017           |
|     2018 | 2012-2018           |
|     2019 | 2013-2019           |
|     2020 | 2014-2020           |
|   Future | current-6 years ago |
|    Years | 7 Olympic           |

## Current Projections

Because of the Olympic averaging nature of the non-land costs,
projecting one year into the future for non-land costs has an upper
bound and a lower bound even without knowing what the OSU crop budgets
are. This is because the highest and lowest values are always discarded
in calculating the non-land costs component of CAUV. If the missing year
ends up with extremely high costs, then that value will be omitted and
the previous 6 years of data (minus the lowest costs) are then averaged.
The reverse can be said if the missing year ends up with extremely low
costs. Therefore, for each tax year we can have an upper bound and a
lower bound. In addition, we construct what we “expect” to be the
non-land costs based on carrying forward the previous year’s values in
place.

Our current expectations for the base cost and additional cost of each
commodities in the CAUV formula as of
2020-05-11.

### Corn

| Year | ODT Base Cost | Low Projection | Expected Projection | High Projection |
| ---: | :------------ | :------------- | :------------------ | :-------------- |
| 2006 | $232.83       | \-             | \-                  | \-              |
| 2007 | $235.70       | \-             | \-                  | \-              |
| 2008 | $242.39       | \-             | $256.74             | \-              |
| 2009 | $264.12       | \-             | $263.38             | \-              |
| 2010 | $286.65       | \-             | $291.55             | \-              |
| 2011 | $300.98       | \-             | $313.59             | \-              |
| 2012 | $350.71       | $363.76        | $350.02             | $306.90         |
| 2013 | $391.90       | $402.66        | $390.51             | $346.77         |
| 2014 | $437.85       | $447.49        | $435.82             | $387.01         |
| 2015 | $516.99       | $534.55        | $516.25             | $482.29         |
| 2016 | $524.47       | $544.03        | $524.36             | $501.26         |
| 2017 | $538.78       | $558.62        | $539.19             | $520.37         |
| 2018 | $529.28       | $560.31        | $531.44             | $526.53         |
| 2019 | $517.63       | $551.90        | $519.53             | $508.91         |
| 2020 | \-            | $530.45        | $503.44             | $491.73         |
| 2021 | \-            | $510.53        | $485.49             | $475.64         |
| 2022 | \-            | $493.00        | $473.14             | $463.06         |

| Year | ODT Add Cost | Low Projection | Expected Projection | High Projection |
| ---: | :----------- | :------------- | :------------------ | :-------------- |
| 2006 | $0.92        | \-             | \-                  | \-              |
| 2007 | $0.91        | \-             | \-                  | \-              |
| 2008 | $0.90        | \-             | $0.74               | \-              |
| 2009 | $0.72        | \-             | $0.74               | \-              |
| 2010 | $0.83        | \-             | $0.86               | \-              |
| 2011 | $0.84        | \-             | $0.89               | \-              |
| 2012 | $0.90        | $1.04          | $0.97               | $0.89           |
| 2013 | $1.04        | $1.15          | $1.06               | $0.94           |
| 2014 | $1.18        | $1.28          | $1.20               | $1.05           |
| 2015 | $1.36        | $1.45          | $1.38               | $1.24           |
| 2016 | $1.38        | $1.45          | $1.36               | $1.30           |
| 2017 | $1.45        | $1.55          | $1.49               | $1.41           |
| 2018 | $1.44        | $1.54          | $1.45               | $1.42           |
| 2019 | $1.43        | $1.54          | $1.44               | $1.35           |
| 2020 | \-           | $1.50          | $1.38               | $1.32           |
| 2021 | \-           | $1.45          | $1.33               | $1.27           |
| 2022 | \-           | $1.40          | $1.34               | $1.27           |

### Soybeans

| Year | ODT Base Cost | Low Projection | Expected Projection | High Projection |
| ---: | :------------ | :------------- | :------------------ | :-------------- |
| 2006 | $167.50       | \-             | \-                  | \-              |
| 2007 | $168.14       | \-             | \-                  | \-              |
| 2008 | $174.44       | \-             | $181.69             | \-              |
| 2009 | $175.21       | \-             | $183.06             | \-              |
| 2010 | $189.10       | \-             | $200.60             | \-              |
| 2011 | $204.60       | \-             | $212.78             | \-              |
| 2012 | $227.51       | $238.30        | $226.51             | $205.28         |
| 2013 | $248.69       | $254.03        | $247.15             | $222.20         |
| 2014 | $275.21       | $281.06        | $273.38             | $244.93         |
| 2015 | $325.42       | $336.37        | $326.13             | $303.99         |
| 2016 | $336.33       | $345.95        | $336.36             | $317.16         |
| 2017 | $347.10       | $357.99        | $346.71             | $332.70         |
| 2018 | $346.26       | $362.64        | $346.52             | $338.62         |
| 2019 | $338.54       | $360.34        | $338.75             | $329.80         |
| 2020 | \-            | $349.33        | $331.51             | $321.80         |
| 2021 | \-            | $336.63        | $319.02             | $310.20         |
| 2022 | \-            | $325.48        | $309.54             | $300.68         |

| Year | ODT Add Cost | Low Projection | Expected Projection | High Projection |
| ---: | :----------- | :------------- | :------------------ | :-------------- |
| 2006 | $0.49        | \-             | \-                  | \-              |
| 2007 | $0.49        | \-             | \-                  | \-              |
| 2008 | $0.50        | \-             | $0.54               | \-              |
| 2009 | $0.57        | \-             | $0.55               | \-              |
| 2010 | $0.66        | \-             | $0.71               | \-              |
| 2011 | $0.77        | \-             | $0.86               | \-              |
| 2012 | $0.93        | $1.13          | $1.06               | $0.80           |
| 2013 | $1.12        | $1.29          | $1.15               | $0.95           |
| 2014 | $1.27        | $1.45          | $1.30               | $1.10           |
| 2015 | $1.24        | $1.34          | $1.10               | $1.14           |
| 2016 | $1.07        | $1.14          | $1.06               | $1.06           |
| 2017 | $1.05        | $1.13          | $1.00               | $1.04           |
| 2018 | $0.94        | $1.03          | $0.96               | $0.93           |
| 2019 | $0.90        | $0.98          | $0.91               | $0.83           |
| 2020 | \-           | $0.96          | $0.89               | $0.80           |
| 2021 | \-           | $0.93          | $0.82               | $0.77           |
| 2022 | \-           | $0.90          | $0.91               | $0.79           |

### Wheat

| Year | ODT Base Cost | Low Projection | Expected Projection | High Projection |
| ---: | :------------ | :------------- | :------------------ | :-------------- |
| 2006 | $151.98       | \-             | \-                  | \-              |
| 2007 | $153.67       | \-             | \-                  | \-              |
| 2008 | $156.68       | \-             | $157.42             | \-              |
| 2009 | $159.01       | \-             | $161.15             | \-              |
| 2010 | $170.16       | \-             | $175.87             | \-              |
| 2011 | $192.94       | \-             | $185.33             | \-              |
| 2012 | $211.52       | $217.51        | $211.31             | $187.49         |
| 2013 | $230.62       | $234.77        | $229.55             | $204.75         |
| 2014 | $255.48       | $268.00        | $254.67             | $226.00         |
| 2015 | $296.98       | $302.24        | $295.82             | $265.12         |
| 2016 | $323.52       | $329.83        | $322.51             | $296.39         |
| 2017 | $336.21       | $347.67        | $335.87             | $315.83         |
| 2018 | $330.53       | $349.23        | $330.11             | $325.75         |
| 2019 | $319.08       | $340.47        | $317.76             | $310.93         |
| 2020 | \-            | $328.17        | $304.78             | $299.57         |
| 2021 | \-            | $310.34        | $288.72             | $277.54         |
| 2022 | \-            | $293.47        | $273.76             | $262.96         |

| Year | ODT Add Cost | Low Projection | Expected Projection | High Projection |
| ---: | :----------- | :------------- | :------------------ | :-------------- |
| 2006 | $0.87        | \-             | \-                  | \-              |
| 2007 | $0.81        | \-             | \-                  | \-              |
| 2008 | $0.84        | \-             | $0.82               | \-              |
| 2009 | $0.86        | \-             | $0.80               | \-              |
| 2010 | $1.14        | \-             | $1.12               | \-              |
| 2011 | $1.19        | \-             | $1.25               | \-              |
| 2012 | $1.41        | $1.58          | $1.47               | $1.25           |
| 2013 | $1.61        | $1.78          | $1.69               | $1.47           |
| 2014 | $1.80        | $1.99          | $1.91               | $1.68           |
| 2015 | $1.77        | $1.94          | $1.74               | $1.77           |
| 2016 | $1.64        | $1.79          | $1.61               | $1.64           |
| 2017 | $1.62        | $1.78          | $1.60               | $1.66           |
| 2018 | $1.49        | $1.68          | $1.57               | $1.49           |
| 2019 | $1.41        | $1.56          | $1.48               | $1.31           |
| 2020 | \-           | $1.47          | $1.41               | $1.25           |
| 2021 | \-           | $1.40          | $1.31               | $1.21           |
| 2022 | \-           | $1.37          | $1.31               | $1.20           |
