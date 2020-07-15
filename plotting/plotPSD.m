function [beta, dbeta] = plotPSD(t, G)
%{
    Plots the conductance power spectrum to the current figure given time
    (t) and conductance (G)

%}
    
    cLevel = 0.95;
    beta = 0;
    dbeta = inf;
    G = reshape(G, size(t));
    G(isnan(G)) = 0;
    
    dt = (t(end) - t(1))/(numel(t) - 1);
    t  = t(1):dt:t(end);
    
    [t_freq, conductance_freq] = fourier_analysis(t, G);
    conductance_freq = reshape(conductance_freq, size(t_freq));
   
    if numel(t_freq) < 2 
        return
    end
    
%     conductance_freq(conductance_freq <= 0) = 1e-10;
%     log10(t_freq(t_freq ~= 0 & t_freq<max(t_freq)))'
%     log10(conductance_freq(t_freq ~= 0 & t_freq<max(t_freq)))'
    
    % Linear fit for log-log plot of PSD:
    fitRes = polyfitn(log10(t_freq(t_freq ~= 0 & t_freq<max(t_freq)))', log10(conductance_freq(t_freq ~= 0 & t_freq<max(t_freq)))', 1);
    fitCoef = fitRes.Coefficients;
    errors  = fitRes.ParameterStd;
    
    fitCoef(2) = 10^fitCoef(2); 
    PSDfit = fitCoef(2)*t_freq.^fitCoef(1);
    
    loglog(t_freq,conductance_freq);
    xlim([min(t_freq), max(t_freq)]);
    hold on;
    loglog(t_freq,PSDfit,'r');
    
    text(0.5,0.8,sprintf('\\beta=%.1f', -fitCoef(1)),'Units','normalized','Color','r','FontSize',18);
    title('Conductance PSD');
    xlabel('Frequency (Hz)');
    ylabel('PSD');
    ylim([min(conductance_freq)/10,max(conductance_freq)*10]);
    set(gca,'Ytick',10.^(-20:1:20));
    grid on;

    beta = -fitCoef(1);
    
    dbeta = errors(1);

end