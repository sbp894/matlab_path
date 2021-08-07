% function D=dtw(a,b,w)
% This function aligns two signals using Dynamic Time Warping
% Input:
%   a=first signal
%   b=second signal
%   w=max window for time alignment (see Wikipedia)
%  Output:
%   D=distance matrix
%  Use D to trace back the optimal path.
%  Written by: SP

function [D, ind2]=dtw(invec1,invec2,w)

if nargin~=3
    error('Number of input parameters should be 3');
end
if size(invec1,1)~=length(invec1)
    invec1=invec1';
end

if size(invec2,1)~=length(invec2)
    invec2=invec2';
end

% fprintf('%d is the window length',w);
D=dtw_SP(invec1,invec2,w);

D(D==1e6)=NaN;
ind2=align_time(D);
% D=D';
% D=dtw_matlab(invec1,invec2,w);
end

% Monotonicity, warping window boundaries are integrated in this code
% Created by SP: 19 Aug, 2016

function ind2=align_time(D)

ind2=zeros(size(D,2),1);

base_ind=size(D,1)-100;
allowed_rows=base_ind+1:size(D,1);

for i=length(ind2):-1:2
    [~,min_ind]=min(D(allowed_rows,i));
    ind2(i)=min_ind+base_ind;
    allowed_rows=base_ind+min_ind-2:base_ind+min_ind;
    allowed_rows(allowed_rows<=0)=[];
    allowed_rows(allowed_rows>size(D,1))=[];
    base_ind=allowed_rows(1)-1;
end

ind2=ind2(2:end)-1;

end