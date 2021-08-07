function outModelVals = AdaptCurve_2exp(inParams, time_vals)
% SP: Updated from RLcurve
% Basic double-exponential -curve model for fitting tone-PST 
% Zhang and Carney 2005: Eq 1 
% Original function: 
% function fit = RLcurve(x,level)
% MG Heinz%

A_sus=inParams(1);
A_r=inParams(2);
A_st=inParams(3);
tau_r= inParams(4);
tau_st= inParams(5);

outModelVals= A_sus + A_r * exp(-time_vals/tau_r) + A_st * exp(-time_vals/tau_st);
% outModelVals= A_r * exp(-time_vals/tau_r) + A_st * exp(-time_vals/tau_st);