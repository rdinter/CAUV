
<!-- yields.md is generated from yields.Rmd. Please edit yields.Rmd for corrections file -->

# Yields

Each soil type has a corresponding [base yield of production for each
commodity from 1984](0-data/soils/offline/pi_dat_orig84.csv) – which is
the most recent comprehensive soil survey for the state of Ohio and
separate from the base yield of non-land costs. Prior to 2006, Ohio
Department of Taxation (ODT) did not adjust for yield trends and
calculated gross operating income for each soil type via their 1984
yields which suppressed revenues – in the formula this would effectively
mean that the \(\widehat{Yield_{c,Ohio,t}}\) equaled
\(Yield_{c,Ohio,1984}\) instead of varying:

\[
Adjustment_{c,s,t} = \left( \frac{\widehat{Yield_{c,Ohio,t}}}{Yield_{c,Ohio,1984}} \times Yield_{c,s,1984} \right)
\]

ODT began adjusting for yield trends through the current method of
taking the 10-year averages of state-wide yields (irrespective of soil
type), dividing by the state-wide yields for each commodity in 1984,
then multiplying this value based on the 1984 commodity yield for the
particular soil type evaluated. This can be thought of as an adjustment
factor to account for the general trend of increasing yields in corn,
wheat, and soybeans. Prior to 2014, the 10-year calculation involved a
two year lag – i.e. the 2014 tax year used average yield values from
2003 through 2012. In 2015 and beyond, there is only a one year lag –
i.e. 2015 tax year used average yield values from 2005 through 2014. For
each crop in a given CAUV year, this can be mathematically described as:

\[
\widehat{Yield_{c,Ohio,t}} = \sum_{i = 0}^{9} \frac{Yield_{c, Ohio, t - i - lag}}{10}
\]

The yields for corn, soybeans, and wheat come from official USDA data
which are automatically downloaded with the
[0-data/0-ohio-nass.R](0-data/0-ohio-nass.R) script. These data
technically come from [Crop Production
Reports](https://usda.mannlib.cornell.edu/MannUsda/viewDocumentInfo.do?documentID=1046).
Typically there is an August, September, October, and November forecast.
Then [finalized
values](https://usda.mannlib.cornell.edu/MannUsda/viewDocumentInfo.do?documentID=1047)
occur in January of the following year. The USDA Quick Stats API will
incorrectly place the most recent forecast value for the current year in
the “YEAR” reference period. This needs to be accounted for.

Yields are one of the components which does not use Olympic averaging,
which makes projecting the component forward more sensitive to new
values.

| Tax Year | Yields                   |
| -------: | :----------------------- |
|     2005 | 1984                     |
|     2006 | 1995-2004                |
|     2007 | 1996-2005                |
|     2008 | 1997-2006                |
|     2009 | 1998-2007                |
|     2010 | 1999-2008                |
|     2011 | 2000-2009                |
|     2012 | 2001-2010                |
|     2013 | 2002-2011                |
|     2014 | 2003-2012                |
|     2015 | 2005-2014                |
|     2016 | 2006-2015                |
|     2017 | 2007-2016                |
|     2018 | 2008-2017                |
|     2019 | 2009-2018                |
|     2020 | 2010-2019                |
|   Future | previous-11 years ago    |
|    Years | 10 Average, one year lag |

## Current Projections

The yields used in CAUV calculation are simple averages over the most
recent 10 years of data. In projecting forward yield values in future
years, the missing years of data are replaced with the 30-year
trend-line yield for the crop in question. There is no corresponding
“high” or “low” projection since this is not an Olympic averaged
component.

Our current expectations for the yields of corn, soybeans, and wheat in
the CAUV formula as of 2020-04-22.

### Corn

| Year | ODT Yield | USDA Yield | Projected Yield |
| ---: | :-------- | :--------- | :-------------- |
| 2006 | 132       | 159        | 132.1           |
| 2007 | 134       | 150        | 134.3           |
| 2008 | 139       | 131        | 139.1           |
| 2009 | 140.7     | 171        | 140.7           |
| 2010 | 140.1     | 160        | 139.7           |
| 2011 | 144.9     | 153        | 144.2           |
| 2012 | 146.5     | 120        | 145.5           |
| 2013 | 148.5     | 174        | 147             |
| 2014 | 151.9     | 176        | 150.1           |
| 2015 | 155.2     | 153        | 153.7           |
| 2016 | 156.2     | 159        | 154.7           |
| 2017 | 156.2     | 177        | 154.7           |
| 2018 | 158.9     | 187        | 157.4           |
| 2019 | 164.1     | 164        | 163             |
| 2020 | \-        | \-         | 162.3           |
| 2021 | \-        | \-         | 163.7           |
| 2022 | \-        | \-         | 166             |

### Soybeans

| Year | ODT Yield | USDA Yield | Projected Yield |
| ---: | :-------- | :--------- | :-------------- |
| 2006 | 40        | 47         | 39.8            |
| 2007 | 40        | 47         | 40.5            |
| 2008 | 42        | 36         | 41.6            |
| 2009 | 42        | 49         | 42              |
| 2010 | 41.2      | 48         | 41.1            |
| 2011 | 42.5      | 48         | 42.5            |
| 2012 | 43.1      | 45         | 43              |
| 2013 | 43.7      | 49.5       | 43.8            |
| 2014 | 45        | 52.5       | 45              |
| 2015 | 46.7      | 50         | 46.7            |
| 2016 | 47.2      | 54.5       | 47.2            |
| 2017 | 47.9      | 49.5       | 48              |
| 2018 | 48.2      | 56         | 48.2            |
| 2019 | 50.4      | 49         | 50.2            |
| 2020 | \-        | \-         | 50.2            |
| 2021 | \-        | \-         | 50.6            |
| 2022 | \-        | \-         | 51.1            |

### Wheat

| Year | ODT Yield | USDA Yield | Projected Yield |
| ---: | :-------- | :--------- | :-------------- |
| 2006 | 63        | 68         | 62.8            |
| 2007 | 64        | 61         | 63.8            |
| 2008 | 67        | 67         | 66.7            |
| 2009 | 66.7      | 71         | 66.5            |
| 2010 | 67.1      | 61         | 66.8            |
| 2011 | 67.3      | 57         | 66.9            |
| 2012 | 66.2      | 68         | 65.8            |
| 2013 | 65.3      | 70         | 64.8            |
| 2014 | 66        | 74         | 65.4            |
| 2015 | 67.1      | 67         | 66.8            |
| 2016 | 66.7      | 80         | 66.4            |
| 2017 | 67.9      | 74         | 67.6            |
| 2018 | 69.2      | 75         | 68.9            |
| 2019 | 69.9      | 56         | 69.7            |
| 2020 | \-        | \-         | 68.2            |
| 2021 | \-        | \-         | 69.4            |
| 2022 | \-        | \-         | 71              |
