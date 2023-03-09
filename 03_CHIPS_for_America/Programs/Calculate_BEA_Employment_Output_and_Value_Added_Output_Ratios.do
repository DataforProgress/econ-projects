
/***********************************************************************************/
*  PROJECT:    		CHIPS for America Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Calculate_BEA_Employment_Output_and_Value_Added_Output_Ratios.do
*  LAST UPDATED: 	3/7/23
*   		
*  NOTES: 			
/***********************************************************************************/

/********************************************************/
/* Clean gross output, employment, and value added data */
/********************************************************/
	
* Clean output data

import excel using ${workdir}/Data/BEA_Gross_Output_by_Industry_Cleaned_2020.xls, clear
drop if _n < 7

destring(A), replace force
destring(C), replace force

rename A indnum
rename B indname
rename C output

replace output = output*1000000000

*drop D E

save ${workdir}/Work/BEA_Gross_Output_by_Industry_Cleaned_2020, replace

* Clean employment data

import excel using ${workdir}/Data/BEA_Employment_by_Industry_Cleaned_2020.xls, clear

drop if _n < 7

destring(A), replace force
destring(C), replace force

rename A indnum
rename B indname2
rename C employment

gen iocode = ""
replace iocode = "111CA" 	if indnum == 1
replace iocode = "113FF" 	if indnum == 2
replace iocode = "211" 		if indnum == 3
replace iocode = "212" 		if indnum == 4
replace iocode = "213" 		if indnum == 5
replace iocode = "22" 		if indnum == 6
replace iocode = "23" 		if indnum == 7
replace iocode = "321" 		if indnum == 8
replace iocode = "327" 		if indnum == 9
replace iocode = "331" 		if indnum == 10
replace iocode = "332" 		if indnum == 11
replace iocode = "333" 		if indnum == 12
replace iocode = "334" 		if indnum == 13
replace iocode = "335" 		if indnum == 14
replace iocode = "3361MV" 	if indnum == 15
replace iocode = "3364OT" 	if indnum == 16
replace iocode = "337" 		if indnum == 17
replace iocode = "339" 		if indnum == 18
replace iocode = "311FT" 	if indnum == 19
replace iocode = "313TT" 	if indnum == 20
replace iocode = "315AL" 	if indnum == 21
replace iocode = "322" 		if indnum == 22
replace iocode = "323" 		if indnum == 23
replace iocode = "324" 		if indnum == 24
replace iocode = "325" 		if indnum == 25
replace iocode = "326" 		if indnum == 26
replace iocode = "42" 		if indnum == 27
replace iocode = "441" 		if indnum == 28
replace iocode = "445" 		if indnum == 29
replace iocode = "452" 		if indnum == 30
replace iocode = "4A0" 		if indnum == 31
replace iocode = "481" 		if indnum == 32
replace iocode = "482" 		if indnum == 33
replace iocode = "483" 		if indnum == 34
replace iocode = "484" 		if indnum == 35
replace iocode = "485" 		if indnum == 36
replace iocode = "486" 		if indnum == 37
replace iocode = "487OS" 	if indnum == 38
replace iocode = "493" 		if indnum == 39
replace iocode = "511" 		if indnum == 40
replace iocode = "512" 		if indnum == 41
replace iocode = "513" 		if indnum == 42
replace iocode = "514" 		if indnum == 43
replace iocode = "521CI" 	if indnum == 44
replace iocode = "523" 		if indnum == 45
replace iocode = "524" 		if indnum == 46
replace iocode = "525" 		if indnum == 47
replace iocode = "HS" 		if indnum == 48
replace iocode = "ORE" 		if indnum == 49
replace iocode = "532RL" 	if indnum == 50
replace iocode = "5411" 	if indnum == 51
replace iocode = "5415" 	if indnum == 52
replace iocode = "5412OP" 	if indnum == 53
replace iocode = "55" 		if indnum == 54
replace iocode = "561" 		if indnum == 55
replace iocode = "562" 		if indnum == 56
replace iocode = "61" 		if indnum == 57
replace iocode = "621" 		if indnum == 58
replace iocode = "622" 		if indnum == 59
replace iocode = "623" 		if indnum == 60
replace iocode = "624" 		if indnum == 61
replace iocode = "711AS" 	if indnum == 62
replace iocode = "713" 		if indnum == 63
replace iocode = "721" 		if indnum == 64
replace iocode = "722" 		if indnum == 65
replace iocode = "81" 		if indnum == 66
replace iocode = "GFGD" 	if indnum == 67
replace iocode = "GFGN" 	if indnum == 68
replace iocode = "GFE" 		if indnum == 69
replace iocode = "GSLG" 	if indnum == 70
replace iocode = "GSLE" 	if indnum == 71

replace employment = employment*1000

save ${workdir}/Work/BEA_Employment_by_Industry_Cleaned_2020, replace
	
	
* Clean value added data

import excel using ${workdir}/Data/BEA_Value_Added_by_Industry_Cleaned_2020.xls, clear firstrow

