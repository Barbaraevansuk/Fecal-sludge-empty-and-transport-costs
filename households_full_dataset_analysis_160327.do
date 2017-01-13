# delimit;

clear all;
set logtype text;
log close;
log using "paper_fc_wtp_analysis.txt", replace;

set seed 123;

set more off;

/*This do-file analyzes data for paper 2. Only data from Mymensingh District is
used. The econometrics will focus only on this district*/


* -------------------------------------; 
use "C:\Users\s.balasubramanya\Google Drive\irc_bdesh\paper_2\households_full_dataset_160327";
count;

* SETTING CLUSTERS AND PROBABILITY WEIGHTS;
svyset village_name [pweight=s_w];


**NUMBER OF PEOPLE WHO USE A TOILET;

kdensity n_users_toilet, bwidth(0.7) lcolor(black) lwidth(medium) lpattern(solid) 
xtitle(age) title(Number of users per pit latrine);
graph save "latrine_users", replace;

*------------------------------------------------------------*;

*SUMMARY STATISTICS;

summ nfamily i.highest_schooling rings inc nfd
	nfi brickwalls mroof toilet_now tage n_users;

*------------------------------------------------------------*;

* HOW MUCH MONEY WAS SPENT FOR EMPTYING?;
drop taka_paid_hat_xb taka_paid_hat_se;
svy: regress taka_paid nfamily i.highest_schooling rings inc 
	nfd nfi brickwalls mroof tage
	if (hired_sweeper==1 & q27==1);
predict taka_paid_hat_xb, xb;
predict taka_paid_hat_se, stdp;
summ taka_paid_hat_xb taka_paid_hat_se if (hired_sweeper==1 & q27==1);

*------------------------------------------------------------*;

*WHAT METHOD OF PIT EMPTYING WOULD YOU USE IN THE FUTURE;

drop will_hire_sweeper_hat_xb will_hire_sweeper_hat_se;
svy: regress will_hire_sweeper nfamily i.highest_schooling rings inc 
	nfd nfi brickwalls mroof tage if toilet_now==1;
predict will_hire_sweeper_hat_xb, xb;
predict will_hire_sweeper_hat_se, stdp;
summ will_hire_sweeper_hat_xb will_hire_sweeper_hat_se;

*------------------------------------------------------------*;
*------------------------------------------------------------*;
* WILLINGNESS TO PAY FOR EMPTYING + TAKING SLUDGE AWAY FROM HOME;

*------------------------------------------------------------*;
drop check;

gen check=.;
replace check=1 if base_bid==400 & base_bid_response==1 & higher_bid==600 & higher_bid_response~=. & lower_bid==300 & lower_bid_response==.;
replace check=1 if base_bid==600 & base_bid_response==1 & higher_bid==700 & higher_bid_response~=. & lower_bid==400 & lower_bid_response==.;
replace check=1 if base_bid==700 & base_bid_response==1 & higher_bid==800 & higher_bid_response~=. & lower_bid==600 & lower_bid_response==.;
replace check=1 if base_bid==800 & base_bid_response==1 & higher_bid==1000 & higher_bid_response~=. & lower_bid==700 & lower_bid_response==.;

replace check=1 if base_bid==400 & base_bid_response==2 & lower_bid==300 & lower_bid_response~=. & higher_bid==600 & higher_bid_response==.;
replace check=1 if base_bid==600 & base_bid_response==2 & lower_bid==400 & lower_bid_response~=. & higher_bid==700 & higher_bid_response==.;
replace check=1 if base_bid==700 & base_bid_response==2 & lower_bid==600 & lower_bid_response~=. & higher_bid==800 & higher_bid_response==.;
replace check=1 if base_bid==800 & base_bid_response==2 & lower_bid==700 & lower_bid_response~=. & higher_bid==1000 & higher_bid_response==.;


*------------------------------------------------------------*;
*MATRIX OF PEOPLE'S RESPONSES*;

*YES/NO;
count if base_bid ==400 & base_bid_response==1 & higher_bid==600 & higher_bid_response==0;
count if base_bid ==600 & base_bid_response==1 & higher_bid==700 & higher_bid_response==0;
count if base_bid ==700 & base_bid_response==1 & higher_bid==800 & higher_bid_response==0;
count if base_bid ==800 & base_bid_response==1 & higher_bid==1000 & higher_bid_response==0;

*NO/YES;

count if base_bid ==400 & base_bid_response==0 & lower_bid==300 & lower_bid_response==1;
count if base_bid ==600 & base_bid_response==0 & lower_bid==400 & lower_bid_response==1;
count if base_bid ==700 & base_bid_response==0 & lower_bid==600 & lower_bid_response==1;
count if base_bid ==800 & base_bid_response==0 & lower_bid==700 & lower_bid_response==1;

*NO/NO;

count if base_bid ==400 & base_bid_response==0 & lower_bid==300 & lower_bid_response==0;
count if base_bid ==600 & base_bid_response==0 & lower_bid==400 & lower_bid_response==0;
count if base_bid ==700 & base_bid_response==0 & lower_bid==600 & lower_bid_response==0;
count if base_bid ==800 & base_bid_response==0 & lower_bid==700 & lower_bid_response==0;

