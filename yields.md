# Yields

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
