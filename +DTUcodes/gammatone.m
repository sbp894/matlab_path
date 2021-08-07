% [OUT, IR, Env, t, bw, t_peak] = gammatone(in,fs,fc,delay_comp)
%
% Calculates gammatone filters for given center frequencies and filters the 
% input signal. The impulse responses of the filters are normalized such 
% that the peak of the magnitude frequency response is 1 / 0dB.
%
% ----------------------------     INPUTS:     ------------------------------
% in            ...input signal vector
% fc            ...scalar or vector specifying the filter center frequencies
% fs            ...sampling rate
% delay_comp    ...peak delay compensation: 'on' or 'off'
%
% ----------------------------     OUTPUTS:     ------------------------------
% OUT           ...length(in) X length(fc) matrix containing temporal outputs
%                   of the filterbank
% IR            ...length(in) X length(fc) matrix containing impulse responses
% Env           ...length(in) X length(fc) matrix containing impulse response envelopes
% t             ...vector specifying the temporal resolution in seconds
% bw            ...vector specifying the -3 dB bandwidth of the filters
% t_peak        ...1 X length(fc) vector containing peak delays in seconds

function [OUT, IR, Env, t, bw, t_peak] = gammatone(in,fs,fc,delay_comp)

%% Define
in = in(:);
N = length(in);
T = N/fs;

%% Calculate gammatone filters in the time domain
fc = fc(:)';
Num_filt = length(fc);      % number of gammatone filters
n = 4;                      % order of filter
ERB = 24.7 + 0.108*fc;      % rectangular bandwidth of the auditory filter
bw = ERB*0.887;             % -3dB bandwidths of gammatone filters
b = 1.018*ERB;              % parameter determining the duration of the IR (bandwidth)
a = 6./(-2*pi*b).^4;        
t = (0:1/fs:T-1/fs)';       % Time vector

tm = repmat(t,1,Num_filt);  % speed up calculation using repmat instead of loop
am = repmat(a,N,1);
bm = repmat(b,N,1);
fcm = repmat(fc,N,1);
Env = (tm.^(n-1))./am.*exp(-2*pi*tm.*bm) / (fs/2); % /(fs/2) so transfer functions peak at 1
IR = Env.*cos(2*pi*tm.*fcm);    

if strcmpi(delay_comp,'on') == 1    % delay compensation
    [~, idx_peak] = max(Env);
    idx_peak_inv = -idx_peak+1;
    for g = 1:Num_filt
        IR(:,g) = circshift(IR(:,g),idx_peak_inv(g));
    end
    Env = abs(hilbert(IR));
end
[~, idx_peak] = max(Env);
t_peak = idx_peak/fs;


%% Filter input signal in the frequency domain
OUT = ifft( fft(IR).*repmat(fft(in),1,Num_filt),N,1,'symmetric' );
