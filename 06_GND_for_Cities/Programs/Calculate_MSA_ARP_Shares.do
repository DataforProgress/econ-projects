
/*************************************************************************/
*  PROJECT:    		GND for Cities Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Calculate_MSA_ARP_Shares.do
*  LAST UPDATED: 	5/23/23
*  
*  NOTES: 			Calculates each MSA's share of funding under
*					Sections 602 and 603 of the 2021 American Rescue Plan
*					
/*************************************************************************/

clear
set more off

cd $workdir


/********************************/
/* CALCULATE ALLOCATIONS BY MSA */
/********************************/

* Clean county/MSA crosswalk
import excel using ${datadir}/County_MSA_Crosswalk.xlsx, firstrow clear
replace met2013 = subinstr(met2013,"C","",.)
destring(met2013), replace force
replace met2013 = met2013*10
destring(county), replace
save ${workdir}/County_MSA_Crosswalk_Cleaned, replace


* For each MSA/state cell, calculate fraction of state's population in that cell

use ${datadir}/ACS_Extract_2021_for_GND_for_Cities, clear
keep if empstat == 1

bys statefip: egen state_emp = sum(perwt)

collapse (sum) perwt (mean) state_emp, by(statefip met2013)
drop if met2013 == 0
sort met2013 statefip
rename perwt msa_state_emp

gen double msa_state_emp_share = msa_state_emp / state_emp

save ${workdir}/MSA_State_Emp_Shares, replace


* Calculate ARPA Section 602 spending allocations

* - Calculate state spending allocations 
use ${workdir}/ARPA_State_Allocation, clear
merge 1:m statefip using ${workdir}/MSA_State_Emp_Shares
drop _merge

gen double msa_state_funding = state_territory_funding*msa_state_emp_share

sort met2013

collapse (sum) msa_state_funding, by(met2013)

save ${workdir}/ARPA_State_Allocation_by_MSA, replace


* - Ignore tribal spending allocation for MSA exercise
* (assume that tribes are located outside of metro areas)


* Calculate ARPA Section 603 spending allocations

* - Calculate local government (metro cities) spending allocation 
import delimited using ${datadir}/Treasury_Allocations/fiscalrecoveryfunds-metrocitiesfunding1-CSV.csv, varnames(1) clear
replace allocation = subinstr(allocation,"$","",.)
replace allocation = subinstr(allocation,",","",.)
destring(allocation), replace force
rename allocation metro_city_funding
drop v4
drop if state == "TOTAL"

* In order to map city-level ARPA spending to metro areas, we first map cities 
* to counties so we can then apply a county-MSA crosswalk. This is accomplished 
* with the help of the "opencagegeo" module, which accesses the OpenCage 
* Geocoding API. Using opencagegeo requires obtaining an API key from 
* https://opencagedata.com (free users can only run a limited number of
* queries each day). 

* For that reason, we provide a file in the Github repository that already
* contains the results of the geocoding (ARPA_Metro_City_Allocation.dta).
* For replication purposes, we include below the command used to create it.

*opencagegeo, state(state) city(city) key(140b02572d5547b88f98c30214049bb7)
*save ${datadir}/ARPA_Metro_City_Allocation, replace

use ${datadir}/ARPA_Metro_City_Allocation, clear

gen county = subinstr(g_county," County","",.)
replace county = subinstr(county," Parish","",.)

* Make adjustment to AL
replace county = "Baldwin" if city == "Foley city" & state == "Alabama"

* Make adjustment to AZ
replace county = "Cochise" if city == "Sierra Vista City" & state == "Arizona"

* Make adjustment to AL
replace county = "Faulkner" if city == "Conway" & state == "Arkansas"

* Make adjustment to CA
replace county = "Sacramento" if city == "Folsom city" & state == "California"
replace county = "San Francisco" if city == "San Francisco" & state == "California"
replace county = "San Diego" if city == "San Marcos City" & state == "California"
replace county = "Los Angeles" if city == "Paramount City" & state == "California"
replace county = "Contra Costa" if city == "Richmond city" & state == "California"
replace county = "Alameda" if city == "Pleasanton City" & state == "California"

* Make adjustments to CO
replace county = "Denver" if city == "Denver" & state == "Colorado"

* Make adjustment to DC
replace county = "Washington" if state == "District of Columbia"

