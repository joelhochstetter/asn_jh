function plot3TimeSeries(params)
%given parameter file plots time-series for conductance, voltage and lambda

    %% Import parameters
    sim = multiImport(params);
    sim = sim{1}; %Only one simulation

    time = sim.Stim.TimeAxis;
    Gjcn = sim.swC;
    Gnw = sim.netC;
    Vjcn = sim.swV;
    Vnw = sim.Stim.Signal;
    Lam = sim.swLam;

    E = sum(sim.adjMat(:))/2;
    sp  = graphallshortestpaths(sparse(double(sim.adjMat)));
    sd = sp(sim.ContactNodes(1), sim.ContactNodes(2));


    %% Conductance , voltage and Lambda
    figure('color','w', 'units', 'centimeters', 'OuterPosition', [10 10 30 30]);
    subplot(3,1,1);
    plot(time, Gjcn)
    xlabel('t', 'FontWeight', 'bold')
    ylabel('G_{jn}', 'FontWeight', 'bold')
    % set(gca, 'YScale', 'log')
    ylim([-0.05, 1.05])

    yyaxis right;
    plot(time, Gnw*sd, 'k--', 'LineWidth', 2)
%     ylim([-0.05, 1.05])
    xlabel('t', 'FontWeight', 'bold')
    ylabel('n G_{nw}', 'FontWeight', 'bold')
    leg = [string(1:E), 'net'];
    legend(leg, 'location', 'southeast')

    subplot(3,1,2);
    plot(time, Vjcn)
    xlabel('t', 'FontWeight', 'bold')
    ylabel('V_{jn}', 'FontWeight', 'bold')


    yyaxis right;
    plot(time, Vnw/sd, 'k--', 'LineWidth', 2)
    xlabel('t', 'FontWeight', 'bold')
    ylabel('V_{nw}/n', 'FontWeight', 'bold')
    leg = [string(1:E), 'net'];
    legend(leg, 'location', 'southeast')
    yyaxis left;
    hline(1);


    subplot(3,1,3);
    plot(time, Lam)
    xlabel('t', 'FontWeight', 'bold')
    ylabel('\Lambda', 'FontWeight', 'bold')
    leg = [string(1:E)];
    legend(leg, 'location', 'southeast')
    hline(0.1);
    hline(0.15);    

end
    