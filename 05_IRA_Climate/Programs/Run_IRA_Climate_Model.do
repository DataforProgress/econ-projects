
/***********************************************************************************************/
*  PROJECT:    		IRA Climate Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Run_IRA_Climate_Model.do
*  LAST UPDATED: 	5/24/23
*
*  NOTES: 			Before running, be sure to change the working directory 
*					at the top of this program		
*
*					Calls the following programs:
*					- Calculate_BEA_Employment_Output_and_Value_Added_Output_Ratios.do
*					- Clean_Domestic_Requirements_Table_2021.do
*					- Calculate_Output_and_Employment_Effects_by_Category.do
*					- Calculate_State_Industry_Shares.do
*					- Calculate_Other_State_Shares.do
*					- Allocate_Jobs_Across_States.do
*
*					Jobs are allocated across states using the following procedure:
* 					- Indirect/induced jobs are allocated in proportion to state employment in 
*					every industry as measured in 2021 ACS;
* 					- Direct jobs are allocated in the same way for those sections of the bill
* 					that do not specify how funds will be distributed geographically; for those
* 					that do have such stipulations, we allocate direct jobs as described in
*					greater detail below
*
/***********************************************************************************************/

clear
clear matrix
clear mata
set more off
set maxvar 100000

global directory = "/Users/Matt/Documents/Data_for_Progress/IRA_Climate/Github"

global datadir = "$directory/Data"
global outputdir = "$directory/Output"
global programsdir = "$directory/Programs"
global workdir = "$directory/Work"

cd $workdir


/*****************************/
/* RUN OTHER NEEDED PROGRAMS */
/*****************************/

* First, call program that cleans BEA data on employment, output, and value-added by industry
* Generates ratios needed for model implementation below

do ${programsdir}/Calculate_BEA_Employment_Output_and_Value_Added_Output_Ratios.do


* Next, call program that cleans 2021 "domestic requirements table" from BEA
* Generates variables needed to construct input-output matrix below

do ${programsdir}/Clean_Domestic_Requirements_Table_2021.do


/**********************************/
/* CALCULATE SPENDING BY INDUSTRY */
/**********************************/

* Clean IRA climate spending
import excel using ${datadir}/IRA_Climate_Industry_Coding.xlsx, firstrow clear

rename I Spending2023
rename J Spending2024
rename K Spending2025
rename L Spending2026
rename M Spending2027
rename N Spending2028
rename O Spending2029
rename P Spending2030
rename Q Spending2031
rename R Spending2032

drop if inlist(Section,"13103","13901","60113(c).1","50261; 50262; 50264")

destring(Spending*), replace force

foreach year of numlist 2023(1)2032 {
	replace Spending`year' = Spending`year'*1000000
	gen SpendingTot`year' = Spending`year'*Weight*(1/FederalShare)
	gen SpendingPub`year' = Spending`year'*Weight
}

drop Weight


* Calculate nominal spending by category and section
preserve

* Combine programs bundled together in the same section
replace Section = "13502" if inlist(Section,"13502.1","13502.2","13502.3","13502.4")
replace Section = "13204" if inlist(Section,"13204.1","13204.2","13204.3")
replace Program = "Environmental Quality Incentives Program (EQIP)" if Section == "21001"

collapse (sum) SpendingPub*, by(CategoryNum Category Section Program)

egen SpendingPubTotal = rowtotal(SpendingPub*)
gen SpendingPubTotal_Mil = SpendingPubTotal/1000000

keep CategoryNum Category Section Program SpendingPubTotal_Mil

* Manually fix entry for which rounded weights sum to slightly more than one
replace SpendingPubTotal_Mil = 6255 if Section == "13501"

* Calculate total public spending
set obs 88
replace Section = "TOTAL" if _n == 88
gen SpendingPubTotal_Mil2 = sum(SpendingPubTotal_Mil)
replace SpendingPubTotal_Mil = SpendingPubTotal_Mil2 if Section == "TOTAL"
drop SpendingPubTotal_Mil2

