# The Ohio State University Extension Budget Items

The intent behind the current methodology for ODT's calculation of non-land costs in the CAUV formula is to account for any costs related to the operation of farmland that is not related to purchasing the land itself or the landowner's time. Effectively this means that from the budget reports for each crop, the ODT will omit the land cost and management cost from the extension office budgets and construct the costs based on a 7 year Olympic average for each component.

There are a total of 137 different items for the corn, soybeans, and wheat costs. They have been grouped into 4 different categories (finances, fixed costs, production, and variable cost). There are also 20 different items which fit under each of the various categories. And there are then different levels for each item, the levels refer to either the production level (low, medium, or high) or the cost of an item.

Budget excel files are organized where they have a low, medium, and high yield value for each crop and are generally the furthest right columns for each data item. There are subtle changes form year to year in terms of where the items are ordered as well as what the category stands for. Because of this, it is near impossible to automate the process of maintaining historical values for the budget cost.

The [`osu_budgets - R.csv`](osu_budgets - R.csv) file is how I have organized historical budget data for corn, soybeans, and wheat. The variables in my formatted:

- `year` - the year of a budget
- `category` - see below.
- `item` - see below.
- `crop` - either corn, soybeans, or wheat.
- `level` - helps define the unit of observation and is either coded cost, l1_low, l2_med, or l3_high. The l1 is done to keep alphabetical order in sorting but they represent the value associated with a low-med-high scenario for yields of a crop. The cost category does not vary for different yields.
- `val` - value indicated on the budget for the particular item.
- `id` - concatenated category-item-crop-level to create a unique id for each year.

And lastly, here are the category-item combinations and descriptions (useful for inputting new values from OSU budgets):

- `finances` - category related to financing operations for variable costs, these values do not vary across yields and and found in approximately the middle of the excel file (in terms of rows and columns).
    - `interest` - the current interest rate on operation of capital, should be a percentage and the same across all crops.
    - `months` - current repayment period for operations, these will likely be different across crops.
- `fixed costs` - category in the budgets related to fixed cost of operation for a crop, should be on the lower end of the excel file. All categories are used except for the management charge and land charge.
    - `fixed_miscellaneous` - started in 2015 budgets, typically the last item in the fixed costs. Includes marketing, farm insurance, dues and professional fees, supplies, utilities, soil tests, small tools, software/hardware, business use of vehicle, transport of supplies/equipment, etc.
    - `labor` - usually first item under fixed costs and is a combination of hours and the prevailing wage rate. Use the average of all the yield levels, although they should all be equal.
    - `machine` - titled the "Mach. And Equip. Charge" and usually in the middle of fixed costs. All yields should be equal, so use the average. There was a large-scale change in 2018 which dramatically lowered this value, for 2018 and beyond this category must be a combination of `machine_new` and `hired_custom_work` for consistency.
    - `machine_new` - only tracked beginning in 2018, this is the actual value for "Mach. And Equip. Charge" after the new tracking of the category.
- `production` - top of the budgets, these are related to the agronomic issues for each crop. Actually placed under the variable costs section.
    - `seed` - usually the first item under the variable cost, should be the amount of seeds used for the various levels of yields and technically match the yield values.
    - `yield` - these are the high-medium-low values for yields in the budgets. The values are always found at the top right of the excel files in order of low to high.
- `variable cost` - close enough to the first section of each excel file for most of these items.
    - `chemicals` - cost of all chemicals related to the production of each crop, these are typically fixed values but if not take the average across the yield values.
    - `crop_insurance` - crop insurance which depends on the expected yields for each crop and will vary across the different levels.
    - `drying` - only corn needs drying, but the cost value needs to be converted into cent per bushel.
    - `fuel_oil_grease` - in about the middle of each variable cost section, but it usually doesn't vary across yield levels.
    - `hired_custom_work` - began in 2018 split of how the budgets were calculated, should be documented across the different production levels but the average should be used to add onto the `machine` category in fixed costs.
    - `k2o` - fertilizer cost is documented as per pound, this should be a column within the category. There should also be different levels in terms of how much fertilizer should be sued, which are to the left of the cost and should be inputted into the low-med-high categories.
    - `lime` - both cost and production units should be used here, although in the situation where there is only one production unit used it should be applied to low-med-high equally.
    - `n` - stands for nitrogen and is used in corn and wheat production (not soybeans). Cost and the production levels are recorded for this and the cost may differ across crops. Cost is in a per-pound cost at the middle right while the production levels are to the left of this value.
    - `p2o5` - cost and the production levels are recorded for this and the cost may differ across crops. Cost is in a per-pound cost at the middle right while the production levels are to the left of this value.
    - `repairs` - should usually be equal across all yields but if not, then the average should be used.
    - `seed` - cost of seed, which is usually the first row in variable costs and in the middle. Corn is per 1,000.
    - `trucking` - category changed in 2018 to be called "Hauling" which includes a per bushel cost that should be used. Prior to 2017, this value needed to be calculated by taking the total cost for low production divided by the yields for the low production yield.
    - `variable_miscellaneous` - usually one of the last line items for this category, it varies across yield levels and is expressed as a cost. It should be recorded as so too.