* Make adjustments to FL
replace county = "Dade" if county == "Miami-Dade" & state == "Florida"
replace county = "De Soto" if county == "DeSoto" & state == "Florida"
replace county = "Osceola" if city == "St. Cloud City" & state == "Florida"
replace county = "Lee" if city == "Bonita Springs city" & state == "Florida"	
replace county = "Sarasota" if city == "North Port city" & state == "Florida"
replace county = "St Lucie" if city == "Fort Pierce" & state == "Florida"
replace county = "St Lucie" if city == "Port St Lucie" & state == "Florida"

* Make adjustment to GA
replace county = "De Kalb" if county == "DeKalb" & state == "Georgia"

* Make adjustments to IL
replace county = "De Kalb" if county == "DeKalb" & state == "Illinois"
replace county = "Du Page" if county == "DuPage" & state == "Illinois"
replace county = "La Salle" if county == "LaSalle" & state == "Illinois"

* Make adjustments to IN
replace county = "De Kalb" if county == "DeKalb" & state == "Indiana"
replace county = "La Grange" if county == "LaGrange" & state == "Indiana"
replace county = "La Porte" if county == "LaPorte" & state == "Indiana"

* Make adjustment to GA
replace county = "Clarke" if city == "Athens-Clarke County" & state == "Georgia"

* Make adjustment to IL
replace county = "Kankakee" if county == "Kankakee " & state == "Illinois"
replace county = "St Clair" if city == "Belleville" & state == "Illinois"
replace county = "St Clair" if city == "East St Louis" & state == "Illinois"

* Make adjustments to IN
replace county = "St Joseph" if city == "Mishawaka" & state == "Indiana"
replace county = "St Joseph" if city == "South Bend" & state == "Indiana"

* Make adjustment to LA
replace county = "St Tammany" if city == "Slidell" & state == "Louisiana"

* Make adjustments to MD
replace county = "Baltimore City" if city == "Baltimore" & state == "Maryland"
replace county = "Prince Georges" if city == "Bowie City" & state == "Maryland"

* Make adjustment to MA
replace county = "Essex" if city ==	"Methuen Town city" & state == "Massachusetts"

* Make adjustments to MI
replace county = "Oakland" if city == "West Bloomfield charter township" & state == "Michigan"
replace county = "Oakland" if city == "Rochester Hills city" & state == "Michigan"
replace county = "St Clair" if city == "Port Huron" & state == "Michigan"

* Make adjustments to MN
replace county = "Dakota" if city == "Eagan city" & state == "Minnesota"
replace county = "Dakota" if city == "Apple Valley city" & state == "Minnesota"
replace county = "Hennepin" if city == "Maple Grove city" & state == "Minnesota"
replace county = "St Louis" if city == "Duluth" & state == "Minnesota"

* Make adjustment to MS
replace county = "De Soto" if city == "Southaven city" & state == "Mississippi"

* Make adjustments to MO
replace county = "St Louis City" if city == "St Louis" & state == "Missouri"
replace county = "St Charles" if city == "O'Fallon" & state == "Missouri"
replace county = "St Charles" if city == "St. Peters city" & state == "Missouri"
replace county = "St Louis" if city == "Florissant" & state == "Missouri"

* Make adjustment to NV
replace county = "Carson City" if city == "Carson City" & state == "Nevada"

* Make adjustments to NJ
replace county = "Atlantic" if city == "Hammonton town" & state == "New Jersey"
replace county = "Morris" if city == "Parsippany-Troyhills Twp" & state == "New Jersey"
replace county = "Hudson" if city == "West New York town" & state == "New Jersey"

* Make adjustment to NM
replace county = "Dona Ana" if city == "Las Cruces" & state == "New Mexico"

* Make adjustments to NY
replace county = "New York" if city == "New York" & state == "New York"
replace county = "Albany" if city == "Albany" & state == "New York"
replace county = "Erie" if city == "Hamburg Town" & state == "New York"

* Make adjustment to OR
replace county = "Linn" if city == "Lebanon city" & state == "Oregon"

* Make adjustments to PA
replace county = "Monroe" if city == "East Stroudsburg borough" & state == "Pennsylvania"
replace county = "Columbia" if city == "Berwick Borough" & state == "Pennsylvania"

