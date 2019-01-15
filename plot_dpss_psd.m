% To plot PSD estimated using DPSS sequences.
% function [Pxx_dB,freq, ax]=plot_dpss_psd(vecin, fs, xscale, optional)
% ---------------------------------------------------------------------------
% Example: [Pxx_dB,freq, ax]=plot_welch_psd(vecin, fs, 'log', 'NW', NW...
% 'title', title_str, 'DC', true, 'plot', true, 'nfft', nfft, 'yscale', 'dB')
% ---------------------------------------------------------------------------
% vecin: input vector, can be either row or column vector.
% fs: Sampling Frequency
% xscale: {'log' (default), 'lin'}
% 'title', title_str
% 'DC', true or false: demean signal if false (default false)
% 'plot', true or false: do not plot PSD if false (default true)
% 'nfft', nfft: for frequency resolution
% 'yscale', {'dB', 'log' || 'mag', 'lin'}

function [Pxx_dB,freq, ax]=plot_dpss_psd(vecin, fs, varargin)

%% parse input
p=inputParser;
NW_default= 2.5;
xscale_default= 'log';
xscale_valid= {'log', 'lin'};
xscale_check= @(x) any(validatestring(x,xscale_valid));

title_default= 'PSD';
DC_default= false;
plot_default= true;
nfft_default= 2^nextpow2(length(vecin));
yscale_default= 'dB';

addRequired(p, 'vecin', @isnumeric);
addRequired(p, 'fs', @isnumeric);
addOptional(p,'xscale', xscale_default, xscale_check);
addParameter(p,'NW', NW_default, @isnumeric)
addParameter(p,'title', title_default, @ischar);
addParameter(p,'DC', DC_default, @islogical);
addParameter(p,'plot', plot_default, @islogical);
addParameter(p,'NFFT', nfft_default, @isnumeric);
addParameter(p,'yscale', yscale_default, @ischar);

p.KeepUnmatched = true;
parse(p,vecin,fs,varargin{:})

%% actual code

if ~p.Results.DC
    vecin=vecin-mean(vecin);
end

[Pxx, freq] = pmtm(vecin, p.Results.NW, p.Results.NFFT, fs);
Pxx_dB= db(Pxx)/2;
if p.Results.plot
    if ismember(lower(p.Results.yscale), {'log', 'db'})
        ax=plot(freq, Pxx_dB, 'linew', 2);
        ylabel('PSD (dB/Hz)');
    elseif ismember(lower(p.Results.yscale), {'lin', 'mag'})
        ax=plot(freq, Pxx, 'linew', 2);
        ylabel('PSD (LIN-MAG/Hz)');
    end
    set(gca, 'xscale', p.Results.xscale);
    
    title(p.Results.title);
    xlim([fs/p.Results.NFFT fs/2]);
    grid on;
else
    ax= nan;
end