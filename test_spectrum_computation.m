% Summary:
% (1) If we want to true amplitudes, we can not zero pad because that changes
% the signal. So we have to use NFFT= numel(x).
% Also frequency is slightly shifted in plot_dft because frequency starts
% at 0 Hz instead of fs/nfft Hz. plot_dft is accurate.

clear;
clc

freq= [.5e3 1e3 3e3];
fs= 20e3;
dur= 1;
amp= [10 .1 1];

%% Example #1: Amplitude and dB SPL
% With DFT: if taper ~= rectangular, won't be the most accurate.
% NFFT has to be equal to signal length. Otherwise the zero-padded signal
% is different that the true signal.

[x, t] = create_sinusoid(freq, fs, dur, amp);

AMP_tick_vals= sort([min(amp)/10 amp 2*max(amp)]);
AMP_tick_labs= cellfun(@(x) num2str(x), num2cell(AMP_tick_vals), 'UniformOutput', false);
FREQ_tick_vals= [.1 1 10]*1e3;
FREQ_tick_labs= cellfun(@(x) num2str(x), num2cell(FREQ_tick_vals), 'UniformOutput', false);

figure(1);
clf;
subplot(211);
plot(t, x)
xlabel('Time (second)')
ylabel('Amplutyde')
xlim([.1 .2])

subplot(223);

hold on;
nfft= numel(x);
hold on;
AdB= plot_dft(x, fs, 'yscale', 'lin', 'nfft', nfft, 'window', 'slepian');
[Pmt, Fmt]= plot_dpss_psd(x, fs, 'nw', 1.5, 'yscale', 'lin', 'nfft', nfft, 'plot', false);
plot(Fmt, sqrt(db2pow(Pmt)), 'LineWidth', 2)
plot(freq, amp, 'ko', 'markersize', 10, 'LineWidth', 2);
set(gca, 'YScale', 'log', 'YTick', AMP_tick_vals, 'YTickLabel', AMP_tick_labs, 'XTick', FREQ_tick_vals, 'XTickLabel', FREQ_tick_labs);
ylim([.95*min(AMP_tick_vals) 1.1*max(AMP_tick_vals)])
legend('DFT w/ 1 DPSS', 'DPSS w/ 2 DPSS', 'Analytic', 'Location', 'southwest');
% ylim([.02 50]);

subplot(224);
hold on;
plot_dft(x, fs, 'yscale', 'dbspl');
plot_dpss_psd(x, fs, 'yscale', 'dbspl', 'nfft', nfft);
ylim([0 120]);
plot(freq, dbspl(amp/sqrt(2)), 'ko', 'markersize', 10, 'LineWidth', 2);
set(gca, 'XTick', FREQ_tick_vals, 'XTickLabel', FREQ_tick_labs);
legend('DFT w/ 1 Rect', 'DPSS w/ 2 DPSS', 'Analytic', 'Location', 'southwest');

grid on;

set(findall(gcf, '-property','FontSize'),'FontSize', 18);

%% Example #2: Computing power in the spectrum.
% Verify that time-domain power equals power computed using frequency
% domain. Also include examples of normalized power, fractional power,

% Example signals: noise
Pxx_dB1= plot_dpss_psd(x, fs, 'nfft', numel(x), 'nw', 1.5, 'norm', true, 'plot', false);
Pxx_dB2= plot_dpss_psd(x, fs, 'nw', 1.5, 'norm', true, 'plot', false);
Pxx_dB3= plot_dpss_psd(x, fs, 'nw', 5, 'norm', true, 'plot', false);
fprintf(['Working on Example #2: Power for time/NFFT/NW variation\n' ...
'---------------------------------------------\n'])
fprintf('\t --> %.2f: power from time-domain signal\n', var(x));
fprintf('\t --> %.2f: power NFFT=numel(x), NW=1.5\n', sum(db2pow(Pxx_dB1)));
fprintf('\t --> %.2f: power NFFT=2^nextpow2(numel(x)), NW=1.5\n', sum(db2pow(Pxx_dB2)));
fprintf('\t --> %.2f: power NFFT=numel(x), NW=5\n', sum(db2pow(Pxx_dB3)));
fprintf(['Done Example #2: Power for time/NFFT/NW variation\n' ...
'---------------------------------------------\n'])


%% Example #3: Computing power in the spectrum in a band.
dur2= 5;
v = randn(dur2*fs, 1);
b= randn(8,1);
a= 1;
n= filter(b, a, v);
t= (1:length(n))/fs;

figure(2);
clf;
subplot(211);
plot(t, n)
xlabel('Time (second)')
ylabel('Amplutyde')
xlim([.1 .2])

% Band #1
band1= [3e3 4e3];
n_BPed= bandpass(flipud(bandpass(flipud(n), band1, fs, 'Steepness', .99)), band1, fs, 'Steepness', .99);

subplot(212);
hold on;
[Pmt_n, Fmt_n]= plot_dpss_psd(n, fs, 'nw', 3, 'norm', true);
plot_dpss_psd(n_BPed, fs, 'nw', 1.5, 'norm', true);
Freq_BP_mask= Fmt_n>band1(1) & Fmt_n<band1(2);
fprintf(['\n ... \n Working on Example #3: bandpass filtered power \n' ...
    '---------------------------------------------\n']);
fprintf('\t --> %.2f: power from time-domain signal\n', var(n_BPed));
fprintf('\t --> %.2f: power NFFT=numel(x), NW=1.5\n', sum(db2pow(Pmt_n(Freq_BP_mask))));
fprintf(['Done Example #3: bandpass filtered power \n' ...
'---------------------------------------------\n'])

