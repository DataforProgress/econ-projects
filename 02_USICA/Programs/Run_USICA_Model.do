
/*************************************************************************/
*  PROJECT:    		USICA Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Run_USICA_Model.do
*  LAST UPDATED: 	2/14/23
*  OBJECTIVE: 		
*  NOTES: 			Before running, set local "run" to 0, 1, or 2 to obtain
*					results for the "Low Scenario," "Baseline Scenario," or
*					"High Scenario," as described below; and be sure to change
*					the working directory at the top of this program
/*************************************************************************/

clear
clear matrix
clear mata
set more off
set maxvar 100000

* Set working directory
global workdir = "/Users/Matt/Documents/Data_for_Progress/USICA/Github"
cd $workdir

* We perform three different runs of the model using different parameter values: 
* - Run "0" corresponds to the "Low Scenario" in the memo;
* - Run "1" to the "Baseline Scenario"; and
* - Run "2" to the "High Scenario"

* Before running this program, set the value of the local variable "run" to either 0, 1, or 2
local run = /*0*/ /*1*/ /*2*/


/******************/
/* CLEAN RAW DATA */
/******************/

* First, call program that cleans BEA data on employment, output, and value-added by industry
* Generates ratios needed for model implementation below

do ${workdir}/Programs/Calculate_BEA_Employment_Output_and_Value_Added_Output_Ratios.do


* Cleaning the USICA data proceeds as follows:

* 1) We begin by reading in our manual categorization of spending in different subsections of USICA
*    by industries based on descriptions of what the funds in each section are used for;

* 2) Using this categorization, we compute the share of funds in each section that go to each industry;

* 3) We then collapse to the industry-by-year level and adjust for expected future inflation

* This yields vectors containing total USICA spending by industry for each year from 2022 to 2027, 
* which we then feed into our input-output model to obtain estimates of employment and GDP impacts

import excel using ${workdir}/Data/USICA_Industry_Coding.xlsx, firstrow clear

rename E Spending2022
rename F Spending2023
rename G Spending2024
rename H Spending2025
rename I Spending2026
rename J Spending2027

drop BillSubsection Name PageNumberinPDF

foreach year of numlist 2022(1)2027 {
	replace Spending`year' = Spending`year'*Weight
}

drop Weight

collapse (sum) Spending*, by(IndustryCode)
rename IndustryCode beaiocodes

* Calculate nominal spending by year
preserve

collapse (sum) Spending*

foreach year of numlist 2022(1)2027 {
	replace Spending`year' = round(Spending`year'/1000000000,0.01)
}

egen SpendingTotal = rowtotal(Spending*)
save ${workdir}/Output/USICA_Total_Spending_by_Fiscal_Year, replace

restore


* Convert to 2020 dollars

* GDP deflators in FRED: 
* - 100 in 2012
* - 112.290 in 2019
* - 113.633 in 2020
* - 118.329 in 2021
* - 120.695835 in 2022
* - 123.1097517 in 2023
* - 125.5719467 in 2024
* - 128.0833857 in 2025
* - 130.6450534 in 2026
* - 133.2579544 in 2027

replace Spending2022 = Spending2022 / (120.695835/113.633)
replace Spending2023 = Spending2023 / (123.1097517/113.633)
replace Spending2024 = Spending2024 / (125.5719467/113.633)
replace Spending2025 = Spending2025 / (128.0833857/113.633)
replace Spending2026 = Spending2026 / (130.6450534/113.633)
replace Spending2027 = Spending2027 / (133.2579544/113.633)


* Generate spending vectors

merge 1:1 beaiocodes using ${workdir}/Data/All_BEAIOCodes.dta
sort num
drop _merge

foreach year of numlist 2022(1)2027 {
	replace Spending`year' = 0 if Spending`year' == .
}

drop if _n > 71

save ${workdir}/Output/USICA_Spending_by_Industry_2022-2027, replace


/****************************************************/
/* CREATE LEONTIEF AND DIRECT REQUIREMENTS MATRICES */
/****************************************************/

* Create Leontief matrix from BEA domestic requirements table for 2020

use ${workdir}/Data/BEA_Industry_by_Industry_Domestic_Requirements_2020, clear
	
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
	

/**************************************************************/
/* CALCULATE OUTPUT, EMPLOYMENT, AND WAGE EFFECTS (2022-2027) */
/**************************************************************/

use ${workdir}/Output/USICA_Spending_by_Industry_2022-2027, clear

