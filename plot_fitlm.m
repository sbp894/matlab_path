function lHan= plot_fitlm(xIN, yIN, plotYes, verbose)

if ~exist('plotYes', 'var')
    plotYes= false;
end



xOUT= sort(xIN);
mdl = fitlm(xIN, yIN);
yOUT= predict(mdl , xOUT(:));

if plotYes
    hold on;
    lHan= plot(xOUT, yOUT, 'k', 'linew', 3);
    
    if verbose
        if mdl.Coefficients.Estimate(2)>0
            % means +ve slope
            xLoc= .05;
        else
            % means -ve slope
            xLoc= .65;
        end
        params= struct('x_txt_val', xLoc, 'y_txt_val', .9, 'y_txt_gap', .08, 'fSize', 16, 'pValThresh', 1e-3, 'title', '');
        add_stat_txt(mdl, params);
    end
    
else
    lHan= [];
end