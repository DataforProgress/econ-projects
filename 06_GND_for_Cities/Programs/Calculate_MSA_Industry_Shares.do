
/*************************************************************************/
*  PROJECT:    		GND for Cities Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Calculate_MSA_Industry_Shares.do
*  LAST UPDATED: 	5/23/23
*  	
*  NOTES: 			Calculates the share of each MSA's employment in
*					each BEA industry, as measured in the 2021 American
*					Community Survey (ACS)
*					
/*************************************************************************/

clear
set more off

cd $workdir

use ${datadir}/ACS_Extract_2021_for_GND_for_Cities.dta, clear

gen bea_naics = ""

replace bea_naics = "111CA" if inlist(ind,170,180)
replace bea_naics = "113FF" if inlist(ind,190,270,280,290)
replace bea_naics = "211" if inlist(ind,370)
replace bea_naics = "212" if inlist(ind,380,390,470,480)
replace bea_naics = "213" if inlist(ind,490)
replace bea_naics = "22" if inlist(ind,570,580,590,670,680,690)
replace bea_naics = "23" if inlist(ind,770)
replace bea_naics = "321" if inlist(ind,3770,3780,3790,3870)
replace bea_naics = "327" if inlist(ind,2470,2480,2490,2570,2590)
replace bea_naics = "331" if inlist(ind,2670,2680,2690,2770)
replace bea_naics = "332" if inlist(ind,2780,2790,2870,2880,2890,2970,2980)
replace bea_naics = "333" if inlist(ind,3070,3080,3090,3170,3180,3190,3290)
replace bea_naics = "334" if inlist(ind,3360,3370,3380,3390)
replace bea_naics = "335" if inlist(ind,3470,3490)
replace bea_naics = "3361MV" if inlist(ind,3570)
replace bea_naics = "3364OT" if inlist(ind,3580,3590,3670,3680,3690)
replace bea_naics = "337" if inlist(ind,3890,3895)
replace bea_naics = "339" if inlist(ind,3960,3970,3980)
replace bea_naics = "311FT" if inlist(ind,1070,1080,1090,1170,1180,1190,1270,1280,1290,1370,1390)
replace bea_naics = "313TT" if inlist(ind,1470,1480,1490,1570,1590,1670)
replace bea_naics = "315AL" if inlist(ind,1680,1690,1770,1790)
replace bea_naics = "322" if inlist(ind,1870,1880,1890)
replace bea_naics = "323" if inlist(ind,1990)
replace bea_naics = "324" if inlist(ind,2070,2090)
replace bea_naics = "325" if inlist(ind,2170,2180,2190,2270,2280,2290)
replace bea_naics = "326" if inlist(ind,2370,2380,2390)
replace bea_naics = "42" if inlist(ind,4070,4080,4090,4170,4180,4190,4260,4270,4280,4290,4370,4380,4390,4470,4480,4490,4560,4570,4580,4585,4590)
replace bea_naics = "441" if inlist(ind,4670,4680,4690)
replace bea_naics = "445" if inlist(ind,4970,4980,4990)
replace bea_naics = "452" if inlist(ind,5380,5381,5390,5391)
replace bea_naics = "4A0" if inlist(ind,4770,4780,4790,4870,4880,4890,5070,5080,5090,5170,5180,5190,5270,5280,5290,5370,5470,5480,5490,5570,5580,5591,5592,5670,5680,5690,5790)
replace bea_naics = "481" if inlist(ind,6070)
replace bea_naics = "482" if inlist(ind,6080)
replace bea_naics = "483" if inlist(ind,6090)
replace bea_naics = "484" if inlist(ind,6170)
replace bea_naics = "485" if inlist(ind,6180,6190)
replace bea_naics = "486" if inlist(ind,6270)
replace bea_naics = "487OS" if inlist(ind,6280,6290)
replace bea_naics = "493" if inlist(ind,6390)
replace bea_naics = "511" if inlist(ind,6470,6480,6490)
replace bea_naics = "512" if inlist(ind,6570,6590)
replace bea_naics = "513" if inlist(ind,6670,6680,6690,6692)
replace bea_naics = "514" if inlist(ind,6675,6695)
replace bea_naics = "521CI;523;524;525" if inlist(ind,6870,6880,6890,6970,6990)
replace bea_naics = "HS;ORE" if inlist(ind,7070,7071,7072)
replace bea_naics = "532RL" if inlist(ind,7080,7170,7180,7190)
replace bea_naics = "5411" if inlist(ind,7270)
replace bea_naics = "5415" if inlist(ind,7380)
replace bea_naics = "5412OP" if inlist(ind,7280,7290,7370,7390,7460,7470,7480,7490)
replace bea_naics = "55" if inlist(ind,7570)
replace bea_naics = "561" if inlist(ind,7580,7590,7670,7680,7690,7770,7780)
replace bea_naics = "562" if inlist(ind,7790)
replace bea_naics = "61" if inlist(ind,7860,7870,7880,7890)
replace bea_naics = "621" if inlist(ind,7970,7980,7990,8070,8080,8090,8170,8180)
replace bea_naics = "622" if inlist(ind,8190,8191,8192)	
replace bea_naics = "623" if inlist(ind,8270,8290)	
replace bea_naics = "624" if inlist(ind,8370,8380,8390,8470)	
replace bea_naics = "711AS" if inlist(ind,8560,8570)	
replace bea_naics = "713" if inlist(ind,8580,8590)	
replace bea_naics = "721" if inlist(ind,8660,8670)	
replace bea_naics = "722" if inlist(ind,8680,8690)	
replace bea_naics = "81" if inlist(ind,8770,8780,8790,8870,8880,8890,8970,8980,8990,9070,9080,9090,9160,9170,9180,9190,9290)	
replace bea_naics = "GFGD" if inlist(ind,9670,9680,9690,9770,9780,9790,9870,9890)
replace bea_naics = "GFGN;GFE;GSLG;GSLE" if inlist(ind,9370,9380,9390,9470,9480,9490,9570,9590)

keep if empstat == 1

rename perwt pop

collapse (sum) pop, by(met2013 bea_naics)
replace pop = 0 if pop == .
drop if met2013 == 0

preserve
collapse (sum) pop, by(met2013)
sort met2013
gen n = _n
save ${workdir}/MSA_Employment, replace
restore

bys bea_naics (met2013): egen double bea_naics_total = sum(pop)

gen double msa_share = pop / bea_naics_total

* Make short version of IOCode_BEA_Naics_Bridge that only contains each industry once
preserve
use ${datadir}/IOCode_BEA_Naics_Bridge, clear
drop statefip _fillin
duplicates drop
sort indnum
save ${datadir}/IOCode_BEA_Naics_Bridge_Short, replace
restore

* Make MSA version of IOCode_BEA_Naics_Bridge
preserve

* Bring in MSA codes and expand with fillin
use ${datadir}/IOCode_BEA_Naics_Bridge_Short, clear
append using ${workdir}/MSA_Employment
fillin met2013 iocode
drop bea_naics indnum pop n _fillin

merge m:1 iocode using ${datadir}/IOCode_BEA_Naics_Bridge_Short
drop _merge
drop if iocode == ""
sort met2013 indnum

save ${datadir}/IOCode_BEA_Naics_Bridge_MSA, replace

restore

merge 1:m met2013 bea_naics using ${datadir}/IOCode_BEA_Naics_Bridge_MSA

sort met2013 indnum
drop if indnum == .
replace msa_share = 0 if msa_share == .
drop if met2013 == .

unique met2013
*Number of unique values of met2013 is  260
*Number of records is  18460

qui tab met2013, matrow(levels)
matrix list levels

* Create matrix with state industry shares
matrix msaindshares = J(260,71,0)
foreach i of numlist 1(1)260 {
	foreach j of numlist 1(1)71 {
		local k = (`i'-1)*71+`j'
		matrix msaindshares[`i',`j'] = msa_share[`k']
	}
}

svmat msaindshares, names(msaindshares)

keep msaindshares*

save ${workdir}/MSA_Industry_Shares, replace
