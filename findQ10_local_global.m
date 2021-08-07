function [Q10_global, frhi, frlo_global, Q10lev, Q10_local, frlo_local] = findQ10_local_global(freq,inten,BF)
% 
% [Q10_global, frhi, frlo_global, Q10lev, Q10_local, frlo_local] = findQ10_local_global(freq,inten,BF)
% 
% (Old) File: findQ10.m
% Modified by M. Heinz 8/1/02 from btq2.m
%
% Now BF is passed, because Q10 is specified as 10 dB above BFthreshold,
% and (impaired) BFs may be chosen to be different than the minimum on the TC (e.g., based on Liberman and Dodds, 1984)
%     also, interpolation changed from linear to log on y-axis
%
%function used to find Q10 of TC, requires colomn vectors 'frequency' and 'intensity'
%which uses a slightly different method and takes into account cases in which either or both
%side of TC end before reaching 10dB above threshold.
%original program by Elizateth Allegretto (1998), modified by Teng Ji (1999)
%function [BF, thresh, Q10, frhi, frlo] = btq(f, inten)


%find the threshold based on passed BF (must be a value in f)

if any(diff(freq))>0
    [freq, descInd]= sort(freq, 'descend');
    inten= inten(descInd);
end

flagError= 0;
temp5 = size(freq);
bf_index=find(freq==BF);  %index of BF
if isempty(bf_index)
    if size(freq,2)~=1
        freq=freq';
    end
    bf_index=dsearchn(freq, BF);
    warning('Couldn''t find exact CF, using closest to find Q10');
end
if isnan(BF)
    Q10_global=nan;
    frhi=nan;
    frlo_global=nan;
    Q10lev=nan;
    Q10_local= nan;
    frlo_local= nan;
    return;
elseif isempty(bf_index)
    error('BF passed to FindQ10 was not in frequency array')
end
thresh = inten(bf_index);  % This is based on passed inten (i.e, smoothed TC, so Q10lev~=unit.thresh+10)

%find Q10
Q10lev = thresh + 10;
frhia = freq(1);
frhib = freq(1);
frloa = freq(temp5(1));
frlob = freq(temp5(1));
inhia = inten(1);
inhib = inten(1);
inloa = inten(temp5(1));
inlob = inten(temp5(1));

%% for high frequency portion of TC
if inten(1) < Q10lev %in case not enough data pts were collected
    %    slp=(inten(1)-inten(2))/(f(1)-f(2));
    %    frhi=(Q10lev-inten(1))/slp+f(1);
    
    %     slp=(inten(1)-inten(2))/(log10(f(1))-log10(f(2)));
    %     frhi=10^((Q10lev-inten(1))/slp+log10(f(1)));
    frhi= max(freq);
    flagError= 1;
else %finding pts immediately above(frhib) and below(frhia) Q10lev
    for j = 2:bf_index
        if frhia == freq(1)
            if inten(j) <= Q10lev
                frhia = freq(j);
                inhia = inten(j);
            end
        end
        if (inten(j) >= Q10lev) && (frhia == freq(1))
            frhib = freq(j);
            inhib = inten(j);
        end
    end
    %  slope = (inhib - inhia)/(frhib - frhia);
    % 	frhi=(Q10lev-inhia)/slope+frhia;
    slope = (inhib - inhia)/(log10(frhib) - log10(frhia));
    frhi=10^((Q10lev-inhia)/slope+log10(frhia));
end

%% for low frequency portion of TC
if inten(temp5(1))< Q10lev % in case not enough data pts were collected
    %    slp=(inten(temp5(1))-inten(temp5(1)-1))/(f(temp5(1))-f(temp5(1)-1));
    %    frlo=(Q10lev-inten(temp5(1)))/slp+f(temp5(1));
    %     slp=(inten(temp5(1))-inten(temp5(1)-1))/(log10(f(temp5(1)))-log10(f(temp5(1)-1)));
    %     frlo=10^((Q10lev-inten(temp5(1)))/slp+log10(f(temp5(1))));
    frlo_global= min(freq);
    flagError= 1;
    
else %finding pts immediately above(frlob) and below(frloa) Q10lev
    for j = temp5(1):-1:bf_index
        if frloa == freq(temp5(1))
            if inten(j) <= Q10lev
                frloa = freq(j);
                inloa = inten(j);
            end
        end
        if (inten(j) >= Q10lev) && (frloa == freq(temp5(1)))
            frlob = freq(j);
            inlob = inten(j);
        end
    end
    %  slope = (inlob - inloa)/(frlob - frloa);
    % 	frlo=(Q10lev-inloa)/slope+frloa;
    slope = (inlob - inloa)/(log10(frlob) - log10(frloa));
    frlo_global=10^((Q10lev-inloa)/slope+log10(frloa));
end


% Get local frlo_local 
frlo_local_index= bf_index -1 + find(inten(bf_index:end)>Q10lev, 1);
if ~isempty(frlo_local_index)
    adj_inds_for_local_frlo= [frlo_local_index-1 frlo_local_index];
    frlo_local= exp(interp1(inten(adj_inds_for_local_frlo), log(freq(adj_inds_for_local_frlo)), Q10lev));
else 
    frlo_local= nan;
end


%% Calculate Q10
% temp10 = [0.001 (frhi-frlo)];
if ~flagError
    Q10_global = BF/(frhi-frlo_global);
else
    Q10_global= nan;
    warning('Error in Q10, either frhi or frlo is not defined');
end

Q10_local= BF/(frhi-frlo_local);

if Q10_global == BF/0.001
    warning('Error in Q10, frhi-frlo < 0.001');
    %     if ~exist('j','var')
    %         j=99;
    %     end
    %     figure(j)
    %     plot (f(:,1),inten(:,1));
end

if frhi == 20000
    warning('Error in Q10, frhi not defined');
end

if frlo_global == 10000
    warning('Error in Q10, frlo not defined');
end

return