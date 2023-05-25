
/*************************************************************************/
*  PROJECT:    		IRA Climate Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Calculate_State_Industry_Shares.do
*  LAST UPDATED: 	5/24/23
*
*  NOTES: 			Calculates the share of each state's employment in
*					each BEA industry, as measured in the 2019 American
*					Community Survey (ACS)	
*
/*************************************************************************/

clear
set more off

cd $workdir

use ${datadir}/ACS_Extract_2019_for_IRA_Climate.dta, clear

merge m:1 ind using ${datadir}/BEA_Naics_Census_Ind_Code_Bridge
drop if _merge == 2
drop _merge

keep if empstat == 1

rename perwt pop

collapse (sum) pop, by(statefip bea_naics)

preserve
collapse (sum) pop, by(statefip)
gen n = _n
save ${workdir}/State_Industry_Employment, replace
restore

bys bea_naics (statefip): egen bea_naics_total = sum(pop)

gen state_share = pop / bea_naics_total

merge 1:m statefip bea_naics using ${datadir}/IOCode_BEA_Naics_Bridge

sort statefip indnum
drop if indnum == .
replace state_share = 0 if state_share == .

* Create matrix with state industry shares
matrix stateindshares = J(51,71,0)
foreach state of numlist 1 2 4 5 6 8 9 10 11 12 13 15 16 17 18 19 20 21 22 23 24 25 26 27 28 29 30 31 32 33 34 35 36 37 38 39 40 41 42 44 45 46 47 48 49 50 51 53 54 55 56 {
	
	if `state' == 1 {
		local i = 1 
	}
	
	if `state' == 2 {
		local i = 2 
	}
	
	if `state' == 4 {
		local i = 3 
	}
	
	if `state' == 5 {
		local i = 4 
	}
	
	if `state' == 6 {
		local i = 5 
	}
	
	if `state' == 8 {
		local i = 6 
	}
	
	if `state' == 9 {
		local i = 7 
	}
	
	if `state' == 10 {
		local i = 8 
	}
	
	if `state' == 11 {
		local i = 9 
	}
	
	if `state' == 12 {
		local i = 10 
	}
	
	if `state' == 13 {
		local i = 11 
	}
	
	if `state' == 15 {
		local i = 12 
	}
	
	if `state' == 16 {
		local i = 13 
	}
	
	if `state' == 17 {
		local i = 14 
	}
	
	if `state' == 18 {
		local i = 15 
	}
	
	if `state' == 19 {
		local i = 16 
	}
	
	if `state' == 20 {
		local i = 17 
	}
	
	if `state' == 21 {
		local i = 18 
	}
	
	if `state' == 22 {
		local i = 19 
	}
	
	if `state' == 23 {
		local i = 20 
	}
	
	if `state' == 24 {
		local i = 21 
	}
	
	if `state' == 25 {
		local i = 22 
	}
	
	if `state' == 26 {
		local i = 23 
	}
	
	if `state' == 27 {
		local i = 24 
	}
	
	if `state' == 28 {
		local i = 25 
	}
	
	if `state' == 29 {
		local i = 26 
	}
	
	if `state' == 30 {
		local i = 27 
	}
	
	if `state' == 31 {
		local i = 28 
	}
	
	if `state' == 32 {
		local i = 29 
	}
	
	if `state' == 33 {
		local i = 30 
	}
	
	if `state' == 34 {
		local i = 31 
	}
	
	if `state' == 35 {
		local i = 32 
	}
	
	if `state' == 36 {
		local i = 33 
	}
	
	if `state' == 37 {
		local i = 34 
	}
	
	if `state' == 38 {
		local i = 35 
	}
	
	if `state' == 39 {
		local i = 36 
	}
	
	if `state' == 40 {
		local i = 37 
	}
	
	if `state' == 41 {
		local i = 38 
	}
	
	if `state' == 42 {
		local i = 39 
	}
	
	if `state' == 44 {
		local i = 40 
	}
	
	if `state' == 45 {
		local i = 41 
	}
	
	if `state' == 46 {
		local i = 42 
	}
	
	if `state' == 47 {
		local i = 43 
	}
	
	if `state' == 48 {
		local i = 44 
	}
	
	if `state' == 49 {
		local i = 45 
	}
	
	if `state' == 50 {
		local i = 46 
	}
	
	if `state' == 51 {
		local i = 47 
	}
	
	if `state' == 53 {
		local i = 48 
	}
	
	if `state' == 54 {
		local i = 49 
	}
	
	if `state' == 55 {
		local i = 50 
	}
	
	if `state' == 56 {
		local i = 51 
	}

	foreach j of numlist 1(1)71 {
		local k = (`i'-1)*71+`j'
		matrix stateindshares[`i',`j'] = state_share[`k']
	}
	
}

svmat stateindshares, names(stateindshares)

keep stateindshares*

save ${workdir}/State_Industry_Shares, replace
	