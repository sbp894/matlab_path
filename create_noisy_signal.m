% function [outSignal, noise]= create_noisy_signal(inSignal, targetSNR, noise_or_Type)
% noise_or_Type: 
%   0 for white, 
%   1 for PSD matched, 
%   or vector should be same
% length as inSignal
function [outSignal, noise]= create_noisy_signal(inSignal, targetSNR, noise_or_Type)

rng('shuffle');

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
        switch noise_or_Type
            case 0
                noise_or_Type= 'white';
            case 1
                noise_or_Type= 'inputPSDmatched';
        end
    else
       noise= noise_or_Type; 
    end
elseif ischar(noise_or_Type)
    if isempty(contains(noise_or_Type, {'white', 'pink', 'brown', 'blue', 'purple'}))
       error('noise_or_Type unknown'); 
    end
end

noiseAMP= rms(inSignal)*10^(-targetSNR/20);

if ~exist('noise', 'var')
    noiseWhite= randn(size(inSignal));
    if contains(lower(noise_or_Type), {'white', 'pink', 'brown', 'blue', 'purple'})
        cn= dsp.ColoredNoise('Color', noise_or_Type, 'SamplesPerFrame', length(inSignal));
        noise= cn();
    elseif contains(lower(noise_or_Type), 'matched')
        a= lpc(inSignal, min(50, numel(inSignal)/50));
        b= 1;
        %     fvtool(b, a, fs);
        noise= filter(b, a, noiseWhite);
    end
end

noise= noiseAMP*noise/rms(noise);
outSignal= inSignal + noise;