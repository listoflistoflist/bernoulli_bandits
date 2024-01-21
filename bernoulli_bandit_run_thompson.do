set trace off
set seed 0
program drop _all
clear all

bernoulli_bandits_thompson 1 1000, probs(0.05 0.9) nol 

bernoulli_bandits_thompson 30 1000, probs(0.05 0.9) nol 

bernoulli_bandits_thompson 30 1000 100, probs(0.05 0.9) nol 

bernoulli_bandits_thompson 30 1000 3 20, probs(0.05 0.9) nol 


bernbandits_th_explicit_int 50 30, probs(0.05 0.9) nol 


*to do: evolution of posterior distribution of theta and credibility intervals
*probability of best arm

*bernoulli_bandits_thompson 30 1000, probs(0.05 0.9)  nol animation


bernoulli_bandits_thompson 1 100, probs(0.05 0.9 0.4)  nol animation

/* To generate an mpg video file and/or an animated gif, you need to specify your graphics path and the path of the third-party open source free program ffmpeg (https://www.ffmpeg.org/).
This program can be executed via Stata. */

local GraphPath "figures\"
cap winexec "figures\ffmpeg-20171216-1f12071-win64-static\bin\ffmpeg.exe" -i `GraphPath'beta_`=r(k)'_arms_trial_%d.png  -b:v 512k `GraphPath'graph`i'.mpg
cap winexec "figures\ffmpeg-20171216-1f12071-win64-static\bin\ffmpeg.exe" -r 10 -i `GraphPath'graph`i'.mpg     -r 10 `GraphPath'graph`i'.gif
