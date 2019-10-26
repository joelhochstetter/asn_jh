function plotPhaseTransitionVC(V,C, saveFolder)
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(2,1,1);
    semilogy(V,C,'x-');
    xlabel 'V/V_{set}/n (V)'
    ylabel 'G (S)'
    title '2nd order phase transition in Conductance'

    subplot(2,1,2);
    semilogy(V,V.^2.*C,'x-');
    xlabel 'V (V)'
    ylabel 'P (W)'
    title 'Power dissipated vs Voltage'
    
    if nargin == 3 
        saveas(gcf,strcat(saveFolder,'/analysis/NetworkPhasePlot.png'))
    end
end