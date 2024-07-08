
*	2020 phone surveys closed farms



clear 
set more off

global path "C:\Users\PFANG\Dropbox (IFPRI)\Myanmar\Commercial_Poultry_and_Swine_Production_in_Peri_urban_Yangon"
global rawdata	"$path\data\clean_data"

global path2 "C:\Users\PFANG\Dropbox (IFPRI)\SatelliteImageMM\satellite"
global madedata	"$path2\made_data"

global out "C:\Users\PFANG\Dropbox (IFPRI)\Myanmar\Integrated poultry fish farm\SatelliteImageMM\out"



*	GPS of closed farms



	**	Closed farms

use "C:\Users\PFANG\Dropbox (IFPRI)\SurveyCTO\livestock\clean_data\lvstk_farm_closed.dta",clear

keep farm_id round a008

drop if a008==1 //these are the firms changed the type of chicken, we consider them as operational

reshape wide a008,i(farm_id) j(round)
sort a0081 a0082 a0083 a0084 a0085 a0086

gen everClosed = 1

egen PmntClosed = anymatch(a0081 a0082 a0083 a0084 a0085 a0086),v(3)

gen TempClosed = PmntClosed==0 & everClosed==1

save "$out\ClosedFarms_wide",replace


	**	Reopened farms
	
use "C:\Users\PFANG\Dropbox (IFPRI)\SurveyCTO\livestock\clean_data\reopen_r2.dta",clear	
append using "C:\Users\PFANG\Dropbox (IFPRI)\SurveyCTO\livestock\clean_data\reopen_r3.dta"
append using "C:\Users\PFANG\Dropbox (IFPRI)\SurveyCTO\livestock\clean_data\reopen_r4.dta"
append using "C:\Users\PFANG\Dropbox (IFPRI)\SurveyCTO\livestock\clean_data\reopen_r5.dta"
append using "C:\Users\PFANG\Dropbox (IFPRI)\SurveyCTO\livestock\clean_data\reopen_r6.dta"
	
isid farm_id	
order a008*

egen last_status =  rowlast(a0081 a0082 a0083 a0084 a0085 a0086)
gen reopen = last_status==1	
	
keep if reopen==1	

keep farm_id reopen

save "$out\ReopenFarms_wide",replace


	**	GPS


use 		"$rawdata\animaltypeGPS.dta",clear 

format GPS__Latitude GPS__Longitude %10.7f

replace integrated_fish_pond=1 if integrated_fish_pond>1 & integrated_fish_pond!=.
keep interview__key integrated_fish_pond GPS__Latitude GPS__Longitude region township village_tract ward_village a010

isid interview__key

save "$out\AllFarmGPS",replace




	**	Merge

import excel "C:\Users\PFANG\Dropbox (IFPRI)\COVID-19\Livestock Phone Survey\Rosters for each round\roster_round1.xlsx",firstrow clear sheet("roster_round1") cellrange(:R269)

	drop if farm_id ==70 //should be error

keep farm_id animal fish interview__key


merge 1:1 farm_id using "$out\ClosedFarms_wide",nogen
merge 1:1 farm_id using "$out\ReopenFarms_wide",nogen
merge 1:1 interview__key using "$out\AllFarmGPS",nogen


sort reopen TempClosed

swapval PmntClosed TempClosed if PmntClosed ==1 & reopen==1

gen closed = everClosed==1 & reo !=1

recode everClosed PmntClosed TempClosed reopen (.=0)

recode everClosed PmntClosed TempClosed reopen (0=.) if farm_id==.


sort region township village_tract ward_village


bys region township village_tract: egen mean_GPS_La = mean(GPS__Latitude)
bys region township village_tract: egen mean_GPS_Lo = mean(GPS__Longitude)

bys region township : egen mean_GPS_La_tw = mean(GPS__Latitude)
bys region township : egen mean_GPS_Lo_tw = mean(GPS__Longitude)

	*	Generate new GPS, fill in missing value based on the GPS of the farms in the same village, or based on the GPS of the village copied from Google

	gen GPSLati_new = GPS__Latitude
	gen GPSLong_new = GPS__Longitude
	
		*	based on other farms in the same village
	replace GPSLati_new = mean_GPS_La if mean_GPS_La!=. & GPSLati_new==.
	replace GPSLong_new = mean_GPS_Lo if mean_GPS_Lo!=. & GPSLong_new==.


		*	based on other farms in the same township
	replace GPSLati_new = mean_GPS_La_tw if mean_GPS_La_tw!=. & GPSLati_new==.
	replace GPSLong_new = mean_GPS_Lo_tw if mean_GPS_Lo_tw!=. & GPSLong_new==.
		
		*	based on gps of villages from GOOGLE
	replace GPSLati_new =17.259488425936645  if GPSLati_new==. & region==1 & township==2
	replace GPSLong_new =95.58295184344084  if GPSLong_new==. & region==1 & township==2
	
*	integrated_fish

	gen integrated_fish=integrated_fish_pond==1
	
	
	

keep farm_id interview__key  everClosed PmntClosed TempClosed reopen closed integrated_fish GPS__Latitude GPS__Longitude GPSLati_new GPSLong_new region township village_tract ward_village
order farm_id interview__key   PmntClosed TempClosed everClosed closed  reopen  GPS__Latitude GPS__Longitude GPSLati_new GPSLong_new integrated_fish region township village_tract ward_village

rename TempClosed EverTempClosed 
format ward_village %10s
format GPS__Latitude GPS__Longitude GPSLati_new GPSLong_new %8.0g


drop if farm_id==.


lab var PmntClosed "永久关闭"
lab var EverTempClosed "当前或者曾经 临时关闭"
lab var everClosed "曾经 关闭 （包括永久和临时）"
lab var closed "当前处于关闭"
lab var reopen "临时关闭后重新营业"
lab var integrated_fish "鱼鸡混养农场"


lab var GPS__Latitude "调研时获取的GPS"
lab var GPS__Longitude "调研时获取的GPS"

lab var GPSLati_new  "调研时获取的GPS + 后期根据村镇名称估计的GPS"
lab var GPSLong_new   "调研时获取的GPS + 后期根据村镇名称估计的GPS"

gsort - PmntClosed -EverTempClosed -reopen

*	all farms in covid survey
export excel using "$out\ClosedFarmGPS.xlsx", first(var) sheet("all",replace)
putexcel set "$out\ClosedFarmGPS.xlsx", sheet("all") modify
putexcel h2:k600, nformat(##.####)


*	all everClosed farms

drop if everClosed==0
export excel using "$out\ClosedFarmGPS.xlsx", first(var) sheet("closed",replace)
putexcel set "$out\ClosedFarmGPS.xlsx", sheet("closed") modify
putexcel h2:k600, nformat(##.####)


*	all everClosed integrated farms

drop if integrated_fish==0
export excel using "$out\ClosedFarmGPS.xlsx", first(var) sheet("closed_intg",replace)
putexcel set "$out\ClosedFarmGPS.xlsx", sheet("closed_intg") modify
putexcel h2:k600, nformat(##.####)









! "$out\ClosedFarmGPS.xlsx"





