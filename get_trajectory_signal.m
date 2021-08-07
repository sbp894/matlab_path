% Tested!!
% Filter a signal along a spectrotemporal trajectory. numel(inSig) has
% to be equal to numel(freqTrajectory).
% function fracSignal= get_trajectory_signal(inSig, fs, freqTrajectory, freq_half_window_co_Hz)
function [fracSignal, filtSignal, sig_demod_empirical]= get_trajectory_signal(inSig, fs, freqTrajectory, filtParams)

%% Make everything column vectors
inSig= inSig(:);
freqTrajectory= freqTrajectory(:);
freqTrajectory(isnan(freqTrajectory))= 0;
siglen= length(inSig);
stim_dur= siglen/fs;


if ~exist('filtParams', 'var') % doesn't exist
    filtParams= 2/stim_dur;
    d_lp = designfilt('lowpassiir','FilterOrder', 3, ...
        'HalfPowerFrequency', filtParams/(fs/2), 'DesignMethod','butter');
elseif isempty(filtParams) % exists but is empty
    filtParams= 2/stim_dur;
    d_lp = designfilt('lowpassiir','FilterOrder', 3, ...
        'HalfPowerFrequency', filtParams/(fs/2), 'DesignMethod','butter');
elseif isnumeric(filtParams) % exists and is numeric 
    d_lp = designfilt('lowpassiir','FilterOrder', 3, ...
        'HalfPowerFrequency', filtParams/(fs/2), 'DesignMethod','butter');
else % is a filter 
    d_lp= filtParams;
end


%%
phi_trajectory= zeros(size(freqTrajectory));
indStart_VoicedSegs= find(freqTrajectory(1:end-1)==0 & freqTrajectory(2:end)>0);
indEnd_VoicedSegs= find(freqTrajectory(1:end-1)>0 & freqTrajectory(2:end)==0);
if freqTrajectory(1)>0 % take care of edge cases #1
    indStart_VoicedSegs= [1; indStart_VoicedSegs];
end
if freqTrajectory(end)>0
    indEnd_VoicedSegs= [indEnd_VoicedSegs; length(freqTrajectory)];
end

if numel(indStart_VoicedSegs)~= numel(indEnd_VoicedSegs)
    error('Should be the same!');
end
% Loop through each voiced segments to compute phi_trajectory. 
for segVar=1:length(indStart_VoicedSegs)
    cur_indStart= indStart_VoicedSegs(segVar);
    cur_indEnd= indEnd_VoicedSegs(segVar);
    phi_trajectory(cur_indStart:cur_indEnd)= -cumtrapz(freqTrajectory(cur_indStart:cur_indEnd))/fs;
end

sig_demod_empirical= inSig .* exp(2*pi*1j*phi_trajectory); % sqrt_2 times to conserve power after Hilbert transform
sig_demod_empirical= gen_ramp_signal(sig_demod_empirical, fs, 1e-3); % Need to ramp so limit the Onset transience due to filtering

filtSignal= filtfilt(d_lp,sig_demod_empirical); % multiply by sqrt(2) because have only considered +ve frequencies,
% have to consider for -ve frequencies too => power should be twice => amplitdue should be sqrt(2) times

filtSignal= sqrt(2)*abs(filtSignal); % for both +ve and -ve frequencies 
fracSignal= sqrt(2)*abs(filtSignal) / rms(inSig); % normalize by the rms signal power