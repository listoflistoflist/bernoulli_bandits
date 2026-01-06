{smcl}
{* *! version 17.0 27jun2024}{...}
{viewerdialog bbandits_update "dialog bbandits_update"}{...}
{viewerjumpto "Syntax" "bbandits_update##syntax"}{...}
{viewerjumpto "Description" "bbandits_update##description"}{...}
{viewerjumpto "Options" "bbandits_update##options"}{...}
{viewerjumpto "Examples" "bbandits_update##examples"}{...}

{p2col:{bf:bbandits_update}} Update a multi-armed bandit experiment

{marker syntax}{...}
{title:Syntax}
{p}
{cmd:bbandits_update} {it:varlist} [, {it:thompson} {it:greedy} {it:sae} {it:clipping(real 0.05)} {it:epsilon(real 0.1)} {it:active_arms(numlist)} {it:batch_sae(int)} {it:excel}]

{marker description}{...}
{title:Description}
{pstd}
{cmd:bbandits_update} updates the data structure for running a multi-armed bandit experiment based on the provided reward, chosen arm, and batch variables.
The chosen arm variable is required to be numeric. It is recommended to number the arms with integers starting from 0 up to arm k.
The command implements re-encoding of chosen arm values, performing the specified updating algorithm (Thompson Sampling, Epsilon-Greedy or Sequential arm elimination), and preparing the data for the next batch.

{pstd}
The program performs the following steps:

{phang2}
1. Re-encodes the chosen arm variable to be zero-indexed. 

{phang2}
2. Preprocesses data for the specified updating algorithm (Thompson Sampling, Epsilon-Greedy or Sequential Arm elimination).

{phang2}
3. Applies the algorithm within a python function (Python installation necessary for this program).

{phang2}
4. Stores the updated variables back into the Stata dataset.

{phang2}
5. Optionally exports the dataset to an Excel file if the {opt Excel} option is specified.

{pstd}
The underlying algorithms are implemented in Python; therefore, a Python installation is necessary. The clipping rate or epsilon rate
has to be sufficiently high so that each arm is at least played once, otherwise for the respective batch the BOLS estimate is not defined.

{marker options}{...}
{title:Options}
{phang}
{opt t:hompson} specifies Bernoulli Thompson sampling algorithm.

{phang}
{opt g:reedy} specifies the epsilon-greedy algorithm.

{phang}
{opt sae} specifies the Sequential Arm Elimination (SAE) algorithm which is an implementation of the algorithm presented in Esfandiari et al. (2021, p. 7343).

{phang}
{opt c:lipping(real)} specifies the clipping rate for the Bernoulli Thompson algorithm. The default value is 0.05.

{phang}
{opt e:ps(real)} specifies the epsilon rate for the epsilon-greedy algorithm. The default value is 0.1.

{phang}
{opt active_arms(numlist)} specifies the number of active arms according to the sequential elimination algorithm (sae) formatted as a numlist (e.g. 0 2 3 7). 
It is a required input for the sae algorithm. In the initial stage all available arms are active. The numeric index saved in the column "chosen_arm_numeric" should be used 
to specify the respective arms. 

{phang}
{opt ex:cel("path")} indicates that the updated data is saved as an Excel file under the specified path. The saved file can be used to impute the newly observed rewards.

{marker examples}{...}
{title:Examples}
{hline}
{pstd}
Update the multi-armed bandit experiment using the Thompson Sampling algorithm:

{phang2}{cmd: bbandits_update reward chosen_arm batch, thompson}

{pstd}
Update the multi-armed bandit experiment using the epsilon-Greedy algorithm with specified epsilon and seed:

{phang2}{cmd: bbandits_update reward chosen_arm batch, greedy epsilon(0.2)}

{pstd}
Update according to the sequential arm elimination algorithm. It saves a numlist of the active arms in a macro so that it can be used for further analysis:

{phang2}{cmd: bbandits_update reward chosen_arm batch, sae active_arms(0 1 2) batch_sae(5)}

{pstd}
Update and export the dataset to an Excel file:

{phang2}{cmd: bbandits_update reward chosen_arm batch, greedy excel("path")}

{hline}{pstd}{bf:Example 2: Simulated Bernoulli Thomps experiment to get started}

{pstd}
Clear the dataset and create the required data structure. A data set in which each row represents a to be treated unit. A complete list of planned treated units is recommended:

{phang2}{cmd: clear}{p_end}
{phang2}{cmd: set obs 1000}{p_end}

{pstd}
Create an ID variable:

{phang2}{cmd: gen ID = ""}{p_end}

{pstd}
Populate the ID variable with values "school_1", "school_2", ..., "school_1000". Hence there are 1000 schools which are going to be treated:

