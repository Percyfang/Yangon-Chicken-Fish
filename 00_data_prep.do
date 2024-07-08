


clear
set more off

global path 	"C:\Users\PFANG\Dropbox (IFPRI)\Myanmar\Integrated poultry fish farm\PSF2019"
global rawdata 	"C:\Users\PFANG\Dropbox (IFPRI)\Myanmar\Commercial_Poultry_and_Swine_Production_in_Peri_urban_Yangon\data\clean_data"
global madedata "$path\madedata"
global do 		"$path\do"
global table	"$path\table"


****************************************

*	Location, or GPS of Broiler and Layer farms

use "$rawdata\SecA_v1.dta",clear

*gen chicken = inlist(1,a101__3, a101__4, a101__5, a101__6)
gen chicken = inlist(1,a101__3, a101__4, a101__5)
tab chicken
keep if chicken ==1

keep interview__key a101* region township village_tract ward_village GPS__Latitude GPS__Longitude GPS__Accuracy GPS__Altitude GPS__Timestamp a010 phone

save "$madedata\basic.dta", replace	// chicken farms only



****************************************

	* 	layer production
	
	
use  "$rawdata\SecG_v1.dta", clear		// farm level
gen layer_num =  g102 ,after(g102)

replace layer_num=g101 if g102==0
replace layer_num=g107 if layer_num==0

keep layer_num  interview__key

tempfile layer_num
save `layer_num'



	*	broiler production 

use  "$rawdata\SecF_v1.dta", clear		// farm level
	
sort f102u f103u

tabstat f103a,by(f103au) s(n mean median)

gen broiler_num =  f101 ,after(f101)

	replace broiler_num = f201 if f201!=. & broiler_num==0
	
/*
gen broiler_num =  f102 if f102u==1,after(f102u)
	replace broiler_num = f102/1.6 if inlist(f102u,2,3)

replace broiler_num=f101 if broiler_num<f101 | (inlist(f102,0,.) & f101!=.)
*/


	*	semibroiler production 
	
sort f302u f303u

gen semimbroiler_num =  f301,after(f301)

	replace semimbroiler_num = f401 if f401!=. & semimbroiler_num==0

/*
gen semimbroiler_num =  f302 if f302u==1,after(f302u)
	replace semimbroiler_num = f302/1.6 if inlist(f302u,2,3)

replace semimbroiler_num=f301 if semimbroiler_num<f301 | (inlist(f302,0,.) & f301!=.)
*/


keep broiler_num semimbroiler_num interview__key


merge 1:1 interview__key using `layer_num',nogen


egen both_broiler_num = rowtotal(broiler_num semimbroiler_num)	// combine broiler and semi-broiler
replace layer_num=0 if layer_num==.


*tempfile production
*save `production'

save "$madedata\production.dta", replace	// chicken farms only







****************************************

*	total parcel area, total number of chicken houses


use  "$rawdata\Parcel_roster_v1.dta", clear		// parcel level


isid  interview__key Parcel_roster__id
sort  interview__key Parcel_roster__id


keep interview__key Parcel_roster__id b102_acres animal_fish_integrated b104 b105 Num_Intg_fish_pond  

merge m:1 interview__key using "$madedata\basic.dta",keep(3) nogen	// keep chicken farms only


gen parcel_integrated = animal_fish_integrated==1,after(animal_fish_integrated)
tab parcel_integrated	//	about two thirds of parcels are integrated
keep if parcel_integrated ==1	//	only keep the integrated fish chicken farms


keep interview__key b102_acres b104 b105 region township village_tract ward_village GPS__Latitude GPS__Longitude GPS__Accuracy GPS__Altitude  a101__3 a101__4 a101__5

rename	b102_acres	parcel_area
rename	b104	num_chicken_house
rename	b105	year_first_house
rename	a101__3	broiler
rename	a101__4	semibroiler
rename	a101__5	layer

collapse (sum)parcel_area num_chicken_house (min)year_first_house,by(interview__key region township village_tract ward_village GPS__Latitude GPS__Longitude GPS__Accuracy GPS__Altitude broiler semibroiler layer)	// farm level now, total parcel area, total number of chicken houses

tempfile parcel_area
save `parcel_area'


****************************************



use  "$rawdata\Animal_housing_v1.dta", clear		// animal house level

isid interview__key Parcel_roster__id Animal_housing__id

keep interview__key Parcel_roster__id Animal_housing__id c101 c104 c105 c105u c106 c106u c109__1 c109__2 c109__3 c109__4 c109__99 c109s c109s_english c109__0

