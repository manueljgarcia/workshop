********************************************************************************
* Author: Manuel Garcia                                                        *
* Adapted from: Qi Kang and Oscar Sarasty                                      *                                               
* Date: June 2023                                                              *
********************************************************************************

//STEP 1: Import the raw data from Qualtrics (.xlsx; .csv; .tsv), merge it, apply quality assurance, and save it (*.dta).

clear
import excel "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data/Survey_B1_June 14, 2023_09.34.xlsx", sheet("Sheet0") firstrow
gen Block = 1
drop in 1
save "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/block1.dta", replace

clear
import excel "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data/Survey_B2_June 14, 2023_09.36.xlsx", sheet("Sheet0") firstrow
gen Block = 2
drop in 1
save "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/block2.dta", replace

clear
import excel "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data/Survey_B3_June 14, 2023_09.37.xlsx", sheet("Sheet0") firstrow
gen Block = 3
drop in 1
save "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/block3.dta", replace

clear
use "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/block1.dta"
append using "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/block2.dta"
append using "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/block3.dta"
drop if Progress != "100" | Finished == "False" | Q1 != "SIGUIENTE" //we don't need partial responses and under age respondents//

save "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/data.dta", replace


****************************************************************************************************************************************************************************

//STEP 2: Data wrangling -Estimating summary statistics

clear
use "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/data.dta", clear

// Drop CE missing answers
drop if (Q30 == "" | Q32 == "" | Q34 == "" | Q36 == "" | Q38 == "" | Q40 == "" | Q42 == "" | Q44 == "" | Q46 == "" | Q48 == "" | Q50 == "" | Q52 == "")

describe Q3
destring Q3, replace
destring Q9_1_1, replace
destring Q9_2_1, replace
destring Q12_1, replace
destring Q13_1, replace


gen age = (2021 - Q3) //Years old in 2021

gen urban = 1 //Dummy variable (1=urban, 0=rural)
replace urban = 0 if Q5 == "Rural" 

gen male = 1 //Dummy variable (1=male, 0=female)
replace male = 0 if Q6 == "Femenino"

gen household_size = Q9_1_1 + Q9_2_1 //Household size

summarize age urban male household_size

gen edu = Q8
replace edu = "Middle School or below" if Q8 == "Primaria"
replace edu = "High school" if (Q8 == "Secundaria" | Q8 == "Preparatoria o bachillerato")
replace edu = "Professional (Technicians, BS, Graduate Degree)" if (Q8 == "Carrera técnica o comercial" | Q8 == "Universitario (Licenciatura, Ingeniería o posgrado)")
tab edu


gen monthly_income = Q11 //Household monthly income
replace monthly_income = "Under 3,000 Pesos" if Q11 == "Menos de 3,000 pesos"
replace monthly_income = "More than 30,000 Pesos" if Q11 == "Más de 30,000 Pesos"
tab monthly_income


gen share_incomefood = Q12_1 //Household income spent on food
tab share_incomefood

gen share_beeffood = Q13_1 //Food budget spent on beef
tab share_beeffood

gen freq_beefpurchase = Q14 //Frequency of purchase of beef products
replace freq_beefpurchase = "Daily" if Q14 == "Diario"
replace freq_beefpurchase = "Weekly" if Q14 == "Semanal"
replace freq_beefpurchase = "Biweekly" if Q14 == "Quincenal"
replace freq_beefpurchase = "Monthly" if Q14 == "Mensual"
replace freq_beefpurchase = "Less than once a month" if Q14 == "Menos de una vez al mes"
replace freq_beefpurchase = "Never" if Q14 == "Nunca"
tab freq_beefpurchase


gen freq_beefconsumption = Q16 //Frequency of beef consumption
replace freq_beefconsumption = "4 or more times a week" if Q16 == "4 o más por semana"
replace freq_beefconsumption = "2 - 3 times a week" if Q16 == "2-3 veces por semana"
replace freq_beefconsumption = "Once a week" if Q16 == "Una vez por semana"
replace freq_beefconsumption = "2 - 3 times a month" if Q16 == "2-3 veces al mes"
replace freq_beefconsumption = "Once a month" if Q16 == "1 vez al mes"
replace freq_beefconsumption = "Never" if Q16 == "Nunca"
tab freq_beefconsumption


//Overall opinions about foreign places (US, Texas, Canada, and Nicaragua)
gen US_opinion =Q20_1
replace US_opinion = "Somewhat or very unfavorable" if (Q20_1 == "1. (Muy desfavorable)" | Q20_1 == "2. (Algo desfavorable)")
replace US_opinion = "Neutral" if Q20_1 == "3. (Neutral)"
replace US_opinion = "Somewhat or very favorable" if (Q20_1 == "4. (Algo favorable)" | Q20_1 =="5. (Muy favorable)")
tab US_opinion if US_opinion != "Ninguna"

