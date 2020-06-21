function [tau, dta, xmin, xmax, p, pcrit, ks, bins, prob] = plotAvalancheSize(sizeAv, fitP)
%{
    Plots the avalanche size distribution
    Inputs:
    sizeAv: Avalanche sizes
     fitP: A struct containing parameters to fit
        fitP.lc:    Lower cut-off of IEI
        fitP.uc:    Upper cut-off of IEI


    Option to fit if we provide cut-offs

%}
    


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
        
         if ~isfield(fitP, 'useML')
            fitP.useML = false;
         end       
 
         if ~isfield(fitP, 'logBin')
            fitP.logBin = false;
        end             
         
    end

    tau = 0.0;
    dta = 0.0;
    xmin = 0.0;
    xmax = 0.0;
    p    = 0.0;
    pcrit = 0.0;
    ks = 0.0;
    
    if fitP.logBin
        nbins = 2*iqr(sizeAv)/(numel(sizeAv)^(1/3)); %calculated by Freeman Diaconis rule
        [bins, N, edges]=lnbin(sizeAv, nbins);
    else 
        [N,edges] = histcounts(sizeAv, 'Normalization', 'probability');
        bins = (edges(1:end-1) + edges(2:end))/2;
    end
    
    loglog(bins, N, 'bx')
    hold on;

    if fitPL
        
        if fitP.useML
            if numel(unique(sizeAv)) > 2
                [tau, xmin, xmax, dta, p, pcrit, ks] = plparams(sizeAv);
                x = xmin:0.01:xmax;
                A = N(find(edges <= xmin, 1));
                y = A*x.^(-tau);
                loglog(x, y, 'r--');
                text(x(2), y(2)/3, strcat('S^{-', num2str(tau,3),'}'), 'Color','r')
            end
        else
            %only include bins within include range to fit
            fitEdges = edges((edges >= fitP.lc) & (edges <= fitP.uc));
            cutFront = numel(edges(edges < fitP.lc));
            cutEnd   = numel(edges(edges > fitP.uc));
            edgeCen  = (fitEdges(1:end-1)  + fitEdges(2:end))/2;
            fitN     = N(1 + cutFront : end - cutEnd);         

            %fit power law
            [fitresult, xData, yData, gof] = fitPowerLaw(edgeCen , fitN );    
            
            if ~isnan(fitresult.b)
                plot(fitresult, 'b--', xData, yData, 'gx')
            end

            text(edgeCen(1), fitN(1)/3, strcat('S^{-', num2str(-fitresult.b,3),'}'), 'Color','b')
%             legend('not fit', 'inc fit', 'fit')   
            tau = -fitresult.b;
            xmin = fitP.lc;
            
            xmax = fitP.uc;
            if numel(fitN) <= 2
                dta = inf;
            else
                CI  = confint(fitresult, fitP.cLevel);
                tCI = CI(:,2);
                dta = (tCI(2) - tCI(1))/2;
            end
            
        end

    end
    
    set(gca, 'YScale', 'log')
    set(gca, 'XScale', 'log')
    xlabel('S (events)')
    ylabel('P(S)')

    prob = N;

end