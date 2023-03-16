
/*************************************************************************/
*  PROJECT:    		BBB Direct Pay Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Run_BBB_Direct_Pay_Model.do
*  LAST UPDATED: 	3/15/23
*  
*  NOTES: 			Before running, be sure to change the working directory 
*					at the top of this program				
/*************************************************************************/


clear
clear matrix
clear mata
set more off
set maxvar 100000

* Set working directory
global workdir = "/Users/Matt/Documents/Data_for_Progress/BBB_Direct_Pay/Github"
cd $workdir


/******************/
/* CLEAN RAW DATA */
/******************/

* First, call program that cleans BEA data on employment, output, and value-added by industry
* Generates ratios needed for model implementation below

do ${workdir}/Programs/Calculate_BEA_Employment_Output_and_Value_Added_Output_Ratios.do


* Key assumption in our analysis is that clean energy projects below a certain cost will only
* take place if a Direct Pay option is available, since it would otherwise be infeasible for 
* project sponsors to monetize applicable tax credits via partnerships with tax equity investors

* Hence, we import and clean data on ARRA Direct Pay (Section 1603) grants to benchmark the
* distribution of project sizes, then calculate the share of spending accounted for by projects
* costing more/less than $50 million (estimated threshold below which monetization is not an option)

import excel using ${workdir}/Data/Website-Awarded-as-of-3.1.18.xlsx, firstrow clear

drop F-AZ
rename Section1603PaymentsforSpec BusinessName
rename B State
rename C Technology
rename D Amount
rename E Date

drop if _n == 1
drop if BusinessName == "Total" | BusinessName == ""

destring(Amount), replace force
split(Date), p("/")
rename Date3 Year
destring(Year), replace force

* Inflation adjustments (convert everything to 2022 dollars)
gen Amount2022 = .
replace Amount2022 = Amount*(121.9211/95.024) if Year == 2009
replace Amount2022 = Amount*(121.9211/96.166) if Year == 2010
replace Amount2022 = Amount*(121.9211/98.164) if Year == 2011
replace Amount2022 = Amount*(121.9211/100.000) if Year == 2012
replace Amount2022 = Amount*(121.9211/101.751) if Year == 2013
replace Amount2022 = Amount*(121.9211/103.654) if Year == 2014
replace Amount2022 = Amount*(121.9211/104.691) if Year == 2015
replace Amount2022 = Amount*(121.9211/105.740) if Year == 2016
replace Amount2022 = Amount*(121.9211/107.747) if Year == 2017

gen AboveThreshold = .
replace AboveThreshold = 0 if Amount2022 < 50000000
replace AboveThreshold = 1 if Amount2022 >= 50000000

collapse (sum) Amount2022, by(AboveThreshold)

local AmountBelowThreshold = Amount2022[1]
local AmountAboveThreshold = Amount2022[2]

local ShareBelowThreshold = round(`AmountBelowThreshold' / (`AmountBelowThreshold'+ `AmountAboveThreshold'),0.01)
local ShareAboveThreshold = round(`AmountAboveThreshold' / (`AmountBelowThreshold'+ `AmountAboveThreshold'),0.01)

gen ShareBelowThreshold = `ShareBelowThreshold'
gen ShareAboveThreshold = `ShareAboveThreshold'

keep ShareBelowThreshold ShareAboveThreshold
drop if _n == 2

save ${workdir}/Output/Section_1603_Grant_Shares, replace


* Read in data on Direct Pay tax credit provisions from Joint Committee on Taxation

import excel using ${workdir}/Data/BBB_Subtitle_F_Direct_Pay_Provisions.xlsx, firstrow clear

