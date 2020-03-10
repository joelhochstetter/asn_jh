function plotIEI(G, thr, dt, pn, fitP)
%{
    Plots the distribution of DeltaG
    Inputs:
        G: Conductance time-series
      thr: Threshold in conductance to define an event
       dt: sampling time of G in s
       pn: if 1 plots +ve and -ve separately on the same axis. Else we plot
            them together

     fitP: A struct containing parameters to fit
        fitP.lc:    Lower cut-off of IEI
        fitP.uc:    Upper cut-off of IEI
        fitP.lcn:    Lower cut-off of IEI for neg event fit
        fitP.ucn:    Upper cut-off of IEI for neg event fit
        fitP.toInc:  Vector of same length as G. Tells which time-points to
                        include

    Option to fit if we provide cut-offs

%}

    if nargin == 4
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
            fitP.uc = 10*max(abs(dG));
        end    
        
        if ~isfield(fitP, 'lcn')
            fitP.lcn = 0;
        end

        if ~isfield(fitP, 'ucn')
            fitP.ucn = 10*max(abs(dG));
        end            
    end


    figure;
    loglog((edgesiei(1:end-1) + edgesiei(2:end))/2,Niei, 'bx')
    [fitresult, xData, yData, gof] = fitPowerLaw((edges1(1:end-1) + edges1(2:end))/2, N1);
    hold on;
    plot(fitresult, xData, yData, 'gx')
    xlim([edgesiei(1), edgesiei(end)]);
    legend('not fitted', 'data', 'fit');
    xlabel('Time (dt)')
    ylabel('P(t)')
    text(10,500,strcat('t^{-', num2str(-fitresult.b,3),'}'))
    
    
    if pn
        
        ddG = dG > thr;
        ieiDat = IEI(ddG, 1)*dt;
        [Niei,edgesiei] = histcounts(ieiDat, 'Normalization', 'probability');
        loglog((edgesiei(1:end-1) + edgesiei(2:end))/2,Niei, 'bx')
        hold on;
        
        %negative fluctuations        
        ddG = dG < thr;
        ieiDat = IEI(ddG, 1)*dt;
        [Niei1,edgesiei1] = histcounts(ieiDat, 'Normalization', 'probability');
        loglog((edgesiei1(1:end-1) + edgesiei1(2:end))/2, Niei1, 'rx')        
        legend('\Delta G > 0', '\Delta G < 0')
        xlabel('IEI (s)')
        ylabel('P(IEI)') 
        
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
            
            %repeat for dG < 0
            fitEdges = edges1((edges1 >= fitP.lcn) & (edges1 <= fitP.ucn));
            cutFront = numel(edges1(edges1 < fitP.lcn));
            cutEnd   = numel(edges1(edges1 > fitP.ucn));
            edgeCen1 = (fitEdges(1:end-1)  + fitEdges(2:end))/2;
            fitN1    = N1(1 + cutFront : end - cutEnd);

            [fitresult1, xData, yData, gof] = fitPowerLaw(edgeCen1, fitN1);
            plot(fitresult1, 'r--', xData, yData, 'mx')
            legend('\Delta G > 0 not fit', '\Delta G < 0 not fit', ...
                '\Delta G > 0 inc fit', '\Delta G > 0 fit', ...
                '\Delta G < 0 inc fit', '\Delta G < 0 fit')
            text(edgeCen(1) , fitN(1)/3 , strcat('\Delta G^{-', num2str(-fitresult.b ,3),'}'), 'Color','b') 
            text(edgeCen1(1), fitN1(1)/3, strcat('\Delta G^{-', num2str(-fitresult1.b,3),'}'), 'Color','r')
%             title(strcat('\Delta G > 0: \Delta G^{-', ...
%                 num2str(-fitresult.b,3),'}', ...
%                 ',  \Delta G < 0: \Delta G^{-', num2str(-fitresult1.b,3),'}'))
        else
            legend('\Delta G > 0', '\Delta G < 0')
            title('\Delta G distribution')

        end
       
    else %~pn
        [N,edges] = histcounts(abs(dG), 'Normalization', 'probability');
        loglog((edges(1:end-1) + edges(2:end))/2,N, 'bx')
        hold on;
        title('\Delta G distribution')
        xlabel('\Delta G')
        ylabel('P(\Delta G)') 
        
        
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
            text(edgeCen(1), fitN(1)/3, strcat('\Delta G^{-', num2str(-fitresult.b,3),'}'), 'Color','b')
            legend('not fit', 'inc fit', 'fit')        
        end
        
    end
    set(gca, 'XScale', 'log')
    set(gca, 'YScale', 'log')


end