gen TX_opinion =Q20_2
replace TX_opinion = "Somewhat or very unfavorable" if (Q20_2 == "1. (Muy desfavorable)" | Q20_2 == "2. (Algo desfavorable)")
replace TX_opinion = "Neutral" if Q20_2 == "3. (Neutral)"
replace TX_opinion = "Somewhat or very favorable" if (Q20_2 == "4. (Algo favorable)" | Q20_2 =="5. (Muy favorable)")
tab TX_opinion if TX_opinion != "Ninguna"

gen Can_opinion =Q20_3
replace Can_opinion = "Somewhat or very unfavorable" if (Q20_3 == "1. (Muy desfavorable)" | Q20_3 == "2. (Algo desfavorable)")
replace Can_opinion = "Neutral" if Q20_3 == "3. (Neutral)"
replace Can_opinion = "Somewhat or very favorable" if (Q20_3 == "4. (Algo favorable)" | Q20_3 =="5. (Muy favorable)")
tab Can_opinion if Can_opinion != "Ninguna"

gen Nic_opinion =Q20_4
replace Nic_opinion = "Somewhat or very unfavorable" if (Q20_4 == "1. (Muy desfavorable)" | Q20_4 == "2. (Algo desfavorable)")
replace Nic_opinion = "Neutral" if Q20_4 == "3. (Neutral)"
replace Nic_opinion = "Somewhat or very favorable" if (Q20_4 == "4. (Algo favorable)" | Q20_4 =="5. (Muy favorable)")
tab Nic_opinion if Nic_opinion != "Ninguna"



//Consumers' opinions of characteristics of products labeled with Geographic Indication (GI)
gen GI_Highquality = Q26_1
replace GI_Highquality = "Disagree or totally disagree" if (Q26_1 == "1. (Totalmente en desacuerdo)" | Q26_1 == "2.")
replace GI_Highquality = "Neutral" if Q26_1 == "3. (Neutral)"
replace GI_Highquality = "Agree or totally agree" if (Q26_1 == "4." | Q26_1 =="5. (Totalmente de acuerdo)")
tab GI_Highquality if GI_Highquality != "Ninguna"

gen GI_Constantquality = Q26_2
replace GI_Constantquality = "Disagree or totally disagree" if (Q26_2 == "1. (Totalmente en desacuerdo)" | Q26_2 == "2.")
replace GI_Constantquality = "Neutral" if Q26_2 == "3. (Neutral)"
replace  GI_Constantquality = "Agree or totally agree" if (Q26_2 == "4." | Q26_2 =="5. (Totalmente de acuerdo)")
tab GI_Constantquality if  GI_Constantquality != "Ninguna"

gen GI_Authenticity = Q26_3
replace GI_Authenticity = "Disagree or totally disagree" if (Q26_3 == "1. (Totalmente en desacuerdo)" | Q26_3 == "2.")
replace GI_Authenticity = "Neutral" if Q26_3 == "3. (Neutral)"
replace GI_Authenticity = "Agree or totally agree" if (Q26_3 == "4." | Q26_3 =="5. (Totalmente de acuerdo)")
tab GI_Authenticity if GI_Authenticity != "Ninguna"

gen GI_Exclusivity = Q26_4
replace GI_Exclusivity = "Disagree or totally disagree" if (Q26_4 == "1. (Totalmente en desacuerdo)" | Q26_4 == "2.")
replace GI_Exclusivity = "Neutral" if Q26_4 == "3. (Neutral)"
replace GI_Exclusivity = "Agree or totally agree" if (Q26_4 == "4." | Q26_4 =="5. (Totalmente de acuerdo)")
tab GI_Exclusivity if GI_Exclusivity != "Ninguna"



//Consumers' perceptions of beef quality by country of origin
gen COOL_USqual = Q24_1
replace COOL_USqual = "Poor or very poor" if (Q24_1 == "1. (Pobre calidad)" | Q24_1 == "2.")
replace COOL_USqual = "Fair" if Q24_1 == "3. (Buena calidad)"
replace COOL_USqual = "Good or very good" if (Q24_1 == "4." | Q24_1 =="5. (Excelente calidad)")
tab COOL_USqual if COOL_USqual != "Ninguna"

