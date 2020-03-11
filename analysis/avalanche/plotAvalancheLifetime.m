function [alpha, dal] = plotAvalancheLifetime(lifeAv, fitP)
%{
    Plots the avalanche size distribution
    Inputs:
    sizeAv: Avalanche sizes
     fitP: A struct containing parameters to fit
        fitP.lc:    Lower cut-off of IEI
        fitP.uc:    Upper cut-off of IEI


    Option to fit if we provide cut-offs

%}
    
    alpha = 0.0;
    dal = 0.0;

    if nargin == 1
        fitPL = 0;
    else
        fitPL = 1;
    end
    

    if fitPL
        %add defaults for cut-offs for PL
        if ~isfield(fitP, 'lc')
            fitP.lc = 0;
        end

        if ~isfield(fitP, 'uc')
            fitP.uc = Inf;
        end
        
        if ~isfield(fitP, 'cLevel')
            fitP.cLevel = 0.5;
        end
        
    end

    
    [N,edges] = histcounts(lifeAv, 'Normalization', 'probability');
    loglog((edges(1:end-1) + edges(2:end))/2, N, 'bx')
    hold on;

    if fitPL
        %only include bins within include range to fit
        fitEdges = edges((edges >= fitP.lc) & (edges <= fitP.uc));
        cutFront = numel(edges(edges < fitP.lc));
        cutEnd   = numel(edges(edges > fitP.uc));
        edgeCen  = (fitEdges(1:end-1)  + fitEdges(2:end))/2;
        fitN     = N(1 + cutFront : end - cutEnd);         
        
        %fit power law
        [fitresult, xData, yData, gof] = fitPowerLaw(edgeCen , fitN );    
        plot(fitresult, 'b--', xData, yData, 'gx')

        text(edgeCen(1), fitN(1)/3, strcat('T^{-', num2str(-fitresult.b,3),'}'), 'Color','b')
        legend('not fit', 'inc fit', 'fit')   
        alpha = -fitresult.b;
        CI  = confint(fitresult, fitP.cLevel);
        tCI = CI(:,2);
        dal = (tCI(2) - tCI(1))/2;

    end

    set(gca, 'YScale', 'log')
    set(gca, 'XScale', 'log')
    xlabel('T (bins)')
    ylabel('P(T)')
    

end