foreach year of numlist 2022(1)2027 {
	mkmat Spending`year', matrix(Exp`year')
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

local multiplier = `multiplier'

rename beaiocodes iocode

foreach year of numlist 2022(1)2027 {
		
	* Feed in vector of spending and calculate aggregate output effect
	matrix Y`year' = Leontief*Exp`year'
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
	matrix V`year' = v`year'*Leontief*Exp`year'
	mata: st_matrix("Vsum`year'",colsum(st_matrix("V`year'")))
	matrix list Vsum`year'
	
	* Feed in vector of spending and calculate aggregate employment effect
	matrix E`year' = e`year'*Leontief*Exp`year'
	mata: st_matrix("Esum`year'",colsum(st_matrix("E`year'")))
	matrix list Esum`year'

	* Save expenditure vector
	svmat Exp`year'
	
	* Save output, employment, and wage vectors
	svmat Y`year'
	svmat E`year'
	svmat V`year'
	
	* Apply multiplier (induced effects) - to variables AND matrices
	replace Y`year'1 = `multiplier'*Y`year'1
	replace E`year'1 = `multiplier'*E`year'1
	replace V`year'1 = `multiplier'*V`year'1
	
	matrix Y`year' 		= `multiplier'*Y`year'
	matrix E`year' 		= `multiplier'*E`year'

	save ${workdir}/Work/USICA_Model_Run_Output_and_Employment_Results_`year'_`run', replace

}

if `run' == 0 {
	local runname = "Low_Scenario"
}

if `run' == 1 {
	local runname = "Baseline_Scenario"
}

if `run' == 2 {
	local runname = "High_Scenario"
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

collapse (sum) Y* E* V*, by(sector)
reshape long Y E V Exp, i(sector) j(year)

collapse (sum) Y E V Exp, by(sector)

* Convert back to 2022 dollars
replace Y 	= Y*(120.695835/113.633)
replace Exp = Exp*(120.695835/113.633)
replace V 	= V*(120.695835/113.633)

drop Y Exp V
replace E 	= round(E,1)

rename E Employment
gsort -Employment

save ${workdir}/Output/USICA_Model_Run_Final_Sector_Results_`runname', replace

restore


collapse (sum) Y* E* V*
gen n = _n
reshape long Y E V Exp, i(n) j(year)
*replace year = (year-1)/10
drop n

replace year = floor(year/10)

* Convert back to 2022 dollars
replace Y 	= Y*(120.695835/113.633)
replace Exp = Exp*(120.695835/113.633)
replace V 	= V*(120.695835/113.633)

* Calculate totals across all years
set obs 7
tostring(year), replace
replace year = "Total" if _n == 7

drop Y Exp
replace E	= round(E,1)
replace V 	= round(V/1000000000,0.01)

foreach var of varlist E V {
	gen cumulative`var' = sum(`var')
	replace `var' = cumulative`var' if year == "Total"
	drop cumulative`var'
}

rename E Employment
rename V GDP

* Save final results
save ${workdir}/Output/USICA_Model_Run_Final_Results_`runname', replace

* Calculate "cost per job created/preserved," 
* i.e. the ratio of total spending to number of jobs
preserve
collapse (sum) E
*gen Costperjob = 787233000000/E
gen Costperjob = 787.233/E
save ${workdir}/Output/USICA_Model_Run_Cost_Per_Job_`runname', replace
restore

* Delete temporary files (found in memo under section titled "Results of Validation")
foreach year of numlist 2022(1)2027 {
	erase ${workdir}/Work/USICA_Model_Run_Output_and_Employment_Results_`year'_`run'.dta
}


/*******************************/
/* ALLOCATE JOBS ACROSS STATES */
/*******************************/

* Call program that calculates the share of each state's employment in each BEA industry, 
* as measured in the 2019 American Community Survey (ACS)

preserve
do ${workdir}/Programs/Calculate_State_Industry_Shares.do
restore


* Allocate jobs across states in proportion to existing geographic distribution 
* of employment in each industry
matrix S2022 = stateindshares*E2022
matrix S2023 = stateindshares*E2023
matrix S2024 = stateindshares*E2024
matrix S2025 = stateindshares*E2025
matrix S2026 = stateindshares*E2026
matrix S2027 = stateindshares*E2027

svmat S2022
svmat S2023
svmat S2024
svmat S2025
svmat S2026
svmat S2027

egen S = rowtotal(S*)
replace S = round(S,1)

drop year Employment GDP S20221 S20231 S20241 S20251 S20261 S20271

rename S Employment

gen n = _n
merge 1:1 n using ${workdir}/Work/State_Industry_Employment
drop _merge

set obs 52
tostring(statefip), replace force
replace statefip = "Total" if _n == 52

foreach var of varlist Employment pop {
	gen cumulative`var' = sum(`var')
	replace `var' = cumulative`var' if statefip == "Total"
	drop cumulative`var'
}

gen MeanEmpFraction = (Employment/7)/pop
keep statefip Employment MeanEmpFraction
order statefip Employment MeanEmpFraction

save ${workdir}/Output/USICA_Model_Run_Final_State_Results_`runname', replace

