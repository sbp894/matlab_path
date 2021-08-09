% function [outSignal, noise]= create_noisy_signal(inSignal, targetSNR, noise_or_Type)
% noise_or_Type:
%   string: {'white', 'pink', 'brown', 'blue', 'purple'},
%   numeric: inputAssumes S(f) has a slope (1/f^m),
%   vector: should be same length as inSignal
function [outSignal, noise2use]= create_noisy_signal(inSignal, targetSNR, noise_or_Type, fs, fCorner)

if ~exist('targetSNR', 'var')
    targetSNR= 0;
elseif isempty(targetSNR)
    targetSNR= 0;
end

if ~exist('noise_or_Type', 'var')
    noise_or_Type= 'white';
elseif isempty(noise_or_Type)
    noise_or_Type= 'white';
elseif isnumeric(noise_or_Type)
    if length(noise_or_Type)==1
        if nargin<5
            error('Need fs and fCorner');
        end
        noise_power_slope= noise_or_Type;
        noise_amp_slope= noise_power_slope/2;
        noiseWhite= randn(size(inSignal));
        Amp_fftx= fft(noiseWhite);
        Freq_fftx= (0:(length(Amp_fftx)-1))/length(Amp_fftx)*fs;
        Weight_fftx= min([Freq_fftx; fs-Freq_fftx], [], 1);
        cornerInd= dsearchn(Freq_fftx(:), fCorner);
        Weight_fftx= max(Weight_fftx, Weight_fftx(cornerInd)) .^ noise_amp_slope;
        noise2use= ifft(Amp_fftx(:) .* Weight_fftx(:));

    else
        noise2use= noise_or_Type;
    end
elseif ischar(noise_or_Type)
    if isempty(contains(noise_or_Type, {'white', 'pink', 'brown', 'blue', 'purple'}))
        error('noise_or_Type unknown');
    end
end

noiseAMP= rms(inSignal)*10^(-targetSNR/20);

if ~exist('noise2use', 'var')
    noiseWhite= randn(size(inSignal));
    if contains(lower(noise_or_Type), {'white', 'pink', 'brown', 'blue', 'purple'})
        cn= dsp.ColoredNoise('Color', noise_or_Type, 'SamplesPerFrame', length(inSignal));
        noise2use= cn();
    elseif contains(lower(noise_or_Type), 'matched')
        warning('Currently using lpc and not randomized phase of FFT(IN)')
        a= lpc(inSignal, min(50, numel(inSignal)/50));
        b= 1;
        %     fvtool(b, a, fs);
        noise2use= filter(b, a, noiseWhite);
    end
end

noise2use= noiseAMP*noise2use/rms(noise2use);
outSignal= inSignal + noise2use;