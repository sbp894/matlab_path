% To plot PSD estimated using welch technique.
% function [Pxx_dB,freq, ax]=plot_welch_psd(vecin, fs, window, optional)
% ---------------------------------------------------------------------------
% Example: [Pxx_dB,freq, ax]=plot_welch_psd(vecin, fs, 'hamming', 'xscale', 'log', ...
% 'FracWindow', FracWindow, 'FracOverlap', FracOverlap, 'title', title_str, ...
% 'DC', true, 'plot', true, 'nfft', nfft)
% ---------------------------------------------------------------------------
% vecin: input vector, can be either row or column vector.
% fs: Sampling Frequency
% window: {'hamming' (default), 'bartlett', 'hann', 'blackman', 'rect'}
% xscale: {'log' (default), 'lin'}
% 'FracWindow', FracWindow: ratio of window length to vecin length (default 0.5)
% 'FracOverlap', FracOverlap: fraction of slide length to window length (default 0.5)
% 'title', title_str
% 'DC', true or false: demean signal if false (default false)
% 'plot', true or false: do not plot PSD if false (default true)
% 'nfft', nfft: for frequency resolution

function [Pxx_dB,freq, ax]=plot_welch_psd(vecin, fs, varargin)

%% parse input
p=inputParser;
FracOverlap_default= 0.5;
FracWindow_default= 0.5;

x_scale_default= 'log';

WindowType_default= 'rectwin';
WindowType_valid={'hamming', 'bartlett', 'hann', 'blackman', 'rect', 'rectwin', 'slepian', 'dpss'};
WindowType_check= @(x) any(validatestring(x, WindowType_valid));

title_default= '';
DC_default= false;
plot_default= true;
yrange_default= -1;

addRequired(p, 'vecin', @isnumeric);
addRequired(p, 'fs', @isnumeric);
addOptional(p,'window', WindowType_default, WindowType_check);
addParameter(p,'xscale', x_scale_default, @ischar);
addParameter(p,'FracOverlap', FracOverlap_default, @isnumeric)
addParameter(p,'FracWindow', FracWindow_default, @isnumeric)
addParameter(p,'title', title_default, @ischar);
addParameter(p,'DC', DC_default, @islogical);
addParameter(p,'plot', plot_default, @islogical);
addParameter(p,'NFFT', 2^nextpow2(length(vecin)), @isnumeric);
addParameter(p,'yrange', yrange_default, @isnumeric);

p.KeepUnmatched = true;
parse(p,vecin,fs,varargin{:})

%% actual code
nWindow= round(length(vecin)*p.Results.FracWindow);
nOverlap= floor(p.Results.FracOverlap*nWindow);

if size(vecin,2)~=1
    vecin=vecin';
end

if ~p.Results.DC
    vecin=vecin-mean(vecin); % probably not effective since each segment can have DC
end

switch lower(p.Results.window)
    case {'slepian', 'dpss'}
        t_window=dpss(nWindow, 1, 1);
    case 'hamming'
        t_window=hamming(nWindow);
    case 'bartlett'
        t_window=bartlett(nWindow);
    case 'hann'
        t_window=hann(nWindow);
    case 'blackman'
        t_window=blackman(nWindow);
    case {'rect', 'rectwin'}
        t_window=rectwin(nWindow);
end

[Pxx , freq]= pwelch(vecin, t_window, nOverlap, p.Results.NFFT, fs);
Pxx_dB=pow2db(Pxx);

if p.Results.plot
    ax=plot(freq, Pxx_dB, 'linew', 2);
    set(gca, 'xscale', p.Results.xscale);
    
    title(p.Results.title);
    ylabel('PSD (dB/Hz)');

    if p.Results.yrange>0
        ylim([max(Pxx_dB)-p.Results.yrange max(Pxx_dB)+5]);
    end

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