gen COOL_Mexicoqual = Q24_2
replace COOL_Mexicoqual = "Poor or very poor" if (Q24_2 == "1. (Pobre calidad)" | Q24_2 == "2.")
replace COOL_Mexicoqual = "Fair" if Q24_2 == "3. (Buena calidad)"
replace COOL_Mexicoqual = "Good or very good" if (Q24_2 == "4." | Q24_2 =="5. (Excelente calidad)")
tab COOL_Mexicoqual if COOL_Mexicoqual != "Ninguna"

gen COOL_Canadaqual = Q24_3
replace COOL_Canadaqual = "Poor or very poor" if (Q24_3 == "1. (Pobre calidad)" | Q24_3 == "2.")
replace COOL_Canadaqual = "Fair" if Q24_3 == "3. (Buena calidad)"
replace COOL_Canadaqual = "Good or very good" if (Q24_3 == "4." | Q24_3 =="5. (Excelente calidad)")
tab COOL_Canadaqual if COOL_Canadaqual != "Ninguna"

gen COOL_Nicaraguaqual = Q24_4
replace COOL_Nicaraguaqual = "Poor or very poor" if (Q24_4 == "1. (Pobre calidad)" | Q24_4 == "2.")
replace COOL_Nicaraguaqual = "Fair" if Q24_4 == "3. (Buena calidad)"
replace COOL_Nicaraguaqual = "Good or very good" if (Q24_4 == "4." | Q24_4 =="5. (Excelente calidad)")
tab COOL_Nicaraguaqual if COOL_Nicaraguaqual != "Ninguna"



//Consumers' perceptions of beef quality by US State of origin
gen Texas_beefqual = Q25_1
replace Texas_beefqual = "Poor or very poor" if (Q25_1 == "1. (Pobre calidad)" | Q25_1 == "2.")
replace Texas_beefqual = "Fair" if Q25_1 == "3. (Buena calidad)"
replace Texas_beefqual = "Good or very good" if (Q25_1 == "4." | Q25_1 =="5. (Excelente calidad)")
tab Texas_beefqual if Texas_beefqual != "Ninguna"

gen Nebraska_beefqual = Q25_2
replace Nebraska_beefqual = "Poor or very poor" if (Q25_2 == "1. (Pobre calidad)" | Q25_2 == "2.")
replace Nebraska_beefqual = "Fair" if Q25_2 == "3. (Buena calidad)"
replace Nebraska_beefqual = "Good or very good" if (Q25_2 == "4." | Q25_2 =="5. (Excelente calidad)")
tab Nebraska_beefqual if Nebraska_beefqual != "Ninguna"

gen Kansas_beefqual = Q25_3
replace Kansas_beefqual = "Poor or very poor" if (Q25_3 == "1. (Pobre calidad)" | Q25_3 == "2.")
replace Kansas_beefqual = "Fair" if Q25_3 == "3. (Buena calidad)"
replace Kansas_beefqual = "Good or very good" if (Q25_3 == "4." | Q25_3 =="5. (Excelente calidad)")
tab Kansas_beefqual if Kansas_beefqual != "Ninguna"

gen California_beefqual = Q25_4
replace California_beefqual = "Poor or very poor" if (Q25_4 == "1. (Pobre calidad)" | Q25_4 == "2.")
replace California_beefqual = "Fair" if Q25_4 == "3. (Buena calidad)"
replace California_beefqual = "Good or very good" if (Q25_4 == "4." | Q25_4 =="5. (Excelente calidad)")
tab California_beefqual if California_beefqual != "Ninguna"

gen Oklahoma_beefqual = Q25_5
replace Oklahoma_beefqual = "Poor or very poor" if (Q25_5 == "1. (Pobre calidad)" | Q25_5 == "2.")
replace Oklahoma_beefqual = "Fair" if Q25_5 == "3. (Buena calidad)"
replace Oklahoma_beefqual = "Good or very good" if (Q25_5 == "4." | Q25_5 =="5. (Excelente calidad)")
tab Oklahoma_beefqual if Oklahoma_beefqual != "Ninguna"


****************************************************************************************************************************************************************************

//STEP 3: Data wrangling 

// Number of observations
gen obs = .
forvalues i = 1/`=_N' {
    replace obs = `i' if _n == `i'
    replace obs = obs[_n-1]+1 if _n > `i'
}


// Generate 12 choice sets with 3 alternatives each
foreach i in Alta Altb Altc Altd Alte Altf Altg Alth Alti Altj Altk Altl {
    gen `i'1 = 1
    gen `i'2 = 2
    gen `i'3 = 3
}


// transpose the matrix of alternatives
reshape long Alt, i(obs) j(Q) string


