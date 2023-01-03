
/*************************************************************************/
*  PROJECT:    		ARRA Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Run_ARRA_Model.do
*  LAST UPDATED: 	12/30/22
*
*  NOTES: 			Before running, set local "run" to 0, 1, or 2 
*					to obtain results for "Alternative Scenario 1," 
*					"Baseline Scenario," or "Alternative Scenario 2,"
*					as described below; and be sure to change working 
*					directory in this program as well as
*					Calculate_BEA_Employment_Output_and_Value_Added_Output_Ratios.do
/*************************************************************************/

clear
clear matrix
clear mata
set more off
set maxvar 100000

* Set working directory
global workdir = "/Users/Matt/Documents/Data_for_Progress/ARRA/Github"
cd $workdir

* We perform three different runs of the model using different parameter values: 
* - Run "0" corresponds to "Alternative Scenario 1" in the memo (the "low" scenario);
* - Run "1" to the "Baseline Scenario"; and
* - Run "2" to "Alternative Scenario 2" (the "high" scenario)

* Before running this program, set the value of the local variable "run" to either 0, 1, or 2
local run = 0 /*1*/ /*2*/ 


/******************/
/* CLEAN RAW DATA */
/******************/

* First, call program that cleans BEA data on employment, output, and value-added by industry
* Generates ratios needed for model implementation below

do ${workdir}/Programs/Calculate_BEA_Employment_Output_and_Value_Added_Output_Ratios.do


* Cleaning the ARRA data proceeds as follows:

* 1) We begin by reading in our manual categorization of spending in different titles (i.e. sections) of ARRA
*    by industries based on descriptions of what the funds in each section are used for;

* 2) Using this categorization, we compute the share of funds in each title of the law that go to each industry;

* 3) We then merge with data from the CBO's original score of ARRA, which provides projections of spending
*    by title and year - virtue of this is that we have figures for parts of the law that do not include
*    specific appropriations amounts, e.g. authorizations of tax credits, and we can also rely on estimates
*    that were publicly available at the time the law was passed rather than on post hoc evaluations of what
*    was in fact spent;

* 4) Next, we use our computed industry shares for each title and year to allocate the CBO amounts among industries;

* 5) We make some adjustments to model how tax credits to individuals and businesses affect aggregate expenditures
*    (see below for more detail on our assumptions about the marginal propensity to consume, etc.)

* This yields vectors containing total ARRA spending (public and private) by industry for each year from 2009 to 2019, 
* which we then feed into our input-output model to obtain estimates of employment and GDP impacts

use ${workdir}/Data/ARRA_Spending_Breakdown, clear

preserve

	* For allocating revenue provisions in Division A, Title XII across industries, we calculate 
	* the overall industry shares for all spending in this title and use those
	keep if division == "A" & title == "XII"
	collapse (sum) amount, by(division title beaiocodes)
	drop if beaiocodes == ""
	egen total = sum(amount)
	gen share = amount / total
	gen heading = "Revenue"

	save ${workdir}/Work/Division_A_Title_XII_Total_Shares, replace

restore

append using ${workdir}/Work/Division_A_Title_XII_Total_Shares


* Merge in CBO data
merge m:1 division title heading using ${workdir}/Data/ARRA_Spending_by_Title_and_Year
rename _merge _merge1

* Multiply spending in each title/year by industry shares to get spending by title/year/industry
foreach year of numlist 2009(1)2019 {
	gen spending_adj_`year' = share*spending_`year'
}

drop if heading == "-"
drop if title == "XIII"

collapse (sum) spending_adj*, by(beaiocodes)

merge 1:1 beaiocodes using ${workdir}/Data/All_BEAIOCodes
rename _merge _merge2

drop if beaiocodes == "Legend / Footnotes:"
drop if beaiocodes == "Note. Detail may not add to total due to rounding."
drop if beaiocodes == "-"


* We assume that line items in ARRA involving tax credits/payments to individuals increase consumer spending
* by an amount equal to their total nominal value times the "marginal propensity to consume," which we 
* allow to vary across different runs of the model

