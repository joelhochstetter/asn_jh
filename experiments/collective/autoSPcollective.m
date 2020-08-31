function autoSPcollective(params)
%{
    Runs shortest path collective for a given parameter file, 
%}

    multiRun(params);
    t = multiImport(params);


    %%
    sim = t{1};
    contacts = sim.ContactNodes;
    Connectivity          = struct('filename', sim.ConnectFile);
    Connectivity          = getConnectivity(Connectivity);


    %%%
    adjMat       = Connectivity.weights;
    sp  = kShortestPath(adjMat, contacts(1), contacts(2), 10);
    spE = getPathEdges(sp{1}, Connectivity.EdgeList);

    %%%
    dt        = sim.dt;
    timeVec   = dt:dt:sim.T;

    %% Contour
    timeVector = timeVec;

    figure('color','w', 'units', 'centimeters', 'OuterPosition', [5 5 18 18]);
    %mesh(1:9, timeVector(1:10:60000), abs(sim.swV(1:10:60000,spE)));
    contourf(timeVector(1:1:end),1:9, abs(sim.swV(1:1:end,spE))'/1e-2)
    ylabel('Distance from source','fontweight','bold','fontsize',10);
    xlabel('t (s)','fontweight','bold','fontsize',10);
    % zlabel('Junction voltage (V)');
    colormap(parula)
    hcb = colorbar;
    % caxis([0,0.025])
    caxis([0,2.5])
    title(hcb,'V_{jn}^*', 'FontSize', 10, 'FontWeight', 'bold');
    hcb.FontSize = 10;
    hcb.FontWeight = 'bold';
    colormap inferno;
    xlim([0,7.5])
    set(gca,'YDir','normal')
    grid on;
    axis square
    print(gcf, strcat(params.SimOpt.saveFolder , '/PulsejunctionVoltage.png'), '-dpng', '-r300', '-painters')



    %% Conductance
    figure;
    tend = 15.0;
    cmap = parula(10);

    G0 = sim.Comp.onR;


    %Ordered by activitation time

    ordAct = [1,2,9,3,4,5,8,7,6];
    spA = spE(ordAct);

    hold on;

    h = [];

    for i = 9:-1:1
        h(i) = semilogy(timeVec,sim.swC(:,spA(i))/G0, '-', 'Color', cmap(10-ordAct(i), :));
    end


    xlabel('t (s)', 'FontWeight', 'bold')
    ylabel('G_{jn} (G_0)', 'FontWeight', 'bold')
    set(gca, 'YScale', 'log')
    ylim([0.8e-3,1.5])
    set(gca,'XLim',[0,tend])
    %set(gca, 'XTick',[0:5:80])
    set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);
    yyaxis right
    h(10) = semilogy(timeVec, 9*sim.netC/G0,'--','Linewidth',2., 'Color', 'r');
    ylabel('G_{nw}^*', 'Color','r', 'FontWeight', 'bold')
    set(gca,'YColor','red');
    % leg = [string(flip(ordAct)), 'net'];
    leg = [string(1:9), 'net'];
    ordLeg = [1,2,4,5,6,9,8,7,3, 10];
    myleg = legend(h(ordLeg), leg);
    title(myleg, 'Junction #', 'FontWeight', 'bold')

    set(gca, 'YScale', 'log')
    ylim([0.8e-3,1.5])
    axis square;
    box on;
    print(gcf, strcat(params.SimOpt.saveFolder, '/PulsejunctionConductance.png'), '-dpng', '-r300', '-painters')
    
end