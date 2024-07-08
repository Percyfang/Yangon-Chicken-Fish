
clear
set more off

global path 	"C:\Users\PFANG\Dropbox (IFPRI)\Myanmar\Integrated poultry fish farm\PSF2019"
global rawdata 	"C:\Users\PFANG\Dropbox (IFPRI)\Myanmar\Commercial_Poultry_and_Swine_Production_in_Peri_urban_Yangon\data\clean_data"
global madedata "$path\madedata"
global do 		"$path\do"
global table	"$path\table"


****************************************

use "$madedata\all integrated chicken farms.dta", clear	


putexcel set "$table/Chicken Fish Integrated Farms in Yangon.xlsx", sheet(parameter) modify  

*	肉鸡鸡舍单位平方米年产量



local ncol = 2
local col: word `ncol' of `c(ALPHA)'
local r 4
tabstat b_prdty b_z_prdty b_t_prdty,s(n mean median) save
tabstatmat `col'`r'
putexcel `col'`r'=matrix(`col'`r'),nformat(number)

	*	yangon only

	local ncol = 8
	local col: word `ncol' of `c(ALPHA)'
	local r 4
	tabstat b_prdty b_z_prdty b_t_prdty if region==3,s(n mean median) save
	tabstatmat `col'`r'
	putexcel `col'`r'=matrix(`col'`r'),nformat(number)



*	蛋鸡鸡舍单位平方米蛋鸡的数量

local ncol = 2
local col: word `ncol' of `c(ALPHA)'
local r 13
tabstat l_prdty l_z_prdty l_t_prdty,s(n mean median) save
tabstatmat `col'`r'
putexcel `col'`r'=matrix(`col'`r'),nformat(number)

	*	yangon only
	local ncol = 8
	local col: word `ncol' of `c(ALPHA)'
	local r 13
	tabstat l_prdty l_z_prdty l_t_prdty if region==3,s(n mean median) save
	tabstatmat `col'`r'
	putexcel `col'`r'=matrix(`col'`r'),nformat(number)


*	平均每个肉鸡农场的产量

local ncol = 2
local col: word `ncol' of `c(ALPHA)'
local r 23
tabstat both_broiler_num if both_broiler_num>0,s(n mean median) save
tabstatmat `col'`r'
putexcel `col'`r'=matrix(`col'`r'),nformat(number)

local ++ncol
local col: word `ncol' of `c(ALPHA)'
tabstat both_broiler_num if both_broiler_num>0 & zinc_brler>0,s(n mean median) save
tabstatmat `col'`r'
putexcel `col'`r'=matrix(`col'`r'),nformat(number)

local ++ncol
local col: word `ncol' of `c(ALPHA)'
tabstat both_broiler_num if both_broiler_num>0 & thatch_brler>0,s(n mean median) save
tabstatmat `col'`r'
putexcel `col'`r'=matrix(`col'`r'),nformat(number)

	*yangon province
	local ncol = 8
	local col: word `ncol' of `c(ALPHA)'
	local r 23
	tabstat both_broiler_num if both_broiler_num>0 & region==3,s(n mean median) save
	tabstatmat `col'`r'
	putexcel `col'`r'=matrix(`col'`r'),nformat(number)

	local ++ncol
	local col: word `ncol' of `c(ALPHA)'
	tabstat both_broiler_num if both_broiler_num>0 & zinc_brler>0 & region==3,s(n mean median) save
	tabstatmat `col'`r'
	putexcel `col'`r'=matrix(`col'`r'),nformat(number)

	local ++ncol
	local col: word `ncol' of `c(ALPHA)'
	tabstat both_broiler_num if both_broiler_num>0 & thatch_brler>0 & region==3,s(n mean median) save
	tabstatmat `col'`r'
	putexcel `col'`r'=matrix(`col'`r'),nformat(number)		

*	平均每个蛋鸡农场的蛋鸡数量


local ncol = 2
local col: word `ncol' of `c(ALPHA)'
local r 33
tabstat layer_num if layer_num >0,s(n mean median) save
tabstatmat `col'`r'
putexcel `col'`r'=matrix(`col'`r'),nformat(number)

local ++ncol
local col: word `ncol' of `c(ALPHA)'
tabstat layer_num if layer_num >0 & zinc_layer>0,s(n mean median) save
tabstatmat `col'`r'
putexcel `col'`r'=matrix(`col'`r'),nformat(number)

local ++ncol
local col: word `ncol' of `c(ALPHA)'
tabstat layer_num if layer_num >0 & thatch_layer>0,s(n mean median) save
tabstatmat `col'`r'
putexcel `col'`r'=matrix(`col'`r'),nformat(number)


	*yangon province
	local ncol = 8
	local col: word `ncol' of `c(ALPHA)'
	local r 33
	tabstat layer_num if layer_num >0 & region==3,s(n mean median) save
	tabstatmat `col'`r'
	putexcel `col'`r'=matrix(`col'`r'),nformat(number)

	local ++ncol
	local col: word `ncol' of `c(ALPHA)'
	tabstat layer_num if layer_num >0 & zinc_layer>0& region==3,s(n mean median) save
	tabstatmat `col'`r'
	putexcel `col'`r'=matrix(`col'`r'),nformat(number)

	local ++ncol
	local col: word `ncol' of `c(ALPHA)'
	tabstat layer_num if layer_num >0 & thatch_layer>0& region==3,s(n mean median) save
	tabstatmat `col'`r'
	putexcel `col'`r'=matrix(`col'`r'),nformat(number)

*	仰光100km半径 平均每个农场integrated鸡舍的数量

local ncol = 2
local col: word `ncol' of `c(ALPHA)'
local r 41
tabstat house_integrated_brler house_integrated_layer ,s(n mean median) save
tabstatmat `col'`r'
putexcel `col'`r'=matrix(`col'`r'),nformat(number_sep)

	*	仰光省  
	local ncol = 8
	local col: word `ncol' of `c(ALPHA)'
	local r 41
	tabstat house_integrated_brler house_integrated_layer if region==3,s(n mean median) save
	tabstatmat `col'`r'
	putexcel `col'`r'=matrix(`col'`r'),nformat(number_sep)


*	Animal house size per farm, Yangon 100km radius

local ncol = 2
local col: word `ncol' of `c(ALPHA)'
local r 49
tabstat area_m_brler area_m_layer ,s(n mean median) save
tabstatmat `col'`r'
putexcel `col'`r'=matrix(`col'`r'),nformat(number_sep)

	*	仰光省  
	local ncol = 8
	local col: word `ncol' of `c(ALPHA)'
	local r 49
	tabstat area_m_brler area_m_layer if region==3,s(n mean median) save
	tabstatmat `col'`r'
	putexcel `col'`r'=matrix(`col'`r'),nformat(number_sep)
	

! "$table/Chicken Fish Integrated Farms in Yangon.xlsx",



*	broilers

use  "$rawdata\SecF_v1.dta", clear		// farm level

* number of cycles in a year_first_house

gen x = f102/f101 
sum x if inrange(x,1,6),d
	//	4 cycles based on method 1

sum f200 f202,d
	//	6 cycles based on method 1

	//	let's use the avg 5



*	weight of a native chicken
sum f503a,d






*	layers

	*	one cycle
use  "$rawdata\SecG_v1.dta", clear		// farm level
sum g107,d 
sum g108 if g108u==1,d	//1.2viss

gen x = g200+g201
sum x  if g201u==1,d
sum x  if g201u==2,d



*	number of eggs per chicken
use  "$rawdata\SecG_v1.dta", clear		// farm level

gen x = g103_yr_total/g102
sum x ,d




*	share of broiler and layer house area


use "$madedata\all integrated chicken farms.dta", clear	
gen broilsemi = broiler ==1| semibroiler==1
*replace  broilsemi=0 if house_integrated_brler==.
order house_integrated_brler house_integrated_layer  broilsemi layer, last

tab  broilsemi layer if region ==3




	should we only use 2019 survey to generate the two shares??


*	number of total broilers and layers in 2020

*	number broilers and layers of the Integrated farms in 2020

*	share of integrated in total chicken, for broiler and Layer




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