* We further assume that this spending consists of purchases of a typical basket of consumer goods, 
* so for our modeling purposes we allocate it across industries in proportion to recent weights placed
* on different goods/industries by the consumer price index (CPI)

* Source for CPI weights: https://www.bls.gov/cpi/tables/relative-importance/home.htm

* Merge in CPI weights

merge 1:m beaiocodes using ${workdir}/Data/CPI_Breakdown
rename _merge _merge3


* Set marginal propensity to consume (MPC) based on model run 

if `run' == 0 {
	local mpc = 0.1
}

if `run' == 1 {
	local mpc = 0.2
}

if `run' == 2 {
	local mpc = 0.3
}

* Spending amounts are in millions of dollars, so multiply all by one million
* For any expenditures marked as "consumer spending," allocate across industries and multiply by MPC
foreach year of numlist 2009(1)2019 {
	replace spending_adj_`year' = spending_adj_`year'*1000000
	replace spending_adj_`year' = `mpc'*weight*spending_adj_`year' if beaiocodes == "CPI"
}

replace beaiocodes = beaiocodes2 if beaiocodes == "CPI"


* We assume that line items in ARRA involving tax credits/payments to corporations increase investment spending
* by an amount equal to their total nominal value times an "investment elasticity" which we 
* allow to vary across different runs of the model

* This elasticity captures the percentage increase in investment spending by firms in response to a 
* 1% increase in nominal spending on corporate tax credits

* For our modeling purposes we allocate this across industries in proportion to each industry's share of 
* "net fixed assets" as reported by the Bureau of Economic Analysis; in other words, we assume that investment spending
* will be proportional to the existing distribution of fixed asset holdings across industries at a given point in time

* Source for net fixed asset data: https://www.bea.gov/itable/fixed-assets


* Set "investment elasticity" parameter based on model run

* In the "low" scenario we assume that corporate tax credits have no effect on investment spending,
* consistent with empirical evidence on the effect of the 2003 dividend tax cut from D. Yagan (American Economic Review 2015)
* (available at https://eml.berkeley.edu/~yagan/DividendTax.pdf)
 
if `run' == 0 {
	local investmentelasticity = 0
}

if `run' == 1 {
	local investmentelasticity = 0.1
}

if `run' == 2 {
	local investmentelasticity = 0.2
}

* Spending marked 3361MV/Business Tax corresponds to ARRA's "GM tax break"
foreach year of numlist 2009(1)2019 {
	replace spending_adj_`year' = `investmentelasticity'*spending_adj_`year' if beaiocodes == "3361MV/Business Tax"
}
replace beaiocodes = "3361MV" if beaiocodes == "3361MV/Business Tax"

collapse (sum) spending_adj*, by(beaiocodes)


* Merge in industry fixed asset data
merge 1:m beaiocodes using ${workdir}/Data/Private_Fixed_Asset_Weights_by_Industry_2009-2019


* For any expenditures marked as a "business tax credit," allocate across industries 
* and multiply by "investment elasticity"
foreach year of numlist 2009(1)2019 {
	replace spending_adj_`year' = `investmentelasticity'*weight`year'*spending_adj_`year' if beaiocodes == "Business Tax"
	*replace spending_adj_`year' = weight`year'*spending_adj_`year' if beaiocodes == "Business Tax"
}

replace beaiocodes = beaiocodes2 if beaiocodes == "Business Tax"

collapse (sum) spending_adj*, by(beaiocodes)

drop if beaiocodes == ""

