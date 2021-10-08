function [beta, dbeta] = plotPSD(t, G, fitLims, npts)
%{
    Plots the conductance power spectrum to the current figure given time
    (t) and conductance (G)
    

    fitLims = [lc, uc]: is the range of the fit
%}

    if nargin < 4
        npts = numel(t);
    end
    
    
    beta = 0;
    dbeta = inf;
    G = reshape(G, size(t));
    G(isnan(G)) = 0;
    
    dt = (t(end) - t(1))/(numel(t) - 1);
    t  = t(1):dt:t(end);
    
    [t_freq, conductance_freq] = fourier_analysis(t, G, npts);
    conductance_freq = reshape(conductance_freq, size(t_freq));
   
    if numel(t) < 10 
        return
    end
    
%     conductance_freq(conductance_freq <= 0) = 1e-10;
%     log10(t_freq(t_freq ~= 0 & t_freq<max(t_freq)))'
%     log10(conductance_freq(t_freq ~= 0 & t_freq<max(t_freq)))'
    
    if nargin < 3
        fitLims = [min(t_freq(t_freq > 0))*10, max(t_freq)/2];
    end



    % Linear fit for log-log plot of PSD:
    fitRes = polyfitn(log10(t_freq(t_freq > fitLims(1) & t_freq < fitLims(2)))', log10(conductance_freq(t_freq > fitLims(1) & t_freq < fitLims(2)))', 1);
    fitCoef = fitRes.Coefficients;
    errors  = fitRes.ParameterStd;
    
    if isnan(fitRes.Coefficients(1))
        return
    end
    
    fitCoef(2) = 10^fitCoef(2); 
    PSDfit = fitCoef(2)*t_freq.^fitCoef(1);
    
    loglog(t_freq,conductance_freq, 'k');
    xlim([min(t_freq), max(t_freq)]);
    hold on;
    loglog(t_freq(t_freq > fitLims(1) & t_freq < fitLims(2)), PSDfit(t_freq > fitLims(1) & t_freq < fitLims(2)),'b');
    
    text(0.5,0.8,sprintf('\\beta=%.1f', -fitCoef(1)),'Units','normalized','Color','b','FontSize',12);
%     title('Conductance PSD');
    xlabel('Frequency (Hz)');
    ylabel('PSD');
    ylim([min(conductance_freq)/10,max(conductance_freq)*10]);
    set(gca,'Ytick',10.^(-30:5:20));
%     grid on;

    beta = -fitCoef(1);
    
    dbeta = errors(1);

end