*YES/YES;
count if base_bid ==400 & base_bid_response==1 & higher_bid==600 & higher_bid_response==1;
count if base_bid ==600 & base_bid_response==1 & higher_bid==700 & higher_bid_response==1;
count if base_bid ==700 & base_bid_response==1 & higher_bid==800 & higher_bid_response==1;
count if base_bid ==800 & base_bid_response==1 & higher_bid==1000 & higher_bid_response==1;

*------------------------------------------------------------*;
*------------------------------------------------------------*;

*------------------------------------------------------------*;
*------------------------------------------------------------*;
**SETTING THE STAGE FOR A CONTINGENT VALUATION APPROACH TO ESTIMATE WTP **;

svy: mean nfamily inc nfd nfi brickwalls mroof tage rings highest15 highest610
	highest1112 highest13;

scalar nfamily_m = 4.58;
scalar inc_m = 1261.25;
scalar nfd_m = 1.16;
scalar nfi_m = 0.66;
scalar brickwalls_m = 0.69;
scalar mroof_m = 0.98;
scalar tage_m = 4.01;
scalar rings_m = 2.40;
scalar highest15_m = 0.38;
scalar highest610_m = 0.46;
scalar highest1112_m = 0.08;
scalar highest13_m = 0.05; 

*------------------------------------------------------------*;
*------------------------------------------------------------*;
**CALCULATING WTP USING A SINGLE BID DC RESPONSE;
svy: probit base_bid_response base_bid nfamily i.highest_schooling rings inc 
	nfd nfi brickwalls mroof tage if toilet_now==1;
est store ml;
mcp base_bid, ci show;
est drop ml;

svy: probit base_bid_response base_bid nfamily rings inc 
	nfd nfi brickwalls mroof tage highest15 highest610 highest1112 highest13
	if toilet_now==1;

nlcom (WTP:-(_b[_cons] + nfamily_m*_b[nfamily] + rings_m*_b[rings]
	+ inc_m*_b[inc] + nfd_m*_b[nfd] + nfi_m*_b[nfi] + brickwalls_m*_b[brickwalls]
	+ mroof_m*_b[mroof] + tage_m*_b[tage] + highest15_m*_b[highest15]
	+ highest610_m*_b[highest610] + highest1112_m*_b[highest1112]
	+ highest13_m*_b[highest13])/_b[base_bid]), noheader;
	
*------------------------------------------------------------*;
*------------------------------------------------------------*;
**CALCULATING WTP USING A DOUBLE-BID DC RESPONSE ***;
doubleb base_bid next_bid base_bid_response next_bid_response 
	nfamily rings inc nfd nfi 
	brickwalls mroof tage highest15 highest610 highest1112 highest13
	if (toilet_now==1) [pweight=s_w];

nlcom (WTP:(_b[_cons] + nfamily_m*_b[nfamily] + rings_m*_b[rings]
	+ inc_m*_b[inc] + nfd_m*_b[nfd] + nfi_m*_b[nfi] + brickwalls_m*_b[brickwalls]
	+ mroof_m*_b[mroof] + tage_m*_b[tage] + highest15_m*_b[highest15]
	+ highest610_m*_b[highest610] + highest1112_m*_b[highest1112]
	+ highest13_m*_b[highest13])), noheader;

*------------------------------------------------------------*;
bootstrap WTP=( _b[_cons] + nfamily_m*_b[nfamily] + rings_m*_b[rings] + inc_m*_b[inc]
	+ nfd_m*_b[nfd] + nfi_m*_b[nfi] + brickwalls_m*_b[brickwalls] + mroof_m*_b[mroof]
	+ tage_m*_b[tage] + highest15_m*_b[highest15] + highest610_m*_b[highest610] 
	+ highest1112_m*_b[highest1112] + highest13_m*_b[highest13] ), 
	 reps(100) cluster(village_name): 
	doubleb base_bid next_bid base_bid_response next_bid_response nfamily rings 
	inc nfd nfi brickwalls mroof tage highest15 highest610 highest1112 highest13 
	if (toilet_now==1);

estat bootstrap, all;


*------------------------------------------------------------*;
* svyset village_name, bsrweight(s_w) vce(linearized) singleunit(missing);
 
* svy bootstrap WTP=( _b[_cons] + nfamily_m*_b[nfamily] + rings_m*_b[rings] + inc_m*_b[inc]
	+ nfd_m*_b[nfd] + nfi_m*_b[nfi] + brickwalls_m*_b[brickwalls] + mroof_m*_b[mroof]
	+ tage_m*_b[tage] + highest1112_m*_b[highest1112] + highest13_m*_b[highest13] ): 
	doubleb base_bid next_bid base_bid_response next_bid_response nfamily rings 
	inc nfd nfi brickwalls mroof tage highest1112 highest13 
	if (toilet_now==1);
* estat bootstrap, all;
*------------------------------------------------------------*;


log close;

