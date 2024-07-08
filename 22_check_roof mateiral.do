
clear
set more off

global path 	"C:\Users\PFANG\Dropbox (IFPRI)\Myanmar\Integrated poultry fish farm\PSF2019"
global rawdata 	"C:\Users\PFANG\Dropbox (IFPRI)\Myanmar\Commercial_Poultry_and_Swine_Production_in_Peri_urban_Yangon\data\clean_data"
global madedata "$path\madedata"
global do 		"$path\do"
global table	"$path\table"


****************************************

****************************
*	male and female worker
****************************

use 		"$rawdata\SecI_v1.dta",clear 

egen menNum =   rowtotal(i103A  i103C  i103D)
egen womenNum = rowtotal(i103A  i103B  i103D)
egen workerNum = rowtotal(menNum womenNum)

keep interview__key menNum womenNum workerNum

tempfile workerNumber
save `workerNumber'



****************************
*	roof materials
****************************


use 		"$rawdata\Animal_housing_v1.dta",clear 

*egen houseNum = count(Animal_housing__id),by(interview__key)

gen zinc=c109__1==1
gen thatch=c109__2==1

*keep interview__key zinc thatch houseNum
tab zinc thatch

drop if zinc==0 & thatch==0
*drop if zinc==1 & thatch==1

tab zinc


merge m:1 interview__key using "$madedata\basic.dta",keep(3) nogen keepusing(region)	// keep chicken farms only


*putexcel set "$table/Chicken Fish Integrated Farms in Yangon.xlsx", sheet(Tables1) modify 


tab zinc region if c104==1,matcell(roof) 
tab zinc region,matcell(roof)
	*putexcel M54=matrix(roof),nformat(number)

gen house_size = c105 * c106*0.09,before(c105)



tabstat house_size,s(n mean p50 p10 p90) by(zin)



keep if  c101<4	// keep only chicken

gen workingHousing =  c102==1 & c102a!=2 & c102b!=2,before(c102)

*egen houseNum = count(Animal_housing__id),by(interview__key)
egen houseNum = total(workingHousing),by(interview__key)
replace houseNum=1 if houseNum==0

collapse (sum) zinc thatch (min)integrated=c104 (mean)houseNum,by(interview__key region)
replace integrated=0 if integrated!=1

	*	merge profit
merge 1:1 interview__key using "$rawdata\..\made_data\chickenGrossMargin.dta",nogen keep(3)
	*	Convert all Lahk to USD, use 1 lakh = 67 usd in 2019
	replace bGM       = bGM       *67
	replace sGM       = sGM       *67
	replace lGM       = lGM       *67
	replace chickenGM = chickenGM *67

	*	merge worker number
merge 1:1 interview__key using `workerNumber',nogen keep(3)

gen zincFarm = zinc>thatch,after(thatch)
gen zincFarm2 = zinc>0,after(thatch)
gen zincFarm3 = zinc>0 & thatch==0,after(thatch)

*******
*	compare labor between zinc and thatch
*******

oneway workerNum zincFarm2 if integrated==1 & region==3,tab
oneway menNum zincFarm2 if integrated==1 & region==3,tab
oneway womenNum zincFarm2 if integrated==1 & region==3,tab



*******
*	compare profit between zinc and thatch
*******

drop if bGM==. & sGM==. & lGM==. 

egen chickenRev =rowtotal(bRev sRev lRev) 


sum chickenGM if chickenGM!=0,d
replace chickenGM = r(p5) if chickenGM<r(p5) 
replace chickenGM = r(p95) if chickenGM>r(p95) & chickenGM!=.

sum chickenRev if chickenRev!=0,d
replace chickenRev = r(p5) if chickenRev<r(p5) 
replace chickenRev = r(p95) if chickenRev>r(p95) & chickenRev!=.


sum bGM if bGM!=0,d
replace bGM = r(p5) if bGM<r(p5) 
replace bGM = r(p95) if bGM>r(p95) & bGM!=.

