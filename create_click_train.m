% function click_train= create_click_train(sampling_freq, stim_duration, inter_click_interval, numOfClicks)
function [click_train, time]= create_click_train(fs, ici, nClicks, first_click, dur)

if ~exist('fs', 'var')
    fs= 2e3;
elseif isempty(fs)
    fs= 2e3;
end

if ~exist('ici', 'var')
    ici= .1;
elseif isempty(ici)
    ici= .1;
end

if ~exist('nClicks', 'var')
    nClicks= 10;
elseif isempty(nClicks)
    nClicks= 10;
end

if ~exist('dur', 'var')
    dur= ici*nClicks;
elseif isempty(dur)
    dur= ici*nClicks;
end

if ~exist('first_click', 'var')
    first_click= ici;
elseif isempty(first_click)
    first_click= ici;
end


L= round(fs*dur);
click_train= zeros(L, 1);
time= (1:L)/fs;

click_inds= round((first_click:ici:dur)*fs);
click_train(click_inds)= 1;