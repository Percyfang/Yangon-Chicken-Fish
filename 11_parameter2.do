
*	calculate chicken per m2 at animal house level


use  "$rawdata\Animal_housing_v1.dta", clear		// animal house level

keep if c101<4 //	keep only chicken houses

gen num = c103,after(c103)

gen length_m = c105 * 0.3048 if  c105u==1,after(c105u)
	replace length_m=  c105 * 1.5 * 0.3048 if  c105u==2
gen width_m = c106 * 0.3048 if  c106u==1,after(c106u)
	replace width_m=  c106 * 1.5 * 0.3048 if  c106u==2

gen area_m = length_m * width_m	

gen prdty = num/area_m

gen thatch = c109__2==1


keep if c104==1


merge m:1 interview__key using "$madedata\basic.dta",keep(3) nogen

gen prdty_z = prdty if thatch ==0
gen prdty_t = prdty if thatch ==1


putexcel set "$table/Chicken Fish Integrated Farms in Yangon.xlsx", sheet(parameter) modify  


local ncol = 15
local col: word `ncol' of `c(ALPHA)'
local r 21
tabstat prdty  ,s(n mean median) save
tabstatmat `col'`r'
putexcel `col'`r'=matrix(`col'`r'),nformat(number)

local ncol = 16
local col: word `ncol' of `c(ALPHA)'
local r 21
tabstat prdty  if region==3,s(n mean median) save
tabstatmat `col'`r'
putexcel `col'`r'=matrix(`col'`r'),nformat(number)



*****************************
*	肉鸡养鸡数量
*****************************


local ncol = 15
local col: word `ncol' of `c(ALPHA)'
local r 4
tabstat prdty prdty_z prdty_t if inlist(c101,1,2),s(n mean median) save
tabstatmat `col'`r'
putexcel `col'`r'=matrix(`col'`r'),nformat(number)

	*	yangon only

	local ncol = 21
	local col: word `ncol' of `c(ALPHA)'
	local r 4
	tabstat prdty prdty_z prdty_t if inlist(c101,1,2) & region==3,s(n mean median) save
	tabstatmat `col'`r'
	putexcel `col'`r'=matrix(`col'`r'),nformat(number)


*****************************
*	蛋鸡养鸡数量
*****************************

local ncol = 15
local col: word `ncol' of `c(ALPHA)'
local r 13
tabstat prdty prdty_z prdty_t if inlist(c101,3),s(n mean median) save
tabstatmat `col'`r'
putexcel `col'`r'=matrix(`col'`r'),nformat(number)

	*	yangon only

	local ncol = 21
	local col: word `ncol' of `c(ALPHA)'
	local r 13
	tabstat prdty prdty_z prdty_t if inlist(c101,3) & region==3,s(n mean median) save
	tabstatmat `col'`r'
	putexcel `col'`r'=matrix(`col'`r'),nformat(number)


putexcel B5:W6 B14:W15 O22:P23 ,nformat(0.0)

! "$table/Chicken Fish Integrated Farms in Yangon.xlsx",





