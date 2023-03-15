
/*************************************************************************/
*  PROJECT:    		BBB Direct Pay Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Allocate_BBB_Tax_Credit_Expenditures.do
*  LAST UPDATED: 	3/12/23
*  
*  NOTES: 						
/*************************************************************************/


/*************************************/
/* CREATE SYNTHETIC INDUSTRY VECTORS */
/*************************************/

* Bioenergy (Pollin et al. 2015)
matrix Bioenergy = J(71,1,0)
matrix Bioenergy[1,1] = 0.250 /* Farms */
matrix Bioenergy[2,1] = 0.250 /* Forestry, fishing, and related activities */
matrix Bioenergy[7,1] = 0.250 /* Construction */
matrix Bioenergy[25,1] = 0.125 /* Chemical products */
matrix Bioenergy[53,1] = 0.125 /* Miscellaneous professional, scientific, and technical services */

* Geothermal (Pollin et al. 2015)
matrix Geothermal = J(71,1,0)
matrix Geothermal[5,1] = 0.150 /* Support activities for mining */
matrix Geothermal[7,1] = 0.450 /* Construction */
matrix Geothermal[12,1] = 0.100 /* Machinery */
matrix Geothermal[53,1] = 0.300 /* Miscellaneous professional, scientific, and technical services */

* Hydro (small) (Pollin et al. 2015)
matrix Hydro = J(71,1,0)
matrix Hydro[7,1] = 0.180 /* Construction */
matrix Hydro[11,1] = 0.180 /* Fabricated metal products */
matrix Hydro[12,1] = 0.070 /* Machinery */
matrix Hydro[14,1] = 0.140 /* Electrical equipment, appliances, and components */
matrix Hydro[53,1] = 0.430 /* Miscellaneous professional, scientific, and technical services */

