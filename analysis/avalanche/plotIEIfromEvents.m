function IEIres = plotIEIfromEvents(G, ddG, t, fitP)
%{
    Plots the distribution of inter-event interval
    Inputs:
        G: Conductance time-series
      thr: Threshold in conductance to define an event
       t: time-vector


     fitP: A struct containing parameters to fit
        fitP.lc:    Lower cut-off of IEI
        fitP.uc:    Upper cut-off of IEI
        fitP.lcn:    Lower cut-off of IEI for neg event fit
        fitP.ucn:    Upper cut-off of IEI for neg event fit
        fitP.toInc:  Vector of same length as G. Tells which time-points to
                        include
        fitP.logBins: binary depending on whether or not log bins are used
        fitP.useML: use a maxium likelihood method for fitting


    Option to fit if we provide cut-offs

%}
    dt = (t(end) - t(1))/(numel(t) - 1);
    
    IEIres = struct();
    
    if nargin == 3
        fitPL = 0;
    else
        fitPL = 1;
    end
    
    dG = [diff(G), 0];
    dG(isnan(dG)) = 0;    
    
    if fitPL
        %if we exclude points then we do it here
        if isfield(fitP, 'toInc')
            dG = dG(fitP.toInc);
        end
        
        %add defaults for cut-offs for PL
        if ~isfield(fitP, 'lc')
            fitP.lc = 0;
        end

        if ~isfield(fitP, 'uc')
            fitP.uc = Inf;
        end    
        
        if ~isfield(fitP, 'lcn')
            fitP.lcn = 0;
        end

        if ~isfield(fitP, 'ucn')
            fitP.ucn = Inf;
        end 
        
        if ~isfield(fitP, 'logBins')
            fitP.logBins = false;
        end
        
        if ~isfield(fitP, 'useML')
            fitP.useML = false;
        end
        
    end

    
    
    ieiDat = IEI(ddG, 1);
    ieiDat = ieiDat(ieiDat > 0);
    IEIres.ieiDat = ieiDat;
    IEIres.meanIEI = mean(ieiDat);
    
    
    %[~, ieiDat] = IEI(ddG, 1, t); %uses time-vector
    if fitP.logBins
        N = floor(sqrt(ieiDat));         % number of bins
        start = min(ieiDat); % first bin edge
        stop = max(ieiDat);  % last bin edge
        b = 2.^linspace(log2(start),log2(stop),N+1);
        [Niei,edgesiei] = histcounts(ieiDat, b, 'Normalization', 'probability');
    else
        [Niei,edgesiei] = histcounts(ieiDat, 'Normalization', 'probability');            
    end
    loglog((edgesiei(1:end-1) + edgesiei(2:end))/2,Niei, 'bx')
    hold on;

    if fitPL
        if fitP.useML
            [tau, xmin, xmax, sigmaTau, p, pCrit, ks] = plparams(ieiDat);
            IEIres.tau = tau;
            IEIres.xmin = xmin;
            IEIres.xmax = xmax;
            IEIres.sigmaTau = sigmaTau;
            IEIres.p = p;
            IEIres.pCrit = pCrit;
            IEIres.ks = ks;
            x = xmin:0.01:xmax;
            A = Niei(find(edgesiei <= xmin, 1));
            y = A*x.^(-tau);
            loglog(x, y, 'r--');
            text(x(2), y(2)/3, strcat('t^{-', num2str(tau,3),'}'), 'Color','r')
            
        else %
            %only include bins within include range to fit
            fitEdges = edgesiei((edgesiei >= fitP.lc) & (edgesiei <= fitP.uc));
            cutFront = numel(edgesiei(edgesiei < fitP.lc));
            cutEnd   = numel(edgesiei(edgesiei > fitP.uc));
            edgeCen  = (fitEdges(1:end-1)  + fitEdges(2:end))/2;
            fitN     = Niei(1 + cutFront : end - cutEnd);         
            %fit power law
            [fitresult, xData, yData, gof] = fitPowerLaw(edgeCen , fitN );    
            plot(fitresult, 'b--', xData, yData, 'gx')

            text(edgeCen(1), fitN(1)/3, strcat('t^{-', num2str(-fitresult.b,3),'}'), 'Color','b')
            legend('not fit', 'inc fit', 'fit')    
        end
    end
    set(gca, 'XScale', 'log')
    set(gca, 'YScale', 'log')
    xlabel('IEI (s)')
    ylabel('P(IEI)') 

    
end