save ${outputdir}/IRA_Climate_Total_Spending_by_Category_and_Section, replace

restore


collapse (sum) SpendingTot* SpendingPub*, by(IndustryCode)
rename IndustryCode beaiocodes

* Convert to 2021 dollars
* GDP deflators in FRED (assumes 3% inflation in the long run on the basis of Survey of Professional Forecasters, https://www.philadelphiafed.org/surveys-and-data/real-time-data-research/inflation-forecasts): 
* - 100 in 2012
* - 111.873 in 2019
* - 113.206 in 2020
* - 117.021 in 2021
* - 125.541 in 2022
* - 129.30723 in 2023
* - 133.1864469 in 2024
* - 137.1820403 in 2025
* - 141.2975015 in 2026
* - 145.5364266 in 2027
* - 149.9025194 in 2028
* - 154.3995949 in 2029
* - 159.0315828 in 2030
* - 163.8025303 in 2031
* - 168.7166062 in 2032

rename SpendingTot2023 Spending2023
rename SpendingTot2024 Spending2024
rename SpendingTot2025 Spending2025
rename SpendingTot2026 Spending2026
rename SpendingTot2027 Spending2027
rename SpendingTot2028 Spending2028
rename SpendingTot2029 Spending2029
rename SpendingTot2030 Spending2030
rename SpendingTot2031 Spending2031
rename SpendingTot2032 Spending2032

drop SpendingPub*

replace Spending2023 = Spending2023 / (129.30723/117.021)
replace Spending2024 = Spending2024 / (133.1864469/117.021)
replace Spending2025 = Spending2025 / (137.1820403/117.021)
replace Spending2026 = Spending2026 / (141.2975015/117.021)
replace Spending2027 = Spending2027 / (145.5364266/117.021)
replace Spending2028 = Spending2028 / (149.9025194/117.021)
replace Spending2029 = Spending2029 / (154.3995949/117.021)
replace Spending2030 = Spending2030 / (159.0315828/117.021)
replace Spending2031 = Spending2031 / (163.8025303/117.021)
replace Spending2032 = Spending2032 / (168.7166062/117.021)

merge 1:1 beaiocodes using ${datadir}/All_BEAIOCodes.dta
sort num
drop _merge

foreach year of numlist 2023(1)2032 {
	replace Spending`year' = 0 if Spending`year' == .
}

save ${workdir}/IRA_Climate_Spending_by_Industry, replace


/***********************************************/
/* CALCULATE SPENDING BY INDUSTRY AND CATEGORY */
/***********************************************/

* Clean IRA climate spending
import excel using ${datadir}/IRA_Climate_Industry_Coding.xlsx, firstrow clear

rename I Spending2023
rename J Spending2024
rename K Spending2025
rename L Spending2026
rename M Spending2027
rename N Spending2028
rename O Spending2029
rename P Spending2030
rename Q Spending2031
rename R Spending2032

drop if inlist(Section,"13103","13901","60113(c).1","50261; 50262; 50264")

destring(Spending*), replace force

foreach year of numlist 2023(1)2032 {
	replace Spending`year' = Spending`year'*1000000
	gen SpendingTot`year' = Spending`year'*Weight*(1/FederalShare)
	gen SpendingPub`year' = Spending`year'*Weight
}

drop Weight

collapse (sum) SpendingTot* SpendingPub*, by(IndustryCode Category CategoryNum)
rename IndustryCode beaiocodes

* Calculate nominal spending by year and category
preserve
collapse (sum) SpendingTot* SpendingPub*, by(Category CategoryNum)
sort CategoryNum
foreach year of numlist 2023(1)2032{
	gen SpendingTot`year'_Bil = SpendingTot`year' / 1000000000
	gen SpendingPub`year'_Bil = SpendingPub`year' / 1000000000
	drop SpendingTot`year'
	drop SpendingPub`year'
}

egen double SpendingTot_Bil = rowtotal(SpendingTot*)
egen double SpendingPub_Bil = rowtotal(SpendingPub*)

foreach var of varlist SpendingTot* SpendingPub* {
	replace `var' = round(`var',0.1)
}

set obs 8
replace Category = "Total" if _n == 8

foreach var of varlist SpendingTot* SpendingPub* {
	gen double `var'2 = sum(`var')
	replace `var' = `var'2 if _n == 8
	drop `var'2
}

order CategoryNum Category SpendingPub* SpendingTot*

save ${outputdir}/IRA_Climate_Total_Spending_by_Fiscal_Year_and_Category, replace
restore


foreach categorynum of numlist 1(1)7 {
	
	preserve
	
	keep if CategoryNum == `categorynum'

	* Convert to 2021 dollars
	* GDP deflators in FRED (assumes 3% inflation in the long run on the basis of Survey of Professional Forecasters, 
	* https://www.philadelphiafed.org/surveys-and-data/real-time-data-research/inflation-forecasts): 
	* - 100 in 2012
	* - 111.873 in 2019
	* - 113.206 in 2020
	* - 117.021 in 2021
	* - 125.541 in 2022
	* - 129.30723 in 2023
	* - 133.1864469 in 2024
	* - 137.1820403 in 2025
	* - 141.2975015 in 2026
	* - 145.5364266 in 2027
	* - 149.9025194 in 2028
	* - 154.3995949 in 2029
	* - 159.0315828 in 2030
	* - 163.8025303 in 2031
	* - 168.7166062 in 2032

	rename SpendingTot2023 Spending2023
	rename SpendingTot2024 Spending2024
	rename SpendingTot2025 Spending2025
	rename SpendingTot2026 Spending2026
	rename SpendingTot2027 Spending2027
	rename SpendingTot2028 Spending2028
	rename SpendingTot2029 Spending2029
	rename SpendingTot2030 Spending2030
	rename SpendingTot2031 Spending2031
	rename SpendingTot2032 Spending2032

	drop SpendingPub*

	replace Spending2023 = Spending2023 / (129.30723/117.021)
	replace Spending2024 = Spending2024 / (133.1864469/117.021)
	replace Spending2025 = Spending2025 / (137.1820403/117.021)
	replace Spending2026 = Spending2026 / (141.2975015/117.021)
	replace Spending2027 = Spending2027 / (145.5364266/117.021)
	replace Spending2028 = Spending2028 / (149.9025194/117.021)
	replace Spending2029 = Spending2029 / (154.3995949/117.021)
	replace Spending2030 = Spending2030 / (159.0315828/117.021)
	replace Spending2031 = Spending2031 / (163.8025303/117.021)
	replace Spending2032 = Spending2032 / (168.7166062/117.021)

	merge 1:1 beaiocodes using ${datadir}/All_BEAIOCodes.dta
	sort num
	drop _merge

	foreach year of numlist 2023(1)2032 {
		replace Spending`year' = 0 if Spending`year' == .
	}

	save ${workdir}/IRA_Climate_Spending_by_Industry_Category_`categorynum', replace

	restore
	
}


/***********************************************************/
/* DEFINE SYNTHETIC INDUSTRIES AND CREATE SPENDING VECTORS */
/***********************************************************/

* In order to feed expenditures on renewables into the model we need to make 
* assumptions about how these should be allocated across industries. For this
* we draw on the "synthetic industry" approach (c.f. Garrett-Peltier (2016), 
* "Green versus brown: Comparing the employment impacts of energy efficiency, 
* renewable energy, and fossil fuels using an input-output model," Economic 
* Modelling 61)

* Using this technique and the references in Garrett-Peltier (2016), we 
* construct vectors of weights that describe how a dollar of spending on 
* different synthetic industries should be allocated across the industries that 
* are observable in the BEA I-O tables

* Bioenergy (Pollin et al. 2015)
matrix BioenergyP = J(71,1,0)
matrix BioenergyP[1,1] = 0.250 /* Farms */
matrix BioenergyP[2,1] = 0.250 /* Forestry, fishing, and related activities */
matrix BioenergyP[7,1] = 0.250 /* Construction */
matrix BioenergyP[25,1] = 0.125 /* Chemical products */
matrix BioenergyP[53,1] = 0.125 /* Miscellaneous professional, scientific, and technical services */

* Biomass (Garrett-Peltier 2011) 
matrix Biomass = J(71,1,0) 
matrix Biomass[1,1] = 0.25 /* Farm products (unprocessed) */
matrix Biomass[2,1] = 0.25 /* Forestry,fishing and related */
matrix Biomass[7,1] = 0.25 /* Construction */
matrix Biomass[25,1] = 0.125 /* Chemical products */
matrix Biomass[53,1] = 0.125 /* Miscellaneous professional, scientific and technical services */

* Coal (Garrett-Peltier 2011)
matrix Coal = J(71,1,0)
matrix Coal[4,1] = 0.44 /* Coal mining (mining, except oil and gas) */
matrix Coal[5,1] = 0.08 /* Support activities for extraction and mining */
matrix Coal[24,1] = 0.48 /* Petroleum and coal products */

* Coal (Pollin et al. 2015)
matrix CoalP = J(71,1,0)
matrix CoalP[4,1] = 0.500 /* Mining, except oil and gas */
matrix CoalP[24,1] = 0.500 /* Petroleum and coal products */

* Geothermal (Pollin et al. 2015)
matrix GeothermalP = J(71,1,0)
matrix GeothermalP[5,1] = 0.150 /* Support activities for mining */
matrix GeothermalP[7,1] = 0.450 /* Construction */
matrix GeothermalP[12,1] = 0.100 /* Machinery */
matrix GeothermalP[53,1] = 0.300 /* Miscellaneous professional, scientific, and technical services */

* Hydro (small) (Pollin et al. 2015)
matrix HydroP = J(71,1,0)
matrix HydroP[7,1] = 0.180 /* Construction */
matrix HydroP[11,1] = 0.180 /* Fabricated metal products */
matrix HydroP[12,1] = 0.070 /* Machinery */
matrix HydroP[14,1] = 0.140 /* Electrical equipment, appliances, and components */
matrix HydroP[53,1] = 0.430 /* Miscellaneous professional, scientific, and technical services */

* Nuclear (Authors' calculations ased on Black and Veatch 2012, "Cost and 
* Performance Data for Power Generation Technologies: Prepared for the National 
* Renewable Energy Laboratory," pg. 11)
matrix Nuclear = J(71,1,0)
matrix Nuclear[7,1] = 0.25 /* Construction */
matrix Nuclear[11,1] = 0.10 /* Fabricated metal products */
matrix Nuclear[12,1] = 0.10 /* Machinery */
matrix Nuclear[13,1] = 0.10 /* Computer and electronic products */
matrix Nuclear[14,1] = 0.10 /* Electrical equipment, appliances, and components */
matrix Nuclear[53,1] = 0.15 /* Miscellaneous professional, scientific, and technical services */
matrix Nuclear[54,1] = 0.20 /* Management of companies and enterprises */

* Oil & Gas (Garrett-Peltier 2011)
matrix OilGas = J(71,1,0)
matrix OilGas[3,1] = 0.3 /* Oil and gas extraction */
matrix OilGas[5,1] = 0.04 /* Support activities for extraction and mining */
matrix OilGas[6,1] = 0.1 /* Natural gas distribution (utilities) */
matrix OilGas[24,1] = 0.53 /* Petroleum and coal products */
matrix OilGas[37,1] = 0.03 /* Pipeline transportation */

* Oil and Gas (Pollin et al. 2015)
matrix OilGasP = J(71,1,0)
matrix OilGasP[3,1] = 0.500 /* Oil and gas extraction */
matrix OilGasP[24,1] = 0.250 /* Petroleum and coal products */
matrix OilGasP[37,1] = 0.250 /* Pipeline transportation */

* Smart Grid (Garrett-Peltier 2011)  
matrix SmartGrid = J(71,1,0)
matrix SmartGrid[7,1] = 0.25 /* Construction */
matrix SmartGrid[12,1] = 0.25 /* Machinery */
matrix SmartGrid[13,1] = 0.25 /* Computer and electronic products */
matrix SmartGrid[14,1] = 0.25 /* Electrical equipment, appliances, and components */

* Solar (Garrett-Peltier 2011)  
matrix Solar = J(71,1,0)
matrix Solar[7,1] = 0.3 /* Construction */
matrix Solar[11,1] = 0.175 /* Fabricated metal products */
matrix Solar[13,1] = 0.175 /* Computer and electronic products */
matrix Solar[14,1] = 0.175 /* Electrical equipment, appliances, and components */
matrix Solar[53,1] = 0.175 /* Miscellaneous professional, scientific and technical services */

* Wind (Garrett-Peltier 2011)  
matrix Wind = J(71,1,0)
matrix Wind[7,1] = 0.26 /* Construction */
matrix Wind[11,1] = 0.12 /* Fabricated metal products */
matrix Wind[12,1] = 0.37 /* Machinery */
matrix Wind[13,1] = 0.03 /* Computer and electronic products */
matrix Wind[14,1] = 0.03 /* Electrical equipment, appliances, and components */
matrix Wind[26,1] = 0.12 /* Plastics and rubber products */
matrix Wind[53,1] = 0.07 /* Miscellaneous professional, scientific and technical services */

* Other Non-renewables (Authors' calculations)
matrix Nonrenewables = J(71,1,0)
matrix Nonrenewables = 0.25*Coal + 0.25*Nuclear + 0.5*OilGas

* Other Renewables (Authors' calculations)
matrix Renewables = J(71,1,0)
matrix Renewables = 0.2*Biomass + 0.2*GeothermalP + 0.2*HydroP + 0.2*Solar + 0.2*Wind


/****************************************/
/* CALCULATE EXPENDITURES FOR EACH YEAR */
/****************************************/

use ${workdir}/IRA_Climate_Spending_by_Industry, clear

foreach year of numlist 2023(1)2032 {
	
	qui summ Spending`year' if beaiocodes == "BioenergyP"
	global BioenergyP`year' = `r(mean)'
	matrix BioenergyP`year' = ${BioenergyP`year'}*BioenergyP
	
	qui summ Spending`year' if beaiocodes == "CoalP"
	global CoalP`year' = `r(mean)'
	matrix CoalP`year' = ${CoalP`year'}*CoalP
	
	qui summ Spending`year' if beaiocodes == "Nonrenewables"
	global Nonrenewables`year' = `r(mean)'
	matrix Nonrenewables`year' = ${Nonrenewables`year'}*Nonrenewables
	
	qui summ Spending`year' if beaiocodes == "Nuclear"
	global Nuclear`year' = `r(mean)'
	matrix Nuclear`year' = ${Nuclear`year'}*Nuclear
	
	qui summ Spending`year' if beaiocodes == "OilGasP"
	global OilGasP`year' = `r(mean)'
	matrix OilGasP`year' = ${OilGasP`year'}*OilGasP
	
	qui summ Spending`year' if beaiocodes == "Renewables"
	global Renewables`year' = `r(mean)'
	matrix Renewables`year' = ${Renewables`year'}*Renewables
	
	qui summ Spending`year' if beaiocodes == "SmartGrid"
	global SmartGrid`year' = `r(mean)'
	matrix SmartGrid`year' = ${SmartGrid`year'}*SmartGrid
	
	qui summ Spending`year' if beaiocodes == "Solar"
	global Solar`year' = `r(mean)'
	matrix Solar`year' = ${Solar`year'}*Solar

}

drop if _n > 71

foreach year of numlist 2023(1)2032 {
	mkmat Spending`year', matrix(Exp`year'_beaiocodes)
}

* Calculate total expenditures by year
foreach year of numlist 2023(1)2032 {
	matrix Exp`year' = Exp`year'_beaiocodes + BioenergyP`year' + CoalP`year' + Nonrenewables`year' + Nuclear`year' + OilGasP`year' + Renewables`year' + SmartGrid`year' + Solar`year'
}


/***************************/
/* BASELINE DOMESTIC MODEL */
/***************************/

* Create Leontief matrix

use ${datadir}/BEA_Industry_by_Industry_Domestic_Requirements_2021.dta, clear
	
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
	

/*******************************************************/
/* CALCULATE OUTPUT AND EMPLOYMENT EFFECTS (2023-2032) */
/*******************************************************/

local multiplier = 1.4

foreach year of numlist 2023(1)2032 {
		
	* Feed in vector of spending and calculate aggregate output effect
	matrix Y`year' = Leontief*Exp`year'
	mata: st_matrix("Ysum`year'",colsum(st_matrix("Y`year'")))
	matrix list Ysum`year'

	* Merge in employment/output and VA/output ratios
	merge 1:1 iocode using ${workdir}/BEA_EO_and_VAO_Ratios_by_Industry_Cleaned_2021
	sort indnum
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
	
	* Feed in vector of spending and calculate direct employment effect
	matrix D`year' = e`year'*A*Exp`year'
	mata: st_matrix("Dsum`year'",colsum(st_matrix("D`year'")))
	matrix list Dsum`year'

	* Save expenditure vector
	svmat Exp`year'
	
	* Save output, employment, and wage vectors
	svmat Y`year'
	svmat E`year'
	svmat V`year'
	svmat D`year'
	
	* Apply multiplier (induced effects) - to variables AND matrices
	gen double Emult`year'1 = `multiplier'*E`year'1
	gen double Vmult`year'1 = `multiplier'*V`year'1
	
	matrix Emult`year' 			= `multiplier'*E`year'
	matrix Vmult`year' 			= `multiplier'*V`year'

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

collapse (sum) E*, by(sector)
reshape long Emult, i(sector) j(year)

replace year = floor(year/10)

collapse (sum) Emult, by(sector)

gen EmploymentAvg = round(Emult/10)
keep sector EmploymentAvg
order sector EmploymentAvg
gsort -EmploymentAvg

save ${outputdir}/IRA_Climate_Model_Run_Final_Results_by_Sector, replace

restore


collapse (sum) Y* E* V* D*
gen n = _n
reshape long D E Emult Vmult, i(n) j(year)
drop n

replace year = floor(year/10)

* Convert back to 2022 dollars
replace Vmult 	= Vmult*(125.541/117.021)

rename E EmploymentDirectIndirect
rename Emult EmploymentTotal
rename D EmploymentDirect
rename Vmult GDP

gen EmploymentIndirect = EmploymentDirectIndirect - EmploymentDirect
gen EmploymentInduced = EmploymentTotal - EmploymentIndirect - EmploymentDirect

set obs 11
tostring(year), replace force

* Save employment results
preserve

replace year = "Average" if _n == 11

foreach var of varlist EmploymentDirect EmploymentIndirect EmploymentInduced EmploymentTotal {
	egen mean`var' = mean(`var')
	replace `var' = mean`var' if year == "Average"
	drop mean`var'
}

replace EmploymentDirect	= round(EmploymentDirect,1)
replace EmploymentIndirect	= round(EmploymentIndirect,1)
replace EmploymentInduced	= round(EmploymentInduced,1)
replace EmploymentTotal		= round(EmploymentTotal,1)

keep year EmploymentDirect EmploymentIndirect EmploymentInduced EmploymentTotal
order year EmploymentDirect EmploymentIndirect EmploymentInduced EmploymentTotal

save ${outputdir}/IRA_Climate_Model_Run_Final_Results_Employment, replace

restore

* Save GDP results
preserve

replace year = "Total" if _n == 11

egen cumulativeGDP = sum(GDP)
replace GDP = cumulativeGDP if year == "Total"
drop cumulativeGDP

gen GDP_Bil = round(GDP/1000000000,0.01)

keep year GDP_Bil
order year GDP_Bil

save ${outputdir}/IRA_Climate_Model_Run_Final_Results_GDP, replace

restore


/*******************************************************************/
/* CALCULATE OUTPUT AND EMPLOYMENT EFFECTS BY CATEGORY (2023-2032) */
/*******************************************************************/

* Call program that runs model separately for each of seven major categories
* of climate-related spending in the IRA

do ${programsdir}/Calculate_Output_and_Employment_Effects_by_Category.do


/*******************************/
/* ALLOCATE JOBS ACROSS STATES */
/*******************************/

* Jobs are allocated across states using the following procedure:
*
* - Indirect/induced jobs are allocated in proportion to state employment in 
*   every industry as measured in 2021 ACS;
* - Direct jobs are allocated in the same way for those sections of the bill
*   that do not specify how funds will be distributed geographically; for those
*   that do have such stipulations, we allocate direct jobs as described below:
*
*  1. Clean Electricity and Transmission
*  -- 22004 (Rural Electric Cooperative Loans): allocate direct jobs in proportion to non-MSA population
*  -- 50145 (Tribal Energy Loan Guarantee Program): allocate direct jobs in proportion to state tribal populations

*  2. Clean Transportation
*  -- 13404 (EV Charging/Alternative Fuels Tax Credit): allocate direct jobs in proportion to non-MSA population
*  -- 22002 (Rural Energy for America Program): allocate 50% of direct jobs in proportion to non-MSA population
*  -- 60102 (Clean Ports): allocate direct jobs in proportion to miles of coastline
*  -- 60501 (Neighborhood Access and Equity Grants Program): allocate 50.73% (1.262/3.205) in proportion to "disadvantaged"/low-income population

*  3. Buildings and Energy Efficiency
*  -- 50122 (High-efficiency electric home rebate program): allocate 5% of direct jobs in proportion to state tribal populations

*  4. Manufacturing
*  -- 13501 (Clean Manufacturing Investment Tax Credit (48C)): allocate 60% of direct jobs in proportion to 48C Census tracts

*  5. Environmental Justice
*  -- 60103 (Clean Energy Fund): allocate 55.55% (15/27) of direct jobs in proportion to "disadvantaged"/low-income population
*  -- 80001 (Tribal Climate Resilience): allocate direct jobs in proportion to state tribal populations
*  -- 80002 (Native Hawaiian Climate Resilience): allocate direct jobs to Hawaii
*  -- 80003 (Tribal Electrification Program): allocate direct jobs in proportion to state tribal populations
*  -- 80004 (Emergency Drought Relief for Tribes): allocate direct jobs in proportion to state tribal populations

*  6. Conservation and Agriculture
*  -- 40001 (Coastal Climate Resilience): allocate direct jobs in proportion to miles of coastline
*
*   (Note that we do not attempt to model the geographic impact of provisions in
*   certain sections of the IRA that target spending at "energy communities,"
*   since this term appears to be subject to definitional ambiguity that will
*   likely be resolved through future guidance from the Treasury Department. 
*   See Daniel Raimi and Sophie Pesek (September 7, 2022), "What Is An 
*   Energy Community?" Available at 
*   https://www.resources.org/common-resources/what-is-an-energy-community/)
*


* Calculate the share of each state's employment in each BEA industry, 
* as measured in the 2021 American Community Survey (ACS)

preserve
do ${programsdir}/Calculate_State_Industry_Shares.do
restore


* Calculate other shares needed to allocate direct jobs associated with
* provisions containing stipulations about how funds are distributed 
* geographically, e.g. state tribal population shares

preserve
do ${programsdir}/Calculate_Other_State_Shares.do
restore


* Run program that performs actual allocation of jobs across states
do ${programsdir}/Allocate_Jobs_Across_States.do


/************************************/
/* CALCULATE FINAL RESULTS BY STATE */
/************************************/

* Append results from component allocations performed by Allocate_Jobs_Across_States.do

use ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_0, clear

append using ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_1
append using ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_2
append using ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_3
append using ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_4
append using ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_5
append using ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_6
append using ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_7
append using ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_8
append using ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_9

keep SDAvg SIndirectAvg SInducedAvg SAvg Allocation


* Reshape data and sum across allocations to obtain final results by state

gen index = mod(_n,51)
replace index = 51 if index == 0

reshape wide SDAvg SIndirectAvg SInducedAvg SAvg, i(index) j(Allocation)

drop if index >= 52

egen EmploymentDirectAvg 	= rowtotal(SDAvg*)
egen EmploymentIndirectAvg 	= rowtotal(SIndirectAvg*)
egen EmploymentInducedAvg 	= rowtotal(SInducedAvg*)

replace EmploymentDirectAvg		= round(EmploymentDirectAvg)
replace EmploymentIndirectAvg	= round(EmploymentIndirectAvg)
replace EmploymentInducedAvg	= round(EmploymentInducedAvg)

egen EmploymentAvg = rowtotal(EmploymentDirectAvg EmploymentIndirectAvg EmploymentInducedAvg)

gen statefip = .
replace statefip = 1 if index == 1
replace statefip = 2 if index == 2
replace statefip = 4 if index == 3
replace statefip = 5 if index == 4
replace statefip = 6 if index == 5
replace statefip = 8 if index == 6
replace statefip = 9 if index == 7
replace statefip = 10 if index == 8
replace statefip = 11 if index == 9
replace statefip = 12 if index == 10
replace statefip = 13 if index == 11
replace statefip = 15 if index == 12
replace statefip = 16 if index == 13
replace statefip = 17 if index == 14
replace statefip = 18 if index == 15
replace statefip = 19 if index == 16
replace statefip = 20 if index == 17
replace statefip = 21 if index == 18
replace statefip = 22 if index == 19
replace statefip = 23 if index == 20
replace statefip = 24 if index == 21
replace statefip = 25 if index == 22
replace statefip = 26 if index == 23
replace statefip = 27 if index == 24
replace statefip = 28 if index == 25
replace statefip = 29 if index == 26
replace statefip = 30 if index == 27
replace statefip = 31 if index == 28
replace statefip = 32 if index == 29
replace statefip = 33 if index == 30
replace statefip = 34 if index == 31
replace statefip = 35 if index == 32
replace statefip = 36 if index == 33
replace statefip = 37 if index == 34
replace statefip = 38 if index == 35
replace statefip = 39 if index == 36
replace statefip = 40 if index == 37
replace statefip = 41 if index == 38
replace statefip = 42 if index == 39
replace statefip = 44 if index == 40
replace statefip = 45 if index == 41
replace statefip = 46 if index == 42
replace statefip = 47 if index == 43
replace statefip = 48 if index == 44
replace statefip = 49 if index == 45
replace statefip = 50 if index == 46
replace statefip = 51 if index == 47
replace statefip = 53 if index == 48
replace statefip = 54 if index == 49
replace statefip = 55 if index == 50
replace statefip = 56 if index == 51

keep statefip EmploymentDirectAvg EmploymentIndirectAvg EmploymentInducedAvg EmploymentAvg
order statefip EmploymentDirectAvg EmploymentIndirectAvg EmploymentInducedAvg EmploymentAvg

save ${outputdir}/IRA_Climate_Model_Run_Final_Results_by_State, replace


* Delete temporary files

foreach categorynum of numlist 1(1)7 {
	erase ${workdir}/IRA_Climate_Spending_by_Industry_Category_`categorynum'.dta
}

foreach num of numlist 0(1)9 {
	erase ${workdir}/IRA_Climate_Model_Run_Final_Results_Allocation_`num'.dta
	erase ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_`num'.dta
	erase ${workdir}/IRA_Climate_Model_Run_Results_by_Industry_Year_Allocation_`num'.dta
	erase ${workdir}/IRA_Climate_Spending_by_Industry_Allocation_`num'.dta
}