save ${workdir}/Work/ARRA_Spending_by_Industry_and_Year_2009-2019_Run_`run', replace


/****************************************************/
/* CREATE LEONTIEF AND DIRECT REQUIREMENTS MATRICES */
/****************************************************/

* Create Leontief and direct requirements matrices from BEA total requirements tables for 2009-2019

foreach year of numlist 2009(1)2019 {
	
	use ${workdir}/Data/BEA_Industry_by_Industry_Total_Requirements_1997-2019.dta, clear
	
	keep if year == `year'
	
	gen num = .

	replace num = 1 if iocode == "111CA" 
	replace num = 2 if iocode == "113FF" 
	replace num = 3 if iocode == "211" 
	replace num = 4 if iocode == "212" 
	replace num = 5 if iocode == "213" 
	replace num = 6 if iocode == "22" 
	replace num = 7 if iocode == "23" 
	replace num = 8 if iocode == "321" 
	replace num = 9 if iocode == "327" 
	replace num = 10 if iocode == "331" 
	replace num = 11 if iocode == "332" 
	replace num = 12 if iocode == "333" 
	replace num = 13 if iocode == "334" 
	replace num = 14 if iocode == "335" 
	replace num = 15 if iocode == "3361MV" 
	replace num = 16 if iocode == "3364OT" 
	replace num = 17 if iocode == "337" 
	replace num = 18 if iocode == "339" 
	replace num = 19 if iocode == "311FT" 
	replace num = 20 if iocode == "313TT" 
	replace num = 21 if iocode == "315AL" 
	replace num = 22 if iocode == "322" 
	replace num = 23 if iocode == "323" 
	replace num = 24 if iocode == "324" 
	replace num = 25 if iocode == "325" 
	replace num = 26 if iocode == "326" 
	replace num = 27 if iocode == "42" 
	replace num = 28 if iocode == "441" 
	replace num = 29 if iocode == "445" 
	replace num = 30 if iocode == "452" 
	replace num = 31 if iocode == "4A0" 
	replace num = 32 if iocode == "481" 
	replace num = 33 if iocode == "482" 
	replace num = 34 if iocode == "483" 
	replace num = 35 if iocode == "484" 
	replace num = 36 if iocode == "485" 
	replace num = 37 if iocode == "486" 
	replace num = 38 if iocode == "487OS" 
	replace num = 39 if iocode == "493" 
	replace num = 40 if iocode == "511" 
	replace num = 41 if iocode == "512" 
	replace num = 42 if iocode == "513" 
	replace num = 43 if iocode == "514" 
	replace num = 44 if iocode == "521CI" 
	replace num = 45 if iocode == "523" 
	replace num = 46 if iocode == "524" 
	replace num = 47 if iocode == "525" 
	replace num = 48 if iocode == "HS" 
	replace num = 49 if iocode == "ORE" 
	replace num = 50 if iocode == "532RL" 
	replace num = 51 if iocode == "5411" 
	replace num = 52 if iocode == "5415" 
	replace num = 53 if iocode == "5412OP" 
	replace num = 54 if iocode == "55" 
	replace num = 55 if iocode == "561" 
	replace num = 56 if iocode == "562" 
	replace num = 57 if iocode == "61" 
	replace num = 58 if iocode == "621" 
	replace num = 59 if iocode == "622" 
	replace num = 60 if iocode == "623" 
	replace num = 61 if iocode == "624" 
	replace num = 62 if iocode == "711AS" 
	replace num = 63 if iocode == "713" 
	replace num = 64 if iocode == "721" 
	replace num = 65 if iocode == "722" 
	replace num = 66 if iocode == "81" 
	replace num = 67 if iocode == "GFGD" 
	replace num = 68 if iocode == "GFGN" 
	replace num = 69 if iocode == "GFE" 
	replace num = 70 if iocode == "GSLG" 
	replace num = 71 if iocode == "GSLE"

	drop if num == .
	sort num
	
	* Create Leontief matrix as 71-by-71 matrix since BEA I-O tables have 71 industry categories
	matrix Leontief`year' = J(71,71,.)

	local i = 0
	
	foreach var in "111CA" "113FF" "211" "212" "213" "22" "23" "321" "327" "331" "332" "333" "334" "335" "3361MV" "3364OT" "337" "339" "311FT" "313TT" "315AL" "322" "323" "324" "325" "326" "42" "441" "445" "452" "4A0" "481" "482" "483" "484" "485" "486" "487OS" "493" "511" "512" "513" "514" "521CI" "523" "524" "525" "HS" "ORE" "532RL" "5411" "5415" "5412OP" "55" "561" "562" "61" "621" "622" "623" "624" "711AS" "713" "721" "722" "81" "GFGD" "GFGN" "GFE" "GSLG" "GSLE" {
	
		local i = `i'+1
	
		foreach j of numlist 1(1)71 {
			matrix Leontief`year'[`j',`i'] = var_`var'[`j']
		}
	
	}

	* Create direct requirements matrix
	matrix I = J(71,71,0)
	foreach i of numlist 1(1)71 {
		matrix I[`i',`i'] = 1
	}
	matrix A`year' = -1*(inv(Leontief`year')-I)
	
}