* Make adjustment to SC
replace county = "Richland" if city == "Columbia" & state == "South Carolina"

* Make adjustments to TX
replace county = "Tarrant" if city == "Euless City" & state == "Texas"
replace county = "Denton" if city == "Little Elm city" & state == "Texas"
replace county = "Grayson" if city == "Sherman" & state == "Texas"
replace county = "Smith" if city == "Tyler" & state == "Texas"

* Make adjustments to VA
replace county = "Lynchburg City" if city == "Lynchburg" & state == "Virginia"
replace county = "Radford City" if city == "Radford" & state == "Virginia"
replace county = "Hampton City" if city == "Hampton" & state == "Virginia"
replace county = "Portsmouth City" if city == "Portsmouth" & state == "Virginia"
replace county = "Chesapeake City" if city == "Chesapeake" & state == "Virginia"
replace county = "Virginia Beach City" if city == "Virginia Beach" & state == "Virginia"
replace county = "Colonial Heights Cit" if city == "Colonial Heights" & state == "Virginia"
replace county = "Roanoke City" if city == "Roanoke" & state == "Virginia"
replace county = "Winchester City" if city == "Winchester" & state == "Virginia"
replace county = "Danville City" if city == "Danville" & state == "Virginia"
replace county = "Hopewell City" if city == "Hopewell" & state == "Virginia"
replace county = "Suffolk City" if city == "Suffolk" & state == "Virginia"
replace county = "Norfolk City" if city == "Norfolk" & state == "Virginia"
replace county = "Fredericksburg City" if city == "Fredericksburg" & state == "Virginia"
replace county = "Richmond City" if city == "Richmond" & state == "Virginia"
replace county = "Staunton City" if city == "Staunton" & state == "Virginia"
replace county = "Harrisonburg City" if city == "Harrisonburg" & state == "Virginia"
replace county = "Alexandria City" if city == "Alexandria" & state == "Virginia"
replace county = "Charlottesville City" if city == "Charlottesville" & state == "Virginia"
replace county = "Bristol City" if city == "Bristol" & state == "Virginia"
replace county = "Newport News City" if city == "Newport News" & state == "Virginia"
replace county = "Petersburg City" if city == "Petersburg" & state == "Virginia"

* Make adjustment to WA
replace county = "King" if city == "Sammamish city" & state == "Washington"

* Make adjustment to WY
replace county = "Natrona" if city == "Casper city" & state == "Wyoming"

* Merge in county FIPS codes
drop if state == ""
merge m:1 state county using ${datadir}/County_FIPS_Crosswalk_No_Duplicates.dta

* Manually add a FIPS code in CO
replace county = "Broomfield" if city == "Broomfield City/County" & state == "Colorado"	
replace fips = 08014 if city == "Broomfield City/County" & state == "Colorado"	

* Manually add a FIPS code in FL
replace county = "Miami-Dade" if county == "Dade" & state == "Florida"
replace fips = 12086 if county == "Miami-Dade" & state == "Florida"

* Manually add FIPS codes in PR
replace fips = 72005 if city == "Aguadilla Municipio" & state == "Puerto Rico"
replace fips = 72013 if city == "Arecibo Municipio" & state == "Puerto Rico"
replace fips = 72021 if city == "Bayamon Municipio" & state == "Puerto Rico"
replace fips = 72023 if city == "Cabo Rojo Municipio" & state == "Puerto Rico"
replace fips = 72025 if city == "Caguas Municipio" & state == "Puerto Rico"
replace fips = 72029 if city == "Canovanas Municipio" & state == "Puerto Rico"
replace fips = 72031 if city == "Carolina Municipio" & state == "Puerto Rico"
replace fips = 72035 if city == "Cayey Municipio" & state == "Puerto Rico"
replace fips = 72041 if city == "Cidra Municipio" & state == "Puerto Rico"
replace fips = 72053 if city == "Fajardo Municipio" & state == "Puerto Rico"
replace fips = 72057 if city == "Guayama Municipio" & state == "Puerto Rico"
replace fips = 72061 if city == "Guaynabo Municipio" & state == "Puerto Rico"
replace fips = 72069 if city == "Humacao Municipio" & state == "Puerto Rico"
replace fips = 72071 if city == "Isabela Municipio" & state == "Puerto Rico"
replace fips = 72075 if city == "Juana Diaz Municipio" & state == "Puerto Rico"
replace fips = 72091 if city == "Manati Municipio" & state == "Puerto Rico"
replace fips = 72097 if city == "Mayaguez Municipio" & state == "Puerto Rico"
replace fips = 72113 if city == "Ponce Municipio" & state == "Puerto Rico"
replace fips = 72119 if city == "Rio Grande Municipio" & state == "Puerto Rico"
replace fips = 72125 if city == "San German Municipio" & state == "Puerto Rico"
replace fips = 72127 if city == "San Juan Municipio" & state == "Puerto Rico"
replace fips = 72131 if city == "San Sebastian Municipio" & state == "Puerto Rico"
replace fips = 72135 if city == "Toa Alta Municipio" & state == "Puerto Rico"
replace fips = 72137 if city == "Toa Baja Municipio" & state == "Puerto Rico"
replace fips = 72139 if city == "Trujillo Alto Municipio" & state == "Puerto Rico"
replace fips = 72145 if city == "Vega Baja Municipio" & state == "Puerto Rico"
replace fips = 72153 if city == "Yauco Municipio" & state == "Puerto Rico"