foreach var in C D E F G H I J K L M N {
	replace `var' = subinstr(`var',",","",.)
	destring(`var'), replace force
}

rename C Spending2022
rename D Spending2023
rename E Spending2024
rename F Spending2025
rename G Spending2026
rename H Spending2027
rename I Spending2028
rename J Spending2029
rename K Spending2030
rename L Spending2031
rename M Spending2022_2026
rename N Spending2022_2031

drop if Abbreviation == ""

foreach year in "2022" "2023" "2024" "2025" "2026" "2027" "2028" "2029" "2030" "2031" "2022_2026" "2022_2031" {
	replace Spending`year' = -1000000*Spending`year'
}

* Calculate nominal spending by credit (in billions)
preserve
collapse (sum) Spending*, by(Abbreviation)
keep Abbreviation Spending2022_2031
save ${workdir}/Output/BBB_Direct_Pay_Total_Spending_by_Credit, replace
restore


* Convert to 2020 dollars

* GDP deflators in FRED: 
* - 100 in 2012
* - 112.294 in 2019
* - 113.648 in 2020
* - 118.370 in 2021
* - 121.9211 in 2022
* - 124.359522 in 2023
* - 126.8467124 in 2024
* - 129.3836467 in 2025
* - 131.9713196 in 2026
* - 134.610746 in 2027
* - 137.3029609 in 2028
* - 140.0490202 in 2029
* - 142.8500006 in 2030
* - 145.7070006 in 2031

replace Spending2022 = Spending2022 / (121.9211/113.648)
replace Spending2023 = Spending2023 / (124.359522/113.648)
replace Spending2024 = Spending2024 / (126.8467124/113.648)
replace Spending2025 = Spending2025 / (129.3836467/113.648)
replace Spending2026 = Spending2026 / (131.9713196/113.648)
replace Spending2027 = Spending2027 / (134.610746/113.648)
replace Spending2028 = Spending2028 / (137.3029609/113.648)
replace Spending2029 = Spending2029 / (140.0490202/113.648)
replace Spending2030 = Spending2030 / (142.8500006/113.648)
replace Spending2031 = Spending2031 / (145.7070006/113.648)


/****************************************************/
/* CALL PROGRAM TO ALLOCATE TAX CREDIT EXPENDITURES */
/****************************************************/

* In order to feed tax credit expenditures into the model we need to make two sets of assumptions:
*
* (1) How much private spending is leveraged by the credit in addition to the federal spending, 
*     i.e. what percentage of the total cost of a project is accounted for by the credit and what 
*     percentage by private investment;
*
* (2) How the total expenditures should be allocated across industries, for which we draw on the 
*     "synthetic industry" approach (c.f. Garrett-Peltier (2016), "Green versus brown: Comparing the
*     employment impacts of energy efficiency, renewable energy, and fossil fuels using an input-output 
*     model," Economic Modelling 61)

* Call program that implements both sets of assumptions

do ${workdir}/Programs/Allocate_BBB_Tax_Credit_Expenditures.do


/*******************************************************/
/* RUN MODEL FOR SCENARIOS WITH AND WITHOUT DIRECT PAY */
/*******************************************************/

local multiplier = 1.4

* Loop runs model for two different scenarios: one in which we assume Direct Pay 
* provisions are not implemented and one in which we assume they are

* In the case where we assume Direct Pay is *not* implemented, we multiply total expenditures
* by one minus the fraction of ARRA Section 1603 spending flowing to projects with a cost of
* less than $50 million, the threshold below which we assume it is not feasible to monetize 
* credits via tax equity investors (this fraction is calculated above)

foreach run of numlist 0 1 {
	
	if `run' == 0 {
		local runname = "No_Direct_Pay_Scenario"
	}

	if `run' == 1 {
		local runname = "Direct_Pay_Scenario"
	}

	
	/* CREATE LEONTIEF AND DIRECT REQUIREMENTS MATRICES */

	* Create Leontief matrix

	use ${workdir}/Data/BEA_Industry_by_Industry_Domestic_Requirements_2020.dta, clear
	
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
	
	
	matrix Leontief = J(71,71,.)

	local i = 0
	
	foreach var in "111CA" "113FF" "211" "212" "213" "22" "23" "321" "327" "331" "332" "333" "334" "335" "3361MV" "3364OT" "337" "339" "311FT" "313TT" "315AL" "322" "323" "324" "325" "326" "42" "441" "445" "452" "4A0" "481" "482" "483" "484" "485" "486" "487OS" "493" "511" "512" "513" "514" "521CI" "523" "524" "525" "HS" "ORE" "532RL" "5411" "5415" "5412OP" "55" "561" "562" "61" "621" "622" "623" "624" "711AS" "713" "721" "722" "81" "GFGD" "GFGN" "GFE" "GSLG" "GSLE" {
	
		local i = `i'+1
	
		foreach j of numlist 1(1)71 {
			matrix Leontief[`j',`i'] = var_`var'[`j']
		}
	
	}

	* Create direct requirements matrix
	matrix I = J(71,71,0)
	foreach i of numlist 1(1)71 {
		matrix I[`i',`i'] = 1
	}
	matrix A = -1*(inv(Leontief)-I)


	/* CALCULATE OUTPUT, EMPLOYMENT, AND WAGE EFFECTS (2022-2031) */

	foreach year of numlist 2022(1)2031 {
	
		if `run' == 0 {
			matrix Exp`year'`run' = `ShareAboveThreshold'*Exp`year'
		}
		
		if `run' == 1 {
			matrix Exp`year'`run' = Exp`year'
		}
		
		* Feed in vector of spending and calculate aggregate output effect
		matrix Y`year' = Leontief*Exp`year'`run'
		mata: st_matrix("Ysum`year'",colsum(st_matrix("Y`year'")))
		matrix list Ysum`year'

		* Merge in employment/output and VA/output ratios
		merge 1:1 iocode using ${workdir}/Work/BEA_EO_and_VAO_Ratios_by_Industry_Cleaned_2020
		drop if _merge != 3
		drop _merge
		matrix v`year' = J(71,71,0)
		foreach i of numlist 1(1)71 {
			matrix v`year'[`i',`i'] = va_output_ratio[`i']
		}
		matrix e`year' = J(71,71,0)
		foreach i of numlist 1(1)71 {
			matrix e`year'[`i',`i'] = emp_output_ratio[`i']
		}

		* Feed in vector of spending and calculate aggregate value added effect
		matrix V`year' = v`year'*Leontief*Exp`year'`run'
		mata: st_matrix("Vsum`year'",colsum(st_matrix("V`year'")))
		matrix list Vsum`year'
	
		* Feed in vector of spending and calculate aggregate employment effect
		matrix E`year' = e`year'*Leontief*Exp`year'`run'
		mata: st_matrix("Esum`year'",colsum(st_matrix("E`year'")))
		matrix list Esum`year'
		
		* Feed in vector of spending and calculate direct employment effect
		matrix D`year' = e`year'*A*Exp`year'`run'
		mata: st_matrix("Dsum`year'",colsum(st_matrix("D`year'")))
		matrix list Dsum`year'
	
		* Save output, employment, and GDP vectors
		svmat Y`year'
		svmat E`year'
		svmat V`year'
		svmat D`year'
	
		* Apply multiplier to variables and matrices to get induced effects where needed
		replace Y`year'1 = `multiplier'*Y`year'1
		replace E`year'1 = `multiplier'*E`year'1
		replace V`year'1 = `multiplier'*V`year'1
	
		matrix Y`year' 		= `multiplier'*Y`year'
		matrix E`year' 		= `multiplier'*E`year'
		matrix D`year' 		= D`year'

		save ${workdir}/Work/BBB_Direct_Pay_Model_Run_Output_and_Employment_Results_`year'_`runname', replace

	}


	preserve

	gen sector = ""

	replace sector = "11" if inlist(indnum,1,2)
	replace sector = "21" if inlist(indnum,3,4,5)
	replace sector = "22" if indnum == 6
	replace sector = "23" if indnum == 7
	replace sector = "31-33" if indnum >= 8 & indnum <= 26
	replace sector = "42" if indnum == 27
	replace sector = "44-45" if inlist(indnum,28,29,30,31)
	replace sector = "48-49" if indnum >= 32 & indnum <= 39
	replace sector = "51" if inlist(indnum,40,41,42,43)
	replace sector = "52" if inlist(indnum,44,45,46,47)
	replace sector = "53" if inlist(indnum,48,49,50)
	replace sector = "54" if inlist(indnum,51,52,53)
	replace sector = "55" if indnum == 54
	replace sector = "56" if inlist(indnum,55,56)
	replace sector = "61" if indnum == 57
	replace sector = "62" if inlist(indnum,58,59,60,61)
	replace sector = "71" if inlist(indnum,62,63)
	replace sector = "72" if inlist(indnum,64,65)
	replace sector = "81" if indnum == 66
	replace sector = "92" if inlist(indnum,67,68,69,70,71)

	collapse (sum) Y* E* D* V*, by(sector)
	reshape long Y E D V, i(sector) j(year)

	replace year = floor(year/10)

	* Convert back to 2022 dollars
	replace Y 	= Y*(120.695835/113.648)
	replace V 	= V*(120.695835/113.648)

	collapse (sum) Y* E* D* V*, by(sector)
	
	replace E = floor(E)
	replace E = 0 if E < 0
	
	replace D = floor(D)
	replace D = 0 if D < 0
	
	rename E Emp_`runname'
	rename D Dir_Emp_`runname'
	keep sector Emp_`runname' Dir_Emp_`runname'
	

	save ${workdir}/Work/BBB_Direct_Pay_Model_Run_Final_Results_by_Sector_`runname', replace

	restore
	

	collapse (sum) Y* E* D* V*
	gen n = _n
	reshape long Y E D V, i(n) j(year)
	drop n

	replace year = floor(year/10)

	* Convert back to 2022 dollars
	replace Y 	= Y*(120.695835/113.648)
	replace V 	= V*(120.695835/113.648)
	
	replace E = floor(E)
	replace V = floor(V)
	
	rename E Emp_`runname'
	rename V GDP_`runname'
	
	keep year Emp_`runname' GDP_`runname'

	* Save final results
	save ${workdir}/Work/BBB_Direct_Pay_Model_Run_Final_Results_`runname', replace
	
	* Delete temporary files
	foreach year of numlist 2022(1)2031 {
		erase ${workdir}/Work/BBB_Direct_Pay_Model_Run_Output_and_Employment_Results_`year'_`runname'.dta
	}
	
}

