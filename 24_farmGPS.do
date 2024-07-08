clear 
set more off

global path "C:\Users\PFANG\Dropbox (IFPRI)\Myanmar\Commercial_Poultry_and_Swine_Production_in_Peri_urban_Yangon"
global rawdata	"$path\data\clean_data"

global path2 "C:\Users\PFANG\Dropbox (IFPRI)\SatelliteImageMM\satellite"
global madedata	"$path2\made_data"

global out "C:\Users\PFANG\Dropbox (IFPRI)\Myanmar\Integrated poultry fish farm\SatelliteImageMM\out"


use 		"$rawdata\animaltypeGPS.dta",clear 

keep if integrated_fish_pond>=1 & integrated_fish_pond!=.

format GPS__Latitude GPS__Longitude %10.7f
keep interview__key GPS__Latitude GPS__Longitude

tempfile GPS
save `GPS'






use 		"$rawdata\Animal_housing_v1.dta",clear 

egen houseNum = count(Animal_housing__id),by(interview__key)

gen zinc=c109__1==1
gen thatch=c109__2==1

keep interview__key zinc thatch houseNum

merge m:1 interview__key using `GPS',keep(3) nogen


drop if GPS__Latitude==.



bys interview__key: egen zincHH = max (zinc)
bys interview__key: egen thatchHH = max (thatch)


* we don't want the HH with both zinc and thatch
drop if zincHH ==1 &thatchHH==1

drop if zincHH ==0 &thatchHH==0


collapse zinc thatch houseNum,by(interview__key GPS__Latitude GPS__Longitude)


sort GPS__Latitude GPS__Longitude




export excel using "$out\farmGPS_roofMaterial.xlsx", first(var) replace

putexcel set "$out\farmGPS_roofMaterial.xlsx", sheet("Sheet1") modify
putexcel b2:c150, nformat(##.#######)

! "$out\farmGPS_roofMaterial.xlsx"



