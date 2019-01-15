clear;

fs= 10e3;
dur= .2;

f1= [.5e3 1e3 1.2e3 2e3];
[s1, t]= create_sinusoid(f1, fs, dur);
[sig, fs2]= audioread('/media/parida/DATAPART1/Matlab/SNRenv/SFR_sEPSM/shorter_stim/FLN_Stim_S_P.wav');
sig= gen_resample(sig, fs2, fs);
sig= sig(round(.28*fs):(round(.28*fs)-1+length(s1)));

n1= gen_rescale(randn(size(s1)), 65);
n2= gen_rescale(randn(size(s1)), 65);

x1= n1 + 0*s1 + sig;
x2= n2 + 0*s1 + sig;
NW= 3;

clf;
[freq, coher]= cmtm(x1,x2,1/fs, NW, 0, 0, 1);
% plot(freq, coher, 'linew', 3);
% hold on;
% plot_mscohere(x1, x2, fs, 'hamming', 'xscale', 'lin', 'yscale', 'lin', 'FracWindow', .33, 'FracOverlap', .5);
% ylim([0 1]);