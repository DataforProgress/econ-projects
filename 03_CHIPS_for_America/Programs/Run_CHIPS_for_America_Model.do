
/*************************************************************************/
*  PROJECT:    		CHIPS for America Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Run_CHIPS_for_America_Model.do
*  LAST UPDATED: 	3/9/23
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
global workdir = "/Users/Matt/Documents/Data_for_Progress/CHIPS_for_America/Github"
cd $workdir


/******************/
/* CLEAN RAW DATA */
/******************/

* First, call program that cleans BEA data on employment, output, and value-added by industry
* Generates ratios needed for model implementation below

do ${workdir}/Programs/Calculate_BEA_Employment_Output_and_Value_Added_Output_Ratios.do


* Cleaning the CHIPS for America data proceeds as follows:

* 1) We begin by reading in our manual categorization of spending by industry for the 
*	 subsections of USICA that contain emergency appropriations for implementation of 
*	 the Creating Helpful Incentives to Produce Semiconductors (CHIPS) for America Act, 
*	 enacted by Congress as part of the FY 2021 National Defense Authorization Act;

* 2) Using this categorization, we compute the share of funds in each section that go to each industry;

* 3) We then collapse to the industry-by-year level and adjust for expected future inflation

* This yields vectors containing total CHIPS Act spending by industry for each year from 2022 to 2027, 
* which we then feed into our input-output model to obtain estimates of employment and GDP impacts

import excel using ${workdir}/Data/CHIPS_for_America_Industry_Coding.xlsx, firstrow clear

drop J

rename E Spending2022
rename F Spending2023
rename G Spending2024
rename H Spending2025
rename I Spending2026

drop BillSubsection

foreach year of numlist 2022(1)2026 {
	replace Spending`year' = Spending`year'*Weight
}

drop Weight

* Calculate nominal spending by year
preserve
collapse (sum) Spending*, by(Fund)
set obs 4
replace Fund = "Total" if _n == 4
foreach year of numlist 2022(1)2026 {
	replace Spending`year' = Spending`year'[1] + Spending`year'[2] + Spending`year'[3] if _n == 4
}
egen SpendingTotal = rowtotal(Spending*)
save ${workdir}/Output/CHIPS_for_America_Spending_by_Fiscal_Year, replace
restore

collapse (sum) Spending*, by(IndustryCode)
rename IndustryCode beaiocodes


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


* Generate spending vectors

merge 1:1 beaiocodes using ${workdir}/Data/All_BEAIOCodes.dta
sort num
drop _merge

foreach year of numlist 2022(1)2026 {
	replace Spending`year' = 0 if Spending`year' == .
}

drop if _n > 71

save ${workdir}/Work/CHIPS_for_America_Spending_by_Industry_2022-2026, replace


/****************************************************/
/* CREATE LEONTIEF AND DIRECT REQUIREMENTS MATRICES */
/****************************************************/

* Create Leontief matrix from BEA domestic requirements table for 2020

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


/*************************************************************/
/* CALCULATE OUTPUT, EMPLOYMENT, AND GDP EFFECTS (2022-2027) */
/*************************************************************/

use ${workdir}/Work/CHIPS_for_America_Spending_by_Industry_2022-2026, clear

foreach year of numlist 2022(1)2026 {
	mkmat Spending`year', matrix(Exp`year')
}

local multiplier = 1.4

rename beaiocodes iocode

