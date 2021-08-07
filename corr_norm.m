% function corrVal= corr_norm(x, y)
% Normalized correlation. Not corr coef. 
% corrVal= sum(x.y)/max(sum(x.x), sum(y.*y))
function corrVal= corr_norm(x, y)
numer= nansum(x.*y);
% denom= max(sum(x.*x), sum(y.*y));
denom= sqrt(nansum(x.*x) * nansum(y.*y));
corrVal= numer/denom;