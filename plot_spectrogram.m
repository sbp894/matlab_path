function plot_spectrogram(sig, fs, tWindow, fracOVlap, nfft, doPlot, tStart)
if ~exist('tStart', 'var')
    tStart= 0;
end

if ~exist('doPlot', 'var')
    doPlot= 1;
end
if ~exist('tWindow', 'var')
    tWindow= 64e-3;
elseif isempty(tWindow)
    tWindow= 64e-3;
end
if ~exist('fracOVlap', 'var')
    fracOVlap= .99;
elseif isempty(fracOVlap)
    fracOVlap= .99;
end

if ~exist('nfft', 'var')
    nfft= 2^(nextpow2(tWindow*fs)+1);
elseif isempty(nfft)
    nfft= 2^(nextpow2(tWindow*fs)+1);
end
if doPlot
    spectrogram(sig, blackman(round(tWindow *fs)), round(tWindow*fs*fracOVlap), nfft, 'yaxis', fs);
else
    [S,F,T]= spectrogram(sig, blackman(tWindow *fs), round(tWindow*fs*fracOVlap), nfft, 'yaxis', fs);
    surf((tStart+T)*1e3,F/1e3,pow2db(abs(S)),'EdgeColor','none');
    view(2);
end