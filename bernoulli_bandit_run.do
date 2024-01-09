set trace off
set seed 0
program drop _all
clear all

bernoulli_bandits_set 0.05 0.1 0.5 0.7

bernoulli_bandits_draw 1 1 2 0 3 0, nostats 

bernoulli_bandits_draw 1 100000 2 100000 3 100000,  nol

bernoulli_bandits_set 0.25 0.01 0.5 0.7

bernoulli_bandits_draw 1 100000 2 100000 3 100000 4 100000,  nol
