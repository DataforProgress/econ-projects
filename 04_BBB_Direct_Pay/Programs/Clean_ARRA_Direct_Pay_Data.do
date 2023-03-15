
/*************************************************************************/
*  PROJECT:    		BBB Direct Pay Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Clean_ARRA_Direct_Pay_Data.do
*  LAST UPDATED: 	3/11/23
*  OBJECTIVE: 		Calculates share of ARRA direct pay grant spending
*					accounted for 
*  NOTES: 			
*					
/*************************************************************************/


clear
set more off

global workdir = "/Users/Matt/Documents/Data_for_Progress/Direct_Pay"
cd $workdir

* Import and clean data on ARRA Direct Pay (Section 1603) grants
import excel using ${workdir}/Website-Awarded-as-of-3.1.18.xlsx, firstrow clear

drop F-AZ
rename Section1603PaymentsforSpec BusinessName
rename B State
rename C Technology
rename D Amount
rename E Date

drop if _n == 1
drop if BusinessName == "Total" | BusinessName == ""

destring(Amount), replace force
split(Date), p("/")
rename Date3 Year
destring(Year), replace force

* Inflation adjustments (convert everything to 2022 dollars)
gen Amount2022 = .
replace Amount2022 = Amount*(121.9211/95.024) if Year == 2009
replace Amount2022 = Amount*(121.9211/96.166) if Year == 2010
replace Amount2022 = Amount*(121.9211/98.164) if Year == 2011
replace Amount2022 = Amount*(121.9211/100.000) if Year == 2012
replace Amount2022 = Amount*(121.9211/101.751) if Year == 2013
replace Amount2022 = Amount*(121.9211/103.654) if Year == 2014
replace Amount2022 = Amount*(121.9211/104.691) if Year == 2015
replace Amount2022 = Amount*(121.9211/105.740) if Year == 2016
replace Amount2022 = Amount*(121.9211/107.747) if Year == 2017

gen AboveThreshold = .
replace AboveThreshold = 0 if Amount2022 < 50000000
replace AboveThreshold = 1 if Amount2022 >= 50000000

collapse (sum) Amount2022, by(AboveThreshold)

local AmountBelowThreshold = Amount2022[1]
dis "`AmountBelowThreshold'"
local AmountAboveThreshold = Amount2022[2]
dis "`AmountAboveThreshold'"

local ShareBelowThreshold = round(`AmountBelowThreshold' / (`AmountBelowThreshold'+ `AmountAboveThreshold'),0.01)
dis "`ShareBelowThreshold'"
* 0.36

