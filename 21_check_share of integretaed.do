


clear
set more off

global path 	"C:\Users\PFANG\Dropbox (IFPRI)\Myanmar\Integrated poultry fish farm\PSF2019"
global rawdata 	"C:\Users\PFANG\Dropbox (IFPRI)\Myanmar\Commercial_Poultry_and_Swine_Production_in_Peri_urban_Yangon\data\clean_data"
global madedata "$path\madedata"
global do 		"$path\do"
global table	"$path\table"






use "$madedata\production.dta",clear

merge 1:1 interview__key using "$madedata\all integrated chicken farms.dta", 

gen house_integrated_brler_d =  house_integrated_brler!=. if both_broiler_num!=0,after(house_integrated_brler)
gen house_integrated_layer_d =  house_integrated_layer!=. if layer_num!=0,after(house_integrated_layer)

bys house_integrated_brler_d: egen brler_num_intg = total(both_broiler_num)
bys house_integrated_layer_d: egen layer_num_intg = total(layer_num)

tabstat brler_num_intg,by(house_integrated_brler_d)
tabstat layer_num_intg,by(house_integrated_layer_d)

tab house_integrated_brler_d
tab house_integrated_layer_d






