gen iocode = ""
replace iocode = "111CA" 	if indnum == 1
replace iocode = "113FF" 	if indnum == 2
replace iocode = "211" 		if indnum == 3
replace iocode = "212" 		if indnum == 4
replace iocode = "213" 		if indnum == 5
replace iocode = "22" 		if indnum == 6
replace iocode = "23" 		if indnum == 7
replace iocode = "321" 		if indnum == 8
replace iocode = "327" 		if indnum == 9
replace iocode = "331" 		if indnum == 10
replace iocode = "332" 		if indnum == 11
replace iocode = "333" 		if indnum == 12
replace iocode = "334" 		if indnum == 13
replace iocode = "335" 		if indnum == 14
replace iocode = "3361MV" 	if indnum == 15
replace iocode = "3364OT" 	if indnum == 16
replace iocode = "337" 		if indnum == 17
replace iocode = "339" 		if indnum == 18
replace iocode = "311FT" 	if indnum == 19
replace iocode = "313TT" 	if indnum == 20
replace iocode = "315AL" 	if indnum == 21
replace iocode = "322" 		if indnum == 22
replace iocode = "323" 		if indnum == 23
replace iocode = "324" 		if indnum == 24
replace iocode = "325" 		if indnum == 25
replace iocode = "326" 		if indnum == 26
replace iocode = "42" 		if indnum == 27
replace iocode = "441" 		if indnum == 28
replace iocode = "445" 		if indnum == 29
replace iocode = "452" 		if indnum == 30
replace iocode = "4A0" 		if indnum == 31
replace iocode = "481" 		if indnum == 32
replace iocode = "482" 		if indnum == 33
replace iocode = "483" 		if indnum == 34
replace iocode = "484" 		if indnum == 35
replace iocode = "485" 		if indnum == 36
replace iocode = "486" 		if indnum == 37
replace iocode = "487OS" 	if indnum == 38
replace iocode = "493" 		if indnum == 39
replace iocode = "511" 		if indnum == 40
replace iocode = "512" 		if indnum == 41
replace iocode = "513" 		if indnum == 42
replace iocode = "514" 		if indnum == 43
replace iocode = "521CI" 	if indnum == 44
replace iocode = "523" 		if indnum == 45
replace iocode = "524" 		if indnum == 46
replace iocode = "525" 		if indnum == 47
replace iocode = "HS" 		if indnum == 48
replace iocode = "ORE" 		if indnum == 49
replace iocode = "532RL" 	if indnum == 50
replace iocode = "5411" 	if indnum == 51
replace iocode = "5415" 	if indnum == 52
replace iocode = "5412OP" 	if indnum == 53
replace iocode = "55" 		if indnum == 54
replace iocode = "561" 		if indnum == 55
replace iocode = "562" 		if indnum == 56
replace iocode = "61" 		if indnum == 57
replace iocode = "621" 		if indnum == 58
replace iocode = "622" 		if indnum == 59
replace iocode = "623" 		if indnum == 60
replace iocode = "624" 		if indnum == 61
replace iocode = "711AS" 	if indnum == 62
replace iocode = "713" 		if indnum == 63
replace iocode = "721" 		if indnum == 64
replace iocode = "722" 		if indnum == 65
replace iocode = "81" 		if indnum == 66
replace iocode = "GFGD" 	if indnum == 67
replace iocode = "GFGN" 	if indnum == 68
replace iocode = "GFE" 		if indnum == 69
replace iocode = "GSLG" 	if indnum == 70
replace iocode = "GSLE" 	if indnum == 71

replace valueadded = valueadded*1000000000

save ${workdir}/Work/BEA_Value_Added_by_Industry_Cleaned_2020, replace
	
	
* Merge datasets
	
use ${workdir}/Work/BEA_Gross_Output_by_Industry_Cleaned_2020, clear
	
merge 1:1 indnum using ${workdir}/Work/BEA_Employment_by_Industry_Cleaned_2020
sort indnum
drop _merge

merge 1:1 iocode using ${workdir}/Work/BEA_Value_Added_by_Industry_Cleaned_2020
drop if _merge != 3
drop _merge

sort indnum

* Pool HS and ORE to calculate EO ratio (employment was all in one so we divide it by 2)
*replace employment = 0 if iocode == "ORE"
gen realestate = 0
replace realestate = 1 if inlist(iocode,"HS","ORE")
bys realestate (indnum): egen employment2 = sum(employment)
bys realestate (indnum): egen output2 = sum(output)

gen emp_output_ratio = employment / output if realestate == 0
replace emp_output_ratio = employment2 / output2 if realestate == 1

gen va_output_ratio = valueadded / output

sort indnum
	
drop realestate employment2 output2
	
rename output output2020
rename employment employment2020
rename valueadded valueadded2020

format emp_output_ratio va_output_ratio %12.11f

save ${workdir}/Work/BEA_EO_and_VAO_Ratios_by_Industry_Cleaned_2020, replace

