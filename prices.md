
<!-- prices.md is generated from prices.Rmd. Please edit prices.Rmd for corrections file -->

# Prices

Price for each commodity is a 7-year Olympic average of past marketing
year prices that is also weighted by total production as measured in
bushels for each marketing year with 5% subtracted from the price to
account for management costs. Both the price and production values are
from USDA-NASS reports. The prices for corn, soybeans, and wheat come
from official USDA data which are automatically downloaded with the
[0-data/0-ohio-nass.R](0-data/0-ohio-nass.R) script. These data
technically come from [NASS Price
Program](https://www.nass.usda.gov/Surveys/Guide_to_NASS_Surveys/Prices/)
which are also historically available from
[Cornell](https://usda.library.cornell.edu/concern/publications/c821gj76b?locale=en).
Data are provided for every month but the year for prices are related to
the marketing year, which requires the knowledge of how much volume was
sold for each month to calculate the marketing year price.

| Crop     | Marketing Year |
| :------- | :------------: |
| Corn     |  Sept to Aug   |
| Soybeans |  Sept to Aug   |
| Wheat    |  June to May   |

USDA will typically release a yearly crop values summary for Ohio in
February (can be found [in these press
releases](https://www.nass.usda.gov/Statistics_by_State/Ohio/Publications/Current_News_Releases/index.php)
and titled “20XX Ohio Crop Values Summary”). These are actually
preliminary values for the marketing year in question (ie 2016 values
were released on 2017-02-27) as the marketing year is still in progress.
The final official values won’t be known until after the marketing year
is over but the preliminary value from February is used in CAUV
calculations for the last year of prices.

Prices used in the CAUV formula are based off of an Olympic average of
the previous 7 years. The marketing year depends on the crop, although
the for the most recent year’s USDA price included in CAUV calculations
are based off of projections for what the marketing year will be. By
example, the 2018 CAUV values were finalized in June of 2018 yet the
marketing year prices for corn, soybeans, and wheat for the 2018 values
were not finalized but based off of March mid-year values.

| Tax Year | Prices                  |
| -------: | :---------------------- |
|     2005 | 1997-2003               |
|     2006 | 1998-2004               |
|     2007 | 1999-2005               |
|     2008 | 2000-2006               |
|     2009 | 2001-2007               |
|     2010 | 2002-2008               |
|     2011 | 2003-2009               |
|     2012 | 2004-2010               |
|     2013 | 2005-2011               |
|     2014 | 2006-2012               |
|     2015 | 2008-2014               |
|     2016 | 2009-2015               |
|     2017 | 2010-2016               |
|     2018 | 2011-2017               |
|     2019 | 2012-2018               |
|     2020 | 2013-2019               |
|   Future | previous-7 years ago    |
|    Years | 7 Olympic, one year lag |

## Current Projections

Because of the Olympic averaging nature of the prices, projecting one
year into the future for prices has an upper bound and a lower bound
even without knowing what the marketing year price will end up being.
This is because the highest and lowest values are always discarded in
calculating the prices component of CAUV. If the missing year ends up
with extremely high price, then that value will be omitted and the
previous 6 years of data (minus the lowest price) are then averaged. The
reverse can be said if the missing year ends up with extremely low
price. Therefore, for each tax year we can have an upper bound and a
lower bound. In addition, we construct what we “expect” to be the prices
based on carrying forward the previous year’s values in place.

Our current expectations for the prices of corn, soybeans, and wheat in
the CAUV formula as of
2020-04-24.

### Corn

| Year | ODT Price | USDA Price | Low Projection | Expected Projection | High Projection |
| ---: | :-------- | :--------- | :------------- | :------------------ | :-------------- |
| 2006 | $1.99     | $3.08      | $1.96          | $1.98               | $2.04           |
| 2007 | $1.96     | $4.29      | $1.96          | $1.97               | $2.04           |
| 2008 | $2.02     | $4.21      | $1.97          | $2.06               | $2.06           |
| 2009 | $2.29     | $3.55      | $2.06          | $2.29               | $2.29           |
| 2010 | $2.66     | $5.45      | $2.28          | $2.70               | $2.79           |
| 2011 | $2.89     | $6.44      | $2.57          | $2.89               | $3.05           |
| 2012 | $3.19     | $7.09      | $2.80          | $3.26               | $3.26           |
| 2013 | $3.91     | $4.41      | $3.26          | $3.93               | $3.93           |
| 2014 | $4.48     | $3.78      | $3.93          | $4.54               | $4.54           |
| 2015 | $4.55     | $3.89      | $4.55          | $4.57               | $5.18           |
| 2016 | $4.49     | $3.61      | $4.42          | $4.50               | $5.00           |
| 2017 | $4.51     | $3.61      | $4.50          | $4.50               | $5.09           |
| 2018 | $4.18     | $3.74      | $4.17          | $4.16               | $4.73           |
| 2019 | $3.68     | $4.20      | $3.68          | $3.70               | $4.22           |
| 2020 | \-        | \-         | $3.54          | $3.63               | $3.70           |
| 2021 | \-        | \-         | $3.54          | $3.63               | $3.63           |
| 2022 | \-        | \-         | $3.60          | $3.70               | $3.70           |

### Soybeans

| Year | ODT Price | USDA Price | Low Projection | Expected Projection | High Projection |
| ---: | :-------- | :--------- | :------------- | :------------------ | :-------------- |
| 2006 | $4.84     | $6.46      | $4.61          | $4.88               | $5.12           |
| 2007 | $4.89     | $9.93      | $4.78          | $5.04               | $5.28           |
| 2008 | $5.19     | $10.30     | $4.98          | $5.38               | $5.46           |
| 2009 | $5.60     | $9.78      | $5.35          | $5.83               | $5.83           |
| 2010 | $6.41     | $11.50     | $5.83          | $6.63               | $6.63           |
| 2011 | $7.22     | $13.00     | $6.63          | $7.45               | $7.42           |
| 2012 | $7.74     | $14.60     | $7.16          | $7.93               | $7.93           |
| 2013 | $8.98     | $13.00     | $7.94          | $9.08               | $9.08           |
| 2014 | $10.13    | $10.30     | $9.08          | $10.40              | $10.40          |
| 2015 | $11.09    | $9.16      | $11.00         | $11.08              | $11.95          |
| 2016 | $10.91    | $9.66      | $10.91         | $10.91              | $11.78          |
| 2017 | $10.83    | $9.62      | $10.77         | $10.83              | $11.78          |
| 2018 | $10.43    | $8.69      | $10.38         | $10.46              | $11.35          |
| 2019 | $9.78     | $9.15      | $9.78          | $9.78               | $10.70          |
| 2020 | \-        | \-         | $9.00          | $9.12               | $9.78           |
| 2021 | \-        | \-         | $8.79          | $8.90               | $9.12           |
| 2022 | \-        | \-         | $8.69          | $8.80               | $8.90           |

### Wheat

| Year | ODT Price | USDA Price | Low Projection | Expected Projection | High Projection |
| ---: | :-------- | :--------- | :------------- | :------------------ | :-------------- |
| 2006 | $2.49     | $3.35      | $2.20          | $2.41               | $2.44           |
| 2007 | $2.64     | $5.37      | $2.36          | $2.59               | $2.61           |
| 2008 | $2.89     | $5.82      | $2.59          | $2.87               | $2.87           |
| 2009 | $3.05     | $4.41      | $2.87          | $3.05               | $3.05           |
| 2010 | $3.41     | $5.21      | $3.05          | $3.37               | $3.37           |
| 2011 | $3.64     | $6.73      | $3.37          | $3.62               | $3.95           |
| 2012 | $3.98     | $7.94      | $3.64          | $3.96               | $4.20           |
| 2013 | $4.54     | $6.54      | $3.96          | $4.55               | $4.55           |
| 2014 | $5.16     | $5.60      | $4.55          | $5.19               | $5.19           |
| 2015 | $5.67     | $4.57      | $5.38          | $5.69               | $5.99           |
| 2016 | $5.53     | $4.25      | $5.32          | $5.53               | $6.02           |
| 2017 | $5.53     | $4.90      | $5.53          | $5.53               | $6.02           |
| 2018 | $5.52     | $5.08      | $5.33          | $5.51               | $5.97           |
| 2019 | $5.15     | $5.25      | $4.96          | $5.15               | $5.62           |
| 2020 | \-        | \-         | $4.63          | $4.84               | $5.15           |
| 2021 | \-        | \-         | $4.51          | $4.73               | $4.84           |
| 2022 | \-        | \-         | $4.51          | $4.73               | $4.73           |
