
program define bernoulli_bandits_thompson, rclass

syntax anything [, PROBs(numlist ) NOStats NOLog ANimation]
tokenize `anything'

tempname s H N c
confirm integer number `1'
confirm integer number `2'
if !(`1' >= 1) {
    di as error "Number of samples must be between greater than 0."
}
if !(`2' >= 1) {
    di as error "Horizon must be between greater than 0."
}
cap confirm integer number `3'
if _rc!=0 {
		 di in gr "Number of draws assumed to be one."
	local 3 = 1
	}
if _rc==0 {
	if !(`3' >= 1) {
    di as error "Number of draws must be between greater or equal 1."
	}
}
cap confirm integer number `4'
if _rc!=0 {
		 di in gr "No clipping."
	local 4 = 0
	}
if _rc==0 {
	if !(`4' >= 0) {
    di as error "Clipping number must be between greater or equal 0."
	}
}
scalar `s' = `1'
scalar `H' = `2'
scalar `N' = `3'
scalar `c' = `4'



bernoulli_bandits_set `probs'

tempname best arm_i betas samples k max_index weights
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

}
*mat li `samples'
mata: st_matrix("`max_index'", max_index(st_matrix("`samples'")))
mata: st_matrix("`weights'", weights(st_matrix("`max_index'")))

*mat li `max_index'

*mat li `weights'

local draw
forv i=1/`=rowsof(`weights')' {
local draw "`draw' `=`weights'[`i',1]' `=round(max(`N'*`weights'[`i',2],`c'))'"
}

*di "`draw'"

*Pick the arm with highest sampled estimate
	 qui bernoulli_bandits_draw `draw',  nol
	 *bernoulli_bandits_draw `=`best'' 1 ,  nol

tempname updates
mat `updates' = r(hits_misses)

*di "hits_misses "
*mat li r(hits_misses)

local combine
forv i=1/`=`k'' {
if `updates'[2,`i']!=.{
mat `betas'[2,`i'] = `updates'[2,`i']+1
}
if `updates'[3,`i']!=.{
mat `betas'[3,`i'] = `updates'[3,`i']+1
}

*mat li `betas'
*list bandit*

if "`animation'"!="" {
			tw (function y = betaden(`betas'[2,`i'],`betas'[3,`i'],x), range(0.01 0.99) lwidth(medthick)),  xline(``i'', lpattern(dash) lc(black) lwidth(medthick)) ///
		   ytitle(B(`=`betas'[2,`i']',`=`betas'[3,`i']') densities) ylabel(#0, nolabels nogrid) xlabel(, nogrid) xtitle(Share of successes) plotr(m(zero)) saving("figures/`i'_`t'", replace) nodraw/**/
	*	   graph export "figures\beta_posterior_arm_`i'_trial_`t'.png",  replace
	   }
local combine "`combine' figures/`i'_`t'.gph"
}
	if "`animation'"!="" {
		gr combine `combine', xcommon col(1) iscale(1) saving("figures/combine_`t'", replace) 
		graph export "figures\beta_`=`k''_arms_trial_`t'.png",  replace
	}
}

bernoulli_bandits_draw `draw', `nostats' `nolog'

return add

end



mata:
real matrix max_index(real matrix a)
{
rows = rows(a)
row_values = J(rows, 1, .)
    for (j=1; j<=rows; j++) {
real vector i
maxindex(a[j,.],1,i,w) // which arm (index) has maximum of each draw
	row_values[j,1] = i
    }
return(row_values)
}

end

mata:
real matrix weights(real matrix x)
{
 arm = uniqrows(x)    // Get the unique values of x
_sort(x,1)
info=panelsetup(x,1)
//arm,panelsum(J(rows(x),1,1),info) // frequency of a specific arm being the best
weights=arm,panelsum(J(rows(x),1,1),info)/colsum(panelsum(J(rows(x),1,1),info)) // how many times is each arm best among repeated draws
return(weights)
}
end