// Generate sets=12
gen Set = 12
local letters = "abcdefghijkl"

forval i = 1/12 {
    local l = substr("`letters'", `i', 1)
    replace Set = `i' if Q == "`l'1" | Q == "`l'2" | Q == "`l'3"
}


// Generate Choice
gen Choice = 0
forvalues i = 1/3 {
	replace Choice=1 if (Set==1) & (Block==`i') & (Q=="a1") & (Q30=="Opción 1")
	replace Choice=1 if (Set==1) & (Block==`i') & (Q=="a2") & (Q30=="Opción 2") 
	replace Choice=1 if (Set==1) & (Block==`i') & (Q=="a3")& (Q30=="Ninguno") 
	replace Choice=1 if (Set==2) & (Block==`i') & (Q=="b1") & (Q32=="Opción 1")
	replace Choice=1 if (Set==2) & (Block==`i') & (Q=="b2") & (Q32=="Opción 2") 
	replace Choice=1 if (Set==2) & (Block==`i') & (Q=="b3")& (Q32=="Ninguno") 
	replace Choice=1 if (Set==3) & (Block==`i') & (Q=="c1") & (Q34=="Opción 1")
	replace Choice=1 if (Set==3) & (Block==`i') & (Q=="c2") & (Q34=="Opción 2") 
	replace Choice=1 if (Set==3) & (Block==`i') & (Q=="c3") & (Q34=="Ninguno") 
	replace Choice=1 if (Set==4) & (Block==`i') & (Q=="d1") & (Q36=="Opción 1")
	replace Choice=1 if (Set==4) & (Block==`i') & (Q=="d2") & (Q36=="Opción 2") 
	replace Choice=1 if (Set==4) & (Block==`i') & (Q=="d3") & (Q36=="Ninguno") 
	replace Choice=1 if (Set==5) & (Block==`i') & (Q=="e1") & (Q38=="Opción 1")
	replace Choice=1 if (Set==5) & (Block==`i') & (Q=="e2") & (Q38=="Opción 2") 
	replace Choice=1 if (Set==5) & (Block==`i') & (Q=="e3") & (Q38=="Ninguno") 
	replace Choice=1 if (Set==6) & (Block==`i') & (Q=="f1") & (Q40=="Opción 1")
	replace Choice=1 if (Set==6) & (Block==`i') & (Q=="f2") & (Q40=="Opción 2") 
	replace Choice=1 if (Set==6) & (Block==`i') & (Q=="f3") & (Q40=="Ninguno") 
	replace Choice=1 if (Set==7) & (Block==`i') & (Q=="g1") & (Q42=="Opción 1")
	replace Choice=1 if (Set==7) & (Block==`i') & (Q=="g2") & (Q42=="Opción 2") 
	replace Choice=1 if (Set==7) & (Block==`i') & (Q=="g3") & (Q42=="Ninguno") 
	replace Choice=1 if (Set==8) & (Block==`i') & (Q=="h1") & (Q44=="Opción 1")
	replace Choice=1 if (Set==8) & (Block==`i') & (Q=="h2") & (Q44=="Opción 2") 
	replace Choice=1 if (Set==8) & (Block==`i') & (Q=="h3") & (Q44=="Ninguno")
	replace Choice=1 if (Set==9) & (Block==`i') & (Q=="i1") & (Q46=="Opción 1")
	replace Choice=1 if (Set==9) & (Block==`i') & (Q=="i2") & (Q46=="Opción 2") 
	replace Choice=1 if (Set==9) & (Block==`i') & (Q=="i3") & (Q46=="Ninguno") 
	replace Choice=1 if (Set==10) & (Block==`i') & (Q=="j1") & (Q48=="Opción 1")
	replace Choice=1 if (Set==10) & (Block==`i') & (Q=="j2") & (Q48=="Opción 2") 
	replace Choice=1 if (Set==10) & (Block==`i') & (Q=="j3") & (Q48=="Ninguno") 
	replace Choice=1 if (Set==11) & (Block==`i') & (Q=="k1") & (Q50=="Opción 1")
	replace Choice=1 if (Set==11) & (Block==`i') & (Q=="k2") & (Q50=="Opción 2") 
	replace Choice=1 if (Set==11) & (Block==`i') & (Q=="k3") & (Q50=="Ninguno") 
	replace Choice=1 if (Set==12) & (Block==`i') & (Q=="l1") & (Q52=="Opción 1")
	replace Choice=1 if (Set==12) & (Block==`i') & (Q=="l2") & (Q52=="Opción 2") 
	replace Choice=1 if (Set==12) & (Block==`i') & (Q=="l3") & (Q52=="Ninguno") 
}

* Save it
save "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/data2.dta", replace



****************************************************************************************************************************************************************************

//STEP 4: Merge the Dataset with the experimental design and save it (*.dta)


* 4.1 Import the original experimental design, either in .xlsx or .dta format
use "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data/exp_design.dta", clear

* 4.2 Create dummy variables for each stage of the supply chain and rename them
tab born, gen(dummy_born)
rename dummy_born1 Born_mx
rename dummy_born2 Born_us
rename dummy_born3 Born_tx
rename dummy_born4 Born_can
rename dummy_born5 Born_nic

tab raised, gen(dummy_raised)
rename dummy_raised1 Raised_mx
rename dummy_raised2 Raised_us
rename dummy_raised3 Raised_tx
rename dummy_raised4 Raised_can
rename dummy_raised5 Raised_nic

tab slaughtered, gen(dummy_slaughtered)
rename dummy_slaughtered1 Slaughtered_mx
rename dummy_slaughtered2 Slaughtered_us
rename dummy_slaughtered3 Slaughtered_tx
rename dummy_slaughtered4 Slaughtered_can
rename dummy_slaughtered5 Slaughtered_nic

tab fsafety, gen(dummy_fsafety)
rename dummy_fsafety1 Fsafety // 0=Standard; 1=Enhanced
drop dummy_fsafety2

tab prod, gen(dummy_prod)
rename dummy_prod2 Prod // 0=Approved; 1=Natural production practices
drop dummy_prod1

* 4.3 Save it
save "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/design2.dta", replace

* 4.4 Create a new set of variables
//First, generate the new rows
clear 
input block set alt born raised slaughtered price fsafety prod 
0 0 3 0 0 0 0 0 0 0
end

//Next, use the `expand` command to add the 36 new rows
expand 36

//Iterate the variable block, assigning values of 1,2,3
replace block = int((_n-1)/12) +1

//Iterate the variable set, assigning values of 1 up to 12
replace set = 1 + (mod( _n-1, 12 ) )


//Save the new dataset
save "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/blank_design.dta", replace

* 4.5 Use the function append to merge horizontally the two databases for design
use "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/blank_design.dta", clear
append using "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/design2.dta"

* 4.6  Rename the variables, generate the variable ASC (none option), fill up all the missing values with zeros, and drop unnecessary variables 
rename block Block 
rename set Set
rename alt Alt
rename price Price

replace Price=150 if Price==1
replace Price=220 if Price==2
replace Price=280 if Price==3
replace Price=350 if Price==4

foreach var of varlist * {
	replace `var' = 0 if missing(`var')
}

sort Block Set Alt

gen ASC = 0
replace ASC =1 if Alt ==3

drop born
drop raised
drop slaughtered
drop fsafety
drop prod

order Block Set Alt ASC Born_mx Born_us Born_tx Born_can Born_nic Raised_mx Raised_us Raised_tx Raised_can Raised_nic Slaughtered_mx Slaughtered_us Slaughtered_tx Slaughtered_can Slaughtered_nic Price Fsafety Prod

* 4.7 Save the new data set 
save "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/design3.dta", replace

* 4.8 Merge the dataset with the experimental design
use "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/data2.dta", clear
merge m:1 Block Set Alt using "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/design3.dta"

sort  obs Block Set Alt
drop if Block == . // 0 obervation deleted

gen CHOICESITUATION = int((_n-1)/3) +1

order CHOICESITUATION obs Block Set Alt Choice ASC Born_mx Born_us Born_tx Born_can Born_nic Raised_mx Raised_us Raised_tx Raised_can Raised_nic Slaughtered_mx Slaughtered_us Slaughtered_tx Slaughtered_can Slaughtered_nic Price Fsafety Prod

* 4.9 Save it
save "/Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/data3.dta", replace // Data updated using Home PC code


****************************************************************************************************************************************************************************

//STEP 5: Estimate the results

use "//Users/memesmacbookair/Library/CloudStorage/OneDrive-TexasTechUniversity/PHD PROGRAM/SUMMER 2023/workshop/data_output/data3.dta", clear


gen PRICEATRIB= (Price/18.9)/2.2 //USD/Lb. Exchange rate = $18.90:1USD

// Conditional logit model
clogit Choice PRICEATRIB ASC Born_us Born_tx Born_can Born_nic Raised_us Raised_tx Raised_can Raised_nic Slaughtered_us Slaughtered_tx Slaughtered_can Slaughtered_nic Fsafety Prod, group(CHOICESITUATION)




