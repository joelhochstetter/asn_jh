function results = critAnalysis(events, dt, G, time, V, filename, saveFolder, fitML, binSize, joinperiod, saveNetC)
%{
    Given a conductance cut-off (G1) performs the criticality analysis
    on a given conductance dataset

    Input:
        events (Nx1 vectors): events
        dt (positive float): Time bin
        G  (Nx1 vector)    : Conductance time-series
        time (Nx1 vector)  : Time vector
        V (Nx1 vector)     : Voltage time-series
        savefolder (string): Folder to save the results struct and images
        useML (boolean): use maximum likelihood methods for a slower but
        more accurate fit
        binSize (integer): number of time-steps. if number less than zero
        is provided use the mean(IEI)
        joinperiod (integer):  for time series which join an ensemble of
        different simulations stores periodicity so ignores events calculated 
        between adjacent simulations
        Use -1 for simulations which aren't joins

    Outputs:
        results (struct): Saves the results 
%}
    
    if nargin < 10
        joinperiod = -1;
        if nargin < 9
            binSize = -1;
            if nargin < 8
                fitML = false;
            end
        end
    end
    
    if nargin < 11
        saveNetC = false;
    end

    if numel(time) == 0
        return
    end
    
    
    useLogBins = false;
    fitTrun          = true;
    
    
    mkdir(saveFolder)
    
    results = struct();
    
    results.filename = filename;
    
    V = reshape(V, 1, numel(V));    
    G = reshape(G, 1, numel(G));
    
    %% conductance
    if saveNetC
        results.net.G = G;    %network conductance
    end
    
%     results.net.t = time; %time vector
    results.net.dt = dt; %time vector
    results.net.T = time(end) - time(1) + dt; %time vector
    results.net.V = V;    %voltage
    results.net.meanG = mean(G);
    results.net.Grat  = max(G)/min(G);

    results.net.meanV = mean(V);
%     results.net.meanI = mean(G.*V);
    results.net.mdGdt = (G(end) - G(1))/(time(end) - time(1));
    results.net.mindG = min(abs(diff(G))/dt);
    results.net.maxdG = max(abs(diff(G))/dt);
    results.net.stddG = std(abs(diff(G))/dt);
    
    if abs(results.net.maxdG*dt) <= eps
        return
    end

    if numel(time) < 10
        return
    end
    
    %% Fourier transform
%     figure('visible','off');
%     [beta, dbeta] = plotPSD(time, G);
%     results.PSD.beta  = nan;%beta;
%     results.PSD.dbeta = nan;%dbeta;
%     %need to give uncertainity as well
%     saveas(gcf, strcat(saveFolder, '/PSD.png'))
%     close all;
    
    %% Auto correlation function
%     figure('visible','off');
%     [alpha, dalph] = plotACF(G, dt, true, struct('cLevel', 0.95));
%     results.ACF.alpha  = alpha;
%     results.ACF.dalph = dalph;
%     saveas(gcf, strcat(saveFolder, '/ACF.png'))
%     close all;
    
    
    %% dG distribution
