% function [RLVparams,rates_est,exitflag]=fit_AdaptCurve_2exp(levels,rates,PlotVar,PlotFittedRLV)
% PlotVar=1 (or +ve) to plot the level-rate and level-rate_estimated from
% model


function [adapt_params, rates_est, exitflag]=fit_AdaptCurve_2exp(time_vals, rates, PlotVar, PlotFittedRLV)
if nargin==2
    PlotVar=0;
    PlotFittedRLV=0;
end

warning('Not working. Work in progress. ');
adapt_params=struct('A_sus', nan, 'A_r', nan, 'A_st', nan, 'tau_r', nan, 'tau_st', nan);

%x = [A_sus A_r A_st tau_r tau_st]

x_start=[mean(rates) 2*mean(rates)  .5*mean(rates) 2e-3 60e-3];
x_lb=[  0   0   0   0   45e-3];
x_ub=[400 400 150 3e-3 100e-3];
options=optimset('Display', 'none', 'MaxIter', 1000, 'MaxFunEvals', 10000, 'Diagnostics', 'off', 'TolFun', 1.0000e-05, 'TolX', 1.0000e-03);


[x_sol,~,~,exitflag,~]=lsqcurvefit(@NELfuns.AdaptCurve_2exp, x_start, time_vals, rates, x_lb, x_ub, options);

rates_est=feval('NELfuns.RLcurve', x_sol, time_vals);

if PlotVar || PlotFittedRLV
    if PlotVar
        plot(time_vals,rates);
        if PlotFittedRLV
            hold on;
            plot(time_vals, rates_est);
%             legend('Simulated Data','Model-Fit Data','Location','southeast');
        else
%         legend('Simulated Data','Location','southeast');
        end
    else
        plot(time_vals,rates_est);
%         legend('Model-Fit Data','Location','southeast');
    end
    
    title('Rate-Level Curve');
    xlabel('Intensity (dB SPL)');
    ylabel('Total Rate');
end

% adapt_params.A_sus      = x_sol(1);
adapt_params.A_r        = x_sol(2);
adapt_params.A_st       = x_sol(3);
adapt_params.tau_r      = x_sol(4);
adapt_params.tau_st     = x_sol(5);
adapt_params.levels     = time_vals;
adapt_params.rates      = rates;
adapt_params.rates_est  = rates_est;

% Exitflag: 999 = not fit yet
%            -3 = COMPLEX fit
%            -2 = FIT ERROR
%            -1 = no convergence
%             0 = Max Iterations HIT
%             1 = GOOD fit
%             2 = CHECK FIT, BOUNDARY conditions HIT
%             3 = CHECK FIT, looks like params NOT ROBUST
%             8 = FIT ==> RL model is not appropriate

if(~isreal(x_sol))
    exitflag=-3;
    disp('COMPLEX SOLUTION');
elseif(exitflag==-2)
    disp('ERROR IN FITTING');
elseif(exitflag==-1)
    disp('DID NOT CONVERGE');
elseif(exitflag==0)
    disp('MAX ITERATIONS MADE');
end

for i=1:5
    if((round(100*x_sol(i))==round(100*x_lb(i)))||(round(100* x_sol(i))==round(100*x_ub(i))))
        exitflag=2;
%         fprintf('***Boundary condition restricted Solution (for param %d)***',i);
    end
end