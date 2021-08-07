% [OUT, t, TFs, f] = modfilter(IN, fs, CONTROL)
%
% Calculates the temporal output of a modulation filterbank using a matrix
% of envelope input signals.
%
% The main stages are:
%
% (i)   Filterbank calculation:
%       a) lowpass - bandpass design
%       b) bandpass design
% (ii)  Filtering of input envelope
%
%
% ----------------------------     INPUTS:     ------------------------------
%
% IN            ...input signal envelope matrix: #samples X #bands (even number of samples recommended!)
% fs            ...sampling rate
% CONTROL       ...structure containing the following control data fields:
%   type        ...'BP' for bandpass filterbank design
%                   'LP_BP' for lowpass and bandpass filterbank design
%   fm          ...vector containing modulation filter center frequencies 
%                   the lowest one is the cutoff frequency of the lowpass
%                   if type = 'LP_BP'
%   Q           ...Q of bandpass filters (constant Q)
%   order       ...order of lowpass filter (only necessary if type = 'LP_BP')
%
% ----------------------------     OUTPUTS:     ------------------------------
%
% OUT           ...size(IN,1) X size(IN,2) X length(CONTROL.fm) matrix containing 
%                   temporal filter outputs
% t             ...time vector
% TFs           ...size(IN,1) X length(CONTROL.fm) matrix containing filter
%                   transfer functions (frequency domain)
% f             ...frequency vector

%% Start of function
function [OUT, t, TFs, f] = modfilter(IN, fs, CONTROL)

%% define, adjust signal length
[N, Num_bands] = size(IN);          % number of samples, number of subbands (e.g., output of gammatone filters)
Num_filters = length(CONTROL.fm);   % number of modulation filters
if mod(N,2) ~= 0                    % if number of samples is odd, reduce length by one sample
    N = N-1;
    IN = IN(1:N,:);
end
t = 0:1/fs:(N-1)/fs;

%% Calculate modulation filterbank
f_pos = 0:fs/N:fs/2;                    % vector containing positive frequencies
f = [f_pos -f_pos(end-1:-1:2)].';       % vector containing all frequencies
TFs = zeros(N,Num_filters);             % initialize transfer function matrix

% lowpass - bandpass design
if strcmp(CONTROL.type,'LP_BP')
    TFs(:,1) = sqrt( 1./(1+((2*pi*f/(2*pi*CONTROL.fm(1))).^(2*CONTROL.order))) ); % butterworth filter TF from: http://en.wikipedia.org/wiki/Butterworth_filter
    for k = 2:Num_filters               % calculate transfer functions for bandpass filters
        TFs(:,k) = 1./(1+ (1j*CONTROL.Q*(f./CONTROL.fm(k) - CONTROL.fm(k)./f))); % p287 Hambley.
    end
% only bandpass design
elseif strcmp(CONTROL.type,'BP')
    for k = 1:Num_filters               % calculate transfer functions for bandpass filters
        TFs(:,k) = 1./(1+ (1j*CONTROL.Q*(f./CONTROL.fm(k) - CONTROL.fm(k)./f))); % p287 Hambley.
    end
end
%% Filter signal
TFs = repmat(reshape(TFs,N,1,Num_filters),[1 Num_bands 1]);
OUT = repmat(IN,[1 1 Num_filters]);
OUT = fft(OUT,N,1);
OUT = ifft(OUT.*TFs,N,1,'symmetric');
TFs = squeeze(TFs(:,1,:));
