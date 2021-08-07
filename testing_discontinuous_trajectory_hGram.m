clear;
clc;

nSegs= 7;
firstSegVoiced= 0; % 0 means start with an unvoiced segment
if firstSegVoiced
    nVoicedSegs= numel(1:2:nSegs);
else
    nVoicedSegs= numel(2:2:nSegs);
end
nUnVoicedSegs= nSegs - nVoicedSegs;

rng(4);

params.freqMin= 100;
params.freqMax= 2e3;
params.durMin= .3;
params.durMax= .7;
params.voicedRampDur= 10e-3;
params.voicedOAdbspl=  65;
params.unvoicedOAdbspl=  45;

fs= 10e3;
freqTrajs= randi([params.freqMin params.freqMax], nVoicedSegs, 2);
voiced_durs= params.durMin + (params.durMax - params.durMin) * rand([1 nSegs]);
all_sigs= cell(nVoicedSegs,1);
all_freqTrajectory= cell(nVoicedSegs,1);

for SegVar= 1:nSegs
    
    if rem(SegVar, 2)== firstSegVoiced
        cur_dur= voiced_durs(SegVar);
        cur_freqStart= freqTrajs(ceil(SegVar/2), 1);
        cur_freqEnd= freqTrajs(ceil(SegVar/2), 2);
        
        cur_t= 1/fs:1/fs:cur_dur;
        cur_phi_t= cur_freqStart.*cur_t + (cur_freqEnd-cur_freqStart)/2*(cur_t.^2)/cur_dur; % Formula for phase in terms of frequency
        all_sigs{SegVar}= gen_rescale(gen_ramp_signal(sin(2 * pi * cur_phi_t'), fs, params.voicedRampDur), params.voicedOAdbspl);
        all_freqTrajectory{SegVar}= linspace(cur_freqStart, cur_freqEnd, numel(cur_t))';
    else
        cur_dur= voiced_durs(SegVar)/3; % make unvoiced shorter
        all_sigs{SegVar}= gen_rescale(randn(round(cur_dur*fs), 1), params.unvoicedOAdbspl);
        all_freqTrajectory{SegVar}= zeros(round(cur_dur*fs), 1);
    end
    
end

sig= cell2mat(all_sigs);
t= (1:length(sig))/fs;
freqTrajectory= cell2mat(all_freqTrajectory);


%%
anl.tWindow= 50e-3;
anl.fracOVlap= .95;
anl.nfft= 2^nextpow2(anl.tWindow*fs);
anl.LPFcutoff= 10;

d_lp = designfilt('lowpassiir','FilterOrder', 2, ...
    'HalfPowerFrequency', anl.LPFcutoff/(fs/2), 'DesignMethod','butter');


figure(1);
clf;

subplot(231);
plot(t, sig);
yyaxis right;
plot(t, freqTrajectory/1e3, 'linew', 3);
ax(1)= gca;

subplot(232);
plot_spectrogram(sig, fs, 50e-3, .95);
spectrogram(sig, blackman(anl.tWindow *fs), round(anl.tWindow*anl.fracOVlap), anl.nfft, 'centered', 'yaxis', fs);
ax(2)= gca;
subplot(233);
plot_dft(sig, fs, 'sided', 2, 'dc', true);

linkaxes(ax, 'y');

% Apply freq demodulation
[fracSignal, filtSignal, sig_demod_empirical]= get_trajectory_signal(sig, fs, freqTrajectory, d_lp);

subplot(234);
plot(t, fracSignal);

subplot(235);
spectrogram(sig_demod_empirical, blackman(anl.tWindow *fs), round(anl.tWindow*anl.fracOVlap), anl.nfft, 'centered', 'yaxis', fs);

subplot(236);
plot_dft(sig_demod_empirical, fs, 'sided', 2, 'dc', true);

set(gcf, 'Units', 'inches', 'Position', [2 2 14 8]);