{phang2}{cmd: forval i = 1/1000 {c -(} } {p_end}
{phang2}{cmd:     qui replace ID = "school_" + string(`i') if _n == `i'}{p_end}
{phang2}{cmd: {c )-}}{p_end}

{pstd} Initialize the bandit experiment

{phang2}{cmd: bbandits_initialize, batches(10) arms(3) exploration_phase(2)}{p_end}

{pstd} Assign treatment and observe rewards during the exploration phase

{phang2}{cmd: generate rand = runiform()}{p_end}
{phang2}{cmd: replace reward = .}{p_end}

{phang2}{cmd: forval i = 1/2 {c -(}} {p_end}
{phang2}{cmd:     replace reward = 0 if batch == `i'}{p_end}
{phang2}{cmd:     replace reward = 1 if rand < 0.4 & batch == `i' & chosen_arm_numeric == 2}{p_end}
{phang2}{cmd:     replace reward = 1 if rand < 0.5 & batch == `i' & chosen_arm_numeric == 1}{p_end}
{phang2}{cmd:     replace reward = 1 if rand < 0.6 & batch == `i' & chosen_arm_numeric == 0}{p_end}
{phang2}{cmd: {c )-}}{p_end}

{pstd}
Update assignments using Thompson Sampling:

{phang2}{cmd: bbandits_update reward chosen_arm_numeric batch, thompson clipping(0.2)}{p_end}

{pstd} Run subsequent batches. Capture necessary because in last round of the loop, nothing can be updated anymore.

{phang2}{cmd: forval i = 3/10 {c -(}} {p_end}
{phang2}{cmd:     display `i'}{p_end}
{phang2}{cmd:     replace reward = 0 if batch == `i'}{p_end}
{phang2}{cmd:     replace reward = 1 if rand < 0.4 & batch == `i' & chosen_arm_numeric == 2}{p_end}
{phang2}{cmd:     replace reward = 1 if rand < 0.5 & batch == `i' & chosen_arm_numeric == 1}{p_end}
{phang2}{cmd:     replace reward = 1 if rand < 0.6 & batch == `i' & chosen_arm_numeric == 0}{p_end}
{phang2}{cmd:     capture bbandits_update reward chosen_arm_numeric batch, thompson clipping(0.2)}{p_end}
{phang2}{cmd: {c )-}}{p_end}

{pstd}
Inspect final assignments:

{phang2}{cmd: bbandits reward chosen_arm_numeric batch}{p_end}


{hline}{pstd}{bf:Example 3: Simulated Sequential Arm Elimination experiment}

{pstd}
Clear the dataset and create 1,000 observations:

{phang2}{cmd: clear}{p_end}
{phang2}{cmd: set obs 1000}{p_end}

{pstd}
Create an ID variable:

{phang2}{cmd: gen ID = ""}{p_end}

{pstd}
Populate the ID variable with values "school_1", "school_2", ..., "school_1000":

{phang2}{cmd: forval i = 1/1000 {c -(}}{p_end}
{phang2}{cmd:     qui replace ID = "school_" + string(`i') if _n == `i'}{p_end}
{phang2}{cmd: {c )-}}{p_end}

{pstd}
Initialize the bandit experiment using the sequential arm elimination algorithm:

{phang2}{cmd: bbandits_initialize, batches(5) arms(3) sae}{p_end}

{pstd}
Display the active arms macro which can be used in the subsequent batches of the bbandits_update command. Alternatively, they can be manually specified:

{phang2}{cmd: di "$active_arms_macro"}{p_end}

{pstd}
Generate random rewards:

{phang2}{cmd: generate rand = runiform()}{p_end}
{phang2}{cmd: replace reward = .}{p_end}

{pstd}
Assign rewards in the first batch:

{phang2}{cmd: forval i = 1/1 {c -(}}{p_end}
{phang2}{cmd:     replace reward = 0 if batch == `i'}{p_end}
{phang2}{cmd:     replace reward = 1 if rand < 0.4 & batch == `i' & chosen_arm == 1}{p_end}
{phang2}{cmd:     replace reward = 1 if rand < 0.5 & batch == `i' & chosen_arm == 2}{p_end}
{phang2}{cmd:     replace reward = 1.5 if rand < 0.8 & batch == `i' & chosen_arm == 3}{p_end}
{phang2}{cmd: {c )-}}{p_end}

{pstd}
Update assignments using sequential arm elimination:

{phang2}{cmd: bbandits_update reward chosen_arm_numeric batch, sae active_arms("$active_arms_macro") batch_sae(5)}{p_end}

{pstd}
Assign rewards in the second batch:

{phang2}{cmd: forval i = 2/2 {c -(}}{p_end}
{phang2}{cmd:     replace reward = 0 if batch == `i'}{p_end}
{phang2}{cmd:     replace reward = 1 if rand < 0.4 & batch == `i' & chosen_arm_numeric == 0}{p_end}
{phang2}{cmd:     replace reward = 1 if rand < 0.5 & batch == `i' & chosen_arm_numeric == 1}{p_end}
{phang2}{cmd:     replace reward = 1.5 if rand < 0.8 & batch == `i' & chosen_arm_numeric == 2}{p_end}
{phang2}{cmd: {c )-}}{p_end}

{pstd}
Display updated active arms and update assignments:

{phang2}{cmd: bbandits_update reward chosen_arm_numeric batch, sae active_arms("$active_arms_macro") batch_sae(5)}{p_end}

{hline}
{pstd}{bf: Literature}

Esfandiari, H., Karbasi, A., Mehrabian, A., & Mirrokni, V. (2021, May). Regret bounds for batched bandits. In Proceedings of the AAAI Conference on Artificial Intelligence (Vol. 35, No. 8, pp. 7340-7348).

{hline}
{pstd}
Authors: Jan Kemper, Davud Rostam-Afschar
