% Assumed y1 and y2 are collumn vectors, with nunber of column equal to
% number of elements in x.
% ttest ignores nan as missing values, so should be okay!

function hstar=add_significance(x, y1, y2)

if ~exist('mrkSize', 'var')
    mrkSize=30;
end

if ~exist('txtSize', 'var')
    txtSize=18;
end


if size(y1, 2)~=numel(x)
    y1=y1';
end
if size(y2, 2)~=numel(x)
    y2=y2';
end

[~, p]=ttest(y1, y2);

yStar=max(ylim)-.02*range(ylim);
hold on;
hstar=nan(length(x), 1);

for xVar=1:length(x)
    if p(xVar)<.0001
        hstar(xVar)=text(x(xVar), yStar, '****');
    elseif p(xVar)<.001
        hstar(xVar)=text(x(xVar), yStar, '***');
    elseif p(xVar)<.01
        hstar(xVar)=text(x(xVar), yStar, '**');
    elseif p(xVar)<.05
        hstar(xVar)=text(x(xVar), yStar, '*');
    end
    
    if p(xVar)>.05
        hstar(xVar)=text(x(xVar), yStar, sprintf('(p=%.03f)', p(xVar)));
        set(hstar(xVar), 'fontsize', txtSize, 'fontweight', 'bold', 'HorizontalAlignment', 'center')
    else
        set(hstar(xVar), 'fontsize', mrkSize, 'fontweight', 'bold', 'HorizontalAlignment', 'center')
    end
    
end