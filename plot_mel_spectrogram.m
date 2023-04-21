function [mel_S_dB,mel_freq_Hz, mel_time, mel_spect_params] = plot_mel_spectrogram(sig, fs, varargin)

%% Read input

% Default directory structure
default_params= struct('tWindow_s', 50e-3, 'fracOVlap', .975, 'FrequencyRange_Hz', [80, 20e3], 'NumBands', 128, 'plot', false); % Default spectrogram parameters

% Parse inputs
fun_paramsIN=inputParser;
addParameter(fun_paramsIN, 'tWindow_s', default_params.tWindow_s, @isnumeric)
addParameter(fun_paramsIN, 'fracOVlap', default_params.fracOVlap, @isnumeric)
addParameter(fun_paramsIN, 'FrequencyRange_Hz', default_params.FrequencyRange_Hz, @isnumeric)
addParameter(fun_paramsIN, 'NumBands', default_params.NumBands, @isnumeric)
addParameter(fun_paramsIN, 'plot', default_params.plot, @islogical)
fun_paramsIN.KeepUnmatched= true;
parse(fun_paramsIN, varargin{:});

mel_spect_params= fun_paramsIN.Results;
%% Main loop to get/create spectrograms

[mel_S_dB,mel_freq_Hz, mel_time, mel_spect_params]= get_mel_spect(sig, fs, mel_spect_params);
if mel_spect_params.plot
    plot_SG(mel_time, mel_freq_Hz, mel_S_dB);
end
end



%% Sub-functions
function [mel_S_dB, mel_freq_Hz, mel_time, mel_spect_params]= get_mel_spect(stim, fs_Hz, mel_spect_params)
mel_window= hamming(round(mel_spect_params.tWindow_s*fs_Hz));
mel_overlap_len= round(mel_spect_params.tWindow_s*fs_Hz*mel_spect_params.fracOVlap);
FrequencyRange_Hz= min(fs_Hz/2, mel_spect_params.FrequencyRange_Hz);

[S_mag,mel_freq_Hz,mel_time] = melSpectrogram(stim, fs_Hz, "Window", mel_window, "OverlapLength", mel_overlap_len, "FrequencyRange", FrequencyRange_Hz, "NumBands", mel_spect_params.NumBands);
mel_S_dB= pow2db(S_mag);
end


function plot_SG(mel_time, mel_freq_Hz, mel_S_dB)
figSize_cm= [3 3 18.3 9];
figure_prop_name = {'PaperPositionMode','units','Position', 'Renderer'};
figure_prop_val =  { 'auto'            ,'centimeters', figSize_cm, 'painters'};  % [Xcorner Ycorner Xwidth Ywidth]
figure(2);
clf;
set(gcf,figure_prop_name,figure_prop_val);

imagesc(mel_time, mel_freq_Hz/1e3, mel_S_dB)
set(gca, 'YScale', 'log', 'YDir', 'normal', 'YTick', [.2, .5, 1, 2, 4, 8, 16], 'TickDir', 'both', 'Box', 'off', 'Position', [.08, .15, .9, .78], 'Units', 'normalized');
xlabel('Time (s)')
ylabel('Freq, kHz')
end
