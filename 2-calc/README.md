# Calculations

The following scripts provide the calculations for each component in the CAUV formula:

1. [Capitalization rate](2-calc-caprate.R) - the most recent interest or equity rates are carried forward to the next year for the expected projection.
2. [Non-land costs](2-calc-nonland.R) - fairly tedious amount of calculations with Olympic averages for each component in the budget reports. The expected projections either carry forward the previous year's values for costs or use the preliminary reports published starting around October.
3. [Prices](2-calc-prices.R) - could be refined more with how USDA displays monthly prices, but currently the expected projection uses the previous year's value and carries it forward.
4. [Rotation](2-calc-rot.R) - 
5. [Yields](2-calc-yields.R) - uses forecast values from the USDA for the current year in the expected projections.

