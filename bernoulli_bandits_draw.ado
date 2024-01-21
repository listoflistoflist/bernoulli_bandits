


program define bernoulli_bandits_draw, rclass

syntax anything [, NOStats NOLog]
tokenize `anything'
local i = 1

while "``i''" != "" {
local ++i
}
local length `=(`i'-1)/2'

tempname arms_obs probs

mat `arms_obs' = J(3,`length',.)
local i = 1
local j = 1

while "``i''" != "" {
if mod(`i',2)==1 {
confirm integer number ``i''
mat `arms_obs'[1,`j']=``i'' 
local ++j
}
*di _rc


if mod(`i',2)==0 {
confirm number ``i''
mat `arms_obs'[2,`=`j'-1']=``i'' 
}
*di _rc

local ++i
}

*mat li `arms_obs'

tokenize $BBandits_probabilities
/*assign probab to arms*/
local i = 1
while "``i''" != "" {
confirm number ``i''
local ++i
}
local k  `=`i'-1'

mat `probs' = J(2,`k',.)
local i = 1
while `i'<=`k' {
mat `probs'[1,`=`i'']=`i'
mat `probs'[2,`=`i'']=``i''
*di `i'
local ++i
}
*mat li `probs'

// Iterate over columns in selected arms (the smaller matrix)
forval j = 1/`=colsof(`arms_obs')' {
    // Iterate over columns in true probability of all arms (the larger matrix)
    forval i = 1/`=colsof(`probs')' {
        // Check if the numbers for the arms in row 1 of `arms_obs' and `probs' are the same for the current column
        if `arms_obs'[1, `j'] == `probs'[1, `i'] {
            // If they are the same, update the values in row 3 of `arms_obs' with the values from row 2 of `probs'
            matrix `arms_obs'[3, `j'] = `probs'[2, `i']
        }
    }
}



mat `arms_obs' = `arms_obs''
mata : st_matrix("`arms_obs'", sort(st_matrix("`arms_obs'"), 2))
*mat li `arms_obs'

local N = _N

forv i=1/`length' {
if "`nolog'"=="" {
set obs `=`N'+`arms_obs'[`i',2]'
}
if "`nolog'"!="" {
qui set obs `=`N'+`arms_obs'[`i',2]'
}
if `N'<_N {
if "`nolog'"=="" {
    replace bandit`=`arms_obs'[`i',1]' = rbinomial(1, `=`arms_obs'[`i',3]') in `=`N'+1'/`=_N'
}
if "`nolog'"!="" {
qui    replace bandit`=`arms_obs'[`i',1]' = rbinomial(1, `=`arms_obs'[`i',3]') in `=`N'+1'/`=_N'

}
}
}

if "`nostats'"=="" {
banditstats
return add
}

return local probabilities `r(probabilities)'
return local k  `k'
end

program define banditstats, rclass

if _N>0 {
tokenize $BBandits_probabilities
/*assign probab to arms*/

tempvar pulls_total cum_exp_regret maxarm maxreward

local i = 1
scalar `pulls_total' = 0
local probs_actual 0
while "``i''" != "" {
confirm number ``i''
tempvar b`i' pulls`i' share_arm`i' share_successes`i' N`i'
qui tab bandit`i', matcell(`b`i'')
scalar `N`i''=r(N) 
 if `N`i''>0 {
 	 if `b`i''[1,1]~=. {
		scalar `pulls`i'' = `b`i''[1,1]
	 }
  	 if `b`i''[2,1]~=. {
		scalar `pulls`i'' = `pulls`i'' + `b`i''[2,1]
	 }
  	 if `b`i''[1,1]==. {
	 	*di `i'
		mat `b`i''[1,1]=0
	 }
  	 if `b`i''[2,1]==. & `=rowsof(`b`i'')>1' {
	 	*di `i'
		mat `b`i''[2,1]=0
	 }
  	 if `=rowsof(`b`i'')==1' {
		mat `b`i'' = `b`i'' \ .
		qui count if bandit`i'==1
		mat `b`i''[2,1]=r(N) /*Hits*/
		qui count if bandit`i'==0
		mat `b`i''[1,1]=r(N) /*Misses*/
	 }
	 
scalar `pulls_total' = `pulls_total' + `pulls`i''
local probs_actual `probs_actual', ``i''
}
local ++i
}
local k  `=`i'-1'

local i = 1
while "``i''" != "" {
if `N`i''>0 {
if max(`probs_actual')==``i'' {
scalar `maxarm' = `i' 
scalar `maxreward' = ``i'' 
}
}
local ++i
}

*Expected-payoff regret. This is the same measure as expected-expected regret, but without an expectation on the right hand term. That is, the actually received reward is used rather than the expectation of the selected arm.
scalar `cum_exp_regret' = max(`probs_actual')*`pulls_total'-`pulls`=scalar(`maxarm')''*`=`b`=scalar(`maxarm')''[2,1]/`pulls`=scalar(`maxarm')'''

*Expected-expected regret. This is the difference in the payoff of the selected arm, in expectation over the distribution of that arm, and the payoff of the optimal arm as given by a prescient oracle, in expectation over the distribution of that arm. Importantly, this measure includes no unnecessary variation, but cannot be computed without a complete understanding of the definition of all arms.

if `=scalar(`cum_exp_regret')'==. {
scalar `cum_exp_regret' = max(`probs_actual')*`pulls_total'-`pulls`=scalar(`maxarm')''*`maxreward'	
}

*This is the sum over all pulls of the difference between the best bandit's probability of success and the bandit actually chosen.  Smaller is better, but the algorithm may explore other bandits at the risk of increasing regret in the hopes of finding a 'better' bandit.  This is especially true when the simulation has just started, as it has no information on any of the bandits.

tempname emp_best_arm best_arm hits_misses

mat `emp_best_arm' = J(2,`k',.)
mat `hits_misses' = J(3,`k',.)

di _n  
di in gr "Cumulative Regret: " in ye %10.2f `cum_exp_regret'  in gr " after " in ye `pulls_total' in gr " pulls (minimum asymptotic regret is 0)" /*can be negative in small samples if share of successes exceeds actual probability */

di in smcl in gr "{hline 78}"
local i = 1
while "``i''" != "" {
if `N`i''>0 {
di _skip(8) in gr "Share arm " in ye `i' in gr " played: " in ye %10.2f  `=`pulls`i''/`pulls_total''
*di `pulls`i''
*di `pulls_total'
di  _skip(22) in gr "Hits: " in ye %10.0f  `b`i''[2,1]
di _skip(19) in gr " Misses: " in ye %10.0f  `b`i''[1,1]
mat `hits_misses'[1,`i'] = `i' 
mat `hits_misses'[2,`i'] = `b`i''[2,1] 
mat `hits_misses'[3,`i'] = `b`i''[1,1] 
di _skip(7) in gr " Share of successes: " in ye %10.3f  `=`b`i''[2,1]/`pulls`i'''
mat `emp_best_arm'[1,`i']=`i'
mat `emp_best_arm'[2,`i']=`=`b`i''[2,1]/`pulls`i'''
return scalar share_successes_b`i' = `=`b`i''[2,1]/`pulls`i'''
di _skip(0) in gr " Actual prob. of successes: " in ye %10.3f  ``i''
di _n  
}
local ++i
}

mat `emp_best_arm' = `emp_best_arm''
*mat li `emp_best_arm'
mata : st_matrix("`emp_best_arm'", sort(st_matrix("`emp_best_arm'"), 2))
scalar `best_arm' = `emp_best_arm'[`=rowsof(`emp_best_arm')',1]

*di `best_arm'

return scalar best_arm = `best_arm'
return local probabilities  `probabilities'
return local k  `=`i'-1'
}
else {
	di in gr "no observations"
}

return scalar cum_exp_regret = `cum_exp_regret'
return scalar pulls_total = `pulls_total'
return matrix hits_misses = `hits_misses'
end

