
/*************************************************************************/
*  PROJECT:    		IRA Climate Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Allocate_Jobs_Across_States.do
*  LAST UPDATED: 	5/24/23
*					
/*************************************************************************/

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


/**************************************************************/
/* DEFINE ALLOCATION GROUPS AND RUN MODEL SEPARATELY FOR EACH */
/**************************************************************/

* For those sections of the IRA with provisions specifying how funds will be
* distributed geographically, we allocate at least part of the associated direct 
* jobs in proportion to the allocation of these funds

* To make the calculations tractable we divide up the sections of the IRA into 
* groups based on methodology for allocating funds, with "Allocation 0" denoting
* those sections that have no specific provisions regarding geographic distribution
* of funds and "Allocations 1-9" the others

gen Allocation = 0

* Allocation based on miles of coastline
replace Allocation = 1 if inlist(Section,"40001","60102")

* Allocation based on tribal population
* For Section 50122, allocate only 5% of direct jobs in proportion to state tribal populations
replace Allocation = 2 if inlist(Section,"50122")

* Allocation based on tribal population
replace Allocation = 3 if inlist(Section,"50145","80001","80003","80004")

* Allocation based on rural population
replace Allocation = 4 if inlist(Section,"13404","22004")

* Allocation based on rural population
* For Section 22002, allocate only 50% of direct jobs in proportion to non-MSA population
replace Allocation = 5 if inlist(Section,"22002")

* Allocation based on population below the poverty line
* For Section 60103, allocate 55.55% of direct jobs in proportion to population below the poverty line
replace Allocation = 6 if inlist(Section,"60103")

* Allocation based on population below the poverty line
* For Section 60501, allocate 50.73% of direct jobs 
replace Allocation = 7 if inlist(Section,"60501")

* Allocation based on 48C Census tracts
* For Section 13501, allocate 60% of direct jobs in proportion to 48C Census tracts
replace Allocation = 8 if inlist(Section,"13501")

* Allocation to Hawaii
replace Allocation = 9 if inlist(Section,"80002")


* Loop over ten allocation groups and run model separately for each:

foreach allocationnum of numlist 0(1)9 {
		
	preserve
	
	keep if Allocation == `allocationnum'

	collapse (sum) SpendingTot* SpendingPub*, by(IndustryCode)
	rename IndustryCode beaiocodes

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


	* Generate spending vectors

	merge 1:1 beaiocodes using ${datadir}/All_BEAIOCodes.dta
	sort num
	drop _merge

	foreach year of numlist 2023(1)2032 {
		replace Spending`year' = 0 if Spending`year' == .
	}

	save ${workdir}/IRA_Climate_Spending_by_Industry_Allocation_`allocationnum', replace
	
	restore

}

* Calculate output and employment effects by allocation category (2023-2032)

foreach allocationnum of numlist 0(1)9 {
	
	use ${workdir}/IRA_Climate_Spending_by_Industry_Allocation_`allocationnum', clear
	
	* Construct vectors of spending on synthetic industries
	
	foreach year of numlist 2023(1)2032 {
	
		cap qui summ Spending`year' if beaiocodes == "BioenergyP"
		if `r(N)' != 0 {
			global BioenergyP`year' = `r(mean)'
		}
		else {
			global BioenergyP`year' = 0
		}
		matrix BioenergyP`year' = ${BioenergyP`year'}*BioenergyP
	
		cap qui summ Spending`year' if beaiocodes == "CoalP"
		if `r(N)' != 0 {
			global CoalP`year' = `r(mean)'
		}
		else {
			global CoalP`year' = 0
		}
		matrix CoalP`year' = ${CoalP`year'}*CoalP
	
		cap qui summ Spending`year' if beaiocodes == "Nonrenewables"
		if `r(N)' != 0 {
			global Nonrenewables`year' = `r(mean)'
		}
		else {
			global Nonrenewables`year' = 0
		}
		matrix Nonrenewables`year' = ${Nonrenewables`year'}*Nonrenewables
	
		cap qui summ Spending`year' if beaiocodes == "Nuclear"
		if `r(N)' != 0 {
			global Nuclear`year' = `r(mean)'
		}
		else {
			global Nuclear`year' = 0
		}
		matrix Nuclear`year' = ${Nuclear`year'}*Nuclear
	
		cap qui summ Spending`year' if beaiocodes == "OilGasP"
		if `r(N)' != 0 {
			global OilGasP`year' = `r(mean)'
		}
		else {
			global OilGasP`year' = 0
		}
		matrix OilGasP`year' = ${OilGasP`year'}*OilGasP
	
		cap qui summ Spending`year' if beaiocodes == "Renewables"
		if `r(N)' != 0 {
			global Renewables`year' = `r(mean)'
		}
		else {
			global Renewables`year' = 0
		}
		matrix Renewables`year' = ${Renewables`year'}*Renewables
	
		cap qui summ Spending`year' if beaiocodes == "SmartGrid"
		if `r(N)' != 0 {
			global SmartGrid`year' = `r(mean)'
		}
		else {
			global SmartGrid`year' = 0
		}
		matrix SmartGrid`year' = ${SmartGrid`year'}*SmartGrid
	
		cap qui summ Spending`year' if beaiocodes == "Solar"
		if `r(N)' != 0 {
			global Solar`year' = `r(mean)'
		}
		else {
			global Solar`year' = 0
		}
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
	

	local multiplier = 1.4
	
	rename beaiocodes iocode

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
		matrix colname Exp`year' = Exp`year'
		svmat Exp`year', names(col)
	
		* Save output and employment vectors
		
		matrix colname Y`year' = Y`year'
		svmat Y`year', names(col)
		
		matrix colname V`year' = V`year'
		svmat V`year', names(col)
		
		matrix colname E`year' = E`year'
		svmat E`year', names(col)
		
		matrix colname D`year' = D`year'
		svmat D`year', names(col)
		
		* Apply multiplier (induced effects) - to variables AND matrices
		gen double Emult`year'	=	`multiplier'*E`year'
		gen double Vmult`year' 	= 	`multiplier'*V`year'
	
		matrix Emult`year' 			= `multiplier'*E`year'
		matrix Vmult`year' 			= `multiplier'*V`year'

	}
	
	save ${workdir}/IRA_Climate_Model_Run_Results_by_Industry_Year_Allocation_`allocationnum', replace


	collapse (sum) Y* E* V* D*
	gen n = _n
	reshape long Y E Emult V Vmult D Exp, i(n) j(year)
	*replace year = (year-1)/10
	drop n

	replace year = floor(year/10)

	* Convert back to 2022 dollars
	replace Y 		= Y*(125.541/117.021)
	replace Exp 	= Exp*(125.541/117.021)
	replace V 		= V*(125.541/117.021)
	replace Vmult 	= Vmult*(125.541/117.021)

	gen Indirect = E - D

	save ${workdir}/IRA_Climate_Model_Run_Final_Results_Allocation_`allocationnum', replace
	
}


* Allocation #0 - Basic
	
use ${workdir}/IRA_Climate_Model_Run_Results_by_Industry_Year_Allocation_0, clear

foreach year of numlist 2023(1)2032 {
	
	mkmat E`year'
	mkmat D`year'
	mkmat Emult`year'
	
	* Calculate indirect effects left over after subtracting off the direct effects
	matrix EMinusD`year' = E`year' - D`year'
	
	* Calculate indirect and induced effects left over after subtracting off the direct effects
	matrix EmultMinusD`year' = Emult`year' - D`year'
	
	* Allocate direct jobs
	matrix S`year' = stateindshares*EmultMinusD`year' + stateindshares*D`year'
	
	* Direct jobs by state
	matrix SD`year' = stateindshares*D`year'
	
	* Indirect jobs by state
	matrix SIndirect`year' = stateindshares*EMinusD`year'
	
	* Indirect/induced jobs by state
	matrix STotMinusD`year' = stateindshares*EmultMinusD`year'
	
	matrix colname S`year' = S`year'
	svmat S`year', names(col)
	
	matrix colname SD`year' = SD`year'
	svmat SD`year', names(col)
	
	matrix colname SIndirect`year' = SIndirect`year'
	svmat SIndirect`year', names(col)
	
	matrix colname STotMinusD`year' = STotMinusD`year'
	svmat STotMinusD`year', names(col)
	
}

egen S = rowtotal(S2023 S2024 S2025 S2026 S2027 S2028 S2029 S2030 S2031 S2032)
egen SD = rowtotal(SD2023 SD2024 SD2025 SD2026 SD2027 SD2028 SD2029 SD2030 SD2031 SD2032)
egen SIndirect = rowtotal(SIndirect2023 SIndirect2024 SIndirect2025 SIndirect2026 SIndirect2027 SIndirect2028 SIndirect2029 SIndirect2030 SIndirect2031 SIndirect2032)
egen STotMinusD = rowtotal(STotMinusD2023 STotMinusD2024 STotMinusD2025 STotMinusD2026 STotMinusD2027 STotMinusD2028 STotMinusD2029 STotMinusD2030 STotMinusD2031 STotMinusD2032)

gen SInduced = STotMinusD - SIndirect

gen SDAvg = SD/10
gen SIndirectAvg = SIndirect/10
gen SInducedAvg = SInduced/10
gen SAvg = S/10

gen Allocation = 0

keep S SD SIndirect STotMinusD SInduced SDAvg SIndirectAvg SInducedAvg SAvg Allocation

drop if _n > 51

save ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_0, replace


* Allocation #1 - Miles of coastline
	
use ${workdir}/IRA_Climate_Model_Run_Results_by_Industry_Year_Allocation_1, clear

foreach year of numlist 2023(1)2032 {
	
	mkmat E`year'
	mkmat D`year'
	mkmat Emult`year'
	
	* Calculate indirect effects left over after subtracting off the direct effects
	matrix EMinusD`year' = E`year' - D`year'
	
	* Calculate indirect and induced effects left over after subtracting off the direct effects
	matrix EmultMinusD`year' = Emult`year' - D`year'
	
	* Allocate direct jobs
	matrix S`year' = stateindshares*EmultMinusD`year' + state_total_coastline_shares*D`year'
	
	* Direct jobs by state
	matrix SD`year' = state_total_coastline_shares*D`year'
	
	* Indirect jobs by state
	matrix SIndirect`year' = stateindshares*EMinusD`year'
	
	* Indirect/induced jobs by state
	matrix STotMinusD`year' = stateindshares*EmultMinusD`year'
	
	matrix colname S`year' = S`year'
	svmat S`year', names(col)
	
	matrix colname SD`year' = SD`year'
	svmat SD`year', names(col)
	
	matrix colname SIndirect`year' = SIndirect`year'
	svmat SIndirect`year', names(col)
	
	matrix colname STotMinusD`year' = STotMinusD`year'
	svmat STotMinusD`year', names(col)
	
}

egen S = rowtotal(S2023 S2024 S2025 S2026 S2027 S2028 S2029 S2030 S2031 S2032)
egen SD = rowtotal(SD2023 SD2024 SD2025 SD2026 SD2027 SD2028 SD2029 SD2030 SD2031)
egen SIndirect = rowtotal(SIndirect2023 SIndirect2024 SIndirect2025 SIndirect2026 SIndirect2027 SIndirect2028 SIndirect2029 SIndirect2030 SIndirect2031 SIndirect2032)
egen STotMinusD = rowtotal(STotMinusD2023 STotMinusD2024 STotMinusD2025 STotMinusD2026 STotMinusD2027 STotMinusD2028 STotMinusD2029 STotMinusD2030 STotMinusD2031 STotMinusD2032)

gen SInduced = STotMinusD - SIndirect

gen SDAvg = SD/10
gen SIndirectAvg = SIndirect/10
gen SInducedAvg = SInduced/10
gen SAvg = S/10

gen Allocation = 1

keep S SD SIndirect STotMinusD SInduced SDAvg SIndirectAvg SInducedAvg SAvg Allocation

drop if _n > 51

save ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_1, replace


* Allocation #2 - Tribal population (Section 50122)
* Allocate only 5% of direct jobs in proportion to state tribal populations
	
use ${workdir}/IRA_Climate_Model_Run_Results_by_Industry_Year_Allocation_2, clear

foreach year of numlist 2023(1)2032 {
	
	mkmat E`year'
	mkmat D`year'
	mkmat Emult`year'
	
	* Calculate indirect effects left over after subtracting off the direct effects
	matrix EMinusD`year' = E`year' - D`year'
	
	* Calculate indirect and induced effects left over after subtracting off the direct effects
	matrix EmultMinusD`year' = Emult`year' - D`year'
	
	* Allocate direct jobs
	matrix S`year' = stateindshares*EmultMinusD`year' + stateindshares*0.95*D`year' + state_tribal_popshares*0.05*D`year'
	
	* Direct jobs by state
	matrix SD`year' = stateindshares*0.95*D`year' + state_tribal_popshares*0.05*D`year'
	
	* Indirect jobs by state
	matrix SIndirect`year' = stateindshares*EMinusD`year'
	
	* Indirect/induced jobs by state
	matrix STotMinusD`year' = stateindshares*EmultMinusD`year'
	
	matrix colname S`year' = S`year'
	svmat S`year', names(col)
	
	matrix colname SD`year' = SD`year'
	svmat SD`year', names(col)
	
	matrix colname SIndirect`year' = SIndirect`year'
	svmat SIndirect`year', names(col)
	
	matrix colname STotMinusD`year' = STotMinusD`year'
	svmat STotMinusD`year', names(col)
	
}

egen S = rowtotal(S2023 S2024 S2025 S2026 S2027 S2028 S2029 S2030 S2031 S2032)
egen SD = rowtotal(SD2023 SD2024 SD2025 SD2026 SD2027 SD2028 SD2029 SD2030 SD2031)
egen SIndirect = rowtotal(SIndirect2023 SIndirect2024 SIndirect2025 SIndirect2026 SIndirect2027 SIndirect2028 SIndirect2029 SIndirect2030 SIndirect2031 SIndirect2032)
egen STotMinusD = rowtotal(STotMinusD2023 STotMinusD2024 STotMinusD2025 STotMinusD2026 STotMinusD2027 STotMinusD2028 STotMinusD2029 STotMinusD2030 STotMinusD2031 STotMinusD2032)

gen SInduced = STotMinusD - SIndirect

gen SDAvg = SD/10
gen SIndirectAvg = SIndirect/10
gen SInducedAvg = SInduced/10
gen SAvg = S/10

gen Allocation = 2

keep S SD SIndirect STotMinusD SInduced SDAvg SIndirectAvg SInducedAvg SAvg Allocation

drop if _n > 51

save ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_2, replace


* Allocation #3 - Tribal population (other sections)
	
use ${workdir}/IRA_Climate_Model_Run_Results_by_Industry_Year_Allocation_3, clear

foreach year of numlist 2023(1)2032 {
	
	mkmat E`year'
	mkmat D`year'
	mkmat Emult`year'
	
	* Calculate indirect effects left over after subtracting off the direct effects
	matrix EMinusD`year' = E`year' - D`year'
	
	* Calculate indirect and induced effects left over after subtracting off the direct effects
	matrix EmultMinusD`year' = Emult`year' - D`year'
	
	* Allocate direct jobs
	matrix S`year' = stateindshares*EmultMinusD`year' + state_tribal_popshares*D`year'
	
	* Direct jobs by state
	matrix SD`year' = state_tribal_popshares*D`year'
	
	* Indirect jobs by state
	matrix SIndirect`year' = stateindshares*EMinusD`year'
	
	* Indirect/induced jobs by state
	matrix STotMinusD`year' = stateindshares*EmultMinusD`year'
	
	matrix colname S`year' = S`year'
	svmat S`year', names(col)
	
	matrix colname SD`year' = SD`year'
	svmat SD`year', names(col)
	
	matrix colname SIndirect`year' = SIndirect`year'
	svmat SIndirect`year', names(col)
	
	matrix colname STotMinusD`year' = STotMinusD`year'
	svmat STotMinusD`year', names(col)
	
}

egen S = rowtotal(S2023 S2024 S2025 S2026 S2027 S2028 S2029 S2030 S2031 S2032)
egen SD = rowtotal(SD2023 SD2024 SD2025 SD2026 SD2027 SD2028 SD2029 SD2030 SD2031)
egen SIndirect = rowtotal(SIndirect2023 SIndirect2024 SIndirect2025 SIndirect2026 SIndirect2027 SIndirect2028 SIndirect2029 SIndirect2030 SIndirect2031 SIndirect2032)
egen STotMinusD = rowtotal(STotMinusD2023 STotMinusD2024 STotMinusD2025 STotMinusD2026 STotMinusD2027 STotMinusD2028 STotMinusD2029 STotMinusD2030 STotMinusD2031 STotMinusD2032)

gen SInduced = STotMinusD - SIndirect

gen SDAvg = SD/10
gen SIndirectAvg = SIndirect/10
gen SInducedAvg = SInduced/10
gen SAvg = S/10

gen Allocation = 3

keep S SD SIndirect STotMinusD SInduced SDAvg SIndirectAvg SInducedAvg SAvg Allocation

drop if _n > 51

save ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_3, replace


* Allocation #4 - Rural population (Sections 13404 and 22004)
	
use ${workdir}/IRA_Climate_Model_Run_Results_by_Industry_Year_Allocation_4, clear

foreach year of numlist 2023(1)2032 {
	
	mkmat E`year'
	mkmat D`year'
	mkmat Emult`year'
	
	* Calculate indirect effects left over after subtracting off the direct effects
	matrix EMinusD`year' = E`year' - D`year'
	
	* Calculate indirect and induced effects left over after subtracting off the direct effects
	matrix EmultMinusD`year' = Emult`year' - D`year'
	
	* Allocate direct jobs
	matrix S`year' = stateindshares*EmultMinusD`year' + state_non_msa_pop_shares*D`year'
	
	* Direct jobs by state
	matrix SD`year' = state_non_msa_pop_shares*D`year'
	
	* Indirect jobs by state
	matrix SIndirect`year' = stateindshares*EMinusD`year'
	
	* Indirect/induced jobs by state
	matrix STotMinusD`year' = stateindshares*EmultMinusD`year'
	
	matrix colname S`year' = S`year'
	svmat S`year', names(col)
	
	matrix colname SD`year' = SD`year'
	svmat SD`year', names(col)
	
	matrix colname SIndirect`year' = SIndirect`year'
	svmat SIndirect`year', names(col)
	
	matrix colname STotMinusD`year' = STotMinusD`year'
	svmat STotMinusD`year', names(col)
	
}

egen S = rowtotal(S2023 S2024 S2025 S2026 S2027 S2028 S2029 S2030 S2031 S2032)
egen SD = rowtotal(SD2023 SD2024 SD2025 SD2026 SD2027 SD2028 SD2029 SD2030 SD2031)
egen SIndirect = rowtotal(SIndirect2023 SIndirect2024 SIndirect2025 SIndirect2026 SIndirect2027 SIndirect2028 SIndirect2029 SIndirect2030 SIndirect2031 SIndirect2032)
egen STotMinusD = rowtotal(STotMinusD2023 STotMinusD2024 STotMinusD2025 STotMinusD2026 STotMinusD2027 STotMinusD2028 STotMinusD2029 STotMinusD2030 STotMinusD2031 STotMinusD2032)

gen SInduced = STotMinusD - SIndirect

gen SDAvg = SD/10
gen SIndirectAvg = SIndirect/10
gen SInducedAvg = SInduced/10
gen SAvg = S/10

gen Allocation = 4

keep S SD SIndirect STotMinusD SInduced SDAvg SIndirectAvg SInducedAvg SAvg Allocation

drop if _n > 51

save ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_4, replace


* Allocation #5 - Rural population (Section 22002)
* For Section 22002, allocate only 50% of direct jobs in proportion to non-MSA population
	
use ${workdir}/IRA_Climate_Model_Run_Results_by_Industry_Year_Allocation_5, clear

foreach year of numlist 2023(1)2032 {
	
	mkmat E`year'
	mkmat D`year'
	mkmat Emult`year'
	
	* Calculate indirect effects left over after subtracting off the direct effects
	matrix EMinusD`year' = E`year' - D`year'
	
	* Calculate indirect and induced effects left over after subtracting off the direct effects
	matrix EmultMinusD`year' = Emult`year' - D`year'
	
	* Allocate direct jobs
	matrix S`year' = stateindshares*EmultMinusD`year' + stateindshares*0.5*D`year' + state_non_msa_pop_shares*0.5*D`year'
	
	* Direct jobs by state
	matrix SD`year' = stateindshares*0.5*D`year' + state_non_msa_pop_shares*0.5*D`year'
	
	* Indirect jobs by state
	matrix SIndirect`year' = stateindshares*EMinusD`year'
	
	* Indirect/induced jobs by state
	matrix STotMinusD`year' = stateindshares*EmultMinusD`year'
	
	matrix colname S`year' = S`year'
	svmat S`year', names(col)
	
	matrix colname SD`year' = SD`year'
	svmat SD`year', names(col)
	
	matrix colname SIndirect`year' = SIndirect`year'
	svmat SIndirect`year', names(col)
	
	matrix colname STotMinusD`year' = STotMinusD`year'
	svmat STotMinusD`year', names(col)
	
}

egen S = rowtotal(S2023 S2024 S2025 S2026 S2027 S2028 S2029 S2030 S2031 S2032)
egen SD = rowtotal(SD2023 SD2024 SD2025 SD2026 SD2027 SD2028 SD2029 SD2030 SD2031)
egen SIndirect = rowtotal(SIndirect2023 SIndirect2024 SIndirect2025 SIndirect2026 SIndirect2027 SIndirect2028 SIndirect2029 SIndirect2030 SIndirect2031 SIndirect2032)
egen STotMinusD = rowtotal(STotMinusD2023 STotMinusD2024 STotMinusD2025 STotMinusD2026 STotMinusD2027 STotMinusD2028 STotMinusD2029 STotMinusD2030 STotMinusD2031 STotMinusD2032)

gen SInduced = STotMinusD - SIndirect

gen SDAvg = SD/10
gen SIndirectAvg = SIndirect/10
gen SInducedAvg = SInduced/10
gen SAvg = S/10

gen Allocation = 5

keep S SD SIndirect STotMinusD SInduced SDAvg SIndirectAvg SInducedAvg SAvg Allocation

drop if _n > 51

save ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_5, replace


* Allocation #6 - Low-income population (Section 60103)
* For Section 60103, allocate 55.55% of direct jobs in proportion to population below the poverty line
	
use ${workdir}/IRA_Climate_Model_Run_Results_by_Industry_Year_Allocation_6, clear

foreach year of numlist 2023(1)2032 {
	
	mkmat E`year'
	mkmat D`year'
	mkmat Emult`year'
	
	* Calculate indirect effects left over after subtracting off the direct effects
	matrix EMinusD`year' = E`year' - D`year'
	
	* Calculate indirect and induced effects left over after subtracting off the direct effects
	matrix EmultMinusD`year' = Emult`year' - D`year'
	
	* Allocate direct jobs
	matrix S`year' = stateindshares*EmultMinusD`year' + stateindshares*(0.4445)*D`year' + state_poverty_pop_shares*(0.5555)*D`year'
	
	* Direct jobs by state
	matrix SD`year' = stateindshares*(0.4445)*D`year' + state_poverty_pop_shares*(0.5555)*D`year'
	
	* Indirect jobs by state
	matrix SIndirect`year' = stateindshares*EMinusD`year'
	
	* Indirect/induced jobs by state
	matrix STotMinusD`year' = stateindshares*EmultMinusD`year'
	
	matrix colname S`year' = S`year'
	svmat S`year', names(col)
	
	matrix colname SD`year' = SD`year'
	svmat SD`year', names(col)
	
	matrix colname SIndirect`year' = SIndirect`year'
	svmat SIndirect`year', names(col)
	
	matrix colname STotMinusD`year' = STotMinusD`year'
	svmat STotMinusD`year', names(col)
	
}

egen S = rowtotal(S2023 S2024 S2025 S2026 S2027 S2028 S2029 S2030 S2031 S2032)
egen SD = rowtotal(SD2023 SD2024 SD2025 SD2026 SD2027 SD2028 SD2029 SD2030 SD2031)
egen SIndirect = rowtotal(SIndirect2023 SIndirect2024 SIndirect2025 SIndirect2026 SIndirect2027 SIndirect2028 SIndirect2029 SIndirect2030 SIndirect2031 SIndirect2032)
egen STotMinusD = rowtotal(STotMinusD2023 STotMinusD2024 STotMinusD2025 STotMinusD2026 STotMinusD2027 STotMinusD2028 STotMinusD2029 STotMinusD2030 STotMinusD2031 STotMinusD2032)

gen SInduced = STotMinusD - SIndirect

gen SDAvg = SD/10
gen SIndirectAvg = SIndirect/10
gen SInducedAvg = SInduced/10
gen SAvg = S/10

gen Allocation = 6

keep S SD SIndirect STotMinusD SInduced SDAvg SIndirectAvg SInducedAvg SAvg Allocation

drop if _n > 51

save ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_6, replace


* Allocation #7 - Low-income population (Section 60501)
* For Section 60501, allocate 50.73% of direct jobs in proportion to population below the poverty line
	
use ${workdir}/IRA_Climate_Model_Run_Results_by_Industry_Year_Allocation_7, clear

foreach year of numlist 2023(1)2032 {
	
	mkmat E`year'
	mkmat D`year'
	mkmat Emult`year'
	
	* Calculate indirect effects left over after subtracting off the direct effects
	matrix EMinusD`year' = E`year' - D`year'
	
	* Calculate indirect and induced effects left over after subtracting off the direct effects
	matrix EmultMinusD`year' = Emult`year' - D`year'
	
	* Allocate direct jobs
	matrix S`year' = stateindshares*EmultMinusD`year' + stateindshares*(0.4927)*D`year' + state_poverty_pop_shares*(0.5073)*D`year'
	
	* Direct jobs by state
	matrix SD`year' = stateindshares*(0.4927)*D`year' + state_poverty_pop_shares*(0.5073)*D`year'
	
	* Indirect jobs by state
	matrix SIndirect`year' = stateindshares*EMinusD`year'
	
	* Indirect/induced jobs by state
	matrix STotMinusD`year' = stateindshares*EmultMinusD`year'
	
	matrix colname S`year' = S`year'
	svmat S`year', names(col)
	
	matrix colname SD`year' = SD`year'
	svmat SD`year', names(col)
	
	matrix colname SIndirect`year' = SIndirect`year'
	svmat SIndirect`year', names(col)
	
	matrix colname STotMinusD`year' = STotMinusD`year'
	svmat STotMinusD`year', names(col)
	
}

egen S = rowtotal(S2023 S2024 S2025 S2026 S2027 S2028 S2029 S2030 S2031 S2032)
egen SD = rowtotal(SD2023 SD2024 SD2025 SD2026 SD2027 SD2028 SD2029 SD2030 SD2031)
egen SIndirect = rowtotal(SIndirect2023 SIndirect2024 SIndirect2025 SIndirect2026 SIndirect2027 SIndirect2028 SIndirect2029 SIndirect2030 SIndirect2031 SIndirect2032)
egen STotMinusD = rowtotal(STotMinusD2023 STotMinusD2024 STotMinusD2025 STotMinusD2026 STotMinusD2027 STotMinusD2028 STotMinusD2029 STotMinusD2030 STotMinusD2031 STotMinusD2032)

gen SInduced = STotMinusD - SIndirect

gen SDAvg = SD/10
gen SIndirectAvg = SIndirect/10
gen SInducedAvg = SInduced/10
gen SAvg = S/10

gen Allocation = 7

keep S SD SIndirect STotMinusD SInduced SDAvg SIndirectAvg SInducedAvg SAvg Allocation

drop if _n > 51

save ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_7, replace


* Allocation #8 - 48C Census tracts
* For Section 13501, allocate 60% of direct jobs in proportion to 48C Census tracts
	
use ${workdir}/IRA_Climate_Model_Run_Results_by_Industry_Year_Allocation_8, clear

foreach year of numlist 2023(1)2032 {
	
	mkmat E`year'
	mkmat D`year'
	mkmat Emult`year'
	
	* Calculate indirect effects left over after subtracting off the direct effects
	matrix EMinusD`year' = E`year' - D`year'
	
	* Calculate indirect and induced effects left over after subtracting off the direct effects
	matrix EmultMinusD`year' = Emult`year' - D`year'
	
	* Allocate direct jobs
	matrix S`year' = stateindshares*EmultMinusD`year' + stateindshares*0.4*D`year' + state_shares_48c*0.6*D`year'
	
	* Direct jobs by state
	matrix SD`year' = stateindshares*0.4*D`year' + state_shares_48c*0.6*D`year'
	
	* Indirect jobs by state
	matrix SIndirect`year' = stateindshares*EMinusD`year'
	
	* Indirect/induced jobs by state
	matrix STotMinusD`year' = stateindshares*EmultMinusD`year'
	
	matrix colname S`year' = S`year'
	svmat S`year', names(col)
	
	matrix colname SD`year' = SD`year'
	svmat SD`year', names(col)
	
	matrix colname SIndirect`year' = SIndirect`year'
	svmat SIndirect`year', names(col)
	
	matrix colname STotMinusD`year' = STotMinusD`year'
	svmat STotMinusD`year', names(col)
	
}

egen S = rowtotal(S2023 S2024 S2025 S2026 S2027 S2028 S2029 S2030 S2031 S2032)
egen SD = rowtotal(SD2023 SD2024 SD2025 SD2026 SD2027 SD2028 SD2029 SD2030 SD2031)
egen SIndirect = rowtotal(SIndirect2023 SIndirect2024 SIndirect2025 SIndirect2026 SIndirect2027 SIndirect2028 SIndirect2029 SIndirect2030 SIndirect2031 SIndirect2032)
egen STotMinusD = rowtotal(STotMinusD2023 STotMinusD2024 STotMinusD2025 STotMinusD2026 STotMinusD2027 STotMinusD2028 STotMinusD2029 STotMinusD2030 STotMinusD2031 STotMinusD2032)

gen SInduced = STotMinusD - SIndirect

gen SDAvg = SD/10
gen SIndirectAvg = SIndirect/10
gen SInducedAvg = SInduced/10
gen SAvg = S/10

gen Allocation = 8

keep S SD SIndirect STotMinusD SInduced SDAvg SIndirectAvg SInducedAvg SAvg Allocation

drop if _n > 51

save ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_8, replace


* Allocation #9 - Hawaii
	
use ${workdir}/IRA_Climate_Model_Run_Results_by_Industry_Year_Allocation_9, clear

matrix hawaii = J(51,71,0)
foreach j of numlist 1(1)71 {
		matrix hawaii[12,`j'] = 1
}


