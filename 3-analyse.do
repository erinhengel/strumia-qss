estimates clear

********************************************************************************
************************** GENERATE DATA RESTRICTIONS **************************
********************************************************************************
* Keep only papers that:
*		1. Were published in JHEP, Phys. Rev. D, Astophys. J., Phys. Rev. Lett. or Phys. Lett. B;
*		2. Were published between 2010--2016;
*		3. Are solo-authored.
use "data/strumia", clear
keep if JournalID==1613970|JournalID==1214843|JournalID==1213103|JournalID==1214495|JournalID==1613966
keep if PubYear>2009&PubYear<2017
keep if AuthorN==1

********************************************************************************
******************************** Figures in text *******************************
********************************************************************************
* Total sample size.
count
local n = r(N)
count if Female==1
local f = r(N)
noisily display as text "Observation count: " as error `n' as text " (" as error `=`n'-`f'' as text " by men and " as error `f' as text " by women)."

********************************************************************************
********* Figure 1: Distribution of citations for solo-authored papers *********
********************************************************************************
* Regress citations (asinh and raw) on maxT (lifetime "fame"), PubYear (year of
* publication), JournalID (journal ID number), their interaction and MinPubYear
* (year the author first published a paper) separately in male- and female-authored
* papers. Plot the histogram of the residuals (plus the constant)
foreach datatype in asinh raw {
	if "`datatype'"=="asinh" {
		local depvar asinhCite
		local mbins 50
		local fbins 10
		local citations "Residualised citations (asinh)"
		local legend legend(off)
	}
	else {
		local depvar Cite
		local mbins 1000
		local fbins 50
		local citations "Residualised citations"
		local legend legend(label(1 "Male") label(2 "Female") position(2) size(small) symysize(small) symxsize(small))
	}
	tempvar fem_resid man_resid
	reghdfe `depvar' maxT if Female==1, absorb(i.PubYear##i.JournalID MinPubYear) residuals(`fem_resid')
	replace `fem_resid' = `fem_resid' + _b[_cons]
	reghdfe `depvar' maxT if Female==0, absorb(i.PubYear##i.JournalID MinPubYear) residuals(`man_resid')
	replace `man_resid' = `man_resid' + _b[_cons]
	graph twoway ///
		(histogram `man_resid', color(pfblue%50) bin(`mbins')) ///
		(histogram `fem_resid', color(pfpink%50) bin(`fbins')) ///
		, name(adj_`datatype', replace) ///
		scheme(publishing-female) ///
		`legend' ///
		xtitle("`citations'", size(medium)) ///
		ytitle("") ///
		ylabel(, labsize(small)) ///
		xlabel(, labsize(small)) ///
		aspectratio(0.8)
}
graph combine adj_asinh adj_raw, scheme(publishing-female) commonscheme
graph export "figures/distributions.pdf", replace

********************************************************************************
********** Figure 2: Gender differences in citations across journals ***********
********************************************************************************
* Regress citations on female-authorship controlling for PubYear, maxT and
* MinPubYear among the samples of articles published in each journal separately.
* Plot the coefficient on female ratio along with its 95% confidence interval.
matrix b = J(1,6,.)
matrix ses = J(1,6,.)
local i 0
levelsof JournalID, local(ids) clean
foreach journal in `ids' {
	local ++ i
	eststo est_`journal': reghdfe asinhCite i.Female if JournalID==`journal', absorb(PubYear maxT MinPubYear) vce(cluster MinPubYear)
	matrix b[1, `i'] = _b[1.Female]
	matrix ses[1, `i'] = _se[1.Female]
	local colnames `"`colnames' "`: label JournalID `journal''""'
}
eststo est_all: reghdfe asinhCite i.Female, absorb(i.PubYear##i.JournalID maxT MinPubYear) vce(cluster MinPubYear)
noisily display as text "female-authored papers receive about " as error `=round(100*_b[1.Female])' as text " log points more citations than male-authored papers (standard error " as error `=round(100*_se[1.Female], 0.1)' as text ")."
matrix b[1, 6] = _b[1.Female]
matrix ses[1, 6] = _se[1.Female]
matrix colnames b = `colnames' "All"
coefplot matrix(b), ///
	se(ses) ///
	vertical ///
	level(95) ///
	yline(0) ///
	scheme(publishing_female) ///
	name(coef, replace) ///
	ytitle("Female advantage in citations (asinh)", size(small)) ///
	ylabel(, labsize(small)) ///
	xlabel(, labsize(small)) ///
	aspectratio(0.4)
graph export "figures/coeffs.pdf", replace
