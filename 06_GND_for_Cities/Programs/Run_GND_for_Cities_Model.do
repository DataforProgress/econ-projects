
/**************************************************************************************/
*  PROJECT:    		GND for Cities Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Run_GND_for_Cities_Model.do
*  LAST UPDATED: 	5/23/23
*
*  NOTES: 			Before running, be sure to change the working directory 
*					at the top of this program
*
*					Calls the following programs:
*					- Calculate_BEA_Employment_Output_and_Value_Added_Output_Ratios.do
*					- Clean_Domestic_Requirements_Table_2021.do
*					- Calculate_Sector_Employment.do
*					- Calculate_State_Industry_Shares.do
*					- Calculate_State_ARP_Shares.do
*					- Calculate_MSA_Industry_Shares.do
*					- Calculate_MSA_ARP_Shares.do
*
*					Jobs are allocated across states and metro areas using
*					the following procedure:
*					- Direct jobs allocated according to formula from 
*					Sections 602 and 603 of the 2021 American Rescue Plan;
*					- Indirect/induced jobs allocated in proportion to state and city
*					employment (where observable) from 2021 ACS
*
/**************************************************************************************/


clear
clear matrix
clear mata
set more off
set maxvar 100000

global directory = "/Users/Matt/Documents/Data_for_Progress/GND_for_Cities/Github"

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


/***********************************************************/
/* DEFINE SYNTHETIC INDUSTRIES AND CREATE SPENDING VECTORS */
/***********************************************************/