/**********************/
/* MERGE OUTPUT FILES */
/**********************/

use ${workdir}/Work/BBB_Direct_Pay_Model_Run_Final_Results_by_Sector_No_Direct_Pay_Scenario, clear
merge 1:1 sector using ${workdir}/Work/BBB_Direct_Pay_Model_Run_Final_Results_by_Sector_Direct_Pay_Scenario
drop _merge

gsort -Emp_No_Direct_Pay_Scenario

erase ${workdir}/Work/BBB_Direct_Pay_Model_Run_Final_Results_by_Sector_No_Direct_Pay_Scenario.dta
erase ${workdir}/Work/BBB_Direct_Pay_Model_Run_Final_Results_by_Sector_Direct_Pay_Scenario.dta

save ${workdir}/Output/BBB_Direct_Pay_Model_Run_Final_Results_by_Sector, replace


use ${workdir}/Work/BBB_Direct_Pay_Model_Run_Final_Results_No_Direct_Pay_Scenario, clear
merge 1:1 year using ${workdir}/Work/BBB_Direct_Pay_Model_Run_Final_Results_Direct_Pay_Scenario
drop _merge

gen Emp_Diff = Emp_Direct_Pay_Scenario - Emp_No_Direct_Pay_Scenario
gen GDP_Diff = GDP_Direct_Pay_Scenario - GDP_No_Direct_Pay_Scenario

