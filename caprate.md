# Capitalization Rate

The values used for the calculation of the capitalization rate need to know what the values for an equity and interest end up being. Further, the split between a loan and equity versus years expected the term.

## Update Dates

Data source for the interest is from Farm Credit Services for a 25-year term on a loan \$75,000 and over while the equity rate comes from [USDA-ERS](https://www.ers.usda.gov/data-products/farm-income-and-wealth-statistics/) which has updates each year in February (should be considered "official"), August, and November. It is not clear if the Farm Credit Services produces their historical values of interest rates on a 25-year term loan or when this value is selected by the ODT.

## Calculations

The calculation procedure of the capitalization rate has had a few changes since 2005, which can be summarized for each year as follows:


| Tax Year|Interest Rate       | Equity Rate      | Loan Pct. | Term    | Sinking |
|--------:|:-------------------|:-----------------|:----------|:--------|:--------|
|     2005|1999-2005           |1999-2005         | 60%       | 15 year | 5 year  |
|     2006|2000-2006           |2000-2006         | 60%       | 15 year | 5 year  |
|     2007|2001-2007           |2001-2007         | 60%       | 15 year | 5 year  |
|     2008|2002-2008           |2002-2008         | 60%       | 15 year | 5 year  |
|     2009|2003-2009           |2003-2009         | 60%       | 15 year | 5 year  |
|     2010|2004-2010           |2004-2010         | 60%       | 15 year | 5 year  |
|     2011|2005-2011           |2005-2011         | 60%       | 15 year | 5 year  |
|     2012|2006-2012           |2006-2012         | 60%       | 15 year | 5 year  |
|     2013|2007-2013           |2007-2013         | 60%       | 15 year | 5 year  |
|     2014|2008-2014           |2008-2014         | 60%       | 15 year | 5 year  |
|     2015|2009-2015           |2009-2015         | 80%       | 25 year | 5 year  |
|     2016|2010-2016           |2010-2016         | 80%       | 25 year | 5 year  |
|     2017|2011-2017           |1991-2015         | 80%       | 25 year | 25 year |
|     2018|2012-2018           |1992-2016         | 80%       | 25 year | 25 year |
|     2019|2013-2019           |1993-2017         | 80%       | 25 year | 25 year |
|   Future|current-6 years ago |2lag-26 years ago | 80%       | 25 year | 25 year |
|    Years|7 Olympic           |25 Average        |           |         |         |



The capitalization rate requires the knowledge of an interest rate on a loan and an equity rate as well as the term and debt percentage for determining from the [Mortgage-Equity Method](http://www.commercialappraisalsoftware.dcfsoftware.com/mtgequity.htm). But it can be defined as:

$$\begin{aligned}
{CAP_t} &= {Loan \%}_t \times {Annual Debt Service}_t + \\
& {Equity \%}_t \times {Equity Yield}_t - \nonumber \\
& {Buildup}_t + \nonumber \\
& {Tax Additur Adjustment}_t \nonumber
\end{aligned}$$


The ${Loan \%}_t$ plus ${Equity \%}_t$ must equal one and is currently an 80% to 20% ratio respectively. Prior to 2015, the values were based on 60% loan and 40% equity appreciation.


${Annual Debt Service}_t$ is a debt servicing factor based on a 25-year term mortgage with an associated interest rate. The interest rate used for a particular year is based on a 7-year Olympic average where the value for the loan interest rate came from a 25-year mortgage from Farm Credit Services (FCS). Prior to 2015, a 15-year term was used instead of 25 and there were no lags in this formula. For example, the 2017 interest rate used comes from FCS values between 2011 and 2017. The formula for calculating the debt servicing factor with $r$ as the interest rate (from FCS) and $n$ the term length (currently 25) is:

$$ {Annual Debt Service} = \frac{r \times (1 + r)^n}{(1 + r)^n - 1} $$

Next, the ${Equity Yield}_t$ needs to be calculated -- which is simply the interest rate associated with equity that a farmer may hold. Prior to 2017, the equity yield was a 7-year Olympic average of the prime rate plus 2% from the Wall Street Journal's bank survey -- with no lag for the values. In 2017, the ODT switched the equity yield to be a two year lagged 25-year average of the "Total rate of return on farm equity" from the [Economic Research Services](https://data.ers.usda.gov/reports.aspx?ID=17838) of the USDA. For example, the 2017 value used the ERS's values from 1991 to 2015.

Then, the equity buildup associated with a set time frame needs to be calculated. The equity buildup formula involves an associated interest rate (the ${Equity Yield}_t$ is used here as $r$) and a time-frame $n$, which is set at 25 years currently (prior to 2017, this was set at 5 years of equity buildup):

$$ {Buildup}_t = {Equity \%}_t \times {Mortgage Paid \%}_t \times \frac{r}{(1 + r)^n - 1} $$

For 2017 and beyond, the ${Mortgage Paid \%}_t$ is assumed to be 100%. However, prior to 2017 this value needed to be calculated as the percentage of mortgage paid after 5 years. The mortgage term was needed to determine what the mortgage paid after 5 years would be. For 2015 and beyond the mortgage terms have been for 25 years while prior to 2015 the mortgage term was for 15 years. The formula for calculating the percentage of the mortgage paid off after 5 years is:

$$ {Mortgage Paid \%}_t = \frac{ \frac{1}{ (1 + r)^{n-5} } - \frac{1}{ (1 + r)^n} }{ 1 - \frac{1}{(1 + r)^n} } $$

Where $r$ is the interest rate and $n$ is the term of the loan.

<!--- in addition, --->

And finally, the ${Tax Additur Adjustment}_t$ needs to be calculated. The tax additur is added onto the capitalization rate as a way to proxy for property taxes as a ratio to market value. The statewide average effective tax rate on agricultural land, as determined through table [DTE27](https://www.tax.ohio.gov/tax_analysis/tax_data_series/publications_tds_property.aspx#Allpropertytaxes), from the previous tax year is used in calculation for the tax additur in question. The statewide average effective tax rate is expressed in terms of mills and the tax additur is then expressed as:

$$ {Tax Additur Adjustment}_t = \frac{0.35 \times {Statewide Millage}_{t-1} }{1000} $$

<!--- The ODT does not release table DTE27 until around the same time that --->