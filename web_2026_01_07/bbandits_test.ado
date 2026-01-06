


python:


from bbandits_functions import *

keys = ['Beta_OLS', 'Beta_BOLS_aggregated', 'Z-value', 'P-value', 'CI_lower_bound_95', 'CI_upper_bound_95', 'Treatment_arm_n', 'Reference_arm_n']

end



* test ado file



program bbandits_test

syntax varlist [if] [in] [, Reference_arm(int 0)]

dis "`1'"

local var3 = subinstr("`1'", ",", "", .)
dis "`var3'"

sum `1'

python: reward = Data.get(var="`var3'")



end

