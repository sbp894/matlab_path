% Use plot_dft instead. Many functions have plot_fft. But plot_fft was not
% well organized. Will try to replace all plot_fft calls with plot_dft. 
% To plot DFT 
% function [amp_dB, freq, ax]=plot_fft(vecin, fs, xscale, optional)
% ---------------------------------------------------------------------------
% Example: [Pxx_dB,freq, ax]=plot_fft(vecin, fs, 'log', ...
% 'title', title_str, 'DC', true, 'phase', false, 'plot', true, 'nfft', nfft)
% ---------------------------------------------------------------------------
% vecin: input vector, can be either row or column vector.
% fs: Sampling Frequency
% xscale: {'log' (default), 'lin'}
% 'title', title_str
% 'DC', false (default) or true: demean signal if false
% 'phase', false (default) or true: plot phase or not 
% 'plot', true (default) or false: do not plot PSD if false
% 'nfft', nfft: for frequency resolution

function [amp_dB, freq, ax]=plot_fft(vecin, fs, varargin)

%% parse input
p=inputParser;
xscale_default= 'log';
xscale_valid= {'log', 'lin'};
xscale_check= @(x) any(validatestring(x,xscale_valid));

title_default= 'DFT';
DC_default= false;
plot_default= true;
nfft_default= 2^nextpow2(length(vecin));
phase_default= false;

addRequired(p, 'vecin', @isnumeric);
addRequired(p, 'fs', @isnumeric);
addOptional(p,'xscale', xscale_default, xscale_check);
addParameter(p,'title', title_default, @ischar);
addParameter(p,'DC', DC_default, @islogical);
addParameter(p,'phase', phase_default, @islogical);
addParameter(p,'plot', plot_default, @islogical);
addParameter(p,'NFFT', nfft_default, @isnumeric);

p.KeepUnmatched = true;
parse(p,vecin,fs,varargin{:})

%%

if ~p.Results.DC
    vecin=vecin-mean(vecin);
end

L = length(vecin);
Y = fft(vecin, p.Results.NFFT);

P2 = Y/L;
amp_dB = abs(P2(1:ceil(p.Results.NFFT/2+1)));
amp_dB(2:end-1) = 2*amp_dB(2:end-1);
amp_dB=db(amp_dB);
freq =linspace(0,fs/2,length(amp_dB));

yRangeMAX= 100; % 100 dB atten usuall means noise

if p.Results.phase
    ax(1)=subplot(211);
end
ax=plot(freq,amp_dB, 'linew', 2);
xlabel('f (Hz)');
ylabel('db(|P1(f)|), dB');
title(p.Results.title);
xlim([fs/2/p.Results.NFFT fs/2]);

if p.Results.phase
    ax(2)=subplot(212);
    semilogx(freq,unwrap(angle(P2(1:ceil(p.Results.NFFT/2+1)))), 'linew', 2);
    title('Phase Plot');
    linkaxes(ax, 'x');
end

set(gca, 'xscale', p.Results.xscale);
grid on;
ylim([max(amp_dB)-yRangeMAX+10 max(amp_dB)+10]);