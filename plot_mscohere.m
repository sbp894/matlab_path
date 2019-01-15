% To plot magnitude-squared coherence estimated (using welch technique).
% function [Cxy_dB,freq, ax]=plot_mscohere(vecin, fs, window, optional)
% ---------------------------------------------------------------------------
% Example: [Cxy_dB,freq, ax]=plot_mscohere(vecin1, vecin2, fs, 'hamming', 'xscale', 'log', ...
% 'FracWindow', FracWindow, 'FracOverlap', FracOverlap, 'title', title_str, ...
% 'DC', true, 'plot', true, 'nfft', nfft)
% ---------------------------------------------------------------------------
%% Input Parameters
% Required Params
% -----> vecin1: input vector #1, can be either row or column vector.
% -----> vecin2: input vector #2, can be either row or column vector.
% -----> fs: Sampling Frequency
% Optional Params
% -----> window: {'hamming' (default), 'bartlett', 'hann', 'blackman', 'rectwin'}
% -----> xscale: {'log' (default), 'lin'}
% -----> 'FracWindow', FracWindow: ratio of window length to vecin length (default 0.5)
% -----> 'FracOverlap', FracOverlap: fraction of slide length to window length (default 0.5)
% -----> 'title', title_str
% -----> 'DC', true or false: demean signal if false (default false)
% -----> 'plot', true or false: do not plot PSD if false (default true)
% -----> 'nfft', nfft: for frequency resolution
%% Output Parameters
% -----> Cxy_dB: Coherence in dB
% -----> freq: in Hz (normalized to fs)
% -----> ax: 

function [Cxy_dB, freq, ax]=plot_mscohere(vecin1, vecin2, fs, varargin)

%% parse input
p=inputParser;
FracOverlap_default= 0.5;
FracWindow_default= 0.5;

xy_scale_default= 'log';

WindowType_default= 'hamming';
WindowType_valid={'hamming', 'bartlett', 'hann', 'blackman', 'rectwin'};
WindowType_check= @(x) any(validatestring(x, WindowType_valid));

title_default= '';
DC_default= false;
plot_default= true;

addRequired(p, 'vecin1', @isnumeric);
addRequired(p, 'vecin2', @isnumeric);
addRequired(p, 'fs', @isnumeric);
addOptional(p,'window', WindowType_default, WindowType_check);
addParameter(p,'xscale', xy_scale_default, @ischar);
addParameter(p,'yscale', xy_scale_default, @ischar);
addParameter(p,'FracOverlap', FracOverlap_default, @isnumeric)
addParameter(p,'FracWindow', FracWindow_default, @isnumeric)
addParameter(p,'title', title_default, @ischar);
addParameter(p,'DC', DC_default, @islogical);
addParameter(p,'plot', plot_default, @islogical);
addParameter(p,'NFFT', 2^nextpow2(length(vecin1)), @isnumeric);

p.KeepUnmatched = true;
parse(p, vecin1, vecin2, fs, varargin{:})

%% actual code
nWindow= round(length(vecin1)*p.Results.FracWindow);
nOverlap= floor(p.Results.FracOverlap*nWindow);

if size(vecin1,2)~=1
    vecin1=vecin1';
end

if ~p.Results.DC
    vecin1=vecin1-mean(vecin1); % probably not effective since each segment can have DC
    vecin2=vecin2-mean(vecin2); 
end

switch lower(p.Results.window)
    case 'hamming'
        t_window=hamming(nWindow);
    case 'bartlett'
        t_window=bartlett(nWindow);
    case 'hann'
        t_window=hann(nWindow);
    case 'blackman'
        t_window=blackman(nWindow);
    case 'rectwin'
        t_window=rectwin(nWindow);
end

% [Pxx , freq]= pwelch(vecin, t_window, nOverlap, p.Results.NFFT, fs);
[Cxy,freq] = mscohere(vecin1, vecin2, t_window, nOverlap, p.Results.NFFT, fs);
Cxy_dB=db(Cxy)/2;

if p.Results.plot
    if strcmp(p.Results.yscale, 'log')
        ax=plot(freq, Cxy_dB, 'linew', 2);
    elseif strcmp(p.Results.yscale, 'lin')
        ax=plot(freq, Cxy, 'linew', 2);
    end
    set(gca, 'xscale', p.Results.xscale);
    
    title(p.Results.title);
    ylabel('Coherence (dB)');
    switch p.Results.xscale
        case 'log'
            xlim([fs/p.Results.NFFT fs/2]);
        case 'lin'
            xlim([0 fs/2]);
    end
    grid on;
else
    ax= nan;
end