% function [filteredSPL, originalSPL]=CalibFilter_outSPL(audio_fName, calib_fName, plotYes, verbose)
% Input 
%       audio_fName: filename for audio file
%       calib_fName: filename for calibration file (MAT)
%       plotYes: if 0 doesn't plot
%       verbose: if 0, doesn't print original and filtered SPL
% OUTPUT
%       filteredSPL: Intensity in db SPL of the calib filtered input signal
%       originalSPL:Intensity in db SPL of the input signal
% ----------------------------------------------------------------

% use one calib file
% use one broadband stimulus (probably (1) white noise and (2) speech)
% 100 dB at 1 kHz in calib means if we play a 1-V P-P 1 kHz sinusoid, the
% output will be 100 dB. 
function [filteredSPL, originalSPL]=CalibFilter_outSPL(audio_fName, calib_fName, plotYes, verbose)

if ~exist('plotYes', 'var')
    plotYes=0;
end

if ~exist('verbose', 'var')
    verbose=1;
end

if plotYes
    figure(1); clf;
    figure(2); clf;
    lw=2;
end

%% load stim
[stimOrg, fsOrg]= audioread(audio_fName);
fs=20e3;
qBYp=round(fsOrg/fs);
fs=fsOrg/qBYp;
stim= resample(stimOrg, 1, qBYp);
t=(1:length(stim))/fs;

%% load calib
calibdata= load(calib_fName);
calibdata=calibdata.data.CalibData;

%% remove anything above fs/2.
calibOrgFreqs= calibdata(:,1)*1e3;
calibOrgMaxOutput= calibdata(:,2);

% 1 V P-P with 0 dB gain
baseline_dB= 20*log10(1/sqrt(2)/(20e-6));
calibOrgRelative= calibOrgMaxOutput-baseline_dB;

%% Consider a signal x.
% Energy equation: sum(x.^2)=(1/nfft)*sum(|fft(x, nfft)|.^2)
% So power equation: will be sum(x.^2)/L=(1/L/nfft)*sum(|fft(x, nfft)|.^2)
nfft= 2^nextpow2(length(stim));
fft_stim= fftshift(fft(stim, nfft));
fft_freq=linspace(-fs/2, fs/2, nfft);

%% create calib filter
calibUpdated_dB= 0*fft_stim;

[minFreq, minFreqInd]=min(calibOrgFreqs); %#ok<*ASGLU>
BelowRange_freq_inds=abs(fft_freq)<minFreq;
% calibUpdated_dB(BelowRange_freq_inds)=calibOrgMaxOutput(minFreqInd);
calibUpdated_dB(BelowRange_freq_inds)=-100; %calibOrgMaxOutput(minFreqInd);


[maxFreq, maxFreqInd]=max(calibOrgFreqs);
% maxFreq=4e3;
AboveRange_freq_inds=abs(fft_freq)>maxFreq;
% calibUpdated_dB(AboveRange_freq_inds)=calibOrgMaxOutput(maxFreqInd);
calibUpdated_dB(AboveRange_freq_inds)=baseline_dB;

PositiveInRange_freq_inds= find(fft_freq>=minFreq & fft_freq<=maxFreq); % postive frequencies that are in range
% calibUpdated_dB(PositiveInRange_freq_inds)=interp1(calibOrgFreqs, calibOrgMaxOutput, fft_freq(PositiveInRange_freq_inds), 'spline');
calibUpdated_dB(PositiveInRange_freq_inds)=interp1(calibOrgFreqs, calibOrgMaxOutput, fft_freq(PositiveInRange_freq_inds));
% Comment: no difference b/w spline and linear for long speech signals.

calibUpdated_dB(nfft-PositiveInRange_freq_inds+1)=calibUpdated_dB(PositiveInRange_freq_inds);
calibFilter_lin=db2mag(calibUpdated_dB-baseline_dB);


%% Calculate power in the signal
% OrgPowerFFT= (1/length(stim)/nfft)*sum(abs(fft_stim).^2);
OrgPowerSIG= sum(stim.^2)/length(stim);
FilteredPowerFFT= (1/length(stim)/nfft) * sum( (abs(fft_stim) .*  calibFilter_lin).^2);

originalSPL= 20*log10(sqrt(OrgPowerSIG)/(20e-6));
filteredSPL= 20*log10(sqrt(FilteredPowerFFT)/(20e-6));
if verbose
    fprintf('Originial I= %.1f dB SPL, Filtered I= %.1f dB SPL\n', originalSPL, filteredSPL);
end

if plotYes
    
    %% Calibration plots
    figure(1);
    subplot(211);
    plot(calibOrgFreqs, calibOrgMaxOutput, 'linew', lw);
    grid on;
    ylabel('Max Output (dB)');
    
    subplot(212);
    plot(calibOrgFreqs, calibOrgRelative, 'linew', lw);
    grid on;
    ylabel('Calib Filter (dB)');
    xlabel('Frequency (Hz)');
    
    %% stim/ filter plots
    co= get(gca, 'colororder');
    figure(2);
    subplot(211);
    plot(t, stim);
    xlabel('time (sec)');
    ylabel('speech signal');
    subplot(212);
    yyaxis left;
    plot(fft_freq, abs(fft_stim));
    ylabel('DFT of speech (linear)', 'color', co(1, :));
    yyaxis right;
    plot(fft_freq, calibFilter_lin, 'linew', lw);
    ylabel('Calib filter (linear)', 'color', co(2, :));
    xlabel('freq (Hz)');
    
    grid on;
    set(gca, 'xscale', 'lin');
end