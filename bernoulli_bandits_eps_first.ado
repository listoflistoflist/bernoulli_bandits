
program define bernoulli_bandits_eps_first, rclass

syntax anything [, PROBs(numlist ) NOStats NOLog]
tokenize `anything'

tempname epsilon H
confirm number `1'
if !(`1' >= 0 & `1' <= 1) {
    di as error "Epsilon must be between 0 and 1."
}
if !(`2' >= 1) {
    di as error "Horizon must be between greater than 0."
}
confirm integer number `2'
scalar `epsilon' = `1'
scalar `H' = `2'

bernoulli_bandits_set `probs'



forv i=1/`r(k)' {
forv t=1/`=`epsilon'*`H'' {
qui bernoulli_bandits_draw `i' 1 ,  nol
}
}


tempname best

scalar `best' = `r(best_arm)'

*select best arm
forv t=1/`=(1-`epsilon')*`H'-1' {
qui bernoulli_bandits_draw `=`best'' 1 , nostats nol
}

bernoulli_bandits_draw `=`best'' 1 , `nostats' `nolog'

return add

end



