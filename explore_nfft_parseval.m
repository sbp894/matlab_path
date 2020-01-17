% Example script showing Parseval's theorem using FFT. 
% Amplitude should not depend on stimulus duration. 
% Effect of nfft 
% Calculating variance, dBSPL

clear;
clf;
clc;

fs= 4e3;
lw= 2;

% sig 1
dur1= .2;
f1= 500;
x1= create_sinusoid(f1, fs, dur1);

% sig 2
dur2= .2;
f2= 500;
x2= create_sinusoid(f2, fs, dur2);

% Parseval for length(sig) = nfft
fx1a= abs(fft(x1));
freq_vec1a= linspace(0, 1, numel(fx1a))*fs;
fprintf('diff is %f\n', sum(x1.^2) - sum(fx1a.^2)/length(x1));

% db SPL
[calc_dbspl(x1) dbspl(sqrt(max(fx1a)/length(x1)))]

fx2a= abs(fft(x2));
freq_vec2a= linspace(0, 1, numel(fx2a))*fs;
fprintf('diff is %f\n', sum(x2.^2) - sum(fx2a.^2)/length(x2));
% db SPL
[calc_dbspl(x2) dbspl(sqrt(max(fx2a)/length(x2))) dbspl(max(sqrt(2*((fx2a.^2)/length(x2))/length(x2))))]

figure(1);
subplot(211);
hold on;
plot(freq_vec1a, fx1a, 'linew', lw);
plot(freq_vec2a, fx2a, '--', 'linew', lw);


% % Parseval for length(sig) ~= nfft
nfft= 2^10;
fx1b= abs(fft(x1, nfft));
freq_vec1b= linspace(0, 1, nfft)*fs;
fprintf('diff is %f\n', sum(x1.^2) - sum(fx1b.^2)/nfft);

% db SPL
[calc_dbspl(x1) dbspl(max(sqrt((2*(fx1b.^2)/nfft/length(x1)))))]

% fx2a= abs(fft(x2));
% freq_vec2a= linspace(0, 1, numel(fx2a))*fs;
% fprintf('diff is %f\n', sum(x2.^2) - sum(fx2a.^2)/length(x1));

subplot(212);
hold on;
plot(freq_vec1a, fx1a);
plot(freq_vec1b, fx1b, '--');
% plot(freq_vec2a, fx2a, '--');


% % % % ----------------
% % % % additionally, pmtp
% % % fs= 2;
% % % p1=plot_dpss_psd(x1, fs, 'nfft', nfft, 'plot', false, 'norm', true);
% % % [var(x1) sum(db2pow(p1))/nfft*fs*length(x1)]
