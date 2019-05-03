# CAUV Formula Description

There are over 3,500 soil types in Ohio and each of them receives a CAUV value based on its yields for corn, soybeans, and wheat in 1984. The reason for the 1984 distinction is because that was the last time that Ohio received a state-wide comprehensive survey for expected yields of all the soil types with respect to corn, soybeans, and wheat. A brief description of the intent behind the CAUV formula can be described as:

> It is the expected net present value of an acre of land based. To determine this, first a historical average of yields and prices for corn, soybeans, and wheat to determine gross income. Then historical non-land costs -- compliments of The Ohio State University Agricultural Extension Agency -- are subtracted from gross income for a measure of net income. And finally, this net income is divided by a capitalization rate based upon historical values of farm interest and equity rates. This value will vary based upon the particular soil type(s) for a farm.

However, a more comprehensive overview of the calculation of CAUV is necessary and follows. For each soil type ($s$) in Ohio, a particular year's ($t$) CAUV value is calculated as the soil's net income divided by the capitalization rate:

$$
{CAUV}_{s,t} = \frac{NOI_{s,t}}{CAP_{t}}
$$

where $CAP_{t}$ represents the capitalization rate and $NOI_{s,t}$ represents the net operating income. Effectively, the CAUV value represents net present valuation of expected income from agricultural production at the current rates -- although it will be apparent that current rates are not well reflected and it is more appropriate to call it historical from the previous 5 to 10 years worth of data.


# Net Operating Income

Net operating income, $NOI_{s,t}$, captures the average returns to an acre of land under normal management practices which is adjusted by the state-wide rotation pattern of crops. This is defined as:

$$
NOI_{s,t} = \sum_{c} w_{c,t} \times ({GOI}_{s,c,t} - {nonland}_{s,c,t})
$$

where $c$ denotes the crop type, which is either corn, soybeans, or wheat and represents the dominant crops in Ohio. The term $w_{c,t}$ is a crop's share of state production as represented by acres harvested. $GOI_{s,c,t}$ is the gross operating income for a soil type and is calculated for each of the crop types (corn, soybeans, and wheat) based on yields and prices. $nonland_{s,c,t}$ is the non-land costs associated with each crop type. Both of these variables are further explained in the following sections.

### [Rotation](rotation)

Each crop's share of state production, $w_{c,t}$, is based on a 5-year average of total acres harvested between the three crops -- with weights summing to 1. The values are lagged one year -- the 2018 values for crop rotation percentages are based on the 2013 through 2017. Prior to 2015, all of the values were lagged an additional year -- for example the 2014 tax year used values from 2008-2012 for harvested acreage.

## [Non-Land Costs](nonland)

The non-land costs are calculated as 7-year Olympic averages[^olympic] for typical costs of producing each crop (corn, soybeans, and wheat). The [Farm Office](https://farmoffice.osu.edu/farm-management-tools/farm-budgets) at The Ohio State University Extension conducts annual surveys for costs of production which serve as the yearly values used in the CAUV formula. 

[^olympic]: A 7-year Olympic average is a mean of the previous 7 values after first removing the highest and lowest values from calculation.

For the OSU budgets, each year has an associated low, medium, and high projected yield for each crop. With each projected yield, costs are broken down into fixed and variable costs for each crop and each of these serve the basis for the CAUV non-land costs of each soil type.

Prior to 2015, the non-land costs were lagged one year -- i.e. tax year 2014 used the values from 2007 to 2013. From 2015 onward, the current year values are included in the non-land cost calculations. In most years, the official year's values are published in May. All of the costs within a budget report are used with the exception of the management and land rent charges.

A base cost is assigned for each commodity and includes the fixed costs at their Olympic average as well as the variable costs at the lowest yield in the budget reports at their Olympic average. The base cost has an associated base yield for each commodity, which is calculated as an Olympic average of the lowest yield.

However, each soil type has an associated expected yield (explained in the gross income section) and there is an adjustment applied for each commodity if the expected yield is above or below the base yield. Each additional bushel above or below the base yield is multiplied by an additional cost per yield. The additional costs only involve the variable costs but also need the medium yield scenario in each of the budgets in order to calculate the additional costs for an associated bushel.

$$
{Add}_{c,t} = \sum_{i=item} \frac{ {Medium Cost}_{i,c} - {Low Cost}_{i,c} }{ {Medium Yield}_{c} - {Low Yield}_{c} }
$$

Where $i$ is the item on the OSU budget sheet and all values used are the associated 7-year Olympic average. The additional cost is either added on or subtracted from the base cost of each crop type dependent upon the expected yield for a soil type.

## Gross Operating Income

Gross operating income, ${GOI}_{s,c,t}$, is based on historical yields and prices for each crop. The gross operating income across each soil type and crop is defined as:

$$
{GOI}_{s,c,t} = {Price}_{c,Ohio,t} \times \left( \frac{ {Yield}_{c,Ohio,t} }{ {Yield}_{c,Ohio,1984} } \times {Yield}_{c,s,1984} \right)
$$

where $Yield_{c,Ohio,t}$ is an Olympic average for state-wide yields in Ohio and $Price_{c,Ohio,t}$ is a weighted Olympic average for state-wide prices in Ohio. Prior to 2015, both yield and price were lagged two years in its calculation. Since 2015, yields and prices have a one year lag. The prices are based on 7-year Olympic averages while yields are based on a 10-year average. The $Yield_{c,Ohio,1984}$ variable is a state-wide adjustment for the yields of each crop (corn, soybeans, and wheat) in 1984 to account for yield increases. And the $Yield_{c,s,1984}$ is the yield for each soil type ($s$) for each crop in 1984 to account for differences in soil productivity.

Each soil type has an expected yield for each year, which will impact the expected revenues but is also an important note for the cost section as costs rise with yields.

### [Prices](prices)

Prices are based on USDA-NASS end of marketing year data and are weighted based on state production of harvested bushels for each commodity as a way to proxy expected revenues. The price used for each commodity is an Olympic average over the previous 7 years, lagged one year so the 2018 prices involve 2011 to 2017 prices. Once the price-year combinations for each commodity are determined, the price for ODT is determined by by the year's with prices in the Olympic average are then weighted by the bushels produced for each of the years used.

USDA will periodically make revisions to their official values, so it is necessary to double check previous year values reflect the official USDA values for prices and bushels. 

### [Yields](yields)

Each soil type has a corresponding base yield of production for each crop from 1984 -- which is the most recent comprehensive soil survey for the state of Ohio and separate from the base yield of non-land costs. Prior to 2006, ODT did not adjust for yield trends and calculated gross operating income for each soil type via their 1984 yields thus suppressing estimated revenues.

ODT began adjusting for yield trends in 2006 through the current method of taking the 7-year average of state-wide yields (irrespective of soil type), dividing by the state-wide yields for each crop in 1984, then multiplying this value based on the 1984 crop yield for the particular soil type evaluated. Prior to 2014, the 7-year calculation involved a 2 year lag. In 2015 and beyond, there is only a one year lag. In contrast to most of the other calculated values, the yields are not Olympic averaged.


# [Capitalization Rate](caprate)

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