function timeSeriesLVC(sims, edges, tend, savePath)
%Compares simulations on switch lambda, voltage, conductance
%To save enter a folder path for saving and a filename
    
    if isstruct(sims)
        sims = {sims};
    end


    spLam = sims{1}.swLam(:,edges);
    spRes =  sims{1}.swC(:,edges);
    spVol = sims{1}.swV(:,edges); 
    tvec = sims{1}.Stim.TimeAxis;
    
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(3,1,1)
    semilogy(tvec,abs(spRes))
    xlabel 'time (s)'
    ylabel 'Switch Conductance (S)'
    title 'switch conductance values'
    yyaxis right
    semilogy(tvec,sims{1}.netC,'--');
    ylabel 'Network Conductance (S)'
    legend(cellstr(num2str(edges)),'net')
    xlim([0,tend]);

    subplot(3,1,2)
    plot(tvec,abs(spLam))
    xlabel 'time (s)'
    ylabel '\lambda (Vs)'
    title 'switch \lambda values'
    yyaxis right
    semilogy(tvec,sims{1}.netC,'--');
    ylabel 'Network Conductance (S)'
    legend(cellstr(num2str(edges)),'net')
    xlim([0,tend]);

    subplot(3,1,3)
    plot(tvec,abs(spVol))
    xlabel 'time (s)'
    ylabel '\Delta V (V)'
    title 'switch V values'
    yyaxis right
    semilogy(tvec,sims{1}.netC,'--');
    ylabel 'Network Conductance (S)'
    legend(cellstr(num2str(edges)),'net')
    xlim([0,tend]);
    
    if nargin == 4
        saveas(gcf, savePath);
    end
end