function [NSCC,delay_sec,AVGrates,TOTALspikes] = SCCfull_m(SpikeTrain1, SpikeTrain2, DELAYbinwidth, Duration)
% function [NSCC,delay,AVGrates,TOTALspikes] = SCCfull_m(SpikeTrains,DELAYbinwidth,Duration)
% File: SCCfull_m
% 22Jun2017: SP: Updated ShufCrossCorr
% 
% Calls: SCCfull.c (mex)
% Computes Normalized Shuffled Cross-Correlogram (NSCC) from a set of Spike Trains and Duration
% Based on Louage et. al 2004


SpikeTrain1= cellfun(@(x) x(:), SpikeTrain1, 'UniformOutput', false);
SpikeTrain1= SpikeTrain1(:);
SpikeTrain2= cellfun(@(x) x(:), SpikeTrain2, 'UniformOutput', false);
SpikeTrain2= SpikeTrain2(:);

SpikeTrains= {SpikeTrain1, SpikeTrain2};
%% Compute AVGrates
NUMspikeREPS=cell(1,2);
Kmax=cell(1,2);
NUMspikes=cell(1,2);
TOTALspikes=cell(1,2);
AVGrates=cell(1,2);
SpikeMAT=cell(1,2);

%%
for UNITind=1:2
    NUMspikeREPS{UNITind}=length(SpikeTrains{UNITind});
    NUMspikes{UNITind}=cellfun(@(x) numel(x),SpikeTrains{UNITind})';
    Kmax{UNITind}=max(NUMspikes{UNITind});
    TOTALspikes{UNITind}=sum(NUMspikes{UNITind});
    AVGrates{UNITind}=TOTALspikes{UNITind}/NUMspikeREPS{UNITind}/Duration;
    SpikeMAT{UNITind}=NaN*ones(NUMspikeREPS{UNITind},Kmax{UNITind});
    for REPindREF=1:NUMspikeREPS{UNITind}
        SpikeMAT{UNITind}(REPindREF,1:length(SpikeTrains{UNITind}{REPindREF}))=SpikeTrains{UNITind}{REPindREF};
    end    
end

[SCC,delay_sec] = CorrGrams.SCCfull(SpikeMAT{1}',NUMspikes{1},TOTALspikes{1},SpikeMAT{2}',NUMspikes{2},TOTALspikes{2}, Duration, DELAYbinwidth);

NSCC=SCC/(NUMspikeREPS{1}*NUMspikeREPS{2}*AVGrates{1}*AVGrates{2}*DELAYbinwidth*Duration);

return;