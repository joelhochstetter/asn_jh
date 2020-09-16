function compRunningAvalanche(baseFolder, vals, subtype, binSize, numSims, T, window, dt, fmt, ACfreq)
%{
    Plots comparison between avalanche simulations when changing a
    parameter, for different binSizes. This is for running time-series

    Inputs:
        baseFolder: folder where simulations are found
                    vals: possible values of the independ

Examples:
compRunningAvalanche('/import/silo2/joelh/Criticality/Avalanche/BigNetwork/RectElectChangeV/avNew', sort([0.7:0.1:1.8, 1.05]), 'Vstar', -[0.5,1,2])
compRunningAvalanche('/import/silo2/joelh/Criticality/Avalanche/ACavalanches/AvChangeFreqNew/', 0.25:0.25:1, 'f', -1, 100, 100, 5, 1e-3, '%g', 0.25:0.25:1)
%}

    %% defaults
    if nargin < 5
        numSims = 500;
    end
    
    if nargin < 6
        T = 30;
    end
    
    if nargin < 7
        window = 500;
    end
    
    if nargin < 8
       dt = 1e-3; 
    end
    
    if nargin < 9
        fmt = '%g';
    end

    if nargin < 10
        ACfreq = -1;
    end
    
    %% reshape data
    vals = reshape(vals, [numel(vals),1]);
    binSize = reshape(binSize, [numel(binSize),1]);
    
    %% basic set-up
    close all;
    
    cd(baseFolder)
    saveFolder = strcat(baseFolder, '/RunningAv/');
    mkdir(saveFolder)

    N = numel(vals);
    Nbs = numel(binSize);    
    numTSteps = round(T/dt);
    timeVec = 1:(numSims*numTSteps);
    timeVec = mod(timeVec - 1, numTSteps) + 1;
    time1 = [1:numTSteps]';    
    time0 = time1;
    numTSteps0 = numTSteps;
    numSims0 = numSims;
    timeVec0 = timeVec;
    
    
    %% handle AC date
    if numel(ACfreq) == 1
        ACfreq = ACfreq*ones(size(vals));
    else 
        assert(numel(ACfreq) == numel(vals));
    end
    
    
    %% Loop over each simulation
    for i = 1:N
        close all;
        
        %% handle AC 
        if ACfreq(i) > 0
            PeriodTSteps = 1/(ACfreq(i)*dt);
            timeVec = floor(mod(timeVec0 - 1,  PeriodTSteps) + 1); %modulo doesnt need to be integer
            k = floor(numTSteps/PeriodTSteps);
            numTSteps = ceil(PeriodTSteps);
            numSims = k*numSims0;
            time1 = [1:numTSteps]';             
        end
        
        %%
        load(strcat2({baseFolder, '/', subtype, num2str(vals(i), fmt),'/events.mat'}), 'events');
        load(strcat2({baseFolder, '/', subtype, num2str(vals(i), fmt),'/netC.mat'}), 'netC');
        if numel(netC) == numTSteps*numSims %works for DC and AC integer number of periods
            netCAvg     = mean(reshape(netC, [numTSteps, numSims]),2);
            eventAvg = mean(reshape(events, [numTSteps, numSims]),2);  
        else %works for AC non-integer number of periods
            netCAvg =  runningMeanSeq(netC, timeVec, numTSteps, 1);            
            eventAvg =  runningMeanSeq(events, timeVec, numTSteps, 1);                        
        end
            
        
        
        %% Loop over bins
        for j = 1:Nbs
            close all;
            
            bs = binSize(j);
            
            %% import and set-up
            load(strcat2({baseFolder, '/', subtype, num2str(vals(i), fmt), '/bs', bs, '/critResults.mat'}), 'critResults');
            brAvg =  runningMeanSeq(critResults.avalanche.branchAv, timeVec(critResults.avalanche.timeAv), numTSteps, window);
            SAvg =  runningMeanSeq(critResults.avalanche.sizeAv, timeVec(critResults.avalanche.timeAv), numTSteps, window);
            TAvg =  runningMeanSeq(critResults.avalanche.lifeAv, timeVec(critResults.avalanche.timeAv), numTSteps, window);
            SMax =  runningMaxSeq(critResults.avalanche.sizeAv, timeVec(critResults.avalanche.timeAv), numTSteps, window);
            SMin =  runningMinSeq(critResults.avalanche.sizeAv, timeVec(critResults.avalanche.timeAv), numTSteps, window);
            TMax =  runningMaxSeq(critResults.avalanche.lifeAv, timeVec(critResults.avalanche.timeAv), numTSteps, window);
            TMin =  runningMinSeq(critResults.avalanche.lifeAv, timeVec(critResults.avalanche.timeAv), numTSteps, window);
            
            saveFolder = strcat2({baseFolder, '/RunningAv/', subtype, num2str(vals(i), fmt), '/bs', binSize(j)});        
            mkdir(saveFolder)
            
            %% Plotting
            %% Branching ratio as a function of time
            figure('visible', 'off');
            plot(time1*dt, brAvg, '-', 'LineWidth', 2);
            xlabel('time (s)')
            ylabel('\sigma')
            yyaxis right;
            semilogy(time1*dt, netCAvg, '-', 'LineWidth', 2);
            ylabel('<G>(t) (S)')
            if T == 30
                xticks(0:30); 
                ax = gca;
                labels = string(ax.XAxis.TickLabels); % extract
                labels([2:5:end, 3:5:end, 4:5:end, 5:5:end]) = ''; % remove every other one
                xticklabels(labels);
            end
            print(gcf,strcat(saveFolder, '/meanBranch.png'), '-dpng', '-r300', '-painters') 

            %% <S> as a function of time
            figure('visible', 'off');
            semilogy(time1*dt, SAvg, '-', 'LineWidth', 2);
            hold on;
            plot(time1*dt, SMin, '-', 'LineWidth', 2);
            plot(time1*dt, SMax, '-', 'LineWidth', 2);
            xlabel('time (s)')
            ylabel('S per time')
            yyaxis right;
            plot(time1*dt, netCAvg, '-', 'LineWidth', 2);
            ylabel('<G>(t) (S)')
            legend('<S>', 'S_{min}', 'S_{max}', 'G')
            print(gcf,strcat(saveFolder, '/aveSize.png'), '-dpng', '-r300', '-painters') 

            %% <T> as a function of time
            figure('visible', 'off');
            semilogy(time1*dt, TAvg, '-', 'LineWidth', 2);
            hold on;
            plot(time1*dt, TMin, '-', 'LineWidth', 2);
            plot(time1*dt, TMax, '-', 'LineWidth', 2);
            xlabel('time (s)')
            ylabel('T per time')
            yyaxis right;
            plot(time1*dt, netCAvg, '-', 'LineWidth', 2);
            ylabel('<G>(t) (S)')
            legend('<T>', 'T_{min}', 'T_{max}', 'G')
            print(gcf,strcat(saveFolder, '/aveTime.png'), '-dpng', '-r300', '-painters') 

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
            print(gcf,strcat(saveFolder, '/GvsAvST.png'), '-dpng', '-r300', '-painters') 
            
            
        end
        
        %% bin free plots (variables with no window dependence)
        saveFolder = strcat2({baseFolder, '/RunningAv/', subtype, num2str(vals(i), fmt), '/binFree'});
        mkdir(saveFolder)     
        ieiAvg =  runningMeanSeq(critResults.IEI.ieiDat, timeVec(critResults.IEI.ieiTime(2:end)), numTSteps, window);

        %% Net C for all simulations
        figure('visible', 'off');
        plot(time0, reshape(netC, [numTSteps0, numSims0]))
        xlabel('t (s)')
        ylabel('G (S)')
        title('Ensemble conductance time-series')
        print(gcf,strcat(saveFolder, '/AllnetC.png'), '-dpng', '-r300', '-painters') 
        
        %% Conductance histrograms
        maxG = max(reshape(netC, [numTSteps0, numSims0]));
        minG  = min(reshape(netC, [numTSteps0, numSims0]));
        figure('visible', 'off');
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
%         mtit('Ensemble conductance histograms')
        print(gcf,strcat(saveFolder, '/HistnetC.png'), '-dpng', '-r300', '-painters') 
        
        %% Events as a function of time
        figure('visible', 'off');
        semilogy(time1*dt, eventAvg/dt, '.');
        hold on;
        plot(time1*dt, runningMean(eventAvg, window)/dt, '-', 'LineWidth', 2);
        xlabel('time (s)')
        ylabel('Events per second')
        yyaxis right;
        semilogy(time1*dt, netCAvg, '-', 'LineWidth', 2);
        ylabel('<G>(t) (S)')
        print(gcf,strcat(saveFolder, '/eventRate.png'), '-dpng', '-r300', '-painters') 


        %% IEI as a function of time
        figure('visible', 'off');
        semilogy(time1*dt, ieiAvg, '-', 'LineWidth', 2);
        hline(critResults.IEI.meanIEI);
        xlabel('time (s)')
        ylabel('<IEI> per time')
        yyaxis right;
        semilogy(time1*dt, netCAvg, '-', 'LineWidth', 2);
        ylabel('<G>(t) (S)')
        if T == 30
            xticks(0:30); 
            ax = gca;
            labels = string(ax.XAxis.TickLabels); % extract
            labels([2:5:end, 3:5:end, 4:5:end, 5:5:end]) = ''; % remove every other one
            xticklabels(labels);
        end
        print(gcf,strcat(saveFolder, '/meanIEI.png'), '-dpng', '-r300', '-painters') 

    end
     
end