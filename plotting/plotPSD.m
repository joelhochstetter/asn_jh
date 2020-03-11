function plotPSD(t, G)
%{
    Plots the conductance power spectrum to the current figure given time
    (t) and conductance (G)

%}
    
    G = reshape(G, size(t));
    
    [t_freq, conductance_freq] = fourier_analysis(t, G);
    conductance_freq = reshape(conductance_freq, size(t_freq));
    
    % Linear fit for log-log plot of PSD:
    fitCoef = polyfit(log10(t_freq(t_freq~=0 & t_freq<max(t_freq))), log10(conductance_freq(t_freq~=0 & t_freq<max(t_freq))), 1);
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


end