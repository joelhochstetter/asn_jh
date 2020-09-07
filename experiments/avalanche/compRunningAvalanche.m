function compRunningAvalanche()


    %%
    dt = 1e-3;
    T  = 30;
    bin = 500;


    numTSteps = round(T/dt);
    numSims = 500;
    events = load('events.mat');
    load('critResults')
    load('netC.mat')
    events = events.events;
    timeVec = 1:numel(events);
    timeVec = mod(timeVec - 1, numTSteps) + 1;
    time1 = [1:numTSteps]';
    netCav     = mean(reshape(netC, [numTSteps, numSims]),2);
    eventAvg = mean(reshape(events, [numTSteps, numSims]),2);
    ieiAvg =  runningMeanSeq(critResults.IEI.ieiDat, timeVec(critResults.IEI.ieiTime(2:end)), numTSteps, bin);
    SAvg =  runningMeanSeq(critResults.avalanche.sizeAv, timeVec(critResults.avalanche.timeAv), numTSteps, bin);
    TAvg =  runningMeanSeq(critResults.avalanche.lifeAv, timeVec(critResults.avalanche.timeAv), numTSteps, bin);



    %% Net C for all simulations
    figure;
    plot(time1, reshape(netC, [numTSteps, numSims]))
    xlabel('t (s)')
    ylabel('G (S)')
    title('Ensemble conductance time-series')

    %%
    maxG = max(reshape(netC, [numTSteps, numSims]));
    minG  = min(reshape(netC, [numTSteps, numSims]));
    figure;
    subplot(1,3,1);
    histogram(maxG)
    ylabel('Counts')
    xlabel('G_{max}')
    subplot(1,3,2);
    histogram(minG)
    xlabel('G_{min}')
    subplot(1,3,3);
    histogram(maxG./minG)
    xlabel('G_{max}/G_{min}')
    mtit('Ensemble conductance histograms')


    %% Events as a function of time
    figure;
    plot(time1*dt, eventAvg/dt, '.');
    hold on;
    plot(time1*dt, runningMean(eventAvg, 20)/dt, '-', 'LineWidth', 2);
    xlabel('time (s)')
    ylabel('Events per second')
    yyaxis right;
    semilogy(time1*dt, netCav, '-', 'LineWidth', 2);
    ylabel('<G>(t) (S)')


    %% IEI as a function of time
    figure;
    plot(time1*dt, ieiAvg, '-', 'LineWidth', 2);
    hline(critResults.IEI.meanIEI);
    xlabel('time (s)')
    ylabel('<IEI> per time')
    yyaxis right;
    plot(time1*dt, netCav, '-', 'LineWidth', 2);
    ylabel('<G>(t) (S)')

    %% Branching ratio as a function of time
    figure;
    plot(time1*dt, brAvg, '-', 'LineWidth', 2);
    xlabel('time (s)')
    ylabel('\sigma')
    yyaxis right;
    plot(time1*dt, netCav, '-', 'LineWidth', 2);
    ylabel('<G>(t) (S)')
    


    %% <S> as a function of time
    figure;
    plot(time1*dt, SAvg, '-', 'LineWidth', 2);
    xlabel('time (s)')
    ylabel('<S> per time')
    yyaxis right;
    plot(time1*dt, netCav, '-', 'LineWidth', 2);
    ylabel('<G>(t) (S)')


    %% <T> as a function of time
    figure;
    plot(time1*dt, TAvg, '-', 'LineWidth', 2);
    % hline(critResults.IEI.meanIEI);
    xlabel('time (s)')
    ylabel('<T> per time')
    yyaxis right;
    plot(time1*dt, netCav, '-', 'LineWidth', 2);
    ylabel('<G>(t) (S)')


    %%
    figure;
    subplot(1,2,1);
    loglog(netC(critResults.avalanche.timeAv),  critResults.avalanche.sizeAv, '.')
    xlabel('G (S)')
    ylabel('S')
    subplot(1,2,2);
    loglog(netC(critResults.avalanche.timeAv),  critResults.avalanche.lifeAv, '.')
    xlabel('G (S)')
    ylabel('T')
    mtit('Conductance dependence of avalanches')

end