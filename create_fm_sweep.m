function [sig, time]= create_fm_sweep(freqStart, freqEnd, fs, dur, amp, phi)

if nargin<3
    error('need atleast two input');
end

if any(size(freqStart)-size(freqEnd))
    error('Sizes should match');
end

if ~exist('dur', 'var')
    dur= 1;
elseif isempty(dur)
    dur= 1;
end

if ~exist('amp', 'var')
    amp= ones(size(freqStart));
elseif isempty(amp)
    amp= ones(size(freqStart));
end

if ~exist('phi', 'var')
    phi= 2*pi*randn(size(freqStart));
elseif isempty(phi)
    phi= 2*pi*randn(size(freqStart));
elseif (numel(freqStart)~= numel(phi)) && (numel(phi) == 1)
    phi= phi*ones(size(freqStart));
elseif numel(phi) ~= numel(freqStart)
    error('phase and frequency are of different length');
end


time= (0:1/fs:dur-1/fs)';
sig=zeros(size(time));

for freqVar=1:length(freqStart)
    phi_instantaneous= phi(freqVar) + freqStart(freqVar).*time + (freqEnd(freqVar)-freqStart(freqVar))/2*(time).^2/dur; % Formula for phase in terms of frequency
    sig= sig+ amp(freqVar)*sin(2*pi*phi_instantaneous);
end