/*******************************************/
/* CALCULATE OUTPUT AND EMPLOYMENT EFFECTS */
/*******************************************/

use ${workdir}/Work/ARRA_Spending_by_Industry_and_Year_2009-2019_Run_`run', clear

* Create vectors with spending by industry for each year
foreach year of numlist 2009(1)2019 {
	mkmat spending_adj_`year', matrix(Exp`year')
}

* Set multiplier based on model run
* Multiplier indicates magnitude of induced effects as a percentage of direct/indirect effects

if `run' == 0 {
	local multiplier = 1.3
}

if `run' == 1 {
	local multiplier = 1.4
}

if `run' == 2 {
	local multiplier = 1.5
}

rename beaiocodes iocode

foreach year of numlist 2009(1)2019 {
	
	* Feed in vector of spending and calculate aggregate output effect, 
	* i.e. pre-multiply annual expenditures by Leontief matrix
	matrix Y`year' = Leontief`year'*Exp`year'
	mata: st_matrix("Ysum`year'",colsum(st_matrix("Y`year'")))
	matrix list Ysum`year'

	* Merge in employment/output and value-added/output ratios from BEA
	merge 1:1 iocode using ${workdir}/Work/BEA_EO_and_VAO_Ratios_by_Industry_Cleaned_`year'
	drop if _merge != 3
	drop _merge
	matrix v`year' = J(71,71,0)
	foreach i of numlist 1(1)71 {
		matrix v`year'[`i',`i'] = va_output_ratio`year'[`i']
	}
	matrix e`year' = J(71,71,0)
	foreach i of numlist 1(1)71 {
		matrix e`year'[`i',`i'] = emp_output_ratio`year'[`i']
	}

	* Feed in vector of spending and calculate aggregate value added effect
	* i.e. pre-multiply annual expenditures by Leontief matrix and multiply 
	* raw output in each industry/year by respective value-added/output ratio
	* (this prevents double-counting of output when calculating GDP impact)
	
	matrix V`year' = v`year'*Leontief`year'*Exp`year'
	mata: st_matrix("Vsum`year'",colsum(st_matrix("V`year'")))
	matrix list Vsum`year'
	
	* Feed in vector of spending and calculate aggregate employment effect
	* i.e. pre-multiply annual expenditures by Leontief matrix and multiply 
	* raw output in each industry/year by respective employment/output ratio
	
	matrix E`year' = e`year'*Leontief`year'*Exp`year'
	mata: st_matrix("Esum`year'",colsum(st_matrix("E`year'")))
	matrix list Esum`year'

	* Save expenditure vector
	svmat Exp`year'
	
	* Save output, employment, and value-added (GDP) vectors
	svmat Y`year'
	svmat E`year'
	svmat V`year'
	
	* Apply multiplier to variables and matrices to get induced effects
	replace Y`year'1 	= `multiplier'*Y`year'1
	replace E`year'1 	= `multiplier'*E`year'1
	replace V`year'1 	= `multiplier'*V`year'1
	
	matrix Y`year'  	= `multiplier'*Y`year'
	matrix E`year' 		= `multiplier'*E`year'

	save ${workdir}/Work/ARRA_Model_Run_`run'_Output_and_Employment_Results_`year', replace

}

* Collapse results by year
collapse (sum) Y* E* V*
gen n = _n
reshape long Y E V Exp, i(n) j(year)
replace year = (year-1)/10
drop n

save ${workdir}/Output/ARRA_Model_Run_Final_Results_`run', replace

* Delete temporary files
foreach year of numlist 2009(1)2019 {
	erase ${workdir}/Work/ARRA_Model_Run_`run'_Output_and_Employment_Results_`year'.dta
}

* Calculate "cost per job created" by dividing headline ARRA spending by job creation
preserve
collapse (sum) E
gen Costperjob = 787233000000/E
dis Costperjob[1]
restore
