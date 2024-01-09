
program define bernoulli_bandits_eps_greedy, rclass

syntax anything [, PROBs(numlist ) NOStats NOLog]
tokenize `anything'

tempname epsilon decay H
confirm number `1'
if !(`1' >= 0 & `1' <= 1) {
    di as error "Epsilon must be between 0 and 1."
}
if !(`2' >= -1 ) {
    di as error "Decay rate must be between 0 and 1."
}
if !(`3' >= 1) {
    di as error "Horizon must be between greater than 0."
}
confirm  number `1'
confirm  number `2'
confirm  integer number `3'
scalar `epsilon' = `1'
scalar `decay' = `2'
scalar `H' = `3'

bernoulli_bandits_set `probs'

tempname best arm_i
scalar `best' = .


forv t=1/`=`H'-1' {
* epsilon greedy 
* explore with epsilon/t
if runiform() < `=min(1,`epsilon'/(`t'^`decay'))' | `best'==. {
	scalar `arm_i' = runiformint(1,`r(k)')
	 qui bernoulli_bandits_draw `=`arm_i'' 1 ,  nol	
}
else {
	*select best arm
	 qui bernoulli_bandits_draw `=`best'' 1 ,  nol
}
*di in gr "Best arm =" `=`best''
*di "epsilon/t^`=`decay'' =" `=min(1,`epsilon'/(`t'^`decay'))'

scalar `best' = `r(best_arm)'

}

bernoulli_bandits_draw `=`best'' 1 , `nostats' `nolog'

return add

end



