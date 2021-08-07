function [f0_val, f0_strength, xhat_n, time_quef]= get_pitch_from_cepstrum(x, fs)

x= x(:) .* hamming(length(x));
[xhat_n, ~]= cceps(x); % Complex cepstrum and delay to ensure continuity of DFT(x)
xhat_n= xhat_n(:)';
xhat_n= fftshift(xhat_n);
ind_quef= (1:length(xhat_n)) - length(xhat_n)/2 - 1;
time_quef= ind_quef/fs;

f0_Hz_range= [75 300];
f0_quef_range= sort(1./f0_Hz_range);

valid_logical= time_quef>min(f0_quef_range) & time_quef<max(f0_quef_range);
valid_inds= find(valid_logical);
[f0_strength, maxInd]= max(xhat_n(valid_logical));

f0_val= 1/time_quef(valid_inds(maxInd));