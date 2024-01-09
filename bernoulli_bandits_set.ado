
program define bernoulli_bandits_set, rclass

syntax anything
local probabilities `anything'
tokenize `anything'

local i = 1
while "``i''" != "" {
confirm number ``i''
*di _rc
*di ``i''
cap   generate byte bandit`i' = rbinomial(1, ``i'')
local ++i
}

 // make sure global is not defined
    capture assert mi(`"$probabilities"')
    if ( _rc ) {
        display as err "global macro probabilities already defined"
        exit 498
    }
global BBandits_probabilities `probabilities'

return local probabilities  `probabilities'
return local k  `=`i'-1'
end



