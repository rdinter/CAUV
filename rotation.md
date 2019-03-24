# Rotation

The rotation between corn, soybeans, and wheat come from official USDA data which are automatically downloaded with the [0-data/0-ohio-nass.R](0-data/0-ohio-nass.R) script. These data technically come from [Crop Production Reports](https://usda.mannlib.cornell.edu/MannUsda/viewDocumentInfo.do?documentID=1046). Typically there is an August, September, October, and November forecast. Then [finalized values](https://usda.mannlib.cornell.edu/MannUsda/viewDocumentInfo.do?documentID=1047) occur in January of the following year. The USDA Quick Stats API will incorrectly place the most recent forecast value for the current year in the "YEAR" reference period. This needs to be accounted for.

Rotation is one of the components which does not use Olympic averaging, which makes projecting the component forward more sensitive to new values.

| Tax Year|Rotation  |
|--------:|:---------|
|     2005|ad hoc    |
|     2006|ad hoc    |
|     2007|ad hoc    |
|     2008|ad hoc    |
|     2009|ad hoc    |
|     2010|2004-2008 |
|     2011|2005-2009 |
|     2012|2006-2010 |
|     2013|2007-2011 |
|     2014|2008-2012 |
|     2015|2010-2014 |
|     2016|2011-2015 |
|     2017|2012-2016 |
|     2018|2013-2017 |
|     2019|2014-2018 |
|   Future|previous-5 years ago |
|    Years|5 Average, one year lag |
