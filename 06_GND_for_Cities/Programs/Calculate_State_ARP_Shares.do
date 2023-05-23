
/*************************************************************************/
*  PROJECT:    		GND for Cities Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Calculate_State_ARP_Shares.do
*  LAST UPDATED: 	5/23/23
*  
*  NOTES: 			Calculates each state's share of funding under
*					Sections 602 and 603 of the 2021 American Rescue Plan
*					
/*************************************************************************/

clear
set more off

cd $workdir


/**********************************/
/* CALCULATE ALLOCATIONS BY STATE */
/**********************************/

* Calculate ARPA Section 602 spending allocations

* - Calculate state spending allocations 
import delimited using ${datadir}/Treasury_Allocations/fiscalrecoveryfunds-statefunding1-CSV.csv, varnames(1) clear
replace totalfunding = subinstr(totalfunding,"$","",.)
replace totalfunding = subinstr(totalfunding,",","",.)
destring(totalfunding), replace force
rename totalfunding state_territory_funding
keep state state_territory_funding

gen statefip = .
replace statefip = 1 if state == "Alabama"
replace statefip = 2 if state == "Alaska"
replace statefip = 4 if state == "Arizona"
replace statefip = 5 if state == "Arkansas"
replace statefip = 6 if state == "California"
replace statefip = 8 if state == "Colorado"
replace statefip = 9 if state == "Connecticut"
replace statefip = 10 if state == "Delaware"
replace statefip = 11 if state == "District of Columbia"
replace statefip = 12 if state == "Florida"
replace statefip = 13 if state == "Georgia"
replace statefip = 15 if state == "Hawaii"
replace statefip = 16 if state == "Idaho"
replace statefip = 17 if state == "Illinois"
replace statefip = 18 if state == "Indiana"
replace statefip = 19 if state == "Iowa"
replace statefip = 20 if state == "Kansas"
replace statefip = 21 if state == "Kentucky"
replace statefip = 22 if state == "Louisiana"
replace statefip = 23 if state == "Maine"
replace statefip = 24 if state == "Maryland"
replace statefip = 25 if state == "Massachusetts"
replace statefip = 26 if state == "Michigan"
replace statefip = 27 if state == "Minnesota"
replace statefip = 28 if state == "Mississippi"
replace statefip = 29 if state == "Missouri"
replace statefip = 30 if state == "Montana"
replace statefip = 31 if state == "Nebraska"
replace statefip = 32 if state == "Nevada"
replace statefip = 33 if state == "New Hampshire"
replace statefip = 34 if state == "New Jersey"
replace statefip = 35 if state == "New Mexico"
replace statefip = 36 if state == "New York"
replace statefip = 37 if state == "North Carolina"
replace statefip = 38 if state == "North Dakota"
replace statefip = 39 if state == "Ohio"
replace statefip = 40 if state == "Oklahoma"
replace statefip = 41 if state == "Oregon"
replace statefip = 42 if state == "Pennsylvania"
replace statefip = 44 if state == "Rhode Island"
replace statefip = 45 if state == "South Carolina"
replace statefip = 46 if state == "South Dakota"
replace statefip = 47 if state == "Tennessee"
replace statefip = 48 if state == "Texas"
replace statefip = 49 if state == "Utah"
replace statefip = 50 if state == "Vermont"
replace statefip = 51 if state == "Virginia"
replace statefip = 53 if state == "Washington"
replace statefip = 54 if state == "West Virginia"
replace statefip = 55 if state == "Wisconsin"
replace statefip = 56 if state == "Wyoming"

drop if state == "" | state == "TOTAL"

save ${workdir}/ARPA_State_Allocation, replace


