% To plot DFT
% function [amp_dB, freq, ax]=plot_dft(vecin, fs, xscale, optional)
% ---------------------------------------------------------------------------
% Example: [Pxx_dB,freq, ax]=plot_dft(vecin, fs, 'log', 'NW', NW...
% 'title', title_str, 'DC', true, 'plot', true, 'nfft', nfft)
% ---------------------------------------------------------------------------
% vecin: input vector, can be either row or column vector.
% fs: Sampling Frequency
% xscale: {'log' (default), 'lin'}
% 'title', title_str
% 'DC', false (default) or true: demean signal if false
% 'phase', false (default) or true: plot phase or not
% 'plot', true (default) or false: do not plot PSD if false
% 'nfft', nfft: for frequency resolution

function [ampOut, freq, lHan]=plot_dft(vecin, fs, varargin)

%% parse input
p=inputParser;
x_scale_default= 'log';
y_scale_default= 'log';

title_default= 'DFT';
DC_default= false;
plot_default= true;
nfft_default= 2^nextpow2(length(vecin));
phase_default= false;
yRange_default= 100;

addRequired(p, 'vecin', @isnumeric);
addRequired(p, 'fs', @isnumeric);
addParameter(p,'xscale', x_scale_default, @ischar);
addParameter(p,'yscale', y_scale_default, @ischar);
addParameter(p,'title', title_default, @ischar);
addParameter(p,'DC', DC_default, @islogical);
addParameter(p,'phase', phase_default, @islogical);
addParameter(p,'plot', plot_default, @islogical);
addParameter(p,'NFFT', nfft_default, @isnumeric);
addParameter(p,'yRange', yRange_default, @isnumeric);

p.KeepUnmatched = true;
parse(p,vecin,fs,varargin{:})

%%

if ~p.Results.DC
    vecin=vecin-mean(vecin);
end

L = length(vecin);
Y = fft(vecin, p.Results.NFFT);

P2 = Y/L;
amp = abs(P2(1:ceil(p.Results.NFFT/2+1)));
amp(2:end-1) = 2*amp(2:end-1);
amp_dB=db(amp);
freq =linspace(0,fs/2,length(amp_dB));

if p.Results.phase
    ax(1)=subplot(211);
end

if strcmp(p.Results.yscale, 'log')
    lHan=plot(freq, amp_dB, 'linew', 2);
    ampOut= amp_dB;
elseif strcmp(p.Results.yscale, 'lin')
    lHan=plot(freq, amp, 'linew', 2);
    ampOut= amp;
end

grid on;
xlabel('f (Hz)');
ylabel('db(|P1(f)|), dB');
title(p.Results.title);

if p.Results.phase
    ax(2)=subplot(212);
    semilogx(freq, unwrap(angle(P2(1:ceil(p.Results.NFFT/2+1)))), 'linew', 2);
    title('Phase Plot');
    linkaxes(ax, 'x');
    grid on;
end

set(gca, 'xscale', p.Results.xscale);
xlim([fs/2/p.Results.NFFT fs/2]);
if ~sum(contains(p.UsingDefaults, 'yRange'))
    ylim([max(amp_dB)-p.Results.phase.yRange+10 max(amp_dB)+10]);
end