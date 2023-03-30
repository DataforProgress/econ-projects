
/*************************************************************************/
*  PROJECT:    		IRA Climate Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Calculate_Other_State_Shares.do
*  LAST UPDATED: 	3/19/23
*
*  NOTES: 							
/*************************************************************************/

/*********************************************************/
/* Calculate each state's share of total coastline miles */
/*********************************************************/

import excel using ${datadir}/Coastline_Data_Cleaned.xlsx, firstrow clear

egen coastlinemiles_total_sum = sum(coastlinemiles_total)
gen state_total_coastline_share = coastlinemiles_total / coastlinemiles_total_sum

* Create matrix with state total coastline shares
matrix state_total_coastline_shares = J(51,71,0)
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
		matrix state_total_coastline_shares[`i',`j'] = state_total_coastline_share[`i']
	}
	
}

svmat state_total_coastline_shares, names(state_total_coastline_shares)

keep state_total_coastline_shares*

save ${workdir}/State_Total_Coastline_Shares, replace


/******************************************************************************/
/* Calculate each state's share of the federally recognized tribal population */
/******************************************************************************/

import excel using "${datadir}/Tribal_Populations.xlsx", firstrow clear
rename State state
collapse (sum) EnrolledCitizens, by(state)

set obs `=_N+17'
replace state = "AR" if _n == _N-16
replace state = "DE" if _n == _N-15
replace state = "DC" if _n == _N-14
replace state = "GA" if _n == _N-13
replace state = "HI" if _n == _N-12
replace state = "IL" if _n == _N-11
replace state = "IN" if _n == _N-10
replace state = "KY" if _n == _N-9
replace state = "MD" if _n == _N-8
replace state = "MO" if _n == _N-7
replace state = "NH" if _n == _N-6
replace state = "NJ" if _n == _N-5
replace state = "OH" if _n == _N-4
replace state = "PA" if _n == _N-3
replace state = "TN" if _n == _N-2
replace state = "VT" if _n == _N-1
replace state = "WV" if _n == _N

* Generate state FIPS codes
gen statefip = .
replace statefip = 1 if state == "AL"
replace statefip = 2 if state == "AK"
replace statefip = 4 if state == "AZ"
replace statefip = 5 if state == "AR"
replace statefip = 6 if state == "CA"
replace statefip = 8 if state == "CO"
replace statefip = 9 if state == "CT"
replace statefip = 10 if state == "DE"
replace statefip = 11 if state == "DC"
replace statefip = 12 if state == "FL"
replace statefip = 13 if state == "GA"
replace statefip = 15 if state == "HI"
replace statefip = 16 if state == "ID"
replace statefip = 17 if state == "IL"
replace statefip = 18 if state == "IN"
replace statefip = 19 if state == "IA"
replace statefip = 20 if state == "KS"
replace statefip = 21 if state == "KY"
replace statefip = 22 if state == "LA"
replace statefip = 23 if state == "ME"
replace statefip = 24 if state == "MD"
replace statefip = 25 if state == "MA"
replace statefip = 26 if state == "MI"
replace statefip = 27 if state == "MN"
replace statefip = 28 if state == "MS"
replace statefip = 29 if state == "MO"
replace statefip = 30 if state == "MT"
replace statefip = 31 if state == "NE"
replace statefip = 32 if state == "NV"
replace statefip = 33 if state == "NH"
replace statefip = 34 if state == "NJ"
replace statefip = 35 if state == "NM"
replace statefip = 36 if state == "NY"
replace statefip = 37 if state == "NC"
replace statefip = 38 if state == "ND"
replace statefip = 39 if state == "OH"
replace statefip = 40 if state == "OK"
replace statefip = 41 if state == "OR"
replace statefip = 42 if state == "PA"
replace statefip = 44 if state == "RI"
replace statefip = 45 if state == "SC"
replace statefip = 46 if state == "SD"
replace statefip = 47 if state == "TN"
replace statefip = 48 if state == "TX"
replace statefip = 49 if state == "UT"
replace statefip = 50 if state == "VT"
replace statefip = 51 if state == "VA"
replace statefip = 53 if state == "WA"
replace statefip = 54 if state == "WV"
replace statefip = 55 if state == "WI"
replace statefip = 56 if state == "WY"

replace EnrolledCitizens = 0 if EnrolledCitizens == .
sort statefip

egen EnrolledCitizens_Tot = sum(EnrolledCitizens)

gen state_tribal_pop_share = EnrolledCitizens / EnrolledCitizens_Tot


* Create matrix with state tribal population shares
matrix state_tribal_popshares = J(51,71,0)
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
		matrix state_tribal_popshares[`i',`j'] = state_tribal_pop_share[`i']
	}
	
}

svmat state_tribal_popshares, names(state_tribal_popshares)

keep state_tribal_popshares*

save ${workdir}/State_Tribal_Pop_Shares, replace


/************************************************************************************/
/* Calculate industry shares by state, weighting by state non-MSA population shares */
/************************************************************************************/

use ${datadir}/ACS_Extract_2019_Full.dta, clear

merge m:1 ind using ${datadir}/BEA_Naics_Census_Ind_Code_Bridge
drop if _merge == 2
drop _merge

* Calculate non-MSA population shares
preserve

gen msa = . 
replace msa = 0 if met2013 == 0
replace msa = 1 if met2013 > 0 & met2013 != .

rename perwt pop

collapse (sum) pop, by(statefip msa)

fillin statefip msa 
replace pop = 0 if pop == .

bys statefip: egen state_pop = sum(pop)

gen non_msa_share = pop / state_pop
keep if msa == 0

egen non_msa_share_mean = mean(non_msa_share)

save ${workdir}/State_Non-MSA_Population_Shares, replace

restore


* Calculate state industry shares weighted by non-MSA population shares
keep if empstat == 1

rename perwt pop

collapse (sum) pop, by(statefip bea_naics)

merge m:1 statefip using ${workdir}/State_Non-MSA_Population_Shares
drop _merge

gen non_msa_weight = non_msa_share/non_msa_share_mean

gen popXnon_msa_weight = pop*non_msa_weight

bys bea_naics (statefip): egen bea_naics_popXnon_msa_weight = sum(popXnon_msa_weight)

gen state_share_non_msa_wt = popXnon_msa_weight / bea_naics_popXnon_msa_weight

merge 1:m statefip bea_naics using ${datadir}/IOCode_BEA_Naics_Bridge

sort statefip indnum
drop if indnum == .
replace state_share_non_msa_wt = 0 if state_share_non_msa_wt == .


* Create matrix with state industry shares weighted by non-MSA population shares
matrix state_non_msa_pop_shares = J(51,71,0)
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
		matrix state_non_msa_pop_shares[`i',`j'] = state_share_non_msa_wt[`k']
	}
	
}

svmat state_non_msa_pop_shares, names(state_non_msa_pop_shares)

keep state_non_msa_pop_shares*

save ${workdir}/State_Industry_Non-MSA_Population_Weighted_Shares, replace


/************************************************************************************/
/* Calculate industry shares by state, weighting by state non-MSA population shares */
/************************************************************************************/

use ${datadir}/ACS_Extract_2019_Full.dta, clear

merge m:1 ind using ${datadir}/BEA_Naics_Census_Ind_Code_Bridge
drop if _merge == 2
drop _merge

* Calculate population shares below the poverty line
preserve

gen inpoverty = . 
replace inpoverty = 0 if poverty >= 100 & poverty != .
replace inpoverty = 1 if poverty >= 1 & poverty < 100 & poverty != .

rename perwt pop

collapse (sum) pop, by(statefip inpoverty)

fillin statefip inpoverty
replace pop = 0 if pop == .

bys statefip: egen state_pop = sum(pop)

gen poverty_share = pop / state_pop
keep if inpoverty == 1

egen poverty_share_mean = mean(poverty_share)

save ${workdir}/State_Poverty_Population_Shares, replace

restore


* Calculate state industry shares weighted by population shares below the poverty line
keep if empstat == 1

rename perwt pop

collapse (sum) pop, by(statefip bea_naics)

merge m:1 statefip using ${workdir}/State_Poverty_Population_Shares
drop _merge

gen poverty_weight = poverty_share/poverty_share_mean

gen popXpoverty_weight = pop*poverty_weight

bys bea_naics (statefip): egen bea_naics_popXpoverty_weight = sum(popXpoverty_weight)

gen state_share_poverty_wt = popXpoverty_weight / bea_naics_popXpoverty_weight

merge 1:m statefip bea_naics using ${datadir}/IOCode_BEA_Naics_Bridge

sort statefip indnum
drop if indnum == .
replace state_share_poverty_wt = 0 if state_share_poverty_wt == .


* Create matrix with state industry shares weighted by population shares below the poverty line
matrix state_poverty_pop_shares = J(51,71,0)
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
		matrix state_poverty_pop_shares[`i',`j'] = state_share_poverty_wt[`k']
	}
	
}

svmat state_poverty_pop_shares, names(state_poverty_pop_shares)

keep state_poverty_pop_shares*

save ${workdir}/State_Industry_Poverty_Population_Weighted_Shares, replace


/****************************/
/* Save 48C spending shares */
/****************************/

use ${datadir}/ACS_Extract_2019_Full.dta, clear

merge m:1 ind using ${datadir}/BEA_Naics_Census_Ind_Code_Bridge
drop if _merge == 2
drop _merge

keep if empstat == 1

rename perwt pop

collapse (sum) pop, by(statefip bea_naics)

merge 1:m statefip bea_naics using ${datadir}/IOCode_BEA_Naics_Bridge

sort statefip indnum
drop if indnum == .


* Use 48(c) investment shares from Jake Rigdon
* (Allocate jobs proportionally to these investment shares for all industries)
* States with either a mine closure or a plant closure:
* AK, AL, AR, AZ, CA, CO, DC, DE, FL, GA, IA, IL, IN, KS, KY, LA, MA, MD, MI, MN, MO, MS, MT, NC, ND, NE, NJ, NM, NV, NY, OH, OK, PA, SC, SD, TN, TX, UT, VA, WI, WV, WY (only difference from our list is addition of CA, DC, and NE)
* States with neither: CT, HI, ID, ME, NH, OR, RI, VT

gen state_share_48c = 0
replace state_share_48c = 455/3161 if statefip == 42 /* PA */
replace state_share_48c = 254/3161 if statefip == 21 /* KY */
replace state_share_48c = 247/3161 if statefip == 17 /* IL */ 
replace state_share_48c = 233/3161 if statefip == 54 /* WV */
replace state_share_48c = 214/3161 if statefip == 39 /* OH */
replace state_share_48c = 136/3161 if statefip == 18 /* IN */
replace state_share_48c = 121/3161 if statefip == 51 /* VA */
replace state_share_48c = 114/3161 if statefip == 8 /* CO */
replace state_share_48c = 103/3161 if statefip == 1 /* AL */
replace state_share_48c = 96/3161 if statefip == 37 /* NC */
replace state_share_48c = 91/3161 if statefip == 26 /* MI */
replace state_share_48c = 88/3161 if statefip == 48 /* TX */
replace state_share_48c = 83/3161 if statefip == 55 /* WI */
replace state_share_48c = 81/3161 if statefip == 29 /* MO */
replace state_share_48c = 73/3161 if statefip == 19 /* IA */
replace state_share_48c = 59/3161 if statefip == 45 /* SC */
replace state_share_48c = 59/3161 if statefip == 13 /* GA */
replace state_share_48c = 51/3161 if statefip == 6 /* CA */
replace state_share_48c = 45/3161 if statefip == 47 /* TN */
replace state_share_48c = 45/3161 if statefip == 49 /* UT */
replace state_share_48c = 45/3161 if statefip == 36 /* NY */
replace state_share_48c = 45/3161 if statefip == 27 /* MN */
replace state_share_48c = 43/3161 if statefip == 40 /* OK */
replace state_share_48c = 43/3161 if statefip == 56 /* WY */
replace state_share_48c = 38/3161 if statefip == 12 /* FL */
replace state_share_48c = 36/3161 if statefip == 30 /* MT */
replace state_share_48c = 30/3161 if statefip == 4 /* AZ */
replace state_share_48c = 29/3161 if statefip == 35 /* NM */
replace state_share_48c = 26/3161 if statefip == 24 /* MD */
replace state_share_48c = 25/3161 if statefip == 34 /* NJ */
replace state_share_48c = 24/3161 if statefip == 25 /* MA */
replace state_share_48c = 20/3161 if statefip == 20 /* KS */
replace state_share_48c = 19/3161 if statefip == 38 /* ND */
replace state_share_48c = 19/3161 if statefip == 28 /* MS */
replace state_share_48c = 18/3161 if statefip == 22 /* LA */
replace state_share_48c = 17/3161 if statefip == 32 /* NV */
replace state_share_48c = 16/3161 if statefip == 46 /* SD */
replace state_share_48c = 8/3161 if statefip == 10 /* DE */
replace state_share_48c = 6/3161 if statefip == 2 /* AK	*/
replace state_share_48c = 3/3161 if statefip == 31 /* NE */
replace state_share_48c = 2/3161 if statefip == 11 /* DC */
replace state_share_48c = 1/3161 if statefip == 5 /* AR	*/

* Create matrix with state 48C shares
matrix state_shares_48c = J(51,71,0)
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
		matrix state_shares_48c[`i',`j'] = state_share_48c[`k']
	}
	
}

svmat state_shares_48c, names(state_shares_48c)

keep state_shares_48c*

save ${workdir}/State_Shares_48c, replace

	