sum bRev if bRev!=0,d
replace bRev = r(p5) if bRev<r(p5) 
replace bRev = r(p95) if bRev>r(p95) & bRev!=.



*	profit and revenue per animal house

gen  chickenGMpHS = chickenGM/houseNum
gen chickenRevpHS = chickenRev/houseNum
 
gen  bGMpHS = bGM/houseNum
gen bRevpHS = bRev/houseNum 


tab zincFarm
tab zincFarm2

tabstat zinc thatch,s(n sum) 
tabstat zinc thatch if integrated==1 & region==3,s(n sum) 

sum chickenGM if integrated==1 & region==3,d
oneway chickenGM zincFarm2 if integrated==1 & region==3 & inrange(chickenGM,r(p25),r(p75)),tab
oneway chickenGM zincFarm2 if integrated==1 & region==3,tab
oneway chickenGM zincFarm2 if integrated==1 ,tab
oneway chickenGM zincFarm2 ,tab

oneway chickenGMpHS zincFarm2 if integrated==1 & region==3,tab
oneway chickenGMpHS zincFarm2 if integrated==1 ,tab
oneway chickenGMpHS zincFarm2 ,tab

oneway houseNum zincFarm2 if integrated==1 & region==3,tab
oneway houseNum zincFarm2 if integrated==1 ,tab
oneway houseNum zincFarm2 ,tab








local r = 70

foreach v in "integrated==1&region==3" "integrated==1" "integrated<2"  {

local a "C F I"
local b "chickenGM houseNum chickenGMpHS"
local c "E H K"
local n: word count `a'

forvalues i = 1/`n' {
local x: word `i' of `a'
local y: word `i' of `b'
local z: word `i' of `c'

tabstat `y' if `v',by(zincFarm2) save nototal s(mean n)
tabstatmat `x'`r'
mat `x'`r'=`x'`r''

anova `y' zincFarm2 if `v'
local star ""
if Ftail(e(df_m),e(df_r),e(F))<0.1  local star *
if Ftail(e(df_m),e(df_r),e(F))<0.05 local star **
if Ftail(e(df_m),e(df_r),e(F))<0.01 local star ***


putexcel `z'`r' = "`star'"

putexcel `x'`r'=matrix(`x'`r') ,nformat(number_sep) 
}
local r = `r'+ 2

}

tabstat chickenGMpHS if integrated==1&region==3,by(zincFarm2) save nototal s(mean)
br if integrated==1&region==3
sort chickenGMpHS

local r = 81

foreach v of varlist chickenGM houseNum chickenGMpHS workerNum menNum womenNum {

local a "C F I"
local b "integrated==1&region==3 integrated==1 integrated<2"
local c "E H K"
local n: word count `a'

forvalues i = 1/`n' {
local x: word `i' of `a'
local y: word `i' of `b'
local z: word `i' of `c'

tabstat `v' if `y',by(zincFarm2) save nototal s(mean)
tabstatmat `x'`r'
mat `x'`r'=`x'`r''

anova `v' zincFarm2 if `y'
local star ""
if Ftail(e(df_m),e(df_r),e(F))<0.1  local star *
if Ftail(e(df_m),e(df_r),e(F))<0.05 local star **
if Ftail(e(df_m),e(df_r),e(F))<0.01 local star ***


putexcel `z'`r' = "`star'"

putexcel `x'`r'=matrix(`x'`r') ,nformat(number_sep) 
}
local r = `r'+ 1

}

/*
oneway chickenGM  zincFarm2,tab
oneway chickenRev zincFarm2,tab
oneway chickenGM  zincFarm2  if integrated==1,tab
oneway chickenRev zincFarm2 if integrated==1,tab
oneway chickenGM  zincFarm2  if integrated==1 & region==3,tab
oneway chickenRev zincFarm2 if integrated==1 & region==3,tab
*/



tabstat bGM if integrated==1&region==3,by(zincFarm2) save nototal s(mean n)
