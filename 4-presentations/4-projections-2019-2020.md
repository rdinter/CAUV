---
title: "Ohio CAUV Value Projections for 2019 and 2020"
subtitle:  | 
  | Department of Agricultural, Environmental and Development Economics,
  | The Ohio State University
author:
- Robert Dinterman^[Post-Doctoral Researcher] and Ani L. Katchova^[Associate Professor and Farm Income Enhancement Chair]
date: "2019-04-30"
output:
  html_document:
    keep_md: yes
  word_document: default
  pdf_document:
    fig_caption: yes
    keep_tex: yes
header-includes: \usepackage{float}
---







# Key Findings

The purpose of this report is to provide projections for 2019 and 2020 for the CAUV values of all soil types in Ohio enrolled in the Current Agricultural Use Value Program (CAUV). Further, the CAUV formula that is used to calculate CAUV values based on soil types is explained, along with the components of the formula and the assumptions that are used to make expected, high, and low CAUV value projections for 2019 and 2020. Recent legislation passed in 2017 made changes to CAUV calculations, which are detailed here as well as previous procedures and current methodology. We explain the current methodology for calculating CAUV values and how these projections were made. We used ODT descriptions of calculations, the [Ohio Code of legislation](http://codes.ohio.gov/orc/5713.31) on CAUV, and the [phase-in legislation](http://codes.ohio.gov/orc/5715.01) for the new calculations.

**Key Findings**

- Anticipating a decrease in the average CAUV value across all soil types in Ohio to approximately $870 in the 2019 tax year. This represents a -14% change from the average 2018 CAUV value of $1,015.
- The 2019 tax year is the third year of the phase-in from large-scale changes in the calculation of CAUV values. If the phase-in procedure was not in place, then the average 2019 CAUV values would have further dropped to approximately $730.
- Due to uncertainty in finalized input data used in our 2019 CAUV calculations, it is possible for the average CAUV value to change from 2018 average CAUV value by as much as -23% while it is also possible for the average CAUV value to rise by over 27%. However, an increase in CAUV values for 2019 is unlikely.
- Current CAUV projections for the 2020 tax year, which represents the first year without the phased-in procedure, expects a further decline in the average CAUV value to $585 which would be a 14% change from current projections in 2019.
- Due to uncertainty in finalized input data used in our 2020 CAUV calculations, it is possible for the average CAUV value to change from 2019 average CAUV value by as much as -42% while it is also possible for the average CAUV value to rise by over 6%. However, an increase in CAUV values for 2020 is unlikely.

\newpage

# CAUV Value Projections for 2019 and 2020

In 2018, the average CAUV value across all soil types was $1,015 per Ohio Department of Taxation (ODT). Our projection for the average value of CAUV in the 2019 tax year is $872. Our projections for the 2019 average CAUV values could have a high of $1,287 and a low of $787 based on current available information and the nature of how certain components in the CAUV formula use Olympic averaging -- however with as much information currently known these high/low scenarios are unlikely and we anticipate only slight divergences from average CAUV value projection of $872. ODT provides [general information](https://www.tax.ohio.gov/real_property/cauv.aspx) on their calculations for CAUV and how they calculate the CAUV value for each soil type across Ohio although this document will also describe the calculation procedure. Their information also includes the official values of inputs that ODT uses in the formula for CAUV values and is the only official documentation and values for CAUV.

CAUV values contain 5 major components used as inputs for projecting values: capitalization rate, commodity yields, commodity prices, commodity acreage/rotation, and nonland input costs. The commodities used in CAUV are corn, soybeans, and wheat.

Our expectations for the CAUV values for the 2019 tax year are for the components of commodity yields, commodity rotation, and capitalization rate to remain largely unchanged from 2018. Input costs are expected to decline, although this is counteracted with commodity prices similarly expected to decline. Current data on these early data on these inputs into the CAUV formula still being uncertain as of today. Under the expectation scenario, the average CAUV value will continue to decline by a similar proportion as the fall in the CAUV values from 2016 to 2017 to 2018. Grouping soil types based on a productivity index can help display how similarly productive soils are expected to decline in our 2019 projections:

<div class="figure">
<img src="4-projections-2019-2020_files/figure-html/exp-trend-1.png" alt="\label{fig:exp-trend}" width="100%" />
<p class="caption">\label{fig:exp-trend}</p>
</div>

Our projected CAUV values are partially offset by the current provision in the CAUV calculations that phases in the new formula for CAUV, smoothing the adjustment to lower CAUV values the one cycle of property reassessment rather than these declines occurring immediately. Counties in Ohio have a set schedule for receiving new CAUV values along with updates to their other assessed values of property.

The 2018 values had an adjustment factor where only half of the difference was included between the 2017 CAUV value and what the pre-adjusted 2018 CAUV would have been. This also occurs for 2019, where if the calculated CAUV value in 2019 is lower than the 2018 CAUV value for a soil type then only half of the difference is factored into the actual 2019 CAUV value. While the projected average CAUV value for 2019 is $872, the value would have been $729 without the phase-in. Figure \ref{fig:exp-2019} shows how much this adjustment for phasing in of the new calculations differ by soil types:

<div class="figure">
<img src="4-projections-2019-2020_files/figure-html/exp-2019-1.png" alt="\label{fig:exp-2019}" width="100%" />
<p class="caption">\label{fig:exp-2019}</p>
</div>

This adjustment procedure will not be present in tax year of 2020 and beyond as the phase-in was only intended to affect one one set of phased-in values based on the triennial update of property assessments. Because of this, we have further pushed our projections for the 2020 tax year by extending each component in the CAUV calculation an additional year with as much of the available data as possible. Our preliminary results indicate stable values for commodity yields, commodity rotation, and capitalization to remain similar to our projections for 2019. Further, the input costs and commodity prices are anticipated to further decline with a more pronounced decline for prices than input costs. At this time, our expected projections for the 2020 tax year are:

<div class="figure">
<img src="4-projections-2019-2020_files/figure-html/exp-trend-2020-1.png" alt="\label{fig:exp-trend-2020}" width="100%" />
<p class="caption">\label{fig:exp-trend-2020}</p>
</div>


# Current Agricultural Use Value Program Overview

In 1974, Ohio enacted the Current Agricultural Use Value Program (CAUV) as a tax incentive for farmers to continue agricultural production on their land instead of selling it due to urbanization pressure. CAUV provides an appraisal method for valuing agricultural land by use of only agricultural inputs rather than the market value of land. Throughout the 1970s, other states adopted similar programs of differential appraisal methods of agricultural land and, as of 2014, all 50 states within the US provide some form of differential tax treatment of agricultural land. While each state has its own reason for enacting preferential tax treatment and its particular calculation, the intent behind differential taxation is generally understood as applying a net present valuation of agricultural production that is not tied to potential urbanization development pressures. Ohio is no different and has developed its own calculation method that depends on soil quality, commodity yields/prices/rotation, operational costs, and capitalization rate. The basic premise has been in place since the late 1970s although the program has become more sophisticated and received substantial updates in 2006, 2015, and most recently in 2017 that have affected the calculation of CAUV.

No matter what commodity a farmer produces, their CAUV value is determined solely based on their soil type and a formula from the Ohio Department of Taxation (ODT) which aims to represent the expected returns for an average farmer in Ohio. A simplified version of the calculation can be stated as:

> The CAUV value is the expected net present value of an acre of land based on expected net income of the land used for agricultural purposes. To determine this, first a historical average of yields and prices for corn, soybeans, and wheat is used to determine gross income. Then historical non-land costs -- provided by The Ohio State University Extension -- are subtracted from gross income for a measure of net income. And finally, this net income is divided by a capitalization rate based upon historical values of farm interest and equity rates. This CAUV value will vary based upon the particular soil type(s) for a farm.

For agricultural land to be eligible for CAUV, it must either be at least 10 acres devoted exclusively to commercial agricultural use or be able to produce more than \$2,500 in average gross income. The general trend for the state of Ohio since the 1980s has been a steady increase in the total acreage enrolled in CAUV, although there have been declines in enrolled CAUV acreage for areas under urbanization pressure as farmland is converted to residential or commercial purposes. When a land owner decides to unenroll from CAUV for this purpose, they must pay a recoupment penalty that is equal to the CAUV tax savings for the previous 3 tax years -- i.e. the difference between the market value and CAUV value.

## CAUV Value Formula

For each of the over 3,500 soil types ($s$) in Ohio, a particular year's ($t$) CAUV value is calculated as the soil's net income divided by the capitalization rate:

$$
CAUV_{s,t} = \frac{NOI_{s,t}}{CAP_t} \label{eq:cauv}
$$

where $CAP_t$ represents the capitalization rate and $NOI_{s,t}$ represents the net operating income based on revenues less non-land costs for corn, soybeans, and wheat.


## Net Operating Income

Net operating income, ${NOI_{s,t}}$, captures the average returns to an acre of land under normal management practices which is adjusted by the state-wide rotation pattern of crops. This is defined as:

$$
NOI_{s,t} = \sum_{c} w_{c,t}\times(GOI_{s,c,t} - {nonland}_{s,c,t})
$$

where $c$ denotes the crop type, which is either corn, soybeans, or wheat which represent the dominant crops in Ohio and $w_{c,t}$ is crop's share of state production. $GOI_{s,c,t}$ is the gross operating income for a soil type and is calculated for each of the crop types (corn, soybeans, and wheat) based on yields and prices. ${nonland}_{s,c,t}$ is the non-land costs associated with each crop type. Both of these variables are further explained in the following sections.

### Rotation

Each crop's share of state production is based on a 5-year average of total acres harvested between the three crops -- with weights summing to 1. These data technically come from the United States Department of Agriculture (USDA) [Crop Production Reports](https://usda.mannlib.cornell.edu/MannUsda/viewDocumentInfo.do?documentID=1046). Typically there is an August, September, October, and November forecast for Ohio's corn, soybeans, and wheat acreage with the [finalized values](https://usda.mannlib.cornell.edu/MannUsda/viewDocumentInfo.do?documentID=1047) occuring in January of the following year (ie 2018 harvested acres was finalized in January 2019). The values are lagged one year -- the 2019 values for crop rotation percentages are based on the 2014 through 2018 harvested acreage which is known at this time but the 2020 value will will use the 2018 harvested acreage for a preliminary estimate of 2019 harvested acreage. 

The values of rotation used in ODT calculations since 2010 are displayed in the following tables \ref{tab:corn-rot}, \ref{tab:soy-rot}, and \ref{tab:wheat-rot} along with the values used in our 2019 and 2020 CAUV value projections.


Table: Historical Corn Rotation

 Year  ODT Value   USDA Acres Harvested   AVG Acres Harvested   Projected 
-----  ----------  ---------------------  --------------------  ----------
 2010  39.0%       3,270,000              3,210,000             37.7%     
 2011  38.6%       3,200,000              3,216,000             37.7%     
 2012  38.6%       3,650,000              3,220,000             37.7%     
 2013  38.7%       3,740,000              3,268,000             38.1%     
 2014  38.6%       3,480,000              3,276,000             38.1%     
 2015  40.0%       3,260,000              3,468,000             40.2%     
 2016  40.2%       3,300,000              3,466,000             40.1%     
 2017  40.0%       3,150,000              3,486,000             40.3%     
 2018  39.0%       3,300,000              3,386,000             39.0%     
 2019  NA%         NA                     3,298,000             38.0%     
 2020  NA%         NA                     3,264,639             37.6%     


Table: Historical Soy Rotation

 Year  ODT Value   USDA Acres Harvested   AVG Acres Harvested   Projected 
-----  ----------  ---------------------  --------------------  ----------
 2010  51.0%       4,590,000              4,448,000             52.2%     
 2011  50.9%       4,540,000              4,470,000             52.4%     
 2012  51.1%       4,590,000              4,492,000             52.6%     
 2013  51.2%       4,490,000              4,476,000             52.2%     
 2014  52.0%       4,690,000              4,546,000             52.9%     
 2015  52.6%       4,740,000              4,580,000             53.1%     
 2016  53.0%       4,840,000              4,610,000             53.4%     
 2017  54.0%       5,090,000              4,670,000             53.9%     
 2018  55.0%       4,980,000              4,770,000             55.0%     
 2019  NA%         NA                     4,868,000             56.1%     
 2020  NA%         NA                     4,919,894             56.7%     


Table: Historical Wheat Rotation

 Year  ODT Value   USDA Acres Harvested   AVG Acres Harvested   Projected 
-----  ----------  ---------------------  --------------------  ----------
 2010  10.0%       700,000                900,000               10.6%     
 2011  10.5%       850,000                912,000               10.7%     
 2012  10.3%       450,000                886,000               10.4%     
 2013  10.1%       640,000                864,000               10.1%     
 2014  9.4%        545,000                808,000               9.4%      
 2015  7.4%        480,000                637,000               7.4%      
 2016  6.8%        560,000                593,000               6.9%      
 2017  6.0%        460,000                535,000               6.2%      
 2018  6.0%        450,000                537,000               6.2%      
 2019  NA%         NA                     499,000               5.7%      
 2020  NA%         NA                     486,947               5.6%      

\newpage

### Non-Land Costs

The non-land costs are calculated as 7-year Olympic averages for typical costs of producing each crop (corn, soybeans, and wheat). The [Farm Office](https://farmoffice.osu.edu/farm-management-tools/farm-budgets) at The Ohio State University Extension conducts annual surveys for costs of production which serve as the yearly estimates that are used in the 7-year Olympic average. Prior to 2015, the non-land costs were lagged one year -- i.e. tax year 2014 used the values from 2007 to 2013. From 2015 onward, the current year values are included in the non-land cost calculations. Because of the nature of an Olympic average, the non-land costs used in 2019 CAUV is bounded between a "high" and a "low" value by averaging the previous 6-years after dropping only the highest or lowest value respectively. We calculate these values to place bounds on the non-land costs of each commodity. The historical and projected values are displayed in figure \ref{fig:viz-nonland}:

<div class="figure">
<img src="4-projections-2019-2020_files/figure-html/viz-nonland-1.png" alt="\label{fig:viz-nonland}" width="100%" />
<p class="caption">\label{fig:viz-nonland}</p>
</div>

A base cost is assigned for each commodity and is the same across all soil types. The base cost has an associated base yield for each commodity, which is calculated from the budget reports of OSU Extension. However, each soil type has an associated expected yield (explained in the following section) and there is an adjustment applied for each commodity if the expected yield is above or below the base yield. Each additional yield above or below the base yield is multiplied by an additional cost per yield -- which is calculated in the same manner as the base costs with a 7-year Olympic average. However, these additional costs vary across soil types which makes it difficult to present for all soil types.

In the event that the "high" value of our projected non-land costs occur, then this is where the 2019 non-land costs are all the lowest values in the previous 7-years and causes the CAUV to be a higher value. The opposite is true for the "low" value in that the non-land costs are all 7-year highs.

Tables \ref{tab:corn-base}, \ref{tab:corn-add}, \ref{tab:soy-base}, \ref{tab:soy-add}, \ref{tab:wheat-base}, and \ref{tab:wheat-add}

Our projection of non-land base costs for corn is ; for soybeans is ; and for wheat is  per acre for 2019.

\newpage


Table: Historical Corn Base Costs

 Year  ODT Base Cost   Projection   Low Projection   High Projection 
-----  --------------  -----------  ---------------  ----------------
 2006  $232.83         $NA          $NA              $NA             
 2007  $235.70         $NA          $NA              $NA             
 2008  $242.39         $258.44      Inf              Inf             
 2009  $264.12         $265.18      Inf              Inf             
 2010  $286.65         $293.13      Inf              Inf             
 2011  $300.98         $315.04      Inf              Inf             
 2012  $350.71         $350.94      $365.42          $308.26         
 2013  $391.90         $393.31      $404.50          $348.09         
 2014  $437.85         $438.22      $449.28          $388.52         
 2015  $516.99         $518.46      $536.31          $483.59         
 2016  $524.47         $526.74      $545.30          $502.49         
 2017  $538.78         $540.77      $559.88          $521.58         
 2018  $529.28         $532.45      $561.46          $527.62         
 2019  $NA             $519.19      $553.37          $509.98         
 2020  $NA             $500.25      $532.23          $493.05         


Table: Historical Corn Additional Costs

 Year  ODT Add Cost   Projection   Low Projection   High Projection 
-----  -------------  -----------  ---------------  ----------------
 2006  $0.92          $NA          $NA              $NA             
 2007  $0.91          $NA          $NA              $NA             
 2008  $0.90          $0.77        $NaN             $NaN            
 2009  $0.72          $0.75        $NaN             $NaN            
 2010  $0.83          $0.86        $NaN             $NaN            
 2011  $0.84          $0.90        $NaN             $NaN            
 2012  $0.90          $0.97        $1.05            $0.90           
 2013  $1.04          $1.07        $1.16            $0.95           
 2014  $1.18          $1.22        $1.28            $1.06           
 2015  $1.36          $1.36        $1.44            $1.24           
 2016  $1.38          $1.39        $1.44            $1.30           
 2017  $1.45          $1.47        $1.54            $1.40           
 2018  $1.44          $1.44        $1.52            $1.42           
 2019  $NA            $1.41        $1.53            $1.34           
 2020  $NA            $1.39        $1.49            $1.33           


Table: Historical Soybeans Base Costs

 Year  ODT Base Cost   Projection   Low Projection   High Projection 
-----  --------------  -----------  ---------------  ----------------
 2006  $167.50         $NA          $NA              $NA             
 2007  $168.14         $NA          $NA              $NA             
 2008  $174.44         $182.17      Inf              $NaN            
 2009  $175.21         $183.11      $NaN             $NaN            
 2010  $189.10         $201.60      $NaN             $NaN            
 2011  $204.60         $213.63      $NaN             $NaN            
 2012  $227.51         $227.08      $238.74          $205.49         
 2013  $248.69         $247.71      $254.49          $222.50         
 2014  $275.21         $273.55      $281.53          $245.24         
 2015  $325.42         $326.03      $336.94          $304.40         
 2016  $336.33         $336.63      $346.37          $317.49         
 2017  $347.10         $346.25      $358.49          $332.90         
 2018  $346.26         $346.69      $362.95          $338.83         
 2019  $NA             $338.88      $360.66          $330.01         
 2020  $NA             $329.95      $349.23          $322.37         


Table: Historical Soybeans Additional Costs

 Year  ODT Add Cost   Projection   Low Projection   High Projection 
-----  -------------  -----------  ---------------  ----------------
 2006  $0.49          $NA          $NA              $NA             
 2007  $0.49          $NA          $NA              $NA             
 2008  $0.50          $0.56        $NaN             $NaN            
 2009  $0.57          $0.56        $NaN             $NaN            
 2010  $0.66          $0.74        $NaN             $NaN            
 2011  $0.77          $0.82        $NaN             $NaN            
 2012  $0.93          $0.99        $1.13            $0.80           
 2013  $1.12          $1.15        $1.29            $0.95           
 2014  $1.27          $1.25        $1.43            $1.10           
 2015  $1.24          $1.16        $1.33            $1.14           
 2016  $1.07          $1.07        $1.14            $1.06           
 2017  $1.05          $1.04        $1.13            $1.04           
 2018  $0.94          $0.95        $1.03            $0.93           
 2019  $NA            $0.92        $0.99            $0.83           
 2020  $NA            $0.91        $0.96            $0.84           


Table: Historical Wheat Base Costs

 Year  ODT Base Cost   Projection   Low Projection   High Projection 
-----  --------------  -----------  ---------------  ----------------
 2006  $151.98         $NA          $NA              $NA             
 2007  $153.67         $NA          $NA              $NA             
 2008  $156.68         $158.26      Inf              $NaN            
 2009  $159.01         $161.53      Inf              $NaN            
 2010  $170.16         $179.55      Inf              $NaN            
 2011  $192.94         $191.57      Inf              $NaN            
 2012  $211.52         $206.18      $218.09          $187.90         
 2013  $230.62         $227.70      $235.39          $205.19         
 2014  $255.48         $257.51      $268.56          $226.37         
 2015  $296.98         $291.15      $302.89          $265.46         
 2016  $323.52         $320.21      $330.25          $296.77         
 2017  $336.21         $336.08      $348.08          $316.21         
 2018  $330.53         $331.13      $349.74          $326.08         
 2019  $NA             $319.52      $341.07          $311.39         
 2020  $NA             $307.73      $328.28          $302.81         


Table: Historical Wheat Additional Costs

 Year  ODT Add Cost   Projection   Low Projection   High Projection 
-----  -------------  -----------  ---------------  ----------------
 2006  $0.87          $NA          $NA              $NA             
 2007  $0.81          $NA          $NA              $NA             
 2008  $0.84          $0.84        $NaN             $NaN            
 2009  $0.86          $0.86        $NaN             $NaN            
 2010  $1.14          $1.13        $NaN             $NaN            
 2011  $1.19          $1.24        $NaN             $NaN            
 2012  $1.41          $1.45        $1.55            $1.24           
 2013  $1.61          $1.66        $1.73            $1.45           
 2014  $1.80          $1.84        $1.92            $1.64           
 2015  $1.77          $1.76        $1.88            $1.73           
 2016  $1.64          $1.64        $1.75            $1.62           
 2017  $1.62          $1.62        $1.74            $1.63           
 2018  $1.49          $1.49        $1.65            $1.47           
 2019  $NA            $1.39        $1.54            $1.30           
 2020  $NA            $1.33        $1.45            $1.26           

\newpage


## Gross Operating Income

Gross operating income, $GOI_{s,c,t}$, is based on historical yields and prices for each crop. The gross operating income across each soil type and crop is defined as:

$$
GOI_{s,c,t} = \frac{Yield_{c,Ohio,t}}{Yield_{c,Ohio,1984}} \times Yield_{c,s,1984} \times Price_{c,Ohio,t}
$$

where $Yield_{c,Ohio,t}$ is an Olympic average for state-wide yields in Ohio and $Price_{c,Ohio,t}$ is a weighted Olympic average for state-wide prices in Ohio. Prior to 2015, both yield and price were lagged two years in its calculation and yields were based on a 10-year Olympic average. Since 2015, yields and prices have a one year lag and yields are now based on 7-year Olympic averages. The $Yield_{c,Ohio,1984}$ variable is a state-wide adjustment for the yields of each crop (corn, soybeans, and wheat) in 1984 to account for yield increases. And the $Yield_{c,s,1984}$ is the yield for each soil type ($s$) for each crop in 1984 to account for differences in soil productivity.

### Prices

Prices are based on USDA-NASS data and are weighted based on state production to proxy revenues. The yearly crop prices since 1991 and values used in ODT calculations since 2006 can be seen in figure \ref{fig:prices} along with the projected prices.

Due to the nature of Olympic averaging, the "high" and "low" projections for commodity prices can be determined for the 2019 tax year value even though the 2017 price data are not available yet. These projections are displayed as numerical values in figure \ref{fig:prices}.

<div class="figure">
<img src="4-projections-2019-2020_files/figure-html/viz-prices-1.png" alt="\label{fig:prices}" width="100%" />
<p class="caption">\label{fig:prices}</p>
</div>

In the event that the "high" value of our projected commodity prices arises, then this is where the 2019 prices are all the highest values in the previous 7-years and causes the CAUV to be a higher value. The opposite is the scenario of a "low" CAUV where the 2017 commodity prices are the lowest values in the past 7 years. If the 2017 CAUV values utilized these prices, then the "high" value would lead to an average CAUV of $NA while the "low" value would have been $NA. These are of course in comparison to the actual value of $1,153 in 2017.

The crop prices for 2017 will not be known until later in 2019 when each commodities marketing year ends, however it is highly unlikely for the 2017 prices to be markedly different from their 2016 values. Due to this known information, the 2019 projected prices are: $0 per bushel for corn, $0 per bushel for soybeans, and $0 per bushel for wheat.

### Yields

Each soil type has a corresponding base yield of production for each crop from 1984 -- which is the most recent comprehensive soil survey for the state of Ohio and separate from the base yield of non-land costs. Prior to 2006, ODT did not adjust for yield trends and calculated gross operating income for each soil type via their 1984 yields thus suppressing estimated revenues. ODT began adjusting for yield trends through the current method of taking the 7-year Olympic average of state-wide yields (irrespective of soil type), dividing by the state-wide yields for each crop in 1984, then multiplying this value based on the 1984 crop yield for the particular soil type evaluated. Prior to 2014, the 7-year calculation involved a 2 year lag. In 2015 and beyond, there is only a one year lag. Therefore, the yield value for CAUV in 2017 was based on an Olympic average of yields of 2007 through 2016.

The values for commodity yields for tax year 2019 are known because USDA has published their 2017 values for each commodity and are displayed in figure \ref{fig:yields}:

<div class="figure">
<img src="4-projections-2019-2020_files/figure-html/viz-yields-1.png" alt="\label{fig:yields}" width="100%" />
<p class="caption">\label{fig:yields}</p>
</div>

## Capitalization Rate

Prior to 2015, the capitalization rate was based on a 60\% loan and 40\% equity appreciation with interest rates for each value based on a 7-year Olympic average[^olympic] where the value for the loan interest rate came from a 15-year mortgage from Farm Credit Services (FCS) and the equity interest rate was the Federal Funds rate plus two percentage points. Both of these interest rates use the current tax year's value in calculation so the value calculated for 2014 was an Olympic average over the years 2008 through 2014. This loan/equity mix is calculated and then 5 years of equity buildup and appreciation are subtracted from the interest rate plus a tax additur -- the average effective tax rate for agricultural land applied at 35\% of the market value.

[^olympic]: A 7-year Olympic average is a mean of the previous 7 values after first removing the highest and lowest values from calculation.

For the 2015 tax year, the capitalization rate changed to an 80\% loan (based on 25-year mortgage from FCS) and 20\% equity appreciation. Then in 2017, ODT changed the interest rate used for equity appreciation to the 25-year average total rate of return on farm equity from USDA-ERS -- this amount is lagged two years so the 2017 value is based on 1991 through 2015 values. The loan interest rate remains a 7-year Olympic average that is not lagged, so the 2017 interest rate used values from 2011 through 2017. The formula dropped appreciation from calculations and changed the equity buildup calculation from 5 years to 25 years.

The capitalization rate requires the knowledge of an interest rate on a loan and an equity rate as well as the term and debt percentage for determining from the [Mortgage-Equity Method](http://www.commercialappraisalsoftware.dcfsoftware.com/mtgequity.htm). But it can be defined as:

$$
\begin{align}
{CAP_t} &= {Loan \%}_t \times {Annual Debt Service}_t + \\
& {Equity \%}_t \times {Equity Yield}_t - \nonumber \\
& {Buildup}_t + \nonumber \\
& {Tax Additur Adjustment}_t \nonumber
\end{align}
$$


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


The tax additur component remained in the calculation and between 2006 and 2017 it ranged from 1.30% to 1.60%.

The capitalization rates used by the ODT in CAUV calculations since 2003 are displayed in figure \ref{fig:viz-cap}, which shows a steady decline until the formula change in 2015. The projected capitalization rate for 2019 is 8.0% and in 2020 the projected value is 8.0%.

In addition, the scenarios for a "high" and "low" capitalization rate in 2019 and 2020 are numerically displayed in red and blue respectively. A "high" scenario implies the highest potential CAUV values, which would be a lower capitalization rate because the capitalization rate is in the denominator of the formula for CAUV. Vice-versa for the "low" projection of CAUV value. These scenarios utilize the Olympic averages which will always drop the highest and lowest values for the previous 7 years. Since the 2019 FCS interest is unknown, the "high" ("low") scenario assumes that the 2019 interest rate will be 0 (infinite) and calculates the value used in ODT calculations for this. The "high" value of our projected capitalization rate of 7.80% leads to a high CAUV value whereas our capitalization rate is 8.14% for a "low" CAUV value.

<div class="figure">
<img src="4-projections-2019-2020_files/figure-html/viz-cap-1.png" alt="\label{fig:viz-cap}" width="100%" />
<p class="caption">\label{fig:viz-cap}</p>
</div>

Of the capitalization rate projections, only the tax additur and FCS interest rate are currently unknown for 2019 and beyond. The equity appreciation rate is already known because USDA-ERS has published their 2017 value for total rate of return on farm equity -- thus allowing for the 2019 tax year calculation. The 25-year mortgage from FCS uses a 7-year Olympic average, which allows for a "high" and "low" CAUV value projection. The tax additur is reported by the ODT for that particular tax year -- in lieu of utilizing the Olympic average and this projection uses a +/- 0.1\% range with the tax additur from the 2018 value.


Table: Historical Capitalization Rates

 Year  ODT Value   Projected   Low    High 
-----  ----------  ----------  -----  -----
 2010  7.8%        7.8%        8.0%   7.7% 
 2011  7.6%        7.6%        7.8%   7.4% 
 2012  7.5%        7.5%        7.7%   7.2% 
 2013  6.7%        6.7%        7.0%   6.6% 
 2014  6.2%        6.2%        6.6%   6.2% 
 2015  6.6%        6.6%        6.9%   6.4% 
 2016  6.3%        6.3%        6.6%   6.2% 
 2017  8.0%        8.0%        8.2%   7.8% 
 2018  8.0%        8.0%        8.1%   7.8% 
 2019  NA%         8.0%        8.1%   7.8% 
 2020  NA%         8.0%        8.1%   7.8% 


## CAUV Values by Soil Type

Effectively, every soil type throughout Ohio is assigned a CAUV value each year that is dependent on average corn, soybeans, and wheat revenues less costs over the previous 7 to 10 years. Soil types that have higher productive capacity -- based on 1984 values -- will have higher CAUV values than those with lower productivity. However, some soil types are relatively more productive with respect to one crop than the others.

ODT provides a comprehensive soil productivity index for every soil type in Ohio based upon relative yields of corn, soybeans, wheat, oats, and hay across the state of Ohio. The index ranges from 0 to 100 and provides a barometer for how productive soil types across the state are. Figure \ref{fig:cropland-trend} places soil types in bins according to their productivity index and plots the average CAUV value since 1991 to provide a range of CAUV values. ODT provides an additional mandate for a minimum CAUV value. Prior to 2009, this was \$100 but the value subsequently rose to \$170, \$200, \$300, and finally \$350 in 2012.


<div class="figure">
<img src="4-projections-2019-2020_files/figure-html/cropland-trend-1.png" alt="\label{fig:cropland-trend}" width="100%" />
<p class="caption">\label{fig:cropland-trend}</p>
</div>

## Phase-In

Part of the legislative changes to the CAUV formula in 2017 was that the change in CAUV values would be phased in over time. The 2017 values had an adjustment factor where only half of the difference were added on between the 2016 CAUV value and what the pre-adjusted 2017 CAUV would have been. Figure \ref{fig:phase-in} displays how the phase-in legislation affected the 2018 CAUV values across different soil types:

<div class="figure">
<img src="4-projections-2019-2020_files/figure-html/phase-in-1.png" alt="\label{fig:phase-in}" width="100%" />
<p class="caption">\label{fig:phase-in}</p>
</div>

Low productivity soils were largely unaffected as many of the lowest quality soils were at the minimum value for both 2016 and 2017 -- \$350. While the average value across all soil types in 2018 was $1,015, the adjustment associated with the phase-in period accounted for $140 on average. If the phase-in period was not in effect, the average CAUV value would have been $874.


# Possible Ranges


<div class="figure">
<img src="4-projections-2019-2020_files/figure-html/high-trend-1.png" alt="\label{fig:high-trend}" width="100%" />
<p class="caption">\label{fig:high-trend}</p>
</div>


<div class="figure">
<img src="4-projections-2019-2020_files/figure-html/low-trend-1.png" alt="\label{fig:low-trend}" width="100%" />
<p class="caption">\label{fig:low-trend}</p>
</div>


<div class="figure">
<img src="4-projections-2019-2020_files/figure-html/high-trend-2020-1.png" alt="\label{fig:high-trend-2020}" width="100%" />
<p class="caption">\label{fig:high-trend-2020}</p>
</div>


<div class="figure">
<img src="4-projections-2019-2020_files/figure-html/low-trend-2020-1.png" alt="\label{fig:low-trend-2020}" width="100%" />
<p class="caption">\label{fig:low-trend-2020}</p>
</div>


# References

- Farm Office annual crop budget reports https://farmoffice.osu.edu/farm-management-tools/farm-budgets
- Ohio Code of Legislation http://codes.ohio.gov/orc/5713.31 and http://codes.ohio.gov/orc/5715.01
- ODT CAUV Information page https://www.tax.ohio.gov/real_property/cauv.aspx
- USDA-NASS price and yield data https://quickstats.nass.usda.gov

Projections for 2019 CAUV values are available at https://aede.osu.edu/file/cauvprojections2019xlsx