foreach year of numlist 2023(1)2032 {
	
	mkmat E`year'
	mkmat D`year'
	mkmat Emult`year'
	
	* Calculate indirect effects left over after subtracting off the direct effects
	matrix EMinusD`year' = E`year' - D`year'
	
	* Calculate indirect and induced effects left over after subtracting off the direct effects
	matrix EmultMinusD`year' = Emult`year' - D`year'
	
	* Allocate direct jobs
	matrix S`year' = stateindshares*EmultMinusD`year' + hawaii*D`year'
	
	* Direct jobs by state
	matrix SD`year' = hawaii*D`year'
	
	* Indirect jobs by state
	matrix SIndirect`year' = stateindshares*EMinusD`year'
	
	* Indirect/induced jobs by state
	matrix STotMinusD`year' = stateindshares*EmultMinusD`year'
	
	matrix colname S`year' = S`year'
	svmat S`year', names(col)
	
	matrix colname SD`year' = SD`year'
	svmat SD`year', names(col)
	
	matrix colname SIndirect`year' = SIndirect`year'
	svmat SIndirect`year', names(col)
	
	matrix colname STotMinusD`year' = STotMinusD`year'
	svmat STotMinusD`year', names(col)
	
}

egen S = rowtotal(S2023 S2024 S2025 S2026 S2027 S2028 S2029 S2030 S2031 S2032)
egen SD = rowtotal(SD2023 SD2024 SD2025 SD2026 SD2027 SD2028 SD2029 SD2030 SD2031)
egen SIndirect = rowtotal(SIndirect2023 SIndirect2024 SIndirect2025 SIndirect2026 SIndirect2027 SIndirect2028 SIndirect2029 SIndirect2030 SIndirect2031 SIndirect2032)
egen STotMinusD = rowtotal(STotMinusD2023 STotMinusD2024 STotMinusD2025 STotMinusD2026 STotMinusD2027 STotMinusD2028 STotMinusD2029 STotMinusD2030 STotMinusD2031 STotMinusD2032)

gen SInduced = STotMinusD - SIndirect

gen SDAvg = SD/10
gen SIndirectAvg = SIndirect/10
gen SInducedAvg = SInduced/10
gen SAvg = S/10

gen Allocation = 9

keep S SD SIndirect STotMinusD SInduced SDAvg SIndirectAvg SInducedAvg SAvg Allocation

drop if _n > 51

save ${workdir}/IRA_Climate_Model_Run_Final_Results_by_State_Allocation_9, replace