gen GDP_No_Direct_Pay_Scenario_Bil = round(GDP_No_Direct_Pay_Scenario/1000000000,0.1)
gen GDP_Direct_Pay_Scenario_Bil = round(GDP_Direct_Pay_Scenario/1000000000,0.1)
gen GDP_Diff_Bil = round(GDP_Diff/1000000000,0.1)

format GDP_No_Direct_Pay_Scenario %9.1f
format GDP_Direct_Pay_Scenario %9.1f
format GDP_Diff %9.1f

keep year Emp_No_Direct_Pay_Scenario Emp_Direct_Pay_Scenario Emp_Diff GDP_No_Direct_Pay_Scenario_Bil GDP_Direct_Pay_Scenario_Bil GDP_Diff_Bil
order year Emp_No_Direct_Pay_Scenario Emp_Direct_Pay_Scenario Emp_Diff GDP_No_Direct_Pay_Scenario_Bil GDP_Direct_Pay_Scenario_Bil GDP_Diff_Bil


save ${workdir}/Output/BBB_Direct_Pay_Model_Run_Final_Results, replace

erase ${workdir}/Work/BBB_Direct_Pay_Model_Run_Final_Results_No_Direct_Pay_Scenario.dta
erase ${workdir}/Work/BBB_Direct_Pay_Model_Run_Final_Results_Direct_Pay_Scenario.dta