foreach year of numlist 2022(1)2026 {
		
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
	matrix Enomult`year' = e`year'*Leontief*Exp`year'
	mata: st_matrix("Esum`year'",colsum(st_matrix("E`year'")))
	matrix list Esum`year'
	
	* Feed in vector of spending and calculate direct employment effect
	matrix D`year' = e`year'*A*Exp`year'
	mata: st_matrix("Dsum`year'",colsum(st_matrix("D`year'")))
	matrix list Dsum`year'

	* Save expenditure vector
	svmat Exp`year'
	
	* Save output, employment, and wage vectors
	svmat Y`year'
	svmat V`year'
	svmat Enomult`year'
	svmat D`year'
	
	* Apply multiplier to variables and matrices to get induced effects where needed
	replace Y`year'1 = `multiplier'*Y`year'1
	replace V`year'1 = `multiplier'*V`year'1
	gen Emult`year'1 = `multiplier'*Enomult`year'1
	
	matrix Y`year' 			= `multiplier'*Y`year'
	matrix Enomult`year' 	= Enomult`year'
	matrix Emult`year' 		= `multiplier'*Enomult`year'
	matrix D`year' 			= D`year'

	save ${workdir}/Work/CHIPS_for_America_Model_Run_Output_and_Employment_Results_`year', replace

}


collapse (sum) Y* Enomult* Emult* D* V*
gen n = _n
reshape long Y Enomult Emult D V Exp, i(n) j(year)
drop n

replace year = floor(year/10)

* Convert back to 2022 dollars
replace Y 		= Y*(120.695835/113.633)
replace Exp 	= Exp*(120.695835/113.633)
replace V 		= V*(120.695835/113.633)

* Calculate totals across all years
set obs 6
tostring(year), replace
replace year = "Total" if _n == 6

drop Y Exp

gen EmploymentIndirect = Enomult - D
gen EmploymentInduced = Emult - Enomult

rename Emult EmploymentTotal
rename D EmploymentDirect
rename V GDP

replace EmploymentDirect	= round(EmploymentDirect,1)
replace EmploymentIndirect	= round(EmploymentIndirect,1)
replace EmploymentInduced	= round(EmploymentInduced,1)
replace EmploymentTotal		= round(EmploymentTotal,1)
replace GDP  				= round(GDP/1000000000,0.01)

foreach var of varlist EmploymentDirect EmploymentIndirect EmploymentInduced EmploymentTotal GDP {
	gen cumulative`var' = sum(`var')
	replace `var' = cumulative`var' if year == "Total"
	drop cumulative`var'
}

keep year EmploymentDirect EmploymentIndirect EmploymentInduced EmploymentTotal GDP
order year EmploymentDirect EmploymentIndirect EmploymentInduced EmploymentTotal GDP

save ${workdir}/Output/CHIPS_for_America_Model_Run_Final_Results, replace

* Delete temporary files
foreach year of numlist 2022(1)2026 {
	erase ${workdir}/Work/CHIPS_for_America_Model_Run_Output_and_Employment_Results_`year'.dta
}


/*******************************/
/* ALLOCATE JOBS ACROSS STATES */
/*******************************/

* Call program that calculates the share of each state's employment in each BEA industry, 
* as measured in the 2019 American Community Survey (ACS)

preserve
do ${workdir}/Programs/Calculate_State_Industry_Shares.do
restore

* Call program that calculates the share of each state's employment in each BEA industry, 
* as measured in the 2019 American Community Survey (ACS)

preserve
do ${workdir}/Programs/Calculate_State_Semiconductor_Industry_Shares.do
restore

drop *

* Allocate direct jobs across states in proportion to existing geographic distribution 
* of semiconductor employment, and indirect/induced jobs in proportion to existing 
* geographic distribution of employment in each industry

* Calculate indirect effects left over after subtracting off the direct effects
matrix Indirect2022 = Enomult2022 - D2022
matrix Indirect2023 = Enomult2023 - D2023
matrix Indirect2024 = Enomult2024 - D2024
matrix Indirect2025 = Enomult2025 - D2025
matrix Indirect2026 = Enomult2026 - D2026

* Calculate indirect and induced effects left over after subtracting off the direct effects
matrix EmultMinusD2022 = Emult2022 - D2022
matrix EmultMinusD2023 = Emult2023 - D2023
matrix EmultMinusD2024 = Emult2024 - D2024
matrix EmultMinusD2025 = Emult2025 - D2025
matrix EmultMinusD2026 = Emult2026 - D2026

