set trace off
set seed 0
program drop _all
clear all

/*
/*up to 250 arms*/

/*burn in phase with equal probability*/
bernoulli_bandits_set 0.1 0.9
bernoulli_bandits_draw 1 1 2 1, nol

/*draw 2 times one round and then 10 rounds*/
bernoulli_bandits_thompson 1 1 1, probs(0.1 0.9) nol
bernoulli_bandits_thompson 1 1 1, probs(0.1 0.9) nol
bernoulli_bandits_thompson 1 10 1, probs(0.1 0.9) nol


/*draw one round for shares in batches of 100 based on 1, 2, 3 or 4 simulations*/
bernoulli_bandits_thompson 1 1 100 , probs(0.1 0.9) nol
bernoulli_bandits_thompson 2 1 100 , probs(0.1 0.9) nol
bernoulli_bandits_thompson 3 1 100 , probs(0.1 0.9) nol
bernoulli_bandits_thompson 4 1 100 , probs(0.1 0.9) nol
bernoulli_bandits_thompson 100 1 100 , probs(0.1 0.9) nol

/*draw one round for shares in batches of 100 based on 1, 2, 3 or 4 simulations with clipping of 20*/
bernoulli_bandits_thompson 100 1 100 20, probs(0.1 0.9) nol


/*draw 10 rounds for shares in batches of 100 based on 1, 2, 3 or 4 simulations with clipping of 20*/
bernoulli_bandits_thompson 100 10 100 20, probs(0.1 0.9) nol


/*draw 2 rounds for 100 arms*/
bernoulli_bandits_thompson 100 2 100 1, probs(0.01 0.02 0.03 0.04 0.05 0.06 0.07 0.08 0.09 0.10 0.11 0.12 0.13 0.14 0.15 0.16 0.17 0.18 0.19 0.20 0.21 0.22 0.23 0.24 0.25 0.26 0.27 0.28 0.29 0.30 0.31 0.32 0.33 0.34 0.35 0.36 0.37 0.38 0.39 0.40 0.41 0.42 0.43 0.44 0.45 0.46 0.47 0.48 0.49 0.50 0.51 0.52 0.53 0.54 0.55 0.56 0.57 0.58 0.59 0.60 0.61 0.62 0.63 0.64 0.65 0.66 0.67 0.68 0.69 0.70 0.71 0.72 0.73 0.74 0.75 0.76 0.77 0.78 0.79 0.80 0.81 0.82 0.83 0.84 0.85 0.86 0.87 0.88 0.89 0.90 0.91 0.92 0.93 0.94 0.95 0.96 0.97 0.98 0.99 0.100) nol




*to do: evolution of posterior distribution of theta and credibility intervals
*probability of best arm

*bernoulli_bandits_thompson 30 1000, probs(0.05 0.9)  nol animation



bernoulli_bandits_thompson 1 500, probs(0.05 0.9 0.4)  nol animation

/* To generate an mpg video file and/or an animated gif, you need to specify your graphics path and the path of the third-party open source free program ffmpeg (https://www.ffmpeg.org/).
This program can be executed via Stata. */

local GraphPath "figures\"
cap winexec "figures\ffmpeg-20171216-1f12071-win64-static\bin\ffmpeg.exe" -i `GraphPath'beta_`=r(k)'_arms_trial_%d.png  -b:v 512k `GraphPath'graph`i'.mpg
cap winexec "figures\ffmpeg-20171216-1f12071-win64-static\bin\ffmpeg.exe" -r 10 -i `GraphPath'graph`i'.mpg     -r 10 `GraphPath'graph`i'.gif


*/



bernoulli_bandits_thompson 10 1000, probs(0.05 0.9 0.4 0.88 0.4 0.88) nol 

** syntax error due to weights rounded off to zeros, ties remain to be solved 

bernoulli_bandits_thompson 100 1000, probs(0.05 0.9 0.4 0.88 0.4 0.88) nol 


***Plot share each arm selected
gen id= _n
reshape long bandit,i(id) j(b)
ren bandit reward
ren b bandit
replace bandit = . if reward==.
tab reward ,mi

tab bandit

levelsof bandit

hist bandit , discrete frac xtitle(Treatment Arm) xlabel(1(1)`=max(`=subinstr("`r(levels)'"," ",",",.)')', valuelabel angle(90)) ylabel(0(.1)1) xlabel(,nogrid) ytitle("Share of Arm Selected")
graph export "figures\share of arm.png", replace width(1280)
