function [spLam, spRes, spVol] = compareSimsLVC(sims, V, C, idx, edges, savePath)
%Compares simulations on switch lambda, voltage, conductance
%To save enter a folder path for saving and a filename


    spLam = zeros(numel(sims),numel(edges));
    spRes = zeros(numel(sims),numel(edges));
    spVol = zeros(numel(sims),numel(edges));

    for j = 1:numel(sims)
        spLam(j,:) = sims{j}.swLam(idx(j),edges);
        spRes(j,:) =  sims{j}.swC(idx(j),edges);
        spVol(j,:) = sims{j}.swV(idx(j),edges);   
    end
    
    figure('units','normalized','outerposition',[0 0 1 1]);
    subplot(3,1,1)
    semilogy(V,abs(spRes),'x-')
    xlabel 'V (V)'
    ylabel 'Switch Conductance (S)'
    title 'DC Activation (tunnelling model) - switch conductance values'
    yyaxis right
    semilogy(V,C,'--');
    ylabel 'Network Conductance (S)'
    legend(cellstr(num2str(edges)),'net')


    subplot(3,1,2)
    plot(V,abs(spLam),'x-')
    xlabel 'V (V)'
    ylabel '\lambda (Vs)'
    title 'DC Activation (tunnelling model) - switch \lambda values'
    yyaxis right
    semilogy(V,C,'--');
    ylabel 'Network Conductance (S)'
    legend(cellstr(num2str(edges)),'net')
    ylim([0,0.15])

    subplot(3,1,3)
    plot(V,abs(spVol),'x-')
    xlabel 'V (V)'
    ylabel '\Delta V (V)'
    title 'DC Activation (tunnelling model) - switch V values'
    yyaxis right
    semilogy(V,C,'--');
    ylabel 'Network Conductance (S)'
    legend(cellstr(num2str(edges)),'net')

    if nargin == 6
        saveas(gcf, savePath);
    end
end