
/*************************************************************************/
*  PROJECT:    		IRA Climate Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Calculate_Output_and_Employment_Effects_by_Category.do
*  LAST UPDATED: 	3/18/23
*  NOTES: 			
*					
/*************************************************************************/

foreach categorynum of numlist 1(1)7 {
	
	use ${workdir}/IRA_Climate_Spending_by_Industry_Category_`categorynum', clear
	
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

		save ${outputdir}/IRA_Climate_Model_Run_Results_`year'_Category_`categorynum', replace

	}


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

	save ${outputdir}/IRA_Climate_Model_Run_Final_Results_Category_`categorynum', replace
	
	collapse (mean) *

	drop year
	
	save ${outputdir}/IRA_Climate_Model_Run_Final_Results_Averages_Category_`categorynum', replace
	
}

use ${outputdir}/IRA_Climate_Model_Run_Final_Results_Averages_Category_1, clear

append using ${outputdir}/IRA_Climate_Model_Run_Final_Results_Averages_Category_2
append using ${outputdir}/IRA_Climate_Model_Run_Final_Results_Averages_Category_3
append using ${outputdir}/IRA_Climate_Model_Run_Final_Results_Averages_Category_4
append using ${outputdir}/IRA_Climate_Model_Run_Final_Results_Averages_Category_5
append using ${outputdir}/IRA_Climate_Model_Run_Final_Results_Averages_Category_6
append using ${outputdir}/IRA_Climate_Model_Run_Final_Results_Averages_Category_7

gen CategoryNum = _n

save ${outputdir}/IRA_Climate_Model_Run_Final_Results_Averages_by_Category, replace


foreach year of numlist 2023(1)2032 {
	foreach categorynum of numlist 1(1)7 {
		erase ${outputdir}/IRA_Climate_Model_Run_Results_`year'_Category_`categorynum'.dta
	}
}

foreach categorynum of numlist 1(1)7 {
	erase ${outputdir}/IRA_Climate_Model_Run_Final_Results_Category_`categorynum'.dta
	erase ${outputdir}/IRA_Climate_Model_Run_Final_Results_Averages_Category_`categorynum'.dta
}
