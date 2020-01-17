function set_colororder()

co= get(gca, 'ColorOrder');
co= co([1 2 5 4 3 6 7], :);
set(gca, 'ColorOrder', co);