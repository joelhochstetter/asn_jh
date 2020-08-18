function compAvalancheEventDetection(baseFolder, vals, varName, subtype)

    vals = reshape(vals, [numel(vals),1]);
    
    %%
    close all;

    cd(baseFolder)
    saveFolder = strcat(baseFolder, '/AvCompare/');
    mkdir(saveFolder)
    binSize = [-1, 10, 50, 100];
    eventDetectMeths = 1:18;

    N = numel(vals);
    Nbs = numel(binSize);
    Nev = numel(eventDetectMeths);

    %%
    meanG = zeros(N,Nbs,Nev);
    V = zeros(N,Nbs,Nev);
    PSDbeta = zeros(N,Nbs,Nev);
    PSDdbet = zeros(N,Nbs,Nev);
    numEvents = zeros(N,Nbs,Nev);
    meanIEI = zeros(N,Nbs,Nev);
    IEItau = zeros(N,Nbs,Nev);
    IEIdta = zeros(N,Nbs,Nev);
    dGalpha = zeros(N,Nbs,Nev);
    dGdalph = zeros(N,Nbs,Nev);
    Stau = zeros(N,Nbs,Nev);
    Sdta = zeros(N,Nbs,Nev);
    Slct = zeros(N,Nbs,Nev);
    Suct = zeros(N,Nbs,Nev);
    Talp = zeros(N,Nbs,Nev);
    Tdal = zeros(N,Nbs,Nev);
    Tlct = zeros(N,Nbs,Nev);
    Tuct = zeros(N,Nbs,Nev);
    x1  = zeros(N,Nbs,Nev);
    dx1 = zeros(N,Nbs,Nev);
    x2  = zeros(N,Nbs,Nev);
    dx2 = zeros(N,Nbs,Nev);
    x3  = zeros(N,Nbs,Nev);
    dx3 = zeros(N,Nbs,Nev);
    kingAv = zeros(N,Nbs,Nev);
    IEIbins = cell(N,Nbs,Nev);
    IEIprob = cell(N,Nbs,Nev);
    dGbins  = cell(N,Nbs,Nev);
    dGprob  = cell(N,Nbs,Nev);
    Szbins  = cell(N,Nbs,Nev);
    Szprob  = cell(N,Nbs,Nev);
    Tmbins  = cell(N,Nbs,Nev);
    Tmprob  = cell(N,Nbs,Nev);
    ASlife  = cell(N,Nbs,Nev);
    ASsize  = cell(N,Nbs,Nev);

    critResults = cell(N,Nbs,Nev);


    %%
    for j = 1:Nbs
        bs = binSize(j);
        %Vvals = [0.113, 0.225, 0.338, 0.45, 0.562, 0.675, 0.787, 0.9];

        saveFolder = strcat(baseFolder, '/AvCompare/bs', num2str(bs),'/');
        mkdir(saveFolder);

        for k = 1:Nev
            for i = 1:numel(vals)
                critResults{i,j,k} = load(strcat2({baseFolder, '/', subtype, vals(i), '/event', eventDetectMeths(k), '/bs', bs, '/critResults.mat'}));
                critResults{i,j,k} = critResults{i,j,k}.critResults;
            end
        
            for i = 1:N
                meanG(i,j,k) = critResults{i,j,k}.net.meanG;
                V(i,j,k) = mean(critResults{i,j,k}.net.V);
                PSDbeta(i,j,k) = critResults{i,j,k}.PSD.beta;
                PSDdbet(i,j,k) = critResults{i,j,k}.PSD.dbeta;    
                numEvents(i,j,k) = critResults{i,j,k}.events.numEvents;
                meanIEI(i,j,k) = critResults{i,j,k}.IEI.meanIEI;
                IEItau(i,j,k) = critResults{i,j,k}.IEI.tau;
                IEIdta(i,j,k) = critResults{i,j,k}.IEI.sigmaTau;
                IEIbins{i,j,k} = critResults{i,j,k}.IEI.bins;
                IEIprob{i,j,k} = critResults{i,j,k}.IEI.prob;
                dGalpha(i,j,k) = critResults{i,j,k}.dG.alpha;
                dGdalph(i,j,k) = critResults{i,j,k}.dG.dalph;
                dGbins{i,j,k} = critResults{i,j,k}.dG.bins;
                dGprob{i,j,k} = critResults{i,j,k}.dG.prob;
                Stau(i,j,k) = critResults{i,j,k}.avalanche.sizeFit.tau;
                Sdta(i,j,k) = critResults{i,j,k}.avalanche.sizeFit.dTau;
                Slct(i,j,k) = critResults{i,j,k}.avalanche.sizeFit.lc;
                Suct(i,j,k) = critResults{i,j,k}.avalanche.sizeFit.uc;
                Szbins{i,j,k} = critResults{i,j,k}.avalanche.sizeFit.bins;
                Szprob{i,j,k} = critResults{i,j,k}.avalanche.sizeFit.prob;    
                Talp(i,j,k) = critResults{i,j,k}.avalanche.timeFit.alpha;
                Tdal(i,j,k) = critResults{i,j,k}.avalanche.timeFit.dAlpha;
                Tlct(i,j,k) = critResults{i,j,k}.avalanche.timeFit.lc;
                Tuct(i,j,k) = critResults{i,j,k}.avalanche.timeFit.uc;
                Tmbins{i,j,k} = critResults{i,j,k}.avalanche.timeFit.bins;
                Tmprob{i,j,k} = critResults{i,j,k}.avalanche.timeFit.prob;        
                ASlife{i,j,k} = critResults{i,j,k}.avalanche.avSizeFit.mLife;
                ASsize{i,j,k} = critResults{i,j,k}.avalanche.avSizeFit.mSize;         
                x1 (i,j,k) = critResults{i,j,k}.avalanche.gamma.x1;
                dx1(i,j,k) = critResults{i,j,k}.avalanche.gamma.dx1;
                x2 (i,j,k) = critResults{i,j,k}.avalanche.gamma.x2;
                dx2(i,j,k) = critResults{i,j,k}.avalanche.gamma.dx2;
                x3 (i,j,k) = critResults{i,j,k}.avalanche.gamma.x3;
                dx3(i,j,k) = critResults{i,j,k}.avalanche.gamma.dx3;
                bins = critResults{i,j,k}.avalanche.sizeFit.bins;
                prob = critResults{i,j,k}.avalanche.sizeFit.prob;
                [pks, locs] = findpeaks(prob);
                possMax = find(bins(locs) > critResults{i,j,k}.avalanche.sizeFit.uc);
                [~, I] = max(pks(possMax));
                if numel(I) > 0
                    kingAv(i,j,k) = bins(locs(possMax(I)));
                end
            end
        end

        %% Comparison by parameter
        %% dG
        figure('visible', 'off');
        errorbar(vals, dGalpha(:,j), dGdalph(:,j), '--o');
        xlabel(varName)
        ylabel('\alpha')
        yyaxis right;
        semilogy(vals, meanG(:,j), '-o');
        ylabel('<G>')
        title('\Delta G exponent')
        print(gcf,strcat(saveFolder, '/dGComp.png'), '-dpng', '-r300', '-painters')



        %% PSD
        figure('visible', 'off');
        errorbar(vals, PSDbeta(:,j), PSDdbet(:,j), '--o');
        xlabel(varName)
        ylabel('\beta')
        title('PSD exponent')
        print(gcf,strcat(saveFolder, '/PSDComp.png'), '-dpng', '-r300', '-painters')



        %% IEI
        figure('visible', 'off');
        errorbar(vals, IEItau(:,j), IEIdta(:,j), '--o');
        xlabel(varName)
        ylabel('\alpha')
        yyaxis right;
        semilogy(vals, meanIEI(:,j), 'o-');
        ylabel('<IEI>')
        title('Inter-event interval')
        print(gcf,strcat(saveFolder, '/IEIComp.png'), '-dpng', '-r300', '-painters')


        %% Size
        figure('visible', 'off');
        errorbar(vals, Stau(:,j), Sdta(:,j));
        xlabel(varName)
        ylabel('\tau')
        title('Avalanche size')
        yyaxis right;
        plot(vals, Slct(:,j), ':');
        hold on;
        plot(vals, Suct(:,j), 'k--');
        plot(vals, kingAv(:,j), 'r^', 'MarkerSize', 10)
        ylabel('cut-off')
        legend('\alpha', 'lc', 'uc', 'king', 'location', 'best')
        print(gcf,strcat(saveFolder, '/SizeComp.png'), '-dpng', '-r300', '-painters')


        %% Lifetime
        figure('visible', 'off');
        errorbar(vals, Talp(:,j), Tdal(:,j));
        xlabel(varName)
        ylabel('\alpha')
        title('Avalanche life-time')
        yyaxis right;
        plot(vals, Tlct(:,j), ':');
        hold on;
        plot(vals, Tuct(:,j), 'k--');
        ylabel('cut-off')
        legend('\alpha', 'lc', 'uc', 'location', 'best')
        print(gcf,strcat(saveFolder, '/LifeAv.png'), '-dpng', '-r300', '-painters')


        %% Gamma
        figure('visible', 'off');
        errorbar(vals,x1(:,j), dx1(:,j));
        hold on;
        errorbar(vals,x2(:,j), dx2(:,j));
        errorbar(vals,x3(:,j), dx3(:,j));
        xlabel(varName)
        ylabel('1/\sigma\tau\nu')
        legend('S,T', '<S>(T)', 'Shape', 'location', 'best')
        title('Crackling relationship')
        print(gcf,strcat(saveFolder, '/CrackComp.png'), '-dpng', '-r300', '-painters')


        %% Distributions
        %% IEI
        figure('visible', 'off');
        for i = 1:N 
            loglog(IEIbins{i,j}, IEIprob{i,j});
            hold on;
        end
        xlabel('T')
        ylabel('P(T)')
        title('IEI')
        leg = legend(num2str(vals), 'location', 'best');
        title(leg,varName)
        print(gcf,strcat(saveFolder, '/IEIPlot.png'), '-dpng', '-r300', '-painters')


        %% dG
        figure('visible', 'off');
        for i = 1:N 
            loglog(dGbins{i,j}, dGprob{i,j});
            hold on;
        end
        xlabel('\Delta G')
        ylabel('P(\Delta G)')
        title('\Delta G')
        leg = legend(num2str(vals), 'location', 'best');
        title(leg,varName)
        print(gcf,strcat(saveFolder, '/dGPlot.png'), '-dpng', '-r300', '-painters')



        %% Size
        figure('visible', 'off');
        for i = 1:N 
            loglog(Szbins{i,j}, Szprob{i,j});
            hold on;
        end
        xlabel('S')
        ylabel('P(S)')
        title('Avalanche size')
        leg = legend(num2str(vals), 'location', 'best');
        title(leg,varName)
        print(gcf,strcat(saveFolder, '/SizePlot.png'), '-dpng', '-r300', '-painters')


        %% Life
        figure('visible', 'off');
        for i = 1:N 
            loglog(Tmbins{i,j}, Tmprob{i,j});
            hold on;
        end
        xlabel('T')
        ylabel('P(T)')
        title('Avalanche life-time')
        leg = legend(num2str(vals), 'location', 'best');
        title(leg,varName)
        print(gcf,strcat(saveFolder, '/LifePlot.png'), '-dpng', '-r300', '-painters')



        %% Average Size
        figure('visible', 'off');
        for i = 1:N 
            loglog(ASlife{i,j}, ASsize{i,j});
            hold on;
        end
        xlabel('T')
        ylabel('<S>')
        title('Avalanche average size')
        leg = legend(num2str(vals), 'location', 'best');
        title(leg,varName)
        print(gcf,strcat(saveFolder, '/AvSzPlot.png'), '-dpng', '-r300', '-painters')

        %%
        close all;
    end






    %%
    %% Compare by bin-sizes
    for j = 1:N
        saveFolder = strcat(baseFolder, '/AvCompare/', subtype, num2str(vals(j)),'/');
        mkdir(saveFolder);

        %% Comparison by parameter
        binSize(1) = meanIEI(j,1);

        %% Size
        figure('visible', 'off');
        errorbar(binSize, Stau(j,:), Sdta(j,:), 'o');
        set(gca, 'xscale', 'log')
        set(gca, 'yscale', 'log')    
        xlabel('\Delta t')
        ylabel('\tau')
        title('Avalanche size')
        yyaxis right;
        plot(binSize, Slct(j,:), '^');
        hold on;
        plot(binSize, Suct(j,:), 'kh');
        plot(binSize, kingAv(j,:), 'r*', 'MarkerSize', 10)    
        ylabel('cut-off')
        legend('\alpha', 'lc', 'uc', 'king', 'location', 'best')
        print(gcf,strcat(saveFolder, '/SizeComp.png'), '-dpng', '-r300', '-painters')

        %% Lifetime
        figure('visible', 'off');
        errorbar(binSize, Talp(j,:), Tdal(j,:), 'o');
        xlabel('\Delta t')
        ylabel('\alpha')
        title('Avalanche life-time')
        yyaxis right;
        plot(binSize, Tlct(j,:), '^');
        hold on;
        plot(binSize, Tuct(j,:), 'kh');
        ylabel('cut-off')
        legend('\alpha', 'lc', 'uc', 'location', 'best')
        print(gcf,strcat(saveFolder, '/LifeComp.png'), '-dpng', '-r300', '-painters')


        %% Gamma
        figure('visible', 'off');
        errorbar(binSize,x1(j,:), dx1(j,:), 'o');
        hold on;
        errorbar(binSize,x2(j,:), dx2(j,:), '^');
        errorbar(binSize,x3(j,:), dx3(j,:), 'h');
        xlabel('\Delta t')
        ylabel('1/\sigma\tau\nu')
        legend('S,T', '<S>(T)', 'Shape', 'location', 'best')
        title('Crackling relationship')
        print(gcf,strcat(saveFolder, '/CrackComp.png'), '-dpng', '-r300', '-painters')


        %% Distributions
        %% Size
        figure('visible', 'off');
        for i = 1:Nbs
            loglog(Szbins{j,i}, Szprob{j,i});
            hold on;
        end
        xlabel('S')
        ylabel('P(S)')
        title('Avalanche size')
        leg = legend(num2str(binSize,'%.2f'), 'location', 'best');
        title(leg,'\Delta t')
        print(gcf,strcat(saveFolder, '/SizePlot.png'), '-dpng', '-r300', '-painters')


        %% Life
        figure('visible', 'off');
        for i = 1:Nbs 
            loglog(Tmbins{j,i}, Tmprob{j,i});
            hold on;
        end
        xlabel('T')
        ylabel('P(T)')
        title('Avalanche life-time')
        leg = legend(num2str(binSize,'%.2f'), 'location', 'best');
        title(leg,'\Delta t')
        print(gcf,strcat(saveFolder, '/LifePlot.png'), '-dpng', '-r300', '-painters')

        %% Average Size
        figure('visible', 'off');
        for i = 1:Nbs 
            loglog(ASlife{j,i}, ASsize{j,i});
            hold on;
        end
        xlabel('T')
        ylabel('<S>')
        title('Avalanche average size')
        leg = legend(num2str(binSize,'%.2f'), 'location', 'best');
        title(leg,'\Delta t')
        print(gcf,strcat(saveFolder, '/AvSzPlot.png'), '-dpng', '-r300', '-painters')

        %%
        close all;

    end
    
    
end