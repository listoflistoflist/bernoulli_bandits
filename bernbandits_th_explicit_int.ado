
program define bernbandits_th_explicit_int, rclass

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
di "alphas betas"
mat li `betas'
di "Updates"
cap mat li `updates'


forv i=1/`=`k'' {

mata
q2 = Quadrature()
 real scalar f11(real scalar x, real scalar a, real scalar b) { 
	return(betaden(a,b,x))
 }
 real scalar f12(real scalar x, real scalar a, real scalar b) { 
	return(ibeta(a,b,x))
 }
 
 q2.setArgument(1, 5)
 q2.setArgument(2, 5)
 q2.setEvaluator(&f11())
 q2.setLimits((0,1))
 q2.setAbstol(1e-15)
 q2.setReltol(1e-12)
 
 st_numscalar("myx", q2.integrate())
end
	
display myx	
	
betaden(`betas'[2,`i'],`betas'[3,`i'],x)



	
}


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



