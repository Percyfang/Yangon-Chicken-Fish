


********************************************************
*	house area
********************************************************

putexcel set "$table/Chicken Fish Integrated Farms in Yangon.xlsx", sheet(Satellite_result) modify  

local r 6
foreach i in 10 11 12 13 14 15 16 17 18 19 20 21 23 {
import delimited "C:\Users\PFANG\Dropbox (IFPRI)\Myanmar\Integrated poultry fish farm\SatelliteImageMM\KaiFeng\Yangon\csv\result_v3_20`i'.csv",clear

rename v1 house_no

split v2,gen(farmGPS) destring

replace v3="." if v3=="none"
destring v3,gen(cluster_code)


replace v4="." if v4=="none"
destring v4,gen(cluster_house_num)

replace v5="." if v5=="none"
split v5,gen(clusterGPS) destring

rename v6 thatch 
recode thatch 0=.
lab def thatch 1 "thatch" 2 "zinc"
lab val thatch thatch


rename v7 house_area 
recode house_area 0=.


rename v8 pond_area 
recode pond_area 0=.

replace v9="." if v9=="none"
split v9,gen(other_house_no) destring

drop v*


sum house_area,d
replace house_area=r(p50) if house_area==.	// replace missing with median

	*	total area and mean area
local ncol = 3
local col: word `ncol' of `c(ALPHA)'

tabstat house_area,s(n sum mean median) save
tabstatmat `col'`r'
matrix `col'`r'=`col'`r''
putexcel `col'`r'=matrix(`col'`r'),nformat(number_sep)



	*	thatch vs zinc
	
		* numbers
		local ncol = 7
		local col: word `ncol' of `c(ALPHA)'	
		tab thatch,matcell(`col'`r')		
		matrix `col'`r'=`col'`r''
		putexcel `col'`r'=matrix(`col'`r'),nformat(number_sep)
			
	
		*	total area
		local ncol = 9
		local col: word `ncol' of `c(ALPHA)'
		tabstat house_area,s(sum) save by(thatch) nototal
		tabstatmat `col'`r'
		matrix `col'`r'=`col'`r''
		putexcel `col'`r'=matrix(`col'`r'),nformat(number_sep)



		*	mean area
		local ncol = 11
		local col: word `ncol' of `c(ALPHA)'
		tabstat house_area,s(mean) save by(thatch) nototal
		tabstatmat `col'`r'
		matrix `col'`r'=`col'`r''
		putexcel `col'`r'=matrix(`col'`r'),nformat(number_sep)

local ++r

}

! "$table/Chicken Fish Integrated Farms in Yangon.xlsx"


tabstat house_area if thatch==1,s(n mean) save 
tabstatmat x
matlist x

tab thatch,matcell(x)
mat x = x'
matlist x
gen zin = thatch==1
tabstat zin










*	May 28, 2024

*----check the avg size of chicken houses and ponds, using the 2023 updated results


import delimited using "C:\Users\PFANG\Dropbox (IFPRI)\Myanmar\Integrated poultry fish farm\SatelliteImageMM\KaiFeng\Yangon\2023updated_result\result_20230827.csv", clear



rename cluster_size house_area
rename cluster_xmin pond_area

sort house_area


drop if house_area==0

sum house_area,d


sort pond_area
drop if pond_area==0
duplicates drop pond_area,force
sum pond_area,d







