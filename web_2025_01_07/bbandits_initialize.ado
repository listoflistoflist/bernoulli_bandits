

python:


from bbandits_functions import *

keys = ['Beta_OLS', 'Beta_BOLS_aggregated', 'Z-value', 'P-value', 'CI_lower_bound_95', 'CI_upper_bound_95', 'Treatment_arm_n', 'Reference_arm_n']

end


program bbandits_initialize
version 17
syntax [, Batches(int 3) Arms(int 2) Exploration_phase(int 1) SAE]

if ("`sae'" == ""){
	python: df = Data.getAsDict()
	python: df = pd.DataFrame(df)
	python: print(df)
	python: df = intialize(df, batches= `batches', arms = `arms', exploration = `exploration_phase')
}
if ("`sae'" != ""){
	
	python: df = Data.getAsDict()
	python: df = pd.DataFrame(df)
	*python: print(df)
	python: res = esfandiari_batch_size_intialize(df, arms = `arms', batch= `batches')
	python: df = res["df"]
	python: print(f"The active arms for the next round are the following: {res["active_arms"]}")
	python: active_arms_stata = " ".join(str(x) for x in res["active_arms"])
	python: print(active_arms_stata)
	python: Macro.setGlobal('active_arms_macro', active_arms_stata)	
	
}
*python: print(df)
*** Add the chosen_arm_numeric label variable to the dataframe
python: codes = pd.Categorical(df["chosen_arm"], ordered=True).codes
python: df["chosen_arm_numeric"] = codes


*python: df["chosen_arm_numeric"] = pd.factorize(df['chosen_arm'])[0]
python: df.loc[df['chosen_arm_numeric'] == -1, 'chosen_arm_numeric' ] = np.nan

*** Initialize variables in stata
capture drop chosen_arm 
capture drop reward 
capture drop batch
gen reward = .
gen chosen_arm = .
gen batch = .
gen chosen_arm_numeric = .

python: Data.store("reward", None, df['reward'], None)
python: Data.store("chosen_arm", None, df['chosen_arm'], None)
python: Data.store("batch", None, df['batch'], None)
python: Data.store("chosen_arm_numeric", None, df["chosen_arm_numeric"], None)




end