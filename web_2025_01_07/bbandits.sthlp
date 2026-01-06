{smcl}
{* *! version 17.0 30jun2024}{...}
{viewerdialog bbandits "dialog bbandits"}{...}
{viewerjumpto "Syntax" "bbandits##syntax"}{...}
{viewerjumpto "Menu" "bbandits##menu"}{...}
{viewerjumpto "Description" "bbandits##description"}{...}
{viewerjumpto "Options" "bbandits##options"}{...}
{viewerjumpto "Examples" "bbandits##examples"}{...}

{p2col:{bf:bbandits}} Bandit Inference with Thompson Sampling and other methods

{marker syntax}{...}
{title:Syntax}
{p}
{cmd:bbandits} reward assignedarm batch [, {opt reference_arm(int 0)} {opt test_value(real 0.0)} {opt plot_thompson}  {opt stacked}  {opt twooptions_Thompson(string)}
{opt twooptions_bols(string)}  {opt twooptions_ols(string)}
{opt twooptions_sharebybatch(string)}  {opt twoptions_stackedsharebybatch(string)}
{opt twooptions_cumsharesbyybatch(string)}]

{marker description}{...}
{title:Description}
{pstd}
{cmd:bbandits} performs bandit inference using the specified data and options. The data is processed in Stata and then analyzed using Python functions. The results are returned and stored in Stata matrices for further analysis. 
To calculate the BOLS estimates and confidence intervals, each arm should be played at least once in each batch. 
Otherwise, the BOLS estimate for the respective batch is not defined and this batch-arm combination will be dropped for the BOLS analysis. If this happens a warning and the problematic combination is displayed.

{pstd}
The command requires three variables. The first variable is the reward. The second is a categorical variable for the assigned treatment arm which is also called "chosen arm". The third variable is a categorical variable for the batch.

{pstd}
The {opt reference_arm} option specifies the reference arm for the inference, defaulting to 0. The {opt test_value} option specifies the test value for the inference, with a default of 0.0.
If {opt plot_thompson} is specified, the Thompson sampling results are plotted.

{marker requirements}{...}
{title:Requirements}
{pstd} The underlying calculations are computed in Python. Therefore, python and the respective python packages have to be installed.
At least Stata 16 is required. To calculate the BOLS estimates and confidence intervals, each arm should be played at least once in each batch. 
Otherwise, python will return an error like "ZeroDivisionError".

{marker results}{...}
{title:Stored results}

{pstd} 
{cmd:bbandits} stores the following in {cmd:e()}:

{p2col 5 23 26 2: Scalars}{p_end}

{synoptset 20 tabbed}
{synopt:{cmd:e(N)}} number of observations.{p_end}

{p2col 5 23 26 2: Matrices}{p_end}

{synoptset 20 tabbed}
{synopt:{cmd:e(res)}} matrix with all output results.{p_end}
{synopt:{cmd:e(batch_ols_coefficients)}} Matrix with OLS coefficients for each batch.{p_end}
{synopt:{cmd:e(batched_ols_weights)}} Weight matrix that contains the BOLS weights for each batch.{p_end}
{synopt:{cmd:e(reward_evaluation)}} Matrix that contains the potential rewards under adaptive and classical experiments (Upper part main result table).{p_end}


{marker options}{...}
{title:Options}
{phang}{opt r:eference_arm(int 0)} specifies the reference arm for the inference. The default value is 0.  The program requires an integer value. 
It is recommended to numerate the treatment arms from 0 to k (number of treatment arms) in the "chosen_arm" variable. Then, the reference arm 
can be directly specified with the arm's integer. For example, with three given treatment arms, they can be numbered 0, 1 and 2. Now the default reference arm would be 0
and could be changed to 1 by "bbandits reward chosen_arm batch, reference_arm(1)". If the treatment variable is a string, the bbandits command transforms it
into a integer value and saves the label in the column "label_chosen_arm" and the numeric value in the column "chosen_arm".

{phang}{opt t:est_value(real 0.0)} specifies the test value for the inference. The default value is 0.0.

{phang}{opt p:lot_thompson} specifies whether to plot the results of Thompson sampling.

{phang}{opt t:est_value(real 0.0)}

{phang}{opt no:_plot} specifies that no plots are displayed.

{phang}{opt st:acked } specifies whether to plot the stacked plot.

{phang}{opt twooptions_thompson:(string)} takes user-specific two-way options for the twoway Thompson plot.

{phang}{opt twooptions_bols:(string)} takes user-specific two-way options for the plot of the BOLS treatment effects.

{phang}{opt twooptions_ols:(string)} takes user-specific two-way options for the plot of the BOLS and the OLS treatment effects.

{phang}{opt twooptions_sharebybatch:(string)} takes user-specific two-way options for the plot of the shares assigned to each treatment arm by batch.

{phang}{opt twoptions_stackedsharebybatch:(string)} takes user-specific two-way options for the plot of the shares assigned to each treatment arm by batch but stacked as an area.

{phang}{opt twooptions_cumsharesbyybatch:(string)} takes user-specific two-way options for the plot of the cumulative shares assigned to each treatment arm by batch stacked as an area.
  


{marker examples}{...}
{title:Examples}
{hline}
{pstd}{bf:Example 1: Basic Usage}

{phang2}{cmd:. bbandits reward chosen_arm batch}

{pstd}Performs bandit inference on the specified variables.

{phang2}{cmd:. bbandits reward chosen_arm batch, reference_arm(1) test_value(0.5)}

{pstd}Performs bandit inference with a reference arm of 1 and a test value of 0.5.

{pstd}{bf:Example 2: Analyse simulated data}

{phang2}{cmd:. bbandits_sim  1 2 1 , greedy eps(0.2) standard_deviations(1 1 1)} 

{pstd} Simulates data applying an epsilong greedy algorithm with three arms.

{phang2}{cmd:. bbandits reward chosen_arm batch, no_plot} 

{pstd}Performs bandit inference on the specified variables without the additional plots.

{hline}
{pstd}
Authors: Jan Kemper, Davud Rostam-Afschar

