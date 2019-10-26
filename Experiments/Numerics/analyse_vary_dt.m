function analyse_vary_dt(sims, params)
%I want a plot comparing conductance
%difference of conductance as a ratio as function of time
%For AC I want an IV hysteresis curve
%Difference of state vector as function of time
    cmp = numel(params.SimOpt.dt);
    ResRatio = zeros(cmp, numel(sims{1}.netC));
    lamDiff  = zeros(cmp, numel(sims{1}.netC));
    
    for i = 1:cmp
       sims{i} = spliceData(sims{i}, sims{i}.dt, params.SimOpt.dt(1));    
    end
    
    for i = 1:cmp
       ResRatio(i,:) = sims{i}.netC ./ sims{cmp}.netC;
       lamDiff(i,:)  = sqrt(sum((sims{i}.swLam - sims{cmp}.swLam),2).^2);
    end

    multiPlotConductance(sims{1}.Stim.TimeAxis, sims)
    legend(string(params.SimOpt.dt))
    saveas(gcf, strcat(params.SimOpt.saveFolder, '/conValComp.png'));
    close all;
    
    figure;
    semilogy(sims{1}.Stim.TimeAxis, ResRatio);
    xlabel 'time (s)'
    ylabel 'Conductance ratio'
    legend(string(params.SimOpt.dt))
    saveas(gcf, strcat(params.SimOpt.saveFolder, '/conRatComp.png'));    
    close all;
    
    figure;
    semilogy(sims{1}.Stim.TimeAxis, lamDiff);
    xlabel 'time (s)'
    ylabel 'Difference in state vector'
    legend(string(params.SimOpt.dt))
    saveas(gcf, strcat(params.SimOpt.saveFolder, '/stateVecCmp.png'));    
    close all;    
end
