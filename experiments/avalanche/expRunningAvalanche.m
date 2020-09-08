function expRunningAvalanche(baseFolder, window)
%{
    Example usage:
        expRunningAvalanche('/import/silo2/joelh/nanowire-network-experimental/Adrian/Activation_Data_July_2020/S6.M1_2/act_preamp_100K_varying_voltage/Av/bs-1/', 50)

%}

    critFiles = dir(strcat(baseFolder, '/Avalanche*/critResults.mat'));
    saveFolder   = strcat(baseFolder, '/RunningAv/');
    

    %%
    for i = 1:numel(critFiles)
        fname = split(critFiles(i).folder, '/');
        fname = char(fname(end));
        saveFolder1 = strcat(saveFolder, '/', fname);
        mkdir(fullfile(saveFolder1))
        load(strcat(critFiles(i).folder, '/', critFiles(i).name), 'results');
        dt = results.net.dt;
        netC = results.net.G;
        numTSteps = numel(netC);
        time1 = 1:numTSteps;
        brAvg =  runningMeanSeq(critResults.avalanche.branchAv, timeVec(critResults.avalanche.timeAv), numTSteps, window);
        SAvg =  runningMeanSeq(critResults.avalanche.sizeAv, timeVec(critResults.avalanche.timeAv), numTSteps, window);
        TAvg =  runningMeanSeq(critResults.avalanche.lifeAv, timeVec(critResults.avalanche.timeAv), numTSteps, window);

        %% Branching ratio as a function of time
        figure('visible', 'off');
        plot(time1*dt, brAvg, '-', 'LineWidth', 2);
        xlabel('time (s)')
        ylabel('\sigma')
        yyaxis right;
        plot(time1*dt, netC, '-', 'LineWidth', 2);
        ylabel('<G>(t) (S)')
        print(gcf,strcat(saveFolder1, '/meanBranch.png'), '-dpng', '-r300', '-painters') 

        %% <S> as a function of time
        figure('visible', 'off');
        semilogy(time1*dt, SAvg, '-', 'LineWidth', 2);
        xlabel('time (s)')
        ylabel('S per time')
        yyaxis right;
        plot(time1*dt, netC, '-', 'LineWidth', 2);
        ylabel('<G>(t) (S)')
        legend('<S>', 'S_{min}', 'S_{max}', 'G')
        print(gcf,strcat(saveFolder1, '/aveSize.png'), '-dpng', '-r300', '-painters') 

        %% <T> as a function of time
        figure('visible', 'off');
        semilogy(time1*dt, TAvg, '-', 'LineWidth', 2);
        xlabel('time (s)')
        ylabel('T per time')
        yyaxis right;
        plot(time1*dt, netC, '-', 'LineWidth', 2);
        ylabel('<G>(t) (S)')
        legend('<T>', 'T_{min}', 'T_{max}', 'G')
        print(gcf,strcat(saveFolder1, '/aveTime.png'), '-dpng', '-r300', '-painters') 

        %%
        figure('visible', 'off');
        subplot(1,2,1);
        loglog(netC(critResults.avalanche.timeAv),  critResults.avalanche.sizeAv, '.')
        Gmin = 10^(floor(min(log10(netC))));
        Gmax = 10^(ceil(max(log10(netC))));            
        xlim([Gmin,Gmax])
        xlabel('G (S)')
        ylabel('S')
        subplot(1,2,2);
        loglog(netC(critResults.avalanche.timeAv),  critResults.avalanche.lifeAv, '.')
        xlabel('G (S)')
        ylabel('T')
        xlim([Gmin,Gmax])            
    %             mtit('Conductance dependence of avalanches')
        print(gcf,strcat(saveFolder1, '/GvsAvST.png'), '-dpng', '-r300', '-painters')     

        %% bin free plots (variables with no window dependence)
        ieiAvg =  runningMeanSeq(critResults.IEI.ieiDat, timeVec(critResults.IEI.ieiTime(2:end)), numTSteps, window);

        %% Events as a function of time
        figure('visible', 'off');
        semilogy(time1*dt, eventAvg/dt, '.');
        hold on;
        plot(time1*dt, runningMean(eventAvg, window)/dt, '-', 'LineWidth', 2);
        xlabel('time (s)')
        ylabel('Events per second')
        yyaxis right;
        semilogy(time1*dt, netC, '-', 'LineWidth', 2);
        ylabel('<G>(t) (S)')
        print(gcf,strcat(saveFolder1, '/eventRate.png'), '-dpng', '-r300', '-painters') 


        %% IEI as a function of time
        figure('visible', 'off');
        semilogy(time1*dt, ieiAvg, '-', 'LineWidth', 2);
        hline(critResults.IEI.meanIEI);
        xlabel('time (s)')
        ylabel('<IEI> per time')
        yyaxis right;
        plot(time1*dt, netC, '-', 'LineWidth', 2);
        ylabel('<G>(t) (S)')
        print(gcf,strcat(saveFolder1, '/meanIEI.png'), '-dpng', '-r300', '-painters')     

    end
end