
/*************************************************************************/
*  PROJECT:    		IRA Climate Memo
*  PROGRAMMER: 		Matt Mazewski
*  PROGRAM NAME:   	Clean_Domestic_Requirements_Table_2021.do
*  LAST UPDATED: 	5/24/23
*  	
/*************************************************************************/

import excel using ${datadir}/BEA_Industry_by_Industry_Domestic_Requirements_2021.xlsx, clear
drop if _n <= 7

* Destring variables
foreach var in "C" "D" "E" "F" "G" "H" "I" "J" "K" "L" "M" "N" "O" "P" "Q" "R" "S" "T" "U" "V" "W" "X" "Y" "Z" "AA" "AB" "AC" "AD" "AE" "AF" "AG" "AH" "AI" "AJ" "AK" "AL" "AM" "AN" "AO" "AP" "AQ" "AR" "AS" "AT" "AU" "AV" "AW" "AX" "AY" "AZ" "BA" "BB" "BC" "BD" "BE" "BF" "BG" "BH" "BI" "BJ" "BK" "BL" "BM" "BN" "BO" "BP" "BQ" "BR" "BS" "BT" "BU"  {
	destring(`var'), replace force
}

* Rename variables
rename A iocode
rename B name
rename C var_111CA
rename D var_113FF
rename E var_211
rename F var_212
rename G var_213
rename H var_22
rename I var_23
rename J var_321
rename K var_327
rename L var_331
rename M var_332
rename N var_333
rename O var_334
rename P var_335
rename Q var_3361MV
rename R var_3364OT
rename S var_337
rename T var_339
rename U var_311FT
rename V var_313TT
rename W var_315AL
rename X var_322
rename Y var_323
rename Z var_324
rename AA var_325
rename AB var_326
rename AC var_42
rename AD var_441
rename AE var_445
rename AF var_452
rename AG var_4A0
rename AH var_481
rename AI var_482
rename AJ var_483
rename AK var_484
rename AL var_485
rename AM var_486
rename AN var_487OS
rename AO var_493
rename AP var_511
rename AQ var_512
rename AR var_513
rename AS var_514
rename AT var_521CI
rename AU var_523
rename AV var_524
rename AW var_525
rename AX var_HS
rename AY var_ORE
rename AZ var_532RL
rename BA var_5411
rename BB var_5415
rename BC var_5412OP
rename BD var_55
rename BE var_561
rename BF var_562
rename BG var_61
rename BH var_621
rename BI var_622
rename BJ var_623
rename BK var_624
rename BL var_711AS
rename BM var_713
rename BN var_721
rename BO var_722
rename BP var_81
rename BQ var_GFGD
rename BR var_GFGN
rename BS var_GFE
rename BT var_GSLG
rename BU var_GSLE
	
gen year = 2021

gen total = 0
	
save ${datadir}/BEA_Industry_by_Industry_Domestic_Requirements_2021, replace
