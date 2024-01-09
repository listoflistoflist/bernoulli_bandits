
program define bernoulli_bandits_thompson, rclass

syntax anything [, PROBs(numlist ) NOStats NOLog ANimation]
tokenize `anything'

tempname s H
confirm integer number `1'
confirm integer number `2'
if !(`1' >= 1) {
    di as error "Number of samples must be between greater than 0."
}
if !(`2' >= 1) {
    di as error "Horizon must be between greater than 0."
}
scalar `s' = `1'
scalar `H' = `2'

bernoulli_bandits_set `probs'

tempname best arm_i betas samples k
scalar `best' = .
scalar `k' = `r(k)'

mat `betas' = J(3,`k',.)

local i = 1
while  `i' <=`k' {
mat `betas'[1,`i'] = `i' /* arms */
mat `betas'[2,`i'] = 1 /* alphas*/
mat `betas'[3,`i'] = 1 /* betas*/
local ++i
}


forv t=1/`=`H'-1' {
* Thompson sampling

*mat li `betas'

mat `samples' = J(`s',`k',.)

tokenize `probs'

forv i=1/`=`k'' {
	forv p=1/`=`s'' {
		mat `samples'[`p',`i'] = rbeta(`betas'[2,`i'],`betas'[3,`i'])
	}
	if "`animation'"!="" {
		tw (function y = betaden(`betas'[2,`i'],`betas'[3,`i'],x), range(0.01 0.99) lwidth(medthick)),  xline(``i'', lpattern(dash) lc(black) lwidth(medthick)) ///
	   ytitle(B(`=`betas'[2,`i']',`=`betas'[3,`i']') densities) ylabel(#0, nolabels nogrid) xlabel(, nogrid) xtitle(Share of successes) plotr(m(zero)) /*nodraw*/
	   graph export "figures\beta_posterior_arm_`i'_trial_`t'.png",  replace
	   }
}
mata : st_matrix("`samples'", mean(st_matrix("`samples'"))) 

mat `samples' = `betas' \ `samples'

mat `samples' = `samples''

mata : st_matrix("`samples'", sort(st_matrix("`samples'"), 4))

scalar `best' = `samples'[`k',1]
*di in gr "Best arm = " `=`best''


*Pick the arm with highest sampled estimate
	 qui bernoulli_bandits_draw `=`best'' 1 ,  nol

tempname updates
mat `updates' = r(hits_misses)

forv i=1/`=`k'' {
if `updates'[2,`i']!=.{
mat `betas'[2,`i'] = `betas'[2,`i'] + `updates'[2,`i']
}
if `updates'[3,`i']!=.{
mat `betas'[3,`i'] = `betas'[3,`i'] + `updates'[3,`i']
}
}

}

bernoulli_bandits_draw `=`best'' 1 , `nostats' `nolog'

return add

end



