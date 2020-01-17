function [co, co_struct]= set_colblind_order()

co= [[69 117 180]; [215 48 39]; [145 191 219]; [252 141 89]; [224 243 248]; [254 224 144]]/255;
co_struct= struct('b', co(1,:), 'r', co(2,:), 'lb', co(3,:), 'lr', co(4,:), 'wb', co(5,:), 'y', co(6,:));

% set(groot, 'ColorOrder', co);

set(gca, 'ColorOrder', co, 'NextPlot', 'replacechildren');