* In order to feed expenditures on renewables into the model we need to make assumptions about 
* how the total expenditures should be allocated across industries, for which we draw on the 
* "synthetic industry" approach (c.f. Garrett-Peltier (2016), "Green versus brown: Comparing the
* employment impacts of energy efficiency, renewable energy, and fossil fuels using an input-output 
* model," Economic Modelling 61)

* Using this technique and the references in Garrett-Peltier (2016), we construct vectors
* of weights that describe how a dollar of spending on different synthetic industries
* should be allocated across the industries that are observable in the BEA I-O tables

* Bioenergy (Pollin et al. 2015)
matrix BioenergyP = J(71,1,0)
matrix BioenergyP[1,1] = 0.250 /* Farms */
matrix BioenergyP[2,1] = 0.250 /* Forestry, fishing, and related activities */
matrix BioenergyP[7,1] = 0.250 /* Construction */
matrix BioenergyP[25,1] = 0.125 /* Chemical products */
matrix BioenergyP[53,1] = 0.125 /* Miscellaneous professional, scientific, and technical services */

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

* Mass Transit & Freight Rail (Garrett-Peltier 2011)   
matrix MassTransit = J(71,1,0)
matrix MassTransit[7,1] = 0.45 /* Construction */
matrix MassTransit[33,1] = 0.1 /* Rail transportation */
matrix MassTransit[36,1] = 0.45 /* Transit and ground passenger transportation */

* Smart Grid (Pollin et al. 2015)
matrix SmartGridP = J(71,1,0)
matrix SmartGridP[7,1] = 0.250 /* Construction */
matrix SmartGridP[12,1] = 0.250 /* Machinery */
matrix SmartGridP[13,1] = 0.250 /* Computer and electronic products */
matrix SmartGridP[14,1] = 0.250 /* Electrical equipment, appliances, and components */

* Solar (Pollin et al. 2015)
matrix SolarP = J(71,1,0)
matrix SolarP[7,1] = 0.300 /* Construction */
matrix SolarP[11,1] = 0.175 /* Fabricated metal products */
matrix SolarP[12,1] = 0.175 /* Machinery */
matrix SolarP[13,1] = 0.175 /* Computer and electronic products */
matrix SolarP[53,1] = 0.175 /* Miscellaneous professional, scientific, and technical services */

* Weatherization (Pollin et al. 2015)
matrix WeatherizationP = J(71,1,0)
matrix WeatherizationP[7,1] = 1.000 /* Construction */

* Wind (Pollin et al. 2015)
matrix WindP = J(71,1,0)
matrix WindP[7,1] = 0.260 /* Construction */
matrix WindP[11,1] = 0.120 /* Fabricated metal products */
matrix WindP[12,1] = 0.370 /* Machinery */
matrix WindP[13,1] = 0.030 /* Computer and electronic products */
matrix WindP[14,1] = 0.030 /* Electrical equipment, appliances, and components */
matrix WindP[26,1] = 0.120 /* Plastics and rubber products */
matrix WindP[53,1] = 0.070 /* Miscellaneous professional, scientific, and technical services */


* Save annual appropriations from bill
* Apply scaling factor to account for fact that some funding goes to territories (which we don't model)
local scalingfactor = 1-(4.5/350)

local Appropriations2024 = `scalingfactor'*400000000000
local Appropriations2025 = `scalingfactor'*300000000000
local Appropriations2026 = `scalingfactor'*200000000000
local Appropriations2027 = `scalingfactor'*100000000000

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

local Appropriations2024_adj = `Appropriations2024' / (133.1864469/117.021)
local Appropriations2025_adj = `Appropriations2025' / (137.1820403/117.021)
local Appropriations2026_adj = `Appropriations2026' / (141.2975015/117.021)
local Appropriations2027_adj = `Appropriations2027' / (145.5364266/117.021)

dis `Appropriations2024_adj'


* Generate spending vectors

* Allocate 1/5 each of buildings spending to smart grid (synthetic industry), 
* weatherization (synthetic industry), electrical equipment, housing, and 
* miscellaneous professional services (i.e. energy audits)

matrix Buildings = J(71,1,0)
matrix Buildings[14,1] = 0.2 /* Electrical equipment, appliances, and components */
matrix Buildings[48,1] = 0.2 /* Housing */
matrix Buildings[53,1] = 0.2 /* Miscellaneous professional, scientific, and technical services */
matrix Buildings = Buildings + 0.2*SmartGridP + 0.2*WeatherizationP

* Allocate renewables spending according to the following formula
* (based on projections of long-run U.S. renewables mix from EIA, available at 
* https://www.eia.gov/todayinenergy/detail.php?id=51698):
* - 50% solar
* - 30% wind
* - 12.5% hydropower
* - 2.5% geothermal
* - 5% bioenergy
matrix Renewables = 0.5*SolarP + 0.3*WindP + 0.125*HydroP + 0.025*GeothermalP + 0.05*BioenergyP

* Allocate 1/2 each of workforce spending to administrative and support services 
* and educational services
matrix Workforce = J(71,1,0)
matrix Workforce[55,1] = (1/3) /* Administrative and support services */
matrix Workforce[57,1] = (1/3) /* Educational services */
matrix Workforce[70,1] = (1/3) /* State and local general government */

* Allocate 1/3 of transportation spending to mass transit (synthetic industry), and 1/3 each to 
* motor vehicles (i.e. EV's) and other transportation equipment (i.e. charging infrastructure)
matrix Transportation = J(71,1,0)
matrix Transportation[15,1] = (1/3) /* Motor vehicles, bodies and trailers, and parts */
matrix Transportation[16,1] = (1/3) /* Other transportation equipment */
matrix Transportation = Transportation + (1/3)*MassTransit

* Allocate 1/5 each of environmental and climate justice spending to 
* forestry and fishing; utilities; miscellaneous professional services (i.e. air quality monitoring); 
* remediation; and social assistance
matrix Env_and_Climate_Justice = J(71,1,0)
matrix Env_and_Climate_Justice[2,1] = 0.2 /* Forestry, fishing, and related activities */
matrix Env_and_Climate_Justice[6,1] = 0.2 /* Utilities */
matrix Env_and_Climate_Justice[53,1] = 0.2 /* Miscellaneous professional, scientific, and technical services */
matrix Env_and_Climate_Justice[56,1] = 0.2 /* Waste management and remediation services */
matrix Env_and_Climate_Justice[61,1] = 0.2 /* Social assistance */

* Allocate 1/7 each of adaptation and resiliency spending to farms; forestry and fishing;
* utilities; miscellaneous manufacturing (i.e. procurement of livesaving equipment); 
* other real estate (i.e. land acquisition); miscellaneous professional services 
* (i.e. "adaptation measures"; and social assistance
matrix Adaptation_and_Resiliency = J(71,1,0)
matrix Adaptation_and_Resiliency[1,1] = (1/7) /* Farms */
matrix Adaptation_and_Resiliency[2,1] = (1/7) /* Forestry, fishing, and related activities */
matrix Adaptation_and_Resiliency[6,1] = (1/7) /* Utilities */
matrix Adaptation_and_Resiliency[18,1] = (1/7) /* Miscellaneous manufacturing */
matrix Adaptation_and_Resiliency[49,1] = (1/7) /* Other real estate */
matrix Adaptation_and_Resiliency[53,1] = (1/7) /* Miscellaneous professional, scientific, and technical services */
matrix Adaptation_and_Resiliency[61,1] = (1/7) /* Social assistance */

* Allocate administration to general state and local government
matrix Administration = J(71,1,0)
matrix Administration[70,1] = 1 /* State and local general government */


* Based on a breakdown of spending for Denver, CO's Climate Protection Fund, 
* which has been identified as a model for how local governments can act to
* address the climate crisis, we assume that Green New Deal for Cities spending 
* would be distributed across allowable uses in the following proportions:
*
* - Buildings: 25%
* - Renewables: 20%
* - Workforce: 15%
* - Transportation: 15%
* - Environmental and Climate Justice: 10%
* - Adaptation and Resiliency: 10%
* - Administration: 5%
*
* (Source: pg. 7 of https://denvergov.org/files/assets/public/climate-action/cpf_fiveyearplan_final.pdf)

matrix Exp2024 = `Appropriations2024_adj'*[0.25*Buildings + 0.2*Renewables + 0.15*Workforce + 0.15*Transportation + 0.10*Env_and_Climate_Justice + 0.10*Adaptation_and_Resiliency + 0.05*Administration]
matrix Exp2025 = `Appropriations2025_adj'*[0.25*Buildings + 0.2*Renewables + 0.15*Workforce + 0.15*Transportation + 0.10*Env_and_Climate_Justice + 0.10*Adaptation_and_Resiliency + 0.05*Administration]
matrix Exp2026 = `Appropriations2026_adj'*[0.25*Buildings + 0.2*Renewables + 0.15*Workforce + 0.15*Transportation + 0.10*Env_and_Climate_Justice + 0.10*Adaptation_and_Resiliency + 0.05*Administration]
matrix Exp2027 = `Appropriations2027_adj'*[0.25*Buildings + 0.2*Renewables + 0.15*Workforce + 0.15*Transportation + 0.10*Env_and_Climate_Justice + 0.10*Adaptation_and_Resiliency + 0.05*Administration]


/***************************/
/* BASELINE DOMESTIC MODEL */
/***************************/

* Create Leontief matrix

use ${workdir}/BEA_Industry_by_Industry_Domestic_Requirements_2021, clear
	
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

local multiplier = 1.4

foreach year of numlist 2024(1)2027 {
		
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
	
	* Feed in vector of spending and calculate aggregate employment effect
	matrix Emult`year' = 1.4*e`year'*Leontief*Exp`year'
	mata: st_matrix("Emultsum`year'",colsum(st_matrix("Emult`year'")))
	matrix list Emultsum`year'
	
	* Feed in vector of spending and calculate direct employment effect
	matrix D`year' = e`year'*A*Exp`year'
	mata: st_matrix("Dsum`year'",colsum(st_matrix("D`year'")))
	matrix list Dsum`year'

	* Save expenditure vector
	svmat Exp`year'
	
	* Save output, employment, and wage vectors
	svmat Y`year'
	svmat V`year'
	svmat E`year'
	svmat D`year'
	
	* Apply multiplier (induced effects) - to variables AND matrices
	gen double Vmult`year'1 = 	`multiplier'*V`year'1
	gen double Emult`year'1	=	`multiplier'*E`year'1

}


* Calculate total employment by sector
preserve
do ${programsdir}/Calculate_Sector_Employment.do
restore

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

collapse (sum) Y* E* V* D*, by(sector)
reshape long Y E Emult V Vmult D Exp, i(sector) j(year)

replace year = floor(year/10)

* Convert back to 2023 dollars
gen double Y2 		= Y*(129.30723/117.021)
gen double Exp2 	= Exp*(129.30723/117.021)
gen double V2 		= V*(129.30723/117.021)
gen double Vmult2 	= Vmult*(129.30723/117.021)

drop Y Exp V Vmult
rename Y2 Y
rename Exp2 Exp
rename V2 V
rename Vmult2 Vmult

collapse (sum) Y Exp E Emult V Vmult D, by(sector)

gen YAvg 		= Y/4
gen EAvg 		= E/4
gen EmultAvg 	= Emult/4
gen VAvg		= V/4
gen VmultAvg	= Vmult/4
gen DAvg		= D/4

merge 1:1 sector using ${workdir}/Sector_Employment, keepusing(sector_emp)
drop _merge

gen EmploymentAvg = round(EmultAvg)
gen EmploymentAvg_Pct_Sector_Emp = round(EmultAvg/sector_emp,0.0001)
keep sector EmploymentAvg EmploymentAvg_Pct_Sector_Emp
order sector EmploymentAvg EmploymentAvg_Pct_Sector_Emp
gsort -EmploymentAvg

save ${outputdir}/GND_for_Cities_Model_Final_Results_by_Sector, replace

restore


collapse (sum) Y* E* V* D*
gen n = _n
reshape long Y E Emult V Vmult D Exp, i(n) j(year)
drop n

replace year = floor(year/10)

* Convert back to 2023 dollars
replace Y 		= Y*(129.30723/117.021)
replace Exp 	= Exp*(129.30723/117.021)
replace V 		= V*(129.30723/117.021)
replace Vmult 	= Vmult*(129.30723/117.021)

rename E EmploymentDirectIndirect
rename Emult EmploymentTotal
rename D EmploymentDirect
rename Vmult GDP

gen EmploymentIndirect = EmploymentDirectIndirect - EmploymentDirect
gen EmploymentInduced = EmploymentTotal - EmploymentIndirect - EmploymentDirect

set obs 5
tostring(year), replace force

* Save employment results
preserve

replace year = "Average" if _n == 5

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

save ${outputdir}/GND_for_Cities_Model_Final_Results_Employment, replace

restore

* Save GDP results
preserve

replace year = "Total" if _n == 5

egen cumulativeGDP = sum(GDP)
replace GDP = cumulativeGDP if year == "Total"
drop cumulativeGDP

gen GDP_Bil = round(GDP/1000000000,0.1)

keep year GDP_Bil
order year GDP_Bil

save ${outputdir}/GND_for_Cities_Model_Final_Results_GDP, replace

restore


/*******************************/
/* ALLOCATE JOBS ACROSS STATES */
/*******************************/

use ${outputdir}/GND_for_Cities_Model_Final_Results_Employment, clear

* Calculate the share of each state's employment in each BEA industry, 
* as measured in the 2021 American Community Survey (ACS)
preserve
do ${programsdir}/Calculate_State_Industry_Shares.do
restore

* Calculate each state's share of funding under Sections 602 and 603 
* of the 2021 American Rescue Plan
preserve
do ${programsdir}/Calculate_State_ARP_Shares.do
restore

* Calculate indirect effects left over after subtracting off the direct effects
matrix EMinusD2024 = E2024 - D2024
matrix EMinusD2025 = E2025 - D2025
matrix EMinusD2026 = E2026 - D2026
matrix EMinusD2027 = E2027 - D2027

* Calculate indirect and induced effects left over after subtracting off the direct effects
matrix EmultMinusD2024 = Emult2024 - D2024
matrix EmultMinusD2025 = Emult2025 - D2025
matrix EmultMinusD2026 = Emult2026 - D2026
matrix EmultMinusD2027 = Emult2027 - D2027

* Allocate direct jobs in proportion to allocation of ARP funds,
* and indirect/induced jobs in proportion to distribution of employment
* in each industry by state (as measured in the 2021 ACS)
matrix S2024 = stateindshares*EmultMinusD2024 + statearpshares*D2024
matrix S2025 = stateindshares*EmultMinusD2025 + statearpshares*D2025
matrix S2026 = stateindshares*EmultMinusD2026 + statearpshares*D2026
matrix S2027 = stateindshares*EmultMinusD2027 + statearpshares*D2027

* Direct jobs by state
matrix SD2024 = statearpshares*D2024
matrix SD2025 = statearpshares*D2025
matrix SD2026 = statearpshares*D2026
matrix SD2027 = statearpshares*D2027

* Indirect jobs by state
matrix SIndirect2024 = stateindshares*EMinusD2024
matrix SIndirect2025 = stateindshares*EMinusD2025
matrix SIndirect2026 = stateindshares*EMinusD2026
matrix SIndirect2027 = stateindshares*EMinusD2027

* Indirect/induced jobs by state
matrix STotMinusD2024 = stateindshares*EmultMinusD2024
matrix STotMinusD2025 = stateindshares*EmultMinusD2025
matrix STotMinusD2026 = stateindshares*EmultMinusD2026
matrix STotMinusD2027 = stateindshares*EmultMinusD2027

svmat S2024
svmat S2025
svmat S2026
svmat S2027

svmat SD2024
svmat SD2025
svmat SD2026
svmat SD2027

svmat SIndirect2024
svmat SIndirect2025
svmat SIndirect2026
svmat SIndirect2027

svmat STotMinusD2024
svmat STotMinusD2025
svmat STotMinusD2026
svmat STotMinusD2027

egen S = rowtotal(S2024 S2025 S2026 S2027)
egen SD = rowtotal(SD2024 SD2025 SD2026 SD2027)
egen SIndirect = rowtotal(SIndirect2024 SIndirect2025 SIndirect2026 SIndirect2027)
egen STotMinusD = rowtotal(STotMinusD2024 STotMinusD2025 STotMinusD2026 STotMinusD2027)

gen SInduced = STotMinusD - SIndirect

gen EmploymentDirectAvg = SD/4
gen EmploymentIndirectAvg = SIndirect/4
gen EmploymentInducedAvg = SInduced/4

replace EmploymentDirectAvg		= round(EmploymentDirectAvg)
replace EmploymentIndirectAvg	= round(EmploymentIndirectAvg)
replace EmploymentInducedAvg	= round(EmploymentInducedAvg)

egen EmploymentAvg = rowtotal(EmploymentDirectAvg EmploymentIndirectAvg EmploymentInducedAvg)

gen index = _n

gen statefip = ""
replace statefip = "1" if index == 1
replace statefip = "2" if index == 2
replace statefip = "4" if index == 3
replace statefip = "5" if index == 4
replace statefip = "6" if index == 5
replace statefip = "8" if index == 6
replace statefip = "9" if index == 7
replace statefip = "10" if index == 8
replace statefip = "11" if index == 9
replace statefip = "12" if index == 10
replace statefip = "13" if index == 11
replace statefip = "15" if index == 12
replace statefip = "16" if index == 13
replace statefip = "17" if index == 14
replace statefip = "18" if index == 15
replace statefip = "19" if index == 16
replace statefip = "20" if index == 17
replace statefip = "21" if index == 18
replace statefip = "22" if index == 19
replace statefip = "23" if index == 20
replace statefip = "24" if index == 21
replace statefip = "25" if index == 22
replace statefip = "26" if index == 23
replace statefip = "27" if index == 24
replace statefip = "28" if index == 25
replace statefip = "29" if index == 26
replace statefip = "30" if index == 27
replace statefip = "31" if index == 28
replace statefip = "32" if index == 29
replace statefip = "33" if index == 30
replace statefip = "34" if index == 31
replace statefip = "35" if index == 32
replace statefip = "36" if index == 33
replace statefip = "37" if index == 34
replace statefip = "38" if index == 35
replace statefip = "39" if index == 36
replace statefip = "40" if index == 37
replace statefip = "41" if index == 38
replace statefip = "42" if index == 39
replace statefip = "44" if index == 40
replace statefip = "45" if index == 41
replace statefip = "46" if index == 42
replace statefip = "47" if index == 43
replace statefip = "48" if index == 44
replace statefip = "49" if index == 45
replace statefip = "50" if index == 46
replace statefip = "51" if index == 47
replace statefip = "53" if index == 48
replace statefip = "54" if index == 49
replace statefip = "55" if index == 50
replace statefip = "56" if index == 51

keep statefip EmploymentDirectAvg EmploymentIndirectAvg EmploymentInducedAvg EmploymentAvg
order statefip EmploymentDirectAvg EmploymentIndirectAvg EmploymentInducedAvg EmploymentAvg

set obs 52
replace statefip = "Total" if _n == 52

foreach var of varlist EmploymentDirect EmploymentIndirect EmploymentInduced EmploymentAvg {
	egen total`var' = total(`var')
	replace `var' = total`var' if statefip == "Total"
	drop total`var'
}

save ${outputdir}/GND_for_Cities_Model_Final_Results_by_State, replace


/******************************/
/* ALLOCATE JOBS ACROSS MSA's */
/******************************/

* Calculate fraction of total employed population in the 260 observable MSA's
use ${datadir}/ACS_Extract_2021_for_GND_for_Cities.dta, clear
keep if empstat == 1
gen intopmsa = met2013 != 0
collapse (sum) perwt, by(intopmsa)

egen totemp = sum(perwt)
gen share = perwt / totemp

summ share if intopmsa == 1
global topmsashare = `r(mean)'

use ${outputdir}/GND_for_Cities_Model_Final_Results_Employment, clear

* Calculate the share of each MSA's employment in each BEA industry, 
* as measured in the 2021 American Community Survey (ACS)
preserve
do ${programsdir}/Calculate_MSA_Industry_Shares.do
restore

* Calculate each MSA's share of funding under Sections 602 and 603 
* of the 2021 American Rescue Plan
preserve
do ${programsdir}/Calculate_MSA_ARP_Shares.do
restore

* Scale all variables by fraction of employed population in observable MSA's
matrix E2024_scaled				=	${topmsashare}*E2024
matrix E2025_scaled				=	${topmsashare}*E2025
matrix E2026_scaled				=	${topmsashare}*E2026
matrix E2027_scaled				=	${topmsashare}*E2027

matrix D2024_scaled				=	${topmsashare}*D2024
matrix D2025_scaled				=	${topmsashare}*D2025
matrix D2026_scaled				=	${topmsashare}*D2026
matrix D2027_scaled				=	${topmsashare}*D2027

matrix Emult2024_scaled			=	${topmsashare}*Emult2024
matrix Emult2025_scaled			=	${topmsashare}*Emult2025
matrix Emult2026_scaled			=	${topmsashare}*Emult2026
matrix Emult2027_scaled			=	${topmsashare}*Emult2027

* Calculate indirect effects left over after subtracting off the direct effects
matrix EMinusD2024_scaled 		= 	E2024_scaled - D2024_scaled
matrix EMinusD2025_scaled 		= 	E2025_scaled - D2025_scaled
matrix EMinusD2026_scaled 		= 	E2026_scaled - D2026_scaled
matrix EMinusD2027_scaled 		= 	E2027_scaled - D2027_scaled

* Calculate indirect and induced effects left over after subtracting off the direct effects
matrix EmultMinusD2024_scaled 	= 	Emult2024_scaled - D2024_scaled
matrix EmultMinusD2025_scaled 	= 	Emult2025_scaled - D2025_scaled
matrix EmultMinusD2026_scaled 	= 	Emult2026_scaled - D2026_scaled
matrix EmultMinusD2027_scaled 	= 	Emult2027_scaled - D2027_scaled

* Allocate direct jobs in proportion to allocation of ARP funds,
* and indirect/induced jobs in proportion to distribution of employment
* in each industry by MSA (as measured in the 2021 ACS)
matrix M2024 = msaindshares*EmultMinusD2024_scaled + msaarpshares*D2024_scaled
matrix M2025 = msaindshares*EmultMinusD2025_scaled + msaarpshares*D2025_scaled
matrix M2026 = msaindshares*EmultMinusD2026_scaled + msaarpshares*D2026_scaled
matrix M2027 = msaindshares*EmultMinusD2027_scaled + msaarpshares*D2027_scaled

* Direct jobs by MSA
matrix MD2024 = msaarpshares*D2024_scaled
matrix MD2025 = msaarpshares*D2025_scaled
matrix MD2026 = msaarpshares*D2026_scaled
matrix MD2027 = msaarpshares*D2027_scaled

* Indirect jobs by MSA
matrix MIndirect2024 = msaindshares*EMinusD2024_scaled
matrix MIndirect2025 = msaindshares*EMinusD2025_scaled
matrix MIndirect2026 = msaindshares*EMinusD2026_scaled
matrix MIndirect2027 = msaindshares*EMinusD2027_scaled

* Indirect/induced jobs by MSA
matrix MTotMinusD2024 = msaindshares*EmultMinusD2024_scaled
matrix MTotMinusD2025 = msaindshares*EmultMinusD2025_scaled
matrix MTotMinusD2026 = msaindshares*EmultMinusD2026_scaled
matrix MTotMinusD2027 = msaindshares*EmultMinusD2027_scaled

svmat M2024
svmat M2025
svmat M2026
svmat M2027

svmat MD2024
svmat MD2025
svmat MD2026
svmat MD2027

svmat MIndirect2024
svmat MIndirect2025
svmat MIndirect2026
svmat MIndirect2027

svmat MTotMinusD2024
svmat MTotMinusD2025
svmat MTotMinusD2026
svmat MTotMinusD2027


gen met2013 = .
replace met2013 = 10420 if _n == 1
replace met2013 = 10580 if _n == 2
replace met2013 = 10740 if _n == 3
replace met2013 = 10900 if _n == 4
replace met2013 = 11100 if _n == 5
replace met2013 = 11260 if _n == 6
replace met2013 = 11460 if _n == 7
replace met2013 = 11500 if _n == 8
replace met2013 = 11700 if _n == 9
replace met2013 = 12060 if _n == 10
replace met2013 = 12100 if _n == 11
replace met2013 = 12220 if _n == 12
replace met2013 = 12260 if _n == 13
replace met2013 = 12420 if _n == 14
replace met2013 = 12540 if _n == 15
replace met2013 = 12580 if _n == 16
replace met2013 = 12620 if _n == 17
replace met2013 = 12700 if _n == 18
replace met2013 = 12940 if _n == 19
replace met2013 = 13140 if _n == 20
replace met2013 = 13380 if _n == 21
replace met2013 = 13460 if _n == 22
replace met2013 = 13780 if _n == 23
replace met2013 = 13820 if _n == 24
replace met2013 = 13900 if _n == 25
replace met2013 = 13980 if _n == 26
replace met2013 = 14010 if _n == 27
replace met2013 = 14020 if _n == 28
replace met2013 = 14260 if _n == 29
replace met2013 = 14460 if _n == 30
replace met2013 = 14740 if _n == 31
replace met2013 = 14860 if _n == 32
replace met2013 = 15180 if _n == 33
replace met2013 = 15380 if _n == 34
replace met2013 = 15500 if _n == 35
replace met2013 = 15540 if _n == 36
replace met2013 = 15940 if _n == 37
replace met2013 = 15980 if _n == 38
replace met2013 = 16580 if _n == 39
replace met2013 = 16620 if _n == 40
replace met2013 = 16700 if _n == 41
replace met2013 = 16740 if _n == 42
replace met2013 = 16860 if _n == 43
replace met2013 = 16980 if _n == 44
replace met2013 = 17020 if _n == 45
replace met2013 = 17140 if _n == 46
replace met2013 = 17300 if _n == 47
replace met2013 = 17460 if _n == 48
replace met2013 = 17660 if _n == 49
replace met2013 = 17780 if _n == 50
replace met2013 = 17820 if _n == 51
replace met2013 = 17860 if _n == 52
replace met2013 = 17900 if _n == 53
replace met2013 = 18140 if _n == 54
replace met2013 = 18580 if _n == 55
replace met2013 = 19100 if _n == 56
replace met2013 = 19300 if _n == 57
replace met2013 = 19380 if _n == 58
replace met2013 = 19460 if _n == 59
replace met2013 = 19500 if _n == 60
replace met2013 = 19660 if _n == 61
replace met2013 = 19740 if _n == 62
replace met2013 = 19780 if _n == 63
replace met2013 = 19820 if _n == 64
replace met2013 = 20100 if _n == 65
replace met2013 = 20700 if _n == 66
replace met2013 = 20740 if _n == 67
replace met2013 = 20940 if _n == 68
replace met2013 = 21140 if _n == 69
replace met2013 = 21340 if _n == 70
replace met2013 = 21500 if _n == 71
replace met2013 = 21660 if _n == 72
replace met2013 = 22180 if _n == 73
replace met2013 = 22220 if _n == 74
replace met2013 = 22380 if _n == 75
replace met2013 = 22500 if _n == 76
replace met2013 = 22660 if _n == 77
replace met2013 = 23060 if _n == 78
replace met2013 = 23420 if _n == 79
replace met2013 = 23460 if _n == 80
replace met2013 = 23540 if _n == 81
replace met2013 = 23580 if _n == 82
replace met2013 = 24020 if _n == 83
replace met2013 = 24140 if _n == 84
replace met2013 = 24300 if _n == 85
replace met2013 = 24340 if _n == 86
replace met2013 = 24660 if _n == 87
replace met2013 = 24780 if _n == 88
replace met2013 = 24860 if _n == 89
replace met2013 = 25060 if _n == 90
replace met2013 = 25260 if _n == 91
replace met2013 = 25420 if _n == 92
replace met2013 = 25500 if _n == 93
replace met2013 = 25540 if _n == 94
replace met2013 = 25860 if _n == 95
replace met2013 = 25940 if _n == 96
replace met2013 = 26140 if _n == 97
replace met2013 = 26380 if _n == 98
replace met2013 = 26420 if _n == 99
replace met2013 = 26620 if _n == 100
replace met2013 = 26900 if _n == 101
replace met2013 = 26980 if _n == 102
replace met2013 = 27060 if _n == 103
replace met2013 = 27100 if _n == 104
replace met2013 = 27140 if _n == 105
replace met2013 = 27180 if _n == 106
replace met2013 = 27260 if _n == 107
replace met2013 = 27500 if _n == 108
replace met2013 = 27620 if _n == 109
replace met2013 = 27780 if _n == 110
replace met2013 = 27900 if _n == 111
replace met2013 = 28020 if _n == 112
replace met2013 = 28100 if _n == 113
replace met2013 = 28140 if _n == 114
replace met2013 = 28940 if _n == 115
replace met2013 = 29100 if _n == 116
replace met2013 = 29180 if _n == 117
replace met2013 = 29200 if _n == 118
replace met2013 = 29420 if _n == 119
replace met2013 = 29460 if _n == 120
replace met2013 = 29540 if _n == 121
replace met2013 = 29620 if _n == 122
replace met2013 = 29700 if _n == 123
replace met2013 = 29740 if _n == 124
replace met2013 = 29820 if _n == 125
replace met2013 = 29940 if _n == 126
replace met2013 = 30140 if _n == 127
replace met2013 = 30340 if _n == 128
replace met2013 = 30620 if _n == 129
replace met2013 = 30700 if _n == 130
replace met2013 = 30780 if _n == 131
replace met2013 = 31080 if _n == 132
replace met2013 = 31140 if _n == 133
replace met2013 = 31180 if _n == 134
replace met2013 = 31340 if _n == 135
replace met2013 = 31460 if _n == 136
replace met2013 = 31700 if _n == 137
replace met2013 = 31900 if _n == 138
replace met2013 = 32580 if _n == 139
replace met2013 = 32780 if _n == 140
replace met2013 = 32820 if _n == 141
replace met2013 = 32900 if _n == 142
replace met2013 = 33100 if _n == 143
replace met2013 = 33140 if _n == 144
replace met2013 = 33260 if _n == 145
replace met2013 = 33340 if _n == 146
replace met2013 = 33460 if _n == 147
replace met2013 = 33660 if _n == 148
replace met2013 = 33700 if _n == 149
replace met2013 = 33740 if _n == 150
replace met2013 = 33780 if _n == 151
replace met2013 = 33860 if _n == 152
replace met2013 = 34060 if _n == 153
replace met2013 = 34620 if _n == 154
replace met2013 = 34740 if _n == 155
replace met2013 = 34820 if _n == 156
replace met2013 = 34900 if _n == 157
replace met2013 = 34940 if _n == 158
replace met2013 = 34980 if _n == 159
replace met2013 = 35300 if _n == 160
replace met2013 = 35380 if _n == 161
replace met2013 = 35620 if _n == 162
replace met2013 = 35660 if _n == 163
replace met2013 = 35840 if _n == 164
replace met2013 = 35980 if _n == 165
replace met2013 = 36100 if _n == 166
replace met2013 = 36140 if _n == 167
replace met2013 = 36220 if _n == 168
replace met2013 = 36260 if _n == 169
replace met2013 = 36420 if _n == 170
replace met2013 = 36500 if _n == 171
replace met2013 = 36540 if _n == 172
replace met2013 = 36740 if _n == 173
replace met2013 = 36780 if _n == 174
replace met2013 = 36980 if _n == 175
replace met2013 = 37100 if _n == 176
replace met2013 = 37340 if _n == 177
replace met2013 = 37620 if _n == 178
replace met2013 = 37860 if _n == 179
replace met2013 = 37980 if _n == 180
replace met2013 = 38060 if _n == 181
replace met2013 = 38300 if _n == 182
replace met2013 = 38340 if _n == 183
replace met2013 = 38860 if _n == 184
replace met2013 = 38900 if _n == 185
replace met2013 = 38940 if _n == 186
replace met2013 = 39140 if _n == 187
replace met2013 = 39300 if _n == 188
replace met2013 = 39340 if _n == 189
replace met2013 = 39380 if _n == 190
replace met2013 = 39460 if _n == 191
replace met2013 = 39540 if _n == 192
replace met2013 = 39580 if _n == 193
replace met2013 = 39740 if _n == 194
replace met2013 = 39820 if _n == 195
replace met2013 = 39900 if _n == 196
replace met2013 = 40060 if _n == 197
replace met2013 = 40140 if _n == 198
replace met2013 = 40220 if _n == 199
replace met2013 = 40380 if _n == 200
replace met2013 = 40420 if _n == 201
replace met2013 = 40580 if _n == 202
replace met2013 = 40900 if _n == 203
replace met2013 = 40980 if _n == 204
replace met2013 = 41100 if _n == 205
replace met2013 = 41140 if _n == 206
replace met2013 = 41180 if _n == 207
replace met2013 = 41500 if _n == 208
replace met2013 = 41540 if _n == 209
replace met2013 = 41620 if _n == 210
replace met2013 = 41660 if _n == 211
replace met2013 = 41700 if _n == 212
replace met2013 = 41740 if _n == 213
replace met2013 = 41860 if _n == 214
replace met2013 = 41940 if _n == 215
replace met2013 = 42020 if _n == 216
replace met2013 = 42100 if _n == 217
replace met2013 = 42140 if _n == 218
replace met2013 = 42200 if _n == 219
replace met2013 = 42220 if _n == 220
replace met2013 = 42540 if _n == 221
replace met2013 = 42660 if _n == 222
replace met2013 = 42680 if _n == 223
replace met2013 = 43100 if _n == 224
replace met2013 = 43340 if _n == 225
replace met2013 = 43900 if _n == 226
replace met2013 = 44060 if _n == 227
replace met2013 = 44100 if _n == 228
replace met2013 = 44140 if _n == 229
replace met2013 = 44180 if _n == 230
replace met2013 = 44220 if _n == 231
replace met2013 = 44300 if _n == 232
replace met2013 = 44700 if _n == 233
replace met2013 = 45060 if _n == 234
replace met2013 = 45300 if _n == 235
replace met2013 = 45780 if _n == 236
replace met2013 = 45820 if _n == 237
replace met2013 = 45940 if _n == 238
replace met2013 = 46060 if _n == 239
replace met2013 = 46220 if _n == 240
replace met2013 = 46340 if _n == 241
replace met2013 = 46520 if _n == 242
replace met2013 = 46540 if _n == 243
replace met2013 = 46700 if _n == 244
replace met2013 = 47260 if _n == 245
replace met2013 = 47300 if _n == 246
replace met2013 = 47380 if _n == 247
replace met2013 = 47900 if _n == 248
replace met2013 = 48140 if _n == 249
replace met2013 = 48300 if _n == 250
replace met2013 = 48620 if _n == 251
replace met2013 = 48660 if _n == 252
replace met2013 = 48900 if _n == 253
replace met2013 = 49180 if _n == 254
replace met2013 = 49340 if _n == 255
replace met2013 = 49420 if _n == 256
replace met2013 = 49620 if _n == 257
replace met2013 = 49660 if _n == 258
replace met2013 = 49700 if _n == 259
replace met2013 = 49740 if _n == 260


gen met2013name = ""
replace met2013name = "Akron, OH" if _n == 1
replace met2013name = "Albany-Schenectady-Troy, NY" if _n == 2
replace met2013name = "Albuquerque, NM" if _n == 3
replace met2013name = "Allentown-Bethlehem-Easton, PA-NJ" if _n == 4
replace met2013name = "Amarillo, TX" if _n == 5
replace met2013name = "Anchorage, AK" if _n == 6
replace met2013name = "Ann Arbor, MI" if _n == 7
replace met2013name = "Anniston-Oxford-Jacksonville, AL" if _n == 8
replace met2013name = "Asheville, NC" if _n == 9
replace met2013name = "Atlanta-Sandy Springs-Roswell, GA" if _n == 10
replace met2013name = "Atlantic City-Hammonton, NJ" if _n == 11
replace met2013name = "Auburn-Opelika, AL" if _n == 12
replace met2013name = "Augusta-Richmond County, GA-SC" if _n == 13
replace met2013name = "Austin-Round Rock, TX" if _n == 14
replace met2013name = "Bakersfield, CA" if _n == 15
replace met2013name = "Baltimore-Columbia-Towson, MD" if _n == 16
replace met2013name = "Bangor, ME" if _n == 17
replace met2013name = "Barnstable Town, MA" if _n == 18
replace met2013name = "Baton Rouge, LA" if _n == 19
replace met2013name = "Beaumont-Port Arthur, TX" if _n == 20
replace met2013name = "Bellingham, WA" if _n == 21
replace met2013name = "Bend-Redmond, OR" if _n == 22
replace met2013name = "Binghamton, NY" if _n == 23
replace met2013name = "Birmingham-Hoover, AL" if _n == 24
replace met2013name = "Bismarck, ND" if _n == 25
replace met2013name = "Blacksburg-Christiansburg-Radford, VA" if _n == 26
replace met2013name = "Bloomington, IL" if _n == 27
replace met2013name = "Bloomington, IN" if _n == 28
replace met2013name = "Boise City, ID" if _n == 29
replace met2013name = "Boston-Cambridge-Newton, MA-NH" if _n == 30
replace met2013name = "Bremerton-Silverdale, WA" if _n == 31
replace met2013name = "Bridgeport-Stamford-Norwalk, CT" if _n == 32
replace met2013name = "Brownsville-Harlingen, TX" if _n == 33
replace met2013name = "Buffalo-Cheektowaga-Niagara Falls, NY" if _n == 34
replace met2013name = "Burlington, NC" if _n == 35
replace met2013name = "Burlington-South Burlington, VT" if _n == 36
replace met2013name = "Canton-Massillon, OH" if _n == 37
replace met2013name = "Cape Coral-Fort Myers, FL" if _n == 38
replace met2013name = "Champaign-Urbana, IL" if _n == 39
replace met2013name = "Charleston, WV" if _n == 40
replace met2013name = "Charleston-North Charleston, SC" if _n == 41
replace met2013name = "Charlotte-Concord-Gastonia, NC-SC" if _n == 42
replace met2013name = "Chattanooga, TN-GA" if _n == 43
replace met2013name = "Chicago-Naperville-Elgin, IL-IN-WI" if _n == 44
replace met2013name = "Chico, CA" if _n == 45
replace met2013name = "Cincinnati, OH-KY-IN" if _n == 46
replace met2013name = "Clarksville, TN-KY" if _n == 47
replace met2013name = "Cleveland-Elyria, OH" if _n == 48
replace met2013name = "Coeur d'Alene, ID" if _n == 49
replace met2013name = "College Station-Bryan, TX" if _n == 50
replace met2013name = "Colorado Springs, CO" if _n == 51
replace met2013name = "Columbia, MO" if _n == 52
replace met2013name = "Columbia, SC" if _n == 53
replace met2013name = "Columbus, OH" if _n == 54
replace met2013name = "Corpus Christi, TX" if _n == 55
replace met2013name = "Dallas-Fort Worth-Arlington, TX" if _n == 56
replace met2013name = "Daphne-Fairhope-Foley, AL" if _n == 57
replace met2013name = "Dayton, OH" if _n == 58
replace met2013name = "Decatur, AL" if _n == 59
replace met2013name = "Decatur, IL" if _n == 60
replace met2013name = "Deltona-Daytona Beach-Ormond Beach, FL" if _n == 61
replace met2013name = "Denver-Aurora-Lakewood, CO" if _n == 62
replace met2013name = "Des Moines-West Des Moines, IA" if _n == 63
replace met2013name = "Detroit-Warren-Dearborn, MI" if _n == 64
replace met2013name = "Dover, DE" if _n == 65
replace met2013name = "East Stroudsburg, PA" if _n == 66
replace met2013name = "Eau Claire, WI" if _n == 67
replace met2013name = "El Centro, CA" if _n == 68
replace met2013name = "Elkhart-Goshen, IN" if _n == 69
replace met2013name = "El Paso, TX" if _n == 70
replace met2013name = "Erie, PA" if _n == 71
replace met2013name = "Eugene, OR" if _n == 72
replace met2013name = "Fayetteville, NC" if _n == 73
replace met2013name = "Fayetteville-Springdale-Rogers, AR-MO" if _n == 74
replace met2013name = "Flagstaff, AZ" if _n == 75
replace met2013name = "Florence, SC" if _n == 76
replace met2013name = "Fort Collins, CO" if _n == 77
replace met2013name = "Fort Wayne, IN" if _n == 78
replace met2013name = "Fresno, CA" if _n == 79
replace met2013name = "Gadsden, AL" if _n == 80
replace met2013name = "Gainesville, FL" if _n == 81
replace met2013name = "Gainesville, GA" if _n == 82
replace met2013name = "Glens Falls, NY" if _n == 83
replace met2013name = "Goldsboro, NC" if _n == 84
replace met2013name = "Grand Junction, CO" if _n == 85
replace met2013name = "Grand Rapids-Wyoming, MI" if _n == 86
replace met2013name = "Greensboro-High Point, NC" if _n == 87
replace met2013name = "Greenville, NC" if _n == 88
replace met2013name = "Greenville-Anderson-Mauldin, SC" if _n == 89
replace met2013name = "Gulfport-Biloxi-Pascagoula, MS" if _n == 90
replace met2013name = "Hanford-Corcoran, CA" if _n == 91
replace met2013name = "Harrisburg-Carlisle, PA" if _n == 92
replace met2013name = "Harrisonburg, VA" if _n == 93
replace met2013name = "Hartford-West Hartford-East Hartford, CT" if _n == 94
replace met2013name = "Hickory-Lenoir-Morganton, NC" if _n == 95
replace met2013name = "Hilton Head Island-Bluffton-Beaufort, SC" if _n == 96
replace met2013name = "Homosassa Springs, FL" if _n == 97
replace met2013name = "Houma-Thibodaux, LA" if _n == 98
replace met2013name = "Houston-The Woodlands-Sugar Land, TX" if _n == 99
replace met2013name = "Huntsville, AL" if _n == 100
replace met2013name = "Indianapolis-Carmel-Anderson, IN" if _n == 101
replace met2013name = "Iowa City, IA" if _n == 102
replace met2013name = "Ithaca, NY" if _n == 103
replace met2013name = "Jackson, MI" if _n == 104
replace met2013name = "Jackson, MS" if _n == 105
replace met2013name = "Jackson, TN" if _n == 106
replace met2013name = "Jacksonville, FL" if _n == 107
replace met2013name = "Janesville-Beloit, WI" if _n == 108
replace met2013name = "Jefferson City, MO" if _n == 109
replace met2013name = "Johnstown, PA" if _n == 110
replace met2013name = "Joplin, MO" if _n == 111
replace met2013name = "Kalamazoo-Portage, MI" if _n == 112
replace met2013name = "Kankakee, IL" if _n == 113
replace met2013name = "Kansas City, MO-KS" if _n == 114
replace met2013name = "Knoxville, TN" if _n == 115
replace met2013name = "La Crosse-Onalaska, WI-MN" if _n == 116
replace met2013name = "Lafayette, LA" if _n == 117
replace met2013name = "Lafayette-West Lafayette, IN" if _n == 118
replace met2013name = "Lake Havasu City-Kingman, AZ" if _n == 119
replace met2013name = "Lakeland-Winter Haven, FL" if _n == 120
replace met2013name = "Lancaster, PA" if _n == 121
replace met2013name = "Lansing-East Lansing, MI" if _n == 122
replace met2013name = "Laredo, TX" if _n == 123
replace met2013name = "Las Cruces, NM" if _n == 124
replace met2013name = "Las Vegas-Henderson-Paradise, NV" if _n == 125
replace met2013name = "Lawrence, KS" if _n == 126
replace met2013name = "Lebanon, PA" if _n == 127
replace met2013name = "Lewiston-Auburn, ME" if _n == 128
replace met2013name = "Lima, OH" if _n == 129
replace met2013name = "Lincoln, NE" if _n == 130
replace met2013name = "Little Rock-North Little Rock-Conway, AR" if _n == 131
replace met2013name = "Los Angeles-Long Beach-Anaheim, CA" if _n == 132
replace met2013name = "Louisville/Jefferson County, KY-IN" if _n == 133
replace met2013name = "Lubbock, TX" if _n == 134
replace met2013name = "Lynchburg, VA" if _n == 135
replace met2013name = "Madera, CA" if _n == 136
replace met2013name = "Manchester-Nashua, NH" if _n == 137
replace met2013name = "Mansfield, OH" if _n == 138
replace met2013name = "McAllen-Edinburg-Mission, TX" if _n == 139
replace met2013name = "Medford, OR" if _n == 140
replace met2013name = "Memphis, TN-MS-AR" if _n == 141
replace met2013name = "Merced, CA" if _n == 142
replace met2013name = "Miami-Fort Lauderdale-West Palm Beach, FL" if _n == 143
replace met2013name = "Michigan City-La Porte, IN" if _n == 144
replace met2013name = "Midland, TX" if _n == 145
replace met2013name = "Milwaukee-Waukesha-West Allis, WI" if _n == 146
replace met2013name = "Minneapolis-St. Paul-Bloomington, MN-WI" if _n == 147
replace met2013name = "Mobile, AL" if _n == 148
replace met2013name = "Modesto, CA" if _n == 149
replace met2013name = "Monroe, LA" if _n == 150
replace met2013name = "Monroe, MI" if _n == 151
replace met2013name = "Montgomery, AL" if _n == 152
replace met2013name = "Morgantown, WV" if _n == 153
replace met2013name = "Muncie, IN" if _n == 154
replace met2013name = "Muskegon, MI" if _n == 155
replace met2013name = "Myrtle Beach-Conway-North Myrtle Beach, SC-NC" if _n == 156
replace met2013name = "Napa, CA" if _n == 157
replace met2013name = "Naples-Immokalee-Marco Island, FL" if _n == 158
replace met2013name = "Nashville-Davidson--Murfreesboro--Franklin, TN" if _n == 159
replace met2013name = "New Haven-Milford, CT" if _n == 160
replace met2013name = "New Orleans-Metairie, LA" if _n == 161
replace met2013name = "New York-Newark-Jersey City, NY-NJ-PA" if _n == 162
replace met2013name = "Niles-Benton Harbor, MI" if _n == 163
replace met2013name = "North Port-Sarasota-Bradenton, FL" if _n == 164
replace met2013name = "Norwich-New London, CT" if _n == 165
replace met2013name = "Ocala, FL" if _n == 166
replace met2013name = "Ocean City, NJ" if _n == 167
replace met2013name = "Odessa, TX" if _n == 168
replace met2013name = "Ogden-Clearfield, UT" if _n == 169
replace met2013name = "Oklahoma City, OK" if _n == 170
replace met2013name = "Olympia-Tumwater, WA" if _n == 171
replace met2013name = "Omaha-Council Bluffs, NE-IA" if _n == 172
replace met2013name = "Orlando-Kissimmee-Sanford, FL" if _n == 173
replace met2013name = "Oshkosh-Neenah, WI" if _n == 174
replace met2013name = "Owensboro, KY" if _n == 175
replace met2013name = "Oxnard-Thousand Oaks-Ventura, CA" if _n == 176
replace met2013name = "Palm Bay-Melbourne-Titusville, FL" if _n == 177
replace met2013name = "Parkersburg-Vienna, WV" if _n == 178
replace met2013name = "Pensacola-Ferry Pass-Brent, FL" if _n == 179
replace met2013name = "Philadelphia-Camden-Wilmington, PA-NJ-DE-MD" if _n == 180
replace met2013name = "Phoenix-Mesa-Scottsdale, AZ" if _n == 181
replace met2013name = "Pittsburgh, PA" if _n == 182
replace met2013name = "Pittsfield, MA" if _n == 183
replace met2013name = "Portland-South Portland, ME" if _n == 184
replace met2013name = "Portland-Vancouver-Hillsboro, OR-WA" if _n == 185
replace met2013name = "Port St. Lucie, FL" if _n == 186
replace met2013name = "Prescott, AZ" if _n == 187
replace met2013name = "Providence-Warwick, RI-MA" if _n == 188
replace met2013name = "Provo-Orem, UT" if _n == 189
replace met2013name = "Pueblo, CO" if _n == 190
replace met2013name = "Punta Gorda, FL" if _n == 191
replace met2013name = "Racine, WI" if _n == 192
replace met2013name = "Raleigh, NC" if _n == 193
replace met2013name = "Reading, PA" if _n == 194
replace met2013name = "Redding, CA" if _n == 195
replace met2013name = "Reno, NV" if _n == 196
replace met2013name = "Richmond, VA" if _n == 197
replace met2013name = "Riverside-San Bernardino-Ontario, CA" if _n == 198
replace met2013name = "Roanoke, VA" if _n == 199
replace met2013name = "Rochester, NY" if _n == 200
replace met2013name = "Rockford, IL" if _n == 201
replace met2013name = "Rocky Mount, NC" if _n == 202
replace met2013name = "Sacramento--Roseville--Arden-Arcade, CA" if _n == 203
replace met2013name = "Saginaw, MI" if _n == 204
replace met2013name = "St. George, UT" if _n == 205
replace met2013name = "St. Joseph, MO-KS" if _n == 206
replace met2013name = "St. Louis, MO-IL" if _n == 207
replace met2013name = "Salinas, CA" if _n == 208
replace met2013name = "Salisbury, MD-DE" if _n == 209
replace met2013name = "Salt Lake City, UT" if _n == 210
replace met2013name = "San Angelo, TX" if _n == 211
replace met2013name = "San Antonio-New Braunfels, TX" if _n == 212
replace met2013name = "San Diego-Carlsbad, CA" if _n == 213
replace met2013name = "San Francisco-Oakland-Hayward, CA" if _n == 214
replace met2013name = "San Jose-Sunnyvale-Santa Clara, CA" if _n == 215
replace met2013name = "San Luis Obispo-Paso Robles-Arroyo Grande, CA" if _n == 216
replace met2013name = "Santa Cruz-Watsonville, CA" if _n == 217
replace met2013name = "Santa Fe, NM" if _n == 218
replace met2013name = "Santa Maria-Santa Barbara, CA" if _n == 219
replace met2013name = "Santa Rosa, CA" if _n == 220
replace met2013name = "Scranton--Wilkes-Barre--Hazleton, PA" if _n == 221
replace met2013name = "Seattle-Tacoma-Bellevue, WA" if _n == 222
replace met2013name = "Sebastian-Vero Beach, FL" if _n == 223
replace met2013name = "Sheboygan, WI" if _n == 224
replace met2013name = "Shreveport-Bossier City, LA" if _n == 225
replace met2013name = "Spartanburg, SC" if _n == 226
replace met2013name = "Spokane-Spokane Valley, WA" if _n == 227
replace met2013name = "Springfield, IL" if _n == 228
replace met2013name = "Springfield, MA" if _n == 229
replace met2013name = "Springfield, MO" if _n == 230
replace met2013name = "Springfield, OH" if _n == 231
replace met2013name = "State College, PA" if _n == 232
replace met2013name = "Stockton-Lodi, CA" if _n == 233
replace met2013name = "Syracuse, NY" if _n == 234
replace met2013name = "Tampa-St. Petersburg-Clearwater, FL" if _n == 235
replace met2013name = "Toledo, OH" if _n == 236
replace met2013name = "Topeka, KS" if _n == 237
replace met2013name = "Trenton, NJ" if _n == 238
replace met2013name = "Tucson, AZ" if _n == 239
replace met2013name = "Tuscaloosa, AL" if _n == 240
replace met2013name = "Tyler, TX" if _n == 241
replace met2013name = "Urban Honolulu, HI" if _n == 242
replace met2013name = "Utica-Rome, NY" if _n == 243
replace met2013name = "Vallejo-Fairfield, CA" if _n == 244
replace met2013name = "Virginia Beach-Norfolk-Newport News, VA-NC" if _n == 245
replace met2013name = "Visalia-Porterville, CA" if _n == 246
replace met2013name = "Waco, TX" if _n == 247
replace met2013name = "Washington-Arlington-Alexandria, DC-VA-MD-WV" if _n == 248
replace met2013name = "Wausau, WI" if _n == 249
replace met2013name = "Wenatchee, WA" if _n == 250
replace met2013name = "Wichita, KS" if _n == 251
replace met2013name = "Wichita Falls, TX" if _n == 252
replace met2013name = "Wilmington, NC" if _n == 253
replace met2013name = "Winston-Salem, NC" if _n == 254
replace met2013name = "Worcester, MA-CT" if _n == 255
replace met2013name = "Yakima, WA" if _n == 256
replace met2013name = "York-Hanover, PA" if _n == 257
replace met2013name = "Youngstown-Warren-Boardman, OH-PA" if _n == 258
replace met2013name = "Yuba City, CA" if _n == 259
replace met2013name = "Yuma, AZ" if _n == 260

egen M = rowtotal(M2024 M2025 M2026 M2027)
egen MD = rowtotal(MD2024 MD2025 MD2026 MD2027)
egen MIndirect = rowtotal(MIndirect*)
egen MTotMinusD = rowtotal(MTotMinusD*)

gen MInduced = MTotMinusD - MIndirect

gen EmploymentDirectAvg = MD/4
gen EmploymentIndirectAvg = MIndirect/4
gen EmploymentInducedAvg = MInduced/4

replace EmploymentDirectAvg		= round(EmploymentDirectAvg)
replace EmploymentIndirectAvg	= round(EmploymentIndirectAvg)
replace EmploymentInducedAvg	= round(EmploymentInducedAvg)

egen EmploymentAvg = rowtotal(EmploymentDirectAvg EmploymentIndirectAvg EmploymentInducedAvg)

keep met2013name EmploymentDirectAvg EmploymentIndirectAvg EmploymentInducedAvg EmploymentAvg
order met2013name EmploymentDirectAvg EmploymentIndirectAvg EmploymentInducedAvg EmploymentAvg

gsort -EmploymentAvg

save ${outputdir}/GND_for_Cities_Model_Final_Results_by_MSA, replace
