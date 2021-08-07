function [NSAC, delay_sec, AverageRate_per_sec,TOTALspikes] = get_SAC(SpikeTrain1, DELAYbinwidth, Duration)
% function [NSAC,delay_sec,AVGrate,TOTALspikes] = get_SAC(SpikeTrain1,DELAYbinwidth,Duration)
% Renamed to get_SAC from SACfull_m
% Mar, 2021: SP
% Calls: SACfull.c (mex)
% 
% Computes Normalized Shuffled Auto-Coprrelogram (NSAC) from a set of Spike Trains and Duration
% Based on Louage et. al 2004
% 
% ######################
% INPUTs
% ------> SpikeTrain1: a cell array where each element has spikes for a different trial 
% ------> DELAYbinwidth (optional): bin width for NSAC (default: 50us)
% ------> Duration (optional): max delay for NSAC  (default: range of input spike times)
% 
% ######################
% OUTPUTs 
% ------> NSAC: Normalized SAC 
% ------> delay_sec: delay correponding to NSAC 
% ------> AverageRate_per_sec: Average rate per trial 
% ------> TOTALspikes: Total number of spikes

SpikeTrain1= cellfun(@(x) x(:), SpikeTrain1, 'UniformOutput', false);
SpikeTrain1= SpikeTrain1(:);

NUMspikeREPS=length(SpikeTrain1);

nSpikesPerTrial= cellfun(@(x) numel(x), SpikeTrain1);
nSpikesPerTrial= nSpikesPerTrial(:)';
Kmax=max(nSpikesPerTrial);
TOTALspikes= sum(nSpikesPerTrial);

% Create a matrix of spikes where: 
% --> each column has spikes for a different rep
% --> if fewer spikes in a rep, populate with NaN to match matrix column size
SpikeMAT= cell2mat(cellfun(@(x, y) [x; nan(y - numel(x), 1)], SpikeTrain1(:)', repmat({Kmax}, 1, numel(SpikeTrain1)), 'UniformOutput', false));


if ~exist('DELAYbinwidth', 'var')
    DELAYbinwidth= 50e-6;
end

if ~exist('Duration', 'var')
    Duration= nanmax(SpikeMAT(:))-nanmin(SpikeMAT(:));
end

[SAC, delay_sec] = CorrGrams.SACfull(SpikeMAT,nSpikesPerTrial,TOTALspikes, Duration, DELAYbinwidth);

AverageRate_per_sec=TOTALspikes/NUMspikeREPS/Duration;
NSAC=SAC/(NUMspikeREPS*(NUMspikeREPS-1)*AverageRate_per_sec^2*DELAYbinwidth*Duration);  % From Louage et al (2004: J. Neurophysiol)

return;
