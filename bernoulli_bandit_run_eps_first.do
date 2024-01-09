set trace off
set seed 0
program drop _all
clear all


bernoulli_bandits_eps_first 0.1 100, probs(0.05 0.9)  nol 