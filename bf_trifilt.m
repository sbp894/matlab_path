function [data_fit, freqOut, lHan]= bf_trifilt(freq_raw, data_in, plotVar, plotProp, neighborhoodWindow_oct, avgType)

data_in= data_in(:)';

if ~exist('plotVar', 'var')
    plotVar= false;
end

if ~exist('plotProp', 'var')
    plotProp= '-';
end

if ~exist('avgType', 'var')
    avgType= 'weighted-mean';
elseif isempty(avgType)
    avgType= 'weighted-mean';
end


BW_ratio= 2^neighborhoodWindow_oct;

[freqSorted, sortedInds]= sort(freq_raw);
data_raw_sorted= data_in(sortedInds);

freqOut= unique(freqSorted);
data_fit= nan(size(freqOut));


for freqVar= 1:length(freqOut)
    curFreq= freqOut(freqVar);
    maskVector=  freqSorted> curFreq/sqrt(BW_ratio) & freqSorted<= curFreq*sqrt(BW_ratio); % only include freqs in the neighbourhood
    
    switch avgType
        case 'weighted-mean'
            weighVector= (1-abs(log2(freqSorted/curFreq)/neighborhoodWindow_oct)) .* maskVector; % assign weights
            weighVector= weighVector/nansum(weighVector);
            if any(weighVector<0)
                disp('Whoaa!!! No, No Stop!!  ');
            end
            if ~isempty(maskVector)
                data_fit(freqVar)= nansum(data_raw_sorted.*weighVector); % compute output
            end
        case 'mean'    
            data_fit(freqVar)= mean(data_raw_sorted(maskVector)); % compute output
        case 'median'
            data_fit(freqVar)= median(data_raw_sorted(maskVector)); % compute output
    end
end

if plotVar
    lHan= plot(freqOut, data_fit, plotProp, 'linew', 4);
else
    lHan= nan;
end