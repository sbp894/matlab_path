function sos = iirnotch_multi(f0_vector, BW_vector, fs)
%IIRNOTCH_MULTI Design multiple IIR notch filters in Second-Order Sections (SOS) format.
%   SOS = IIRNOTCH_MULTI(F0_VECTOR, BW_VECTOR, FS) designs notch filters at frequencies
%   specified in F0_VECTOR with corresponding bandwidths BW_VECTOR, using sampling
%   frequency FS. Returns coefficients in SOS format for stable filtering.
%
%   Inputs:
%       f0_vector  - Notch frequencies in Hz (column or row vector)
%       BW_vector  - Bandwidths of notches in Hz (same size as f0_vector)
%       fs         - Sampling frequency in Hz (scalar)
%
%   Output:
%       sos        - Second-Order Section matrix for use with sosfilt()
%
%   Example:
%       fs = 1000;
%       f0 = [50, 150];   % Notch at 50Hz and 150Hz
%       BW = [10, 20];    % 10Hz and 20Hz bandwidths
%       sos = iirnotch_multi(f0, BW, fs);
%       filtered_signal = sosfilt(sos, noisy_signal);

% Input validation
if numel(f0_vector) ~= numel(BW_vector)
    error('f0_vector and BW_vector must have the same number of elements');
end
if fs <= 0
    error('Sampling frequency fs must be a positive scalar');
end

% Ensure column vectors
f0_vector = f0_vector(:);
BW_vector = BW_vector(:);

% Compute damping factor 'r' (vectorized)
r = 1 - (BW_vector * pi) / fs;  % Critical fix: Proper scaling with fs

% Verify stability (0 < r < 1)
if any(r <= 0 | r >= 1)
    error('Invalid bandwidth(s). Ensure 0 < BW*pi/fs < 1 for stability');
end

% Compute normalized frequencies (corrected 2*pi term)
theta = 2 * pi * f0_vector / fs;  % Critical fix: Proper frequency normalization
cos_theta = cos(theta);

% Construct SOS matrix (6 columns per section)
% Numerator:   [1,  -2*cos(theta),  1]
% Denominator: [1,  -2*r.*cos(theta),  r.^2]
sos = [ones(size(f0_vector)), -2*cos_theta, ones(size(f0_vector)), ...
       ones(size(f0_vector)), -2*r.*cos_theta, r.^2];
end