%     figure('visible','off');
%     results.dG = plotDeltaG(G, 0, struct('useML', false), joinperiod);%fitML));
%     saveas(gcf, strcat(saveFolder, '/dG.png'))
%     close all;
    
    %% Event trains
    results.events.eventTrain     = events;
    results.events.numEvents      = sum(events);
    results.events.eventFraction  = sum(events)/numel(time);
    
    if results.events.numEvents < 2
        'TERMINATING: No events';
        return;
    end
    
    
    dG = gradient(G);
    dG(isnan(dG)) = 0;
    
    figure('units','normalized','outerposition',[0 0 1 1], 'visible','off');
    subplot(2,2,1);
    plot(time, G)
    hold on;
    plot(time(events > 0), G(events > 0), 'o')
    xlabel('t (s)')
    ylabel('G (S)')
    legend('G', 'event')

    subplot(2,2,2)
    imagesc(time, 1, events)

    subplot(2,2,3)
    plot(time, dG)
    hold on;
    plot(time(events > 0), dG(events > 0), 'o')
    xlabel('t (s)')
    ylabel('\Delta G (S)')
    legend('\Delta G', 'event')

    subplot(2,2,4)
    plot(time, G)
    yyaxis right;
    plot(time, dG)
    xlabel('t (s)')
    ylabel('\Delta G (S)')

    saveas(gcf, strcat(saveFolder, '/eventTrain.png'))
    close all;
    
    
    %% Inter-event interval
    figure('visible','off');
    results.IEI = plotIEIfromEvents(events, time, struct('useML', false), joinperiod);%fitML), joinperiod);
    saveas(gcf, strcat(saveFolder, '/IEIdist.png'))
    close all;

    
    
    %% Avalanche stats: 
    % If binSize = -x (where x > 0) then we use some multiple of the mean(IEI). E.g. -2 is 2*mean(IEI)
    if binSize < 0
        binSize = round(abs(binSize)*results.IEI.meanIEI);
        if isnan(binSize)
            binSize = 1;
        end
    end
    binned = binData(events, binSize);
    [sizeAv, lifeAv, timeAv] = avalancheStats(binned, 1:numel(binned));
    results.avalanche.sizeAv = sizeAv;
    results.avalanche.lifeAv = lifeAv;
    results.avalanche.timeAv = timeAv;    
    results.avalanche.binSize = binSize;   
    
    
    if numel(unique(sizeAv)) <= 2
        return
    end
    
    %% Avalanche size:
    figure('visible','off');
    [tau, dta, xmn, xmx, pvl, pcr, ksd, bins, prob,MLcompare] = plotAvalancheSize(sizeAv, struct('useML', fitML, 'logBin', useLogBins, 'fitTrun', fitTrun));
    results.avalanche.sizeFit.tau = tau;
    results.avalanche.sizeFit.dTau = dta;
    results.avalanche.sizeFit.lc  = xmn;
    results.avalanche.sizeFit.uc  = xmx;
    results.avalanche.sizeFit.pvl = pvl;
    results.avalanche.sizeFit.pcr = pcr;
    results.avalanche.sizeFit.ksd = ksd;
    results.avalanche.sizeFit.bins = bins;
    results.avalanche.sizeFit.prob = prob;
    results.avalanche.sizeFit.MLcompare = MLcompare;
    saveas(gcf, strcat(saveFolder, '/avSize.png'))
    close all;
    
    
    %% Avalanche lifetime:
    if numel(unique(lifeAv)) <= 1
        return
    end
    
    figure('visible','off');
    [alp, dal, xmn, xmx, pvl, pcr, ksd, bins, prob, MLcompare] = plotAvalancheLifetime(lifeAv, struct('useML', fitML, 'logBin', useLogBins, 'fitTrun', fitTrun));
    results.avalanche.timeFit.alpha = alp;
    results.avalanche.timeFit.dAlpha = dal;
    results.avalanche.timeFit.lc  = xmn;
    results.avalanche.timeFit.uc  = xmx;
    results.avalanche.timeFit.pvl = pvl;
    results.avalanche.timeFit.pcr = pcr;
    results.avalanche.timeFit.ksd = ksd;  
    results.avalanche.timeFit.bins = bins;
    results.avalanche.timeFit.prob = prob;    
    results.avalanche.timeFit.MLcompare = MLcompare;    
    saveas(gcf, strcat(saveFolder, '/avLife.png'))
    close all;
    
    
    %% <S>(T)
    figure('visible','off');
    [gamma_m_1, dgamma_m_1, mSize, mLife] = plotAvalancheAveSize(sizeAv, lifeAv, struct('lc', xmn, 'uc', xmx));
    results.avalanche.avSizeFit.mSize = mSize;
    results.avalanche.avSizeFit.mLife = mLife;
    results.avalanche.avSizeFit.gamma_m_1 = gamma_m_1;
    results.avalanche.avSizeFit.dgamma_m_1 = dgamma_m_1;    
    saveas(gcf, strcat(saveFolder, '/avAvSize.png'))
    close all;

    
    
    %% Avalanche shape analysis
    [dur, size_t, time_t] = avalancheShape(binned);
    results.avalanche.shape.dur    = dur;
    results.avalanche.shape.size_t = size_t;
    results.avalanche.shape.time_t = time_t;
    
    %size distribution
    figure('visible','off');
    hold on;
    for i = 2:numel(dur)
        plot(time_t{i},size_t{i})
    end
    xlabel('t (bins)')
    ylabel('s(t) (events)')
    title('Average avalanche shape as a function of time');
    saveas(gcf, strcat(saveFolder, '/avShape.png'))
    close all;

    
    %% Shape collapse and scaling function
    [re_tm,re_sz, scale, acoeff, gamma] = avalancheShapeCollapse(dur, size_t, time_t);
    results.avalanche.shape.re_tm  = re_tm;
    results.avalanche.shape.re_sz  = re_sz;
    results.avalanche.shape.scale  = scale;
    results.avalanche.shape.acoeff = acoeff;
    results.avalanche.shape.gamma  = gamma;
    
    figure('visible','off');
    hold on;
    for i = 2:numel(dur)
        plot(re_tm{i}, scale{i}, '.--')
    end
    tt = 0:1e-3:1;
    plot(tt, scaleFunction(tt, 1, acoeff, 1), '-', 'LineWidth',4)
    xlabel('t (bins)')
    ylabel('s(t) (events)')
    title('Scaling function')
    saveas(gcf, strcat(saveFolder, '/avScalingFun.png'))    
    close all;

    
    %% Comparison of independent measures of gamma+1
    alpha = results.avalanche.timeFit.alpha;
    dal   = results.avalanche.timeFit.dAlpha;
    tau   = results.avalanche.sizeFit.tau;
    dta   = results.avalanche.sizeFit.dTau;
    
    results.avalanche.gamma.x1  = (alpha - 1)/(tau - 1);
    results.avalanche.gamma.dx1 = results.avalanche.gamma.x1 * sqrt((dta/tau)^2 + (dal/alpha)^2);   
    results.avalanche.gamma.x2  = gamma_m_1; 
    results.avalanche.gamma.dx2 = dgamma_m_1;
    results.avalanche.gamma.x3  = 1 +gamma;
    results.avalanche.gamma.dx3 = 0;
    
    save(strcat(saveFolder, '/critResults.mat'), 'results');
    
end