* New allocation method
matrix S2022 = stateindshares*EmultMinusD2022 + statesemiindshares*D2022
matrix S2023 = stateindshares*EmultMinusD2023 + statesemiindshares*D2023
matrix S2024 = stateindshares*EmultMinusD2024 + statesemiindshares*D2024
matrix S2025 = stateindshares*EmultMinusD2025 + statesemiindshares*D2025
matrix S2026 = stateindshares*EmultMinusD2026 + statesemiindshares*D2026

* Direct jobs by state
matrix SD2022 = statesemiindshares*D2022
matrix SD2023 = statesemiindshares*D2023
matrix SD2024 = statesemiindshares*D2024
matrix SD2025 = statesemiindshares*D2025
matrix SD2026 = statesemiindshares*D2026

* Indirect jobs by state
matrix SIndirect2022 = stateindshares*Indirect2022
matrix SIndirect2023 = stateindshares*Indirect2023
matrix SIndirect2024 = stateindshares*Indirect2024
matrix SIndirect2025 = stateindshares*Indirect2025
matrix SIndirect2026 = stateindshares*Indirect2026

* Indirect/induced jobs by state
matrix STotMinusD2022 = stateindshares*EmultMinusD2022
matrix STotMinusD2023 = stateindshares*EmultMinusD2023
matrix STotMinusD2024 = stateindshares*EmultMinusD2024
matrix STotMinusD2025 = stateindshares*EmultMinusD2025
matrix STotMinusD2026 = stateindshares*EmultMinusD2026

svmat S2022
svmat S2023
svmat S2024
svmat S2025
svmat S2026

svmat SD2022
svmat SD2023
svmat SD2024
svmat SD2025
svmat SD2026

svmat SIndirect2022
svmat SIndirect2023
svmat SIndirect2024
svmat SIndirect2025
svmat SIndirect2026

svmat STotMinusD2022
svmat STotMinusD2023
svmat STotMinusD2024
svmat STotMinusD2025
svmat STotMinusD2026

egen EmploymentTotal = rowtotal(S2022 S2023 S2024 S2025 S2026)
egen EmploymentDirect = rowtotal(SD*)
egen EmploymentIndirect = rowtotal(SIndirect*)
egen EmploymentTotMinusD = rowtotal(STotMinusD*)

gen EmploymentInduced = EmploymentTotMinusD - EmploymentIndirect

replace EmploymentDirect = round(EmploymentDirect,1)
replace EmploymentIndirect = round(EmploymentIndirect,1)
replace EmploymentInduced = round(EmploymentInduced,1)
replace EmploymentTotal = EmploymentDirect + EmploymentIndirect + EmploymentInduced

drop S20221 S20231 S20241 S20251 S20261 SD20221 SD20231 SD20241 SD20251 SD20261 ///
SIndirect20221 SIndirect20231 SIndirect20241 SIndirect20251 SIndirect20261 ///
STotMinusD20221 STotMinusD20231 STotMinusD20241 STotMinusD20251 STotMinusD20261 ///
EmploymentTotMinusD

* Merge in state FIPS codes
gen n = _n
merge 1:1 n using ${workdir}/Work/State_Industry_Employment
drop _merge

set obs 52
tostring(statefip), replace force
replace statefip = "Total" if _n == 52

foreach var of varlist EmploymentDirect EmploymentIndirect EmploymentInduced EmploymentTotal {
	gen cumulative`var' = sum(`var')
	replace `var' = cumulative`var' if statefip == "Total"
	drop cumulative`var'
}

keep statefip EmploymentDirect EmploymentIndirect EmploymentInduced EmploymentTotal
order statefip EmploymentDirect EmploymentIndirect EmploymentInduced EmploymentTotal

save ${workdir}/Output/CHIPS_for_America_Model_Run_Final_Results_by_State, replace
