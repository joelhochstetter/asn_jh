function [gamma_m_1, dgamma_m_1, mSize, mLife] = plotAvalancheAveSize(sizeAv, lifeAv, fitP)
%{
    Plots the avalanche average size as a function of lifetime

    Inputs:
    sizeAv: Avalanche sizes
    
     fitP: A struct containing parameters to fit
        fitP.lc:    Lower cut-off of IEI
        fitP.uc:    Upper cut-off of IEI
        fitP.cLevel: confidence level to use for errors


    Option to fit if we provide cut-offs

%}
    %gamma_m_1

    if nargin == 3 
        fitPL = true;
    else
        fitPL = false;
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

    [mSize, mLife] = avalancheAvSize(sizeAv, lifeAv);

    loglog(mLife, mSize, 'bx')
    hold on;
    
    if fitPL
        %only include bins within include range to fit
        fitLives = mLife((mLife >= fitP.lc) & (mLife <= fitP.uc));
        fitSizes = mSize((mLife >= fitP.lc) & (mLife <= fitP.uc));         

        %fit power law
        [fitresult, xData, yData, gof] = fitPowerLaw(fitLives, fitSizes);    
        if ~isnan(fitresult.b)
            plot(fitresult, 'b--', xData, yData, 'gx')
        end
        
        text(fitLives(1), fitSizes(1)/3, strcat('T^{', num2str(fitresult.b,3),'}'), 'Color','b')
        legend('not fit', 'inc fit', 'fit')   
        
        if numel(fitSizes) <= 2
                dgamma_m_1 = inf;
        else
            CI  = confint(fitresult, fitP.cLevel);
            tCI = CI(:,2);
            dgamma_m_1 = (tCI(2) - tCI(1))/2;
        end
        
        gamma_m_1 = fitresult.b;


    end

    set(gca, 'YScale', 'log')
    set(gca, 'XScale', 'log')
    xlabel('T (bins)')
    ylabel('<S>(T)')



end