* - Calculate tribal spending allocation (source: https://ash.harvard.edu/files/ash/files/assessing_the_u.s._treasury_departments_allocations_of_funding_for_tribal_governments.pdf?m=1635972521)
import excel using ${datadir}/ARPA_Tribal_Allocation.xlsx, firstrow clear
rename State stateabbrv
rename TotalARPAFunding tribal_funding
collapse (sum) tribal_funding, by(state)

replace tribal_funding = 0 if tribal_funding == .

gen statefip = .
replace statefip = 1 if stateabbrv == "AL"
replace statefip = 2 if stateabbrv == "AK"
replace statefip = 4 if stateabbrv == "AZ"
replace statefip = 5 if stateabbrv == "AR"
replace statefip = 6 if stateabbrv == "CA"
replace statefip = 8 if stateabbrv == "CO"
replace statefip = 9 if stateabbrv == "CT"
replace statefip = 10 if stateabbrv == "DE"
replace statefip = 11 if stateabbrv == "DC"
replace statefip = 12 if stateabbrv == "FL"
replace statefip = 13 if stateabbrv == "GA"
replace statefip = 15 if stateabbrv == "HI"
replace statefip = 16 if stateabbrv == "ID"
replace statefip = 17 if stateabbrv == "IL"
replace statefip = 18 if stateabbrv == "IN"
replace statefip = 19 if stateabbrv == "IA"
replace statefip = 20 if stateabbrv == "KS"
replace statefip = 21 if stateabbrv == "KY"
replace statefip = 22 if stateabbrv == "LA"
replace statefip = 23 if stateabbrv == "ME"
replace statefip = 24 if stateabbrv == "MD"
replace statefip = 25 if stateabbrv == "MA"
replace statefip = 26 if stateabbrv == "MI"
replace statefip = 27 if stateabbrv == "MN"
replace statefip = 28 if stateabbrv == "MS"
replace statefip = 29 if stateabbrv == "MO"
replace statefip = 30 if stateabbrv == "MT"
replace statefip = 31 if stateabbrv == "NE"
replace statefip = 32 if stateabbrv == "NV"
replace statefip = 33 if stateabbrv == "NH"
replace statefip = 34 if stateabbrv == "NJ"
replace statefip = 35 if stateabbrv == "NM"
replace statefip = 36 if stateabbrv == "NY"
replace statefip = 37 if stateabbrv == "NC"
replace statefip = 38 if stateabbrv == "ND"
replace statefip = 39 if stateabbrv == "OH"
replace statefip = 40 if stateabbrv == "OK"
replace statefip = 41 if stateabbrv == "OR"
replace statefip = 42 if stateabbrv == "PA"
replace statefip = 44 if stateabbrv == "RI"
replace statefip = 45 if stateabbrv == "SC"
replace statefip = 46 if stateabbrv == "SD"
replace statefip = 47 if stateabbrv == "TN"
replace statefip = 48 if stateabbrv == "TX"
replace statefip = 49 if stateabbrv == "UT"
replace statefip = 50 if stateabbrv == "VT"
replace statefip = 51 if stateabbrv == "VA"
replace statefip = 53 if stateabbrv == "WA"
replace statefip = 54 if stateabbrv == "WV"
replace statefip = 55 if stateabbrv == "WI"
replace statefip = 56 if stateabbrv == "WY"

drop if statefip == .

save ${workdir}/ARPA_Tribal_Allocation_by_State, replace


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

* Missing "(sum)"!
* collapse metro_city_funding, by(state)

collapse (sum) metro_city_funding, by(state)

gen statefip = .
replace statefip = 1 if state == "Alabama"
replace statefip = 2 if state == "Alaska"
replace statefip = 4 if state == "Arizona"
replace statefip = 5 if state == "Arkansas"
replace statefip = 6 if state == "California"
replace statefip = 8 if state == "Colorado"
replace statefip = 9 if state == "Connecticut"
replace statefip = 10 if state == "Delaware"
replace statefip = 11 if state == "District of Columbia"
replace statefip = 12 if state == "Florida"
replace statefip = 13 if state == "Georgia"
replace statefip = 15 if state == "Hawaii"
replace statefip = 16 if state == "Idaho"
replace statefip = 17 if state == "Illinois"
replace statefip = 18 if state == "Indiana"
replace statefip = 19 if state == "Iowa"
replace statefip = 20 if state == "Kansas"
replace statefip = 21 if state == "Kentucky"
replace statefip = 22 if state == "Louisiana"
replace statefip = 23 if state == "Maine"
replace statefip = 24 if state == "Maryland"
replace statefip = 25 if state == "Massachusetts"
replace statefip = 26 if state == "Michigan"
replace statefip = 27 if state == "Minnesota"
replace statefip = 28 if state == "Mississippi"
replace statefip = 29 if state == "Missouri"
replace statefip = 30 if state == "Montana"
replace statefip = 31 if state == "Nebraska"
replace statefip = 32 if state == "Nevada"
replace statefip = 33 if state == "New Hampshire"
replace statefip = 34 if state == "New Jersey"
replace statefip = 35 if state == "New Mexico"
replace statefip = 36 if state == "New York"
replace statefip = 37 if state == "North Carolina"
replace statefip = 38 if state == "North Dakota"
replace statefip = 39 if state == "Ohio"
replace statefip = 40 if state == "Oklahoma"
replace statefip = 41 if state == "Oregon"
replace statefip = 42 if state == "Pennsylvania"
replace statefip = 44 if state == "Rhode Island"
replace statefip = 45 if state == "South Carolina"
replace statefip = 46 if state == "South Dakota"
replace statefip = 47 if state == "Tennessee"
replace statefip = 48 if state == "Texas"
replace statefip = 49 if state == "Utah"
replace statefip = 50 if state == "Vermont"
replace statefip = 51 if state == "Virginia"
replace statefip = 53 if state == "Washington"
replace statefip = 54 if state == "West Virginia"
replace statefip = 55 if state == "Wisconsin"
replace statefip = 56 if state == "Wyoming"

save ${workdir}/ARPA_Metro_City_Allocation_by_State, replace


* - Calculate local government (NEU) spending allocation
import delimited using ${datadir}/Treasury_Allocations/fiscalrecoveryfunds-nonentitlementfunding1-CSV.csv, varnames(1) clear
replace allocation = subinstr(allocation,"$","",.)
replace allocation = subinstr(allocation,",","",.)
destring(allocation), replace force
rename allocation neu_funding
drop if state == "TOTAL"

gen statefip = .
replace statefip = 1 if state == "Alabama"
replace statefip = 2 if state == "Alaska"
replace statefip = 4 if state == "Arizona"
replace statefip = 5 if state == "Arkansas"
replace statefip = 6 if state == "California"
replace statefip = 8 if state == "Colorado"
replace statefip = 9 if state == "Connecticut"
replace statefip = 10 if state == "Delaware"
replace statefip = 11 if state == "District of Columbia"
replace statefip = 12 if state == "Florida"
replace statefip = 13 if state == "Georgia"
replace statefip = 15 if state == "Hawaii"
replace statefip = 16 if state == "Idaho"
replace statefip = 17 if state == "Illinois"
replace statefip = 18 if state == "Indiana"
replace statefip = 19 if state == "Iowa"
replace statefip = 20 if state == "Kansas"
replace statefip = 21 if state == "Kentucky"
replace statefip = 22 if state == "Louisiana"
replace statefip = 23 if state == "Maine"
replace statefip = 24 if state == "Maryland"
replace statefip = 25 if state == "Massachusetts"
replace statefip = 26 if state == "Michigan"
replace statefip = 27 if state == "Minnesota"
replace statefip = 28 if state == "Mississippi"
replace statefip = 29 if state == "Missouri"
replace statefip = 30 if state == "Montana"
replace statefip = 31 if state == "Nebraska"
replace statefip = 32 if state == "Nevada"
replace statefip = 33 if state == "New Hampshire"
replace statefip = 34 if state == "New Jersey"
replace statefip = 35 if state == "New Mexico"
replace statefip = 36 if state == "New York"
replace statefip = 37 if state == "North Carolina"
replace statefip = 38 if state == "North Dakota"
replace statefip = 39 if state == "Ohio"
replace statefip = 40 if state == "Oklahoma"
replace statefip = 41 if state == "Oregon"
replace statefip = 42 if state == "Pennsylvania"
replace statefip = 44 if state == "Rhode Island"
replace statefip = 45 if state == "South Carolina"
replace statefip = 46 if state == "South Dakota"
replace statefip = 47 if state == "Tennessee"
replace statefip = 48 if state == "Texas"
replace statefip = 49 if state == "Utah"
replace statefip = 50 if state == "Vermont"
replace statefip = 51 if state == "Virginia"
replace statefip = 53 if state == "Washington"
replace statefip = 54 if state == "West Virginia"
replace statefip = 55 if state == "Wisconsin"
replace statefip = 56 if state == "Wyoming"

drop if statefip == .

save ${workdir}/ARPA_NEU_Allocation_by_State, replace


* - Calculate county spending allocation (source: Treasury)
import delimited using ${datadir}/Treasury_Allocations/fiscalrecoveryfunds_countyfunding_2021.05.10-1a.csv, varnames(1) clear
replace allocation = subinstr(allocation,"$","",.)
replace allocation = subinstr(allocation,",","",.)
destring(allocation), replace force
rename allocation county_funding
drop v4
drop if state == "*Not a Unit of General Local Government" | state == "TOTAL"

replace county = subinstr(county," Borough","",.)
replace county = subinstr(county," Census Area","",.)
replace county = subinstr(county," city"," City",.)
replace county = subinstr(county," City and","",.)
replace county = subinstr(county," County","",.)
replace county = subinstr(county," Parish","",.)
replace county = subinstr(county," Municipality","",.)
replace county = subinstr(county," Municipio","",.)
replace county = subinstr(county,"St.","St",.)

* Make adjustments to AL
replace county = "De Kalb" if county == "DeKalb" & state == "Alabama"
replace county = "St. Clair" if county == "St Clair" & state == "Alabama"

* Make adjustment to DC
replace county = "Washington" if state == "District of Columbia"

* Make adjustments to FL
replace county = "Dade" if county == "Miami-Dade" & state == "Florida"
replace county = "De Soto" if county == "DeSoto" & state == "Florida"

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

* Make adjustment to IA
replace county = "O Brien" if county == "O'Brien" & state == "Iowa"

* Make adjustment to LA
replace county = "La Salle" if county == "LaSalle" & state == "Louisiana"

* Make adjustments to MD
replace county = "Prince Georges" if county == "Prince George's" & state == "Maryland"
replace county = "Queen Annes" if county == "Queen Anne's" & state == "Maryland"
replace county = "St Marys" if county == "St Mary's" & state == "Maryland"

* Make adjustment to MS
replace county = "De Soto" if county == "DeSoto" & state == "Mississippi"

* Make adjustment to MO
replace county = "De Kalb" if county == "DeKalb" & state == "Missouri"

* Make adjustment to NM
replace county = "Dona Ana" if county == "Doña Ana" & state == "New Mexico"

* Make adjustment to ND
replace county = "La Moure" if county == "LaMoure" & state == "North Dakota"

* Make adjustment to Northern Mariana Islands
replace state = "Northern Mariana Islands" if state == "Northern Mariana Isla"

* Make adjustments to PR for spelling/diacritical marks 
* ("Nabuabo" is actually a misspelling though)
replace county = "Anasco" if county == "Añasco"
replace county = "Bayamon" if county == "Bayamón"
replace county = "Canovanas" if county == "Canóvanas"
replace county = "Catano" if county == "Cataño"
replace county = "Comerio" if county == "Comerío"
replace county = "Guanica" if county == "Guánica"
replace county = "Juana Diaz" if county == "Juana Díaz"
replace county = "Las Marias" if county == "Las Marías"
replace county = "Loiza" if county == "Loíza"
replace county = "Manati" if county == "Manatí"
replace county = "Mayaguez" if county == "Mayagüez"
replace county = "Nabuabo" if county == "Naguabo"
replace county = "Penuelas" if county == "Peñuelas"
replace county = "Rincon" if county == "Rincón"
replace county = "Rio Grande" if county == "Río Grande"
replace county = "San German" if county == "San Germán"
replace county = "San Sabastian" if county == "San Sebastián"

* Make adjustment to TN
replace county = "De Kalb" if county == "DeKalb" & state == "Tennessee"

* Make adjustment to TX
replace county = "De Witt" if county == "DeWitt" & state == "Texas"

* Make adjustments to Virgin Islands
replace county = "St. Croix" if county == "St Croix Island"
replace county = "St. John" if county == "St John Island"
replace county = "St. Thomas" if county == "St Thomas Island"

* Merge in county FIPS codes
drop if state == ""
merge m:1 state county using ${datadir}/County_FIPS_Crosswalk_No_Duplicates.dta
drop if _merge == 2

* Manually add FIPS codes in AK
replace fips = 02105 if county == "Hoonah-Angoon" & state == "Alaska"
replace fips = 02158 if county == "Kusilvak" & state == "Alaska"
replace fips = 02195 if county == "Petersburg" & state == "Alaska"
replace fips = 02198 if county == "Prince of Wales-Hyder" & state == "Alaska"
replace fips = 02230 if county == "Skagway" & state == "Alaska"
replace fips = 02275 if county == "Wrangell" & state == "Alaska"

* Manually add a FIPS code in CO
replace fips = 08014 if county == "Broomfield" & state == "Colorado"

* Manually add a FIPS code in HI
replace fips = 15009 if county == "Kalawao" & state == "Hawaii"

* Manually add FIPS codes in PR
replace fips = 72039 if county == "Ciales" & state == "Puerto Rico"
replace fips = 72069 if county == "Humacao" & state == "Puerto Rico"

* Manually add FIPS codes in SD
replace fips = 46102 if county == "Oglala Lakota" & state == "South Dakota"

* Manually add FIPS codes in VA
replace fips = 51570 if county == "Colonial Heights City" & state == "Virginia"

* Ignore American Samoa, Guam, Northern Mariana Islands, and Puerto Rico

save ${workdir}/ARPA_County_Allocation, replace

collapse (sum) county_funding, by(state)

gen statefip = .
replace statefip = 1 if state == "Alabama"
replace statefip = 2 if state == "Alaska"
replace statefip = 4 if state == "Arizona"
replace statefip = 5 if state == "Arkansas"
replace statefip = 6 if state == "California"
replace statefip = 8 if state == "Colorado"
replace statefip = 9 if state == "Connecticut"
replace statefip = 10 if state == "Delaware"
replace statefip = 11 if state == "District of Columbia"
replace statefip = 12 if state == "Florida"
replace statefip = 13 if state == "Georgia"
replace statefip = 15 if state == "Hawaii"
replace statefip = 16 if state == "Idaho"
replace statefip = 17 if state == "Illinois"
replace statefip = 18 if state == "Indiana"
replace statefip = 19 if state == "Iowa"
replace statefip = 20 if state == "Kansas"
replace statefip = 21 if state == "Kentucky"
replace statefip = 22 if state == "Louisiana"
replace statefip = 23 if state == "Maine"
replace statefip = 24 if state == "Maryland"
replace statefip = 25 if state == "Massachusetts"
replace statefip = 26 if state == "Michigan"
replace statefip = 27 if state == "Minnesota"
replace statefip = 28 if state == "Mississippi"
replace statefip = 29 if state == "Missouri"
replace statefip = 30 if state == "Montana"
replace statefip = 31 if state == "Nebraska"
replace statefip = 32 if state == "Nevada"
replace statefip = 33 if state == "New Hampshire"
replace statefip = 34 if state == "New Jersey"
replace statefip = 35 if state == "New Mexico"
replace statefip = 36 if state == "New York"
replace statefip = 37 if state == "North Carolina"
replace statefip = 38 if state == "North Dakota"
replace statefip = 39 if state == "Ohio"
replace statefip = 40 if state == "Oklahoma"
replace statefip = 41 if state == "Oregon"
replace statefip = 42 if state == "Pennsylvania"
replace statefip = 44 if state == "Rhode Island"
replace statefip = 45 if state == "South Carolina"
replace statefip = 46 if state == "South Dakota"
replace statefip = 47 if state == "Tennessee"
replace statefip = 48 if state == "Texas"
replace statefip = 49 if state == "Utah"
replace statefip = 50 if state == "Vermont"
replace statefip = 51 if state == "Virginia"
replace statefip = 53 if state == "Washington"
replace statefip = 54 if state == "West Virginia"
replace statefip = 55 if state == "Wisconsin"
replace statefip = 56 if state == "Wyoming"

drop if statefip == .

save ${workdir}/ARPA_County_Allocation_by_State, replace


/*************************************/
/* MERGE ALL STATE-LEVEL ALLOCATIONS */
/*************************************/

use ${workdir}/ARPA_State_Allocation, clear

merge 1:1 statefip using ${workdir}/ARPA_Tribal_Allocation_by_State
rename _merge _merge1

merge 1:1 statefip using ${workdir}/ARPA_Metro_City_Allocation_by_State
rename _merge _merge2

merge 1:1 statefip using ${workdir}/ARPA_NEU_Allocation_by_State
rename _merge _merge3

merge 1:1 statefip using ${workdir}/ARPA_County_Allocation_by_State
rename _merge _merge4

drop if state == "Puerto Rico"

replace tribal_funding = 0 if tribal_funding == .

gen double total_funding = state_territory_funding + tribal_funding + metro_city_funding + neu_funding + county_funding
egen double funding_sum = sum(total_funding)

gen double funding_share = total_funding / funding_sum


* Create matrix with state ARPA shares
matrix statearpshares = J(51,71,0)
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
		matrix statearpshares[`i',`j'] = funding_share[`i']
	}
	
}

svmat statearpshares, names(statearpshares)

keep statearpshares*

save ${workdir}/State_ARP_Shares, replace

