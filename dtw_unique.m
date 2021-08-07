% Copyright (C) 2013 Quan Wang <wangq10@rpi.edu>,
% Signal Analysis and Machine Perception Laboratory,
% Department of Electrical, Computer, and Systems Engineering,
% Rensselaer Polytechnic Institute, Troy, NY 12180, USA

% dynamic time warping of two signals

function [CostMat, IndMapvec2TOvec1]=dtw_unique(invec1, invec2, w)
% s: signal 1, size is ns*k, row for time, colume for channel 
% t: signal 2, size is nt*k, row for time, colume for channel 
% w: window parameter
%      if s(i) is matched with t(j) then |i-j|<=w
% d: resulting distance

if nargin < 2
    error('Input two vectors');
end

if size(invec1,1)~=length(invec1)
    invec1=invec1';
end

if size(invec2,1)~=length(invec2)
    invec2=invec2';
end

if ~exist('w', 'var')
    w= -inf;
end

len1= numel(invec1);
len2= numel(invec2);

if len1>=len2
    error('Length of inVec1 should be smaller than length of inVec2');
end

w=max(w, abs(len1-len2)); % adapt window size

%% initialization
CostMat=zeros(len1,len2)+Inf; % cache matrix
CostMat(1,1:w)= abs(invec1(1)-invec2(1:w));

%% begin dynamic programming
for rowVar=2:len1
    for colVar=max(2, rowVar+1-w):min(rowVar-1+w,len2)
        
        curCost= abs(invec1(rowVar)-invec2(colVar));
        
        baseCost= min(CostMat(rowVar-1, 1:colVar-1));
        
        CostMat(rowVar,colVar) = baseCost + curCost;
    end
end


%% Finding path with minimum distance
IndMapvec2TOvec1= nan(size(invec1));
CostMatTemp= CostMat;
for rowVar= len1:-1:2
    [~, IndMapvec2TOvec1(rowVar)]= min(CostMatTemp(rowVar, :)); 
    CostMatTemp(rowVar-1, IndMapvec2TOvec1(rowVar):len2)= inf;
end
[~, IndMapvec2TOvec1(1)]= min(CostMatTemp(1, 1:IndMapvec2TOvec1(2)-1));