set trace off
set seed 0
program drop _all
clear all


bernoulli_bandits_eps_greedy 0.1 2 100, probs(0.05 0.9)  nol 

bernoulli_bandits_eps_greedy 0.1 0.5 100, probs(0.05 0.9)  nol 

bernoulli_bandits_eps_greedy 0.1 -0.8 100, probs(0.05 0.9)  nol 

bernoulli_bandits_eps_greedy 0.1 999 100, probs(0.05 0.9) nol 