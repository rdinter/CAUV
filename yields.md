# Yields

Each soil type has a corresponding [base yield of production for each commodity from 1984](0-data/soils/offline/pi_dat_orig84.csv) -- which is the most recent comprehensive soil survey for the state of Ohio and separate from the base yield of non-land costs. Prior to 2006, Ohio Department of Taxation (ODT) did not adjust for yield trends and calculated gross operating income for each soil type via their 1984 yields which suppressed revenues -- in the formula this would effectively mean that the $\widehat{Yield_{c,Ohio,t}}$ equaled $Yield_{c,Ohio,1984}$ instead of varying:

$$
Adjustment_{c,s,t} = \left( \frac{\widehat{Yield_{c,Ohio,t}}}{Yield_{c,Ohio,1984}} \times Yield_{c,s,1984} \right)
$$

ODT began adjusting for yield trends through the current method of taking the 10-year averages of state-wide yields (irrespective of soil type), dividing by the state-wide yields for each commodity in 1984, then multiplying this value based on the 1984 commodity yield for the particular soil type evaluated. This can be thought of as an adustment factor to account for the general trend of increasing yields in corn, wheat, and soybeans. Prior to 2014, the 10-year calculation involved a two year lag -- i.e. the 2014 tax year used average yield values from 2003 through 2012. In 2015 and beyond, there is only a one year lag -- i.e. 2015 tax year used average yield values from 2005 through 2014. For each crop in a given CAUV year, this can be mathematically described as:

$$
\widehat{Yield_{c,Ohio,t}} = \sum_{i = 0}^{9} \frac{Yield_{c, Ohio, t - i - lag}}{10}
$$

The yields for corn, soybeans, and wheat come from official USDA data which are automatically downloaded with the [0-data/0-ohio-nass.R](0-data/0-ohio-nass.R) script. These data technically come from [Crop Production Reports](https://usda.mannlib.cornell.edu/MannUsda/viewDocumentInfo.do?documentID=1046). Typically there is an August, September, October, and November forecast. Then [finalized values](https://usda.mannlib.cornell.edu/MannUsda/viewDocumentInfo.do?documentID=1047) occur in January of the following year. The USDA Quick Stats API will incorrectly place the most recent forecast value for the current year in the "YEAR" reference period. This needs to be accounted for.

Yields are one of the components which does not use Olympic averaging, which makes projecting the component forward more sensitive to new values.

| Tax Year|Yields    |
|--------:|:---------|
|     2005|1984      |
|     2006|1995-2004 |
|     2007|1996-2005 |
|     2008|1997-2006 |
|     2009|1998-2007 |
|     2010|1999-2008 |
|     2011|2000-2009 |
|     2012|2001-2010 |
|     2013|2002-2011 |
|     2014|2003-2012 |
|     2015|2005-2014 |
|     2016|2006-2015 |
|     2017|2007-2016 |
|     2018|2008-2017 |
|     2019|2009-2018 |
|   Future|previous-11 years ago |
|    Years|10 Average, one year lag |