* Nuclear (Authors' calculations, roughly based on B&V 2012)
matrix Nuclear = J(71,1,0)
matrix Nuclear[7,1] = 0.25 /* Construction */
matrix Nuclear[11,1] = 0.10 /* Fabricated metal products */
matrix Nuclear[12,1] = 0.10 /* Machinery */
matrix Nuclear[13,1] = 0.10 /* Computer and electronic products */
matrix Nuclear[14,1] = 0.10 /* Electrical equipment, appliances, and components */
matrix Nuclear[53,1] = 0.15 /* Miscellaneous professional, scientific, and technical services */
matrix Nuclear[54,1] = 0.20 /* Management of companies and enterprises */

* Other Renewables - (Per Arjun Krishnaswami, assume miscellaneous renewables resemble geothermal)
matrix Renewables = J(71,1,0)
matrix Renewables[5,1] = 0.150 /* Support activities for mining */
matrix Renewables[7,1] = 0.450 /* Construction */
matrix Renewables[12,1] = 0.100 /* Machinery */
matrix Renewables[53,1] = 0.300 /* Miscellaneous professional, scientific, and technical services */

* Smart Grid (Pollin et al. 2015)
matrix SmartGrid = J(71,1,0)
matrix SmartGrid[7,1] = 0.250 /* Construction */
matrix SmartGrid[12,1] = 0.250 /* Machinery */
matrix SmartGrid[13,1] = 0.250 /* Computer and electronic products */
matrix SmartGrid[14,1] = 0.250 /* Electrical equipment, appliances, and components */

* Solar (Pollin et al. 2015)
matrix Solar = J(71,1,0)
matrix Solar[7,1] = 0.300 /* Construction */
matrix Solar[11,1] = 0.175 /* Fabricated metal products */
matrix Solar[12,1] = 0.175 /* Machinery */
matrix Solar[13,1] = 0.175 /* Computer and electronic products */
matrix Solar[53,1] = 0.175 /* Miscellaneous professional, scientific, and technical services */

* Wind (Pollin et al. 2015)
matrix Wind = J(71,1,0)
matrix Wind[7,1] = 0.260 /* Construction */
matrix Wind[11,1] = 0.120 /* Fabricated metal products */
matrix Wind[12,1] = 0.370 /* Machinery */
matrix Wind[13,1] = 0.030 /* Computer and electronic products */
matrix Wind[14,1] = 0.030 /* Electrical equipment, appliances, and components */
matrix Wind[26,1] = 0.120 /* Plastics and rubber products */
matrix Wind[53,1] = 0.070 /* Miscellaneous professional, scientific, and technical services */


/**************************************************/
/* CREATE VECTORS WITH EXPENDITURES FOR EACH YEAR */
/**************************************************/

matrix Spending2022 = J(13,1,.)
matrix Spending2023 = J(13,1,.)
matrix Spending2024 = J(13,1,.)
matrix Spending2025 = J(13,1,.)
matrix Spending2026 = J(13,1,.)
matrix Spending2027 = J(13,1,.)
matrix Spending2028 = J(13,1,.)
matrix Spending2029 = J(13,1,.)
matrix Spending2030 = J(13,1,.)
matrix Spending2031 = J(13,1,.)

foreach num of numlist 1(1)13 {
	
	matrix Spending2022[`num',1] = Spending2022[`num']
	matrix Spending2023[`num',1] = Spending2023[`num']
	matrix Spending2024[`num',1] = Spending2024[`num']
	matrix Spending2025[`num',1] = Spending2025[`num']
	matrix Spending2026[`num',1] = Spending2026[`num']
	matrix Spending2027[`num',1] = Spending2027[`num']
	matrix Spending2028[`num',1] = Spending2028[`num']
	matrix Spending2029[`num',1] = Spending2029[`num']
	matrix Spending2030[`num',1] = Spending2030[`num']
	matrix Spending2031[`num',1] = Spending2031[`num']
	
}

foreach year of numlist 2022(1)2031 {
	
	matrix Exp45_`year' 	= J(71,1,0)
	matrix Exp48_`year' 	= J(71,1,0)
	matrix Exp48D_`year' 	= J(71,1,0)
	matrix Exp45Q_`year' 	= J(71,1,0)
	matrix Exp45W_`year' 	= J(71,1,0)
	matrix Exp45X_`year' 	= J(71,1,0)
	matrix Exp30C_`year' 	= J(71,1,0)
	matrix Exp48C_`year' 	= J(71,1,0)
	matrix Exp48E_`year' 	= J(71,1,0)
	matrix Exp48AA_`year' 	= J(71,1,0)
	matrix Exp45BB_`year' 	= J(71,1,0)
	matrix Exp48F_`year' 	= J(71,1,0)
	matrix Exp45CC_`year' 	= J(71,1,0)

}


/************************************************************************************/
/* ESTIMATE PRIVATE SPENDING AND ALLOCATE TAX CREDIT EXPENDITURES ACROSS INDUSTRIES */
/************************************************************************************/

/* Source for credit details: https://www.bhfs.com/Templates/media/files/insights/Build%20Back%20Better%20Act%20-%20Tax%20Policy%20Summary%20and%20Analysis.pdf */

/******************************/
/* 45 (Production Tax Credit) */
/******************************/

* Base credit of 0.5 cents per kWh, bonus credit of 2.5 cents per kWh
* Assume 50/50 split so credit amount is 1.5 cents per kWh
* Cost of renewable generation is now 3 cents per kWh or less (see: https://www.irena.org/newsroom/pressreleases/2021/Jun/Majority-of-New-Renewables-Undercut-Cheapest-Fossil-Fuel-on-Cost) so we can suppose the credit is 50%
* Abstract away from other adjustments since they don't change the calculation much
* Industries are "wind facilities, closed-loop and open-loop biomass facilities, geothermal facilities, landfill gas facilities, trash facilities, qualified hydropower facilities, and marine and hydrokinetic renewable energy facilities"

* Industry allocation (from EIA Short-Term Energy Outlook for May 2022): 
* - Conventional Hydropower	0.333 - give 50% of this the 6% credit and 50% the 2%/10% credit (also 6%, so actually the whole thing is 6%)
* - Wind 0.5
* - Solar (a) 0.125
* - Biomass 0.028
* - Geothermal 0.014


foreach year of numlist 2022(1)2031 {
	matrix Exp45_`year' = (Spending`year'[1]/0.5)*(0.333*Hydro + 0.5*Wind + 0.125*Solar + 0.028*Bioenergy + 0.014*Geothermal)
}


/******************************/
/* 48 (Investment Tax Credit) */
/******************************/

* Base credit of 6% for "solar property, qualified fuel cell property, qualified small wind energy property, waste energy recovery property, and qualified investment credit facility property (e.g., wind, open-loop biomass, hydropower facilities)"
* Base credit of 6% for "combined heat and power system property and geothermal heat pump property," bonus credit of 30% (assume 50/50 split so credit amount of 18%)
* Base credit of 2% for microturbine property, bonus credit of 10% (assume 50/50 split so credit amount of 6%)
* Applies to "solar property, qualified fuel cell property, qualified microturbine property, qualified small wind energy property, and qualified investment credit facility property that begin construction before January 1, 2027"
* Phases down around 2032 for certain categories but this is beyond the window we care about

* Industry allocation (from EIA Short-Term Energy Outlook for May 2022): 
* - Conventional Hydropower	0.333 - give 50% of this the 6% credit and 50% the 2%/10% credit (also 6%, so actually the whole thing is 6%)
* - Wind 0.5
* - Solar (a) 0.125
* - Biomass 0.028
* - Geothermal 0.014

foreach year of numlist 2022(1)2031 {
	matrix Exp48_`year' = (Spending`year'[2]/0.06)*(0.333*Hydro + 0.5*Wind + 0.125*Solar + 0.028*Bioenergy) + (Spending`year'[2]/0.18)*(0.014*Geothermal)
}


/**************************************************************/
/* 48D (Investment Credit for Electric Transmission Property) */
/**************************************************************/

* 6% base credit amount, 30% bonus amount (simple!)
* Assume 50/50 split so credit amount is 18%
* Let's call this "smart grid"

foreach year of numlist 2022(1)2031 {
	matrix Exp48D_`year' = (Spending`year'[3]/0.18)*SmartGrid
}


/*******************************************/
/* 45Q (Carbon Oxide Sequestration Credit) */
/*******************************************/

* Base credit is $12 per ton of carbon oxide captured and utilized, or $17 per ton captured and sequestered
* Bonus credit is $60 per ton of carbon oxide captured and utilized, or $85 per ton captured and sequestered
* Assume 50/50 split between utilization/sequestration and 50/50 split between base/bonus
* If we also assume the cost of capturing a ton of carbon is $600 (see: https://www.science.org/content/article/cost-plunges-capturing-carbon-dioxide-air), then we get a credit amount of ((12+17+60+85)/4)/600 = 43.5 / 600 = 7.25%

foreach year of numlist 2022(1)2031 {
	matrix Exp45Q_`year' = (Spending`year'[4]/0.0725)*Renewables
}


/*******************************************************/
/* 45W (Zero-Emission Nuclear Power Production Credit) */
/*******************************************************/

* Base credit is 0.3 cents per kWh, bonus credit is 1.5 cents
* Assume 50/50 split so credit amount is 0.9 cents
* Average cost of nuclear power is $50 - $100 per MWh (see: https://www.mr-sustainability.com/stories/2020/nuclear-power-2); this means credit is 900 cents = $9 per MWh, so if we assume cost of nuclear power is $100 per MWh then credit amount is 9%
* Ignore how the credit is reduced in response to price increases

foreach year of numlist 2022(1)2031 {
	matrix Exp45W_`year' = (Spending`year'[5]/0.09)*Nuclear
}


/*************************************************/
/* 45X (Credit for Production of Clean Hydrogen) */
/*************************************************/

* Base credit of 60 cents per kilogram of qualified clean hydrogen, bonus credit of $3 per kilogram
* Don't know the mix so say 50/50 and call the credit $1.80 on average
* Total cost is about $5 per kilogram (see: https://www.cnbc.com/2022/01/06/what-is-green-hydrogen-vs-blue-hydrogen-and-why-it-matters.html)
* Let's approximate as a 36% credit

foreach year of numlist 2022(1)2031 {
	matrix Exp45X_`year' = (Spending`year'[6]/0.36)*Renewables
}


/****************************************************/
/* 30C (Alternative Fuel Refueling Property Credit) */
/****************************************************/

* Base credit for businesses is 6%, bonus credit of 30%; base credit for individuals is 30% 
* Don't know the mix for businesses so say 50/50 and call the credit 18% on average; don't know the business/individual mix so say 50/50 and call the credit 24% on average
* Assign to industry "electrical equipment, appliances, and components"

foreach year of numlist 2022(1)2031 {
	matrix Exp30C_`year' = (Spending`year'[7]/0.24)*SmartGrid
}


/**********************************************/
/* 48C (Advanced Energy Manufacturing Credit) */
/**********************************************/

* Base credit of 6%, bonus credit of 30% 
* Don't know the mix so say 50/50 and call the credit 18% on average
* Use industrial mix from earlier memo:
* - 62.6% allocated to Electrical Equipment, Appliances, and Components
* - 20.5% allocated to Machinery Manufacturing (Industrial machinery for plant floors)
* - 2.8% allocated to Motor Vehicles
* - 10.0% allocated to Other Transportation Equipment
* - 1.8% allocated to Chemical Products
* - 2.1% allocated to Utilities (Smart grid using Garrett-Peltier's definition)
* - 0.3% allocated to Pipeline Transportation

foreach year of numlist 2022(1)2031 {
	matrix Exp48C_`year'[6,1] 	= 0.021*(Spending`year'[8]/0.18)
	matrix Exp48C_`year'[12,1] 	= 0.205*(Spending`year'[8]/0.18)
	matrix Exp48C_`year'[14,1] 	= 0.626*(Spending`year'[8]/0.18)
	matrix Exp48C_`year'[15,1] 	= 0.028*(Spending`year'[8]/0.18)
	matrix Exp48C_`year'[16,1] 	= 0.100*(Spending`year'[8]/0.18)
	matrix Exp48C_`year'[25,1] 	= 0.018*(Spending`year'[8]/0.18)
	matrix Exp48C_`year'[37,1] 	= 0.003*(Spending`year'[8]/0.18)
}


/**************************************************/
/* 48E (Advanced Manufacturing Investment Credit) */
/**************************************************/

* "Creates a new investment tax credit for property that creates semiconductors and semiconductor tooling equipment" */
* Base credit of 5%, bonus credit of 25% 
* Don't know the mix so say 50/50 and call the credit 15%
* Allocate 50% to Electrical Equipment, Appliances, and Components and 50% to Machinery Manufacturing

foreach year of numlist 2022(1)2031 {
	matrix Exp48E_`year'[12,1] 	= (Spending`year'[9]/0.15)*0.5
	matrix Exp48E_`year'[14,1] 	= (Spending`year'[9]/0.15)*0.5
}


/***************************************************/
/* 45AA (Advanced Manufacturing Production Credit) */
/***************************************************/

* "[C]omponents covered are: thin photovoltaic cell, crystalline photovoltaic cell, photovoltaic wafer, solar grade polysilicon, solar modules, and wind energy components. Wind energy components are broken out by blades, nacelles, towers and foundations"
* Let's go with 1/2 solar, 1/2 wind 
* Treating it as a 10% credit (see other doc for derivation)
* Because of phaseout, for 2028 say it's a 7.5% credit; for 2029, a 5% credit, and for 2030, a 2.5% credit
* Ignore the 10% increase for being a union facility (won't make much difference to the calculation)

foreach year of numlist 2022(1)2027 {
	matrix Exp48C_`year'[6,1] 	= (Spending`year'[10]/0.1)
}

matrix Exp45AA_2028 	= (Spending2028[10]/0.075)
matrix Exp45AA_2029 	= (Spending2029[10]/0.05)
matrix Exp45AA_2030 	= (Spending2030[10]/0.025)
matrix Exp45AA_2031 	= 0


/**********************************************/
/* 45BB (Clean Electricity Production Credit) */
/**********************************************/

* Basically a new, "technology-neutral" version of the PTC
* Base credit of 0.3 cents per kWh, bonus credit of 1.5 cents per kWh
* Assume 50/50 split so credit amount is 0.9 cents per kWh
* Cost of renewable generation is now 3 cents per kWh or less (see: https://www.irena.org/newsroom/pressreleases/2021/Jun/Majority-of-New-Renewables-Undercut-Cheapest-Fossil-Fuel-on-Cost) so we can suppose the credit is 0.9/3 = 30%

* Industry allocation (from EIA Short-Term Energy Outlook for May 2022): 
* - Conventional Hydropower	0.333 - give 50% of this the 6% credit and 50% the 2%/10% credit (also 6%, so actually the whole thing is 6%)
* - Wind 0.5
* - Solar (a) 0.125
* - Biomass 0.028
* - Geothermal 0.014

foreach year of numlist 2022(1)2031 {
	matrix Exp45BB	= (Spending`year'[11]/0.3)*(0.333*Hydro + 0.5*Wind + 0.125*Solar + 0.028*Bioenergy + 0.014*Geothermal)
}


/*********************************************/
/* 48F (Clean Electricity Investment Credit) */
/*********************************************/

* Basically a new, "technology-neutral" version of the ITC
* Base credit of 6%, bonus credit of 30%
* Assume 50/50 split so credit amount is 18%

* Industry allocation (from EIA Short-Term Energy Outlook for May 2022): 
* - Conventional Hydropower	0.333 - give 50% of this the 6% credit and 50% the 2%/10% credit (also 6%, so actually the whole thing is 6%)
* - Wind 0.5
* - Solar (a) 0.125
* - Biomass 0.028
* - Geothermal 0.014

foreach year of numlist 2022(1)2031 {
	matrix Exp45BB	= (Spending`year'[12]/0.18)*(0.333*Hydro + 0.5*Wind + 0.125*Solar + 0.028*Bioenergy + 0.014*Geothermal)
}


/*******************************************/
/* 45CC (Clean Fuel Production Tax Credit) */
/*******************************************/

* Base credit is 20 cents per gallon for most clean fuels, 35 cents per gallon for aviation fuel
* Bonus credit is $1 per gallon for most clean fuels, $1.75 for aviation fuel
* Don't know the mix for non-aviation/aviation so say 50/50 and call the base credit 27.5 cents on average for base and $1.375 for bonus; say 50/50 mix for base/bonus and call the credit 82.5 cents
* In late 2021, biodiesel was over $5 per gallon (see: https://www.biofuelsdigest.com/bdigest/2022/02/10/biodiesel-prices-seen-soaring-further-in-2022/)
* Hence, credit is approximately 0.825 / 5 = 16.5% (round to 15%)

foreach year of numlist 2022(1)2031 {
	matrix Exp45BB	= (Spending`year'[13]/0.15)*Bioenergy
}



/****************************************/
/* CALCULATE TOTAL EXPENDITURES BY YEAR */
/****************************************/

foreach year of numlist 2022(1)2031 {
	matrix Exp`year' = Exp45_`year' + Exp48_`year' + Exp48D_`year' + Exp45Q_`year' + Exp45W_`year' + Exp45X_`year' + Exp30C_`year' + Exp48C_`year' + Exp48E_`year' + Exp48AA_`year' + Exp45BB_`year' + Exp48F_`year' + Exp45CC_`year'
}