*br state city county if _merge == 1 & state != "Puerto Rico"

* Merge in MSA codes
rename county countyname
rename fips county
drop if _merge == 2
rename _merge _merge1
merge m:1 county using ${workdir}/County_MSA_Crosswalk_Cleaned
* Only ones that don't merge are in Puerto Rico, but that's okay
drop if _merge == 2

*br if metro_city_funding != . & met2013 == .

collapse (sum) metro_city_funding, by(met2013 met2013name)

rename metro_city_funding msa_metro_city_funding

save ${workdir}/ARPA_Metro_City_Allocation_by_MSA, replace


* - Calculate local government (NEU) spending allocation
use ${workdir}/ARPA_NEU_Allocation_by_State, clear

merge 1:m statefip using ${workdir}/MSA_State_Emp_Shares
drop _merge

drop if met2013 == .

gen double msa_neu_funding = neu_funding*msa_state_emp_share

collapse (sum) msa_neu_funding, by(met2013)

save ${workdir}/ARPA_NEU_Allocation_by_MSA, replace


* - Calculate county spending allocation using allocation computed in Calculate_State_ARP_Shares.do
use ${workdir}/ARPA_County_Allocation, clear

* Merge in MSA codes
rename county countyname
rename fips county
rename _merge _merge1
merge m:1 county using ${workdir}/County_MSA_Crosswalk_Cleaned
* Only ones that don't merge are in Puerto Rico, but that's okay
drop if _merge == 2

collapse (sum) county_funding, by(met2013 met2013name)

rename county_funding msa_county_funding

save ${workdir}/ARPA_County_Allocation_by_MSA, replace


/***********************************/
/* MERGE ALL MSA-LEVEL ALLOCATIONS */
/***********************************/

use ${workdir}/ARPA_State_Allocation_by_MSA, clear
drop if met2013 == .

* Merge in NEU allocations while data are still at the MSA-by-state level
merge 1:1 met2013 using ${workdir}/ARPA_NEU_Allocation_by_MSA
rename _merge _merge1

merge 1:1 met2013 using ${workdir}/ARPA_Metro_City_Allocation_by_MSA
drop if _merge == 2
rename _merge _merge2
replace msa_metro_city_funding = 0 if msa_metro_city_funding == .

merge 1:1 met2013 using ${workdir}/ARPA_County_Allocation_by_MSA
drop if _merge == 2
rename _merge _merge3

gen double total_funding = msa_state_funding + msa_metro_city_funding + msa_neu_funding + msa_county_funding
egen double funding_sum = sum(total_funding)

gen double funding_share = total_funding / funding_sum

sort met2013

* Create matrix with MSA ARPA shares
matrix msaarpshares = J(260,71,0)
foreach i of numlist 1(1)260 {
	foreach j of numlist 1(1)71 {
		local k = (`i'-1)*71+`j'
		matrix msaarpshares[`i',`j'] = funding_share[`i']
	}
}

svmat msaarpshares, names(msaarpshares)

keep msaarpshares*

save ${workdir}/MSA_ARP_Shares, replace