gen length_m = c105 * 0.3048 if  c105u==1,after(c105u)
	replace length_m=  c105 * 1.5 * 0.3048 if  c105u==2
gen width_m = c106 * 0.3048 if  c106u==1,after(c106u)
	replace width_m=  c106 * 1.5 * 0.3048 if  c106u==2

gen area_m = length_m * width_m	
	
	
keep if c101<4	//	keep only chicken houses
	
gen house_integrated = c104==1,after(c104)
	
keep if 	house_integrated==1 //	keep only the chicken houses that integrated with fish pond


gen zinc = c109__1==1
gen thatch = c109__2==1
replace zinc=0 if thatch==1 & zinc==1	// if both materials are used, assuming thatch is easier to be identified.
	
gen chicken_type = 	c101==3,after(c101)





/*	conversion facotor of floor over roof
merge m:1 interview__key using `production',nogen
merge m:1 interview__key using `parcel_area',nogen

sum length_m if chicken_type==1 & region==3,d
sum width_m if chicken_type==1 & region==3,d
sum length_m if chicken_type==0 & region==3,d
sum width_m if chicken_type==0 & region==3,d

sum length_m if zinc==1 & region==3,d
sum width_m if zinc==1 & region==3,d
sum length_m if thatch==1 & region==3,d
sum width_m if thatch==1 & region==3,d
*/



	
collapse (sum)area_m zinc thatch house_integrated,by(interview__key chicken_type)	
	
reshape wide area_m zinc thatch house_integrated, i(interview__key) j(chicken_type)
	
rename *0 *_brler
rename *1 *_layer


merge 1:1 interview__key using "$madedata\production.dta",nogen
merge 1:1 interview__key using `parcel_area',nogen
	
sort num_chicken_house



drop if num_chicken_house==.



gen b_prdty = both_broiler_num/area_m_brler,after(area_m_brler)

gen b_z_prdty = both_broiler_num/area_m_brler if zinc_brler>0,after(b_prdty)
gen b_t_prdty = both_broiler_num/area_m_brler if thatch_brler>0,after(b_prdty)





gen l_prdty = layer_num/area_m_layer,after(area_m_layer)
gen l_z_prdty = layer_num/area_m_layer if zinc_layer>0,after(l_prdty)
gen l_t_prdty = layer_num/area_m_layer if thatch_layer>0,after(l_prdty)


drop semimbroiler_num broiler_num
replace broiler=1 if semibroiler==1


lab var interview__key	   "农场序号"
lab var area_m_brler	   "肉鸡 鸡舍总面积，平方米"
lab var b_prdty            "肉鸡 鸡舍平均每平方米的全年肉鸡数量，只/平方米"
lab var b_t_prdty          "肉鸡 茅草屋顶鸡舍 平均每平方米的全年肉鸡数量，只/平方米"
lab var b_z_prdty          "肉鸡 铁板屋顶鸡舍 平均每平方米的全年肉鸡数量，只/平方米"
lab var zinc_brler         "肉鸡 铁板屋顶鸡舍 个数"
lab var thatch_brler       "肉鸡 茅草屋顶鸡舍 个数"
lab var area_m_layer       "蛋鸡 鸡舍总面积，平方米"
lab var l_prdty            "蛋鸡 鸡舍平均每平方米的全年蛋鸡数量，只/平方米"
lab var l_t_prdty          "蛋鸡 茅草屋顶鸡舍 平均每平方米的全年蛋鸡数量，只/平方米"
lab var l_z_prdty          "蛋鸡 铁板屋顶鸡舍 平均每平方米的全年蛋鸡数量，只/平方米"
lab var zinc_layer         "蛋鸡 铁板屋顶鸡舍 个数"
lab var thatch_layer       "蛋鸡 茅草屋顶鸡舍 个数"
lab var both_broiler_num   "肉鸡 全年销售数量"
lab var layer_num          "蛋鸡 数量"
lab var region             "省份"
lab var township           "城镇"
lab var village_tract      "村"
lab var ward_village       "区"
lab var broiler            "是否养肉鸡"
lab var layer              "是否养蛋鸡"
lab var parcel_area        "农场总面积"
lab var num_chicken_house  "鸡舍总数量"
lab var year_first_house   "第一个鸡舍盖的年份"
lab var house_integrated_brler   "肉鸡 鸡舍个数"
lab var house_integrated_layer   "蛋鸡 鸡舍个数"


save "$madedata\all integrated chicken farms.dta", replace	

export excel  using "$table/Chicken Fish Integrated Farms in Yangon.xlsx",sheet("all", modify) first(variable) 



