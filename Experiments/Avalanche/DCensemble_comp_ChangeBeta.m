%%
close all;
baseFolder = '~/Documents/NeuroNanoAI/Avalanche/WSBA/';

cd(baseFolder)
saveFolder = strcat(baseFolder, '/AvCompare/');
mkdir(saveFolder)
binSize = [-1, 10, 50, 100];

bvals = [0.2:0.2:1.0]';

N = numel(bvals);
Nbs = numel(binSize);


%%
meanG = zeros(N,Nbs);
V = zeros(N,Nbs);
PSDbeta = zeros(N,Nbs);
PSDdbet = zeros(N,Nbs);
numEvents = zeros(N,Nbs);
meanIEI = zeros(N,Nbs);
IEItau = zeros(N,Nbs);
IEIdta = zeros(N,Nbs);
dGalpha = zeros(N,Nbs);
dGdalph = zeros(N,Nbs);
Stau = zeros(N,Nbs);
Sdta = zeros(N,Nbs);
Slct = zeros(N,Nbs);
Suct = zeros(N,Nbs);
Talp = zeros(N,Nbs);
Tdal = zeros(N,Nbs);
Tlct = zeros(N,Nbs);
Tuct = zeros(N,Nbs);
x1  = zeros(N,Nbs);
dx1 = zeros(N,Nbs);
x2  = zeros(N,Nbs);
dx2 = zeros(N,Nbs);
x3  = zeros(N,Nbs);
dx3 = zeros(N,Nbs);
kingAv = zeros(N,Nbs);
IEIbins = cell(N,Nbs);
IEIprob = cell(N,Nbs);
dGbins  = cell(N,Nbs);
dGprob  = cell(N,Nbs);
Szbins  = cell(N,Nbs);
Szprob  = cell(N,Nbs);
Tmbins  = cell(N,Nbs);
Tmprob  = cell(N,Nbs);
ASlife  = cell(N,Nbs);
ASsize  = cell(N,Nbs);

critResults = cell(N,Nbs);


%%
for j = 1:Nbs
    bs = binSize(j);
    %Vvals = [0.113, 0.225, 0.338, 0.45, 0.562, 0.675, 0.787, 0.9];

    saveFolder = strcat(baseFolder, '/AvCompare/bs', num2str(bs),'/');
    mkdir(saveFolder);


    for i = 1:numel(bvals)
        critResults{i,j} = load(strcat2({baseFolder, 'beta', bvals(i), '/bs', bs, '/critResults.mat'}));
        critResults{i,j} = critResults{i,j}.critResults;
    end



    for i = 1:N
        meanG(i,j) = critResults{i,j}.net.meanG;
        V(i,j) = mean(critResults{i,j}.net.V);
        PSDbeta(i,j) = critResults{i,j}.PSD.beta;
        PSDdbet(i,j) = critResults{i,j}.PSD.dbeta;    
        numEvents(i,j) = critResults{i,j}.events.numEvents;
        meanIEI(i,j) = critResults{i,j}.IEI.meanIEI;
        IEItau(i,j) = critResults{i,j}.IEI.tau;
        IEIdta(i,j) = critResults{i,j}.IEI.sigmaTau;
        IEIbins{i,j} = critResults{i,j}.IEI.bins;
        IEIprob{i,j} = critResults{i,j}.IEI.prob;
        dGalpha(i,j) = critResults{i,j}.dG.alpha;
        dGdalph(i,j) = critResults{i,j}.dG.dalph;
        dGbins{i,j} = critResults{i,j}.dG.bins;
        dGprob{i,j} = critResults{i,j}.dG.prob;
        Stau(i,j) = critResults{i,j}.avalanche.sizeFit.tau;
        Sdta(i,j) = critResults{i,j}.avalanche.sizeFit.dTau;
        Slct(i,j) = critResults{i,j}.avalanche.sizeFit.lc;
        Suct(i,j) = critResults{i,j}.avalanche.sizeFit.uc;
        Szbins{i,j} = critResults{i,j}.avalanche.sizeFit.bins;
        Szprob{i,j} = critResults{i,j}.avalanche.sizeFit.prob;    
        Talp(i,j) = critResults{i,j}.avalanche.timeFit.alpha;
        Tdal(i,j) = critResults{i,j}.avalanche.timeFit.dAlpha;
        Tlct(i,j) = critResults{i,j}.avalanche.timeFit.lc;
        Tuct(i,j) = critResults{i,j}.avalanche.timeFit.uc;
        Tmbins{i,j} = critResults{i,j}.avalanche.timeFit.bins;
        Tmprob{i,j} = critResults{i,j}.avalanche.timeFit.prob;        
        ASlife{i,j} = critResults{i,j}.avalanche.avSizeFit.mLife;
        ASsize{i,j} = critResults{i,j}.avalanche.avSizeFit.mSize;         
        x1 (i,j) = critResults{i,j}.avalanche.gamma.x1;
        dx1(i,j) = critResults{i,j}.avalanche.gamma.dx1;
        x2 (i,j) = critResults{i,j}.avalanche.gamma.x2;
        dx2(i,j) = critResults{i,j}.avalanche.gamma.dx2;
        x3 (i,j) = critResults{i,j}.avalanche.gamma.x3;
        dx3(i,j) = critResults{i,j}.avalanche.gamma.dx3;
        bins = critResults{i,j}.avalanche.sizeFit.bins;
        prob = critResults{i,j}.avalanche.sizeFit.prob;
        [pks, locs] = findpeaks(prob);
        possMax = find(bins(locs) > critResults{i,j}.avalanche.sizeFit.uc);
        [~, I] = max(pks(possMax));
        if numel(I) > 0
            kingAv(i,j) = bins(locs(possMax(I)));
        end
    end


    %% Comparison by parameter
    %% dG
    figure('visible', 'off');
    errorbar(bvals, dGalpha(:,j), dGdalph(:,j), '--o');
    xlabel('\beta')
    ylabel('\alpha')
    yyaxis right;
    semilogy(bvals, meanG(:,j), '-o');
    ylabel('<G>')
    title('\Delta G exponent')
    print(gcf,strcat(saveFolder, '/dGComp.png'), '-dpng', '-r300', '-painters')



    %% PSD
    figure('visible', 'off');
    errorbar(bvals, PSDbeta(:,j), PSDdbet(:,j), '--o');
    xlabel('\beta')
    ylabel('\beta')
    title('PSD exponent')
    print(gcf,strcat(saveFolder, '/PSDComp.png'), '-dpng', '-r300', '-painters')



    %% IEI
    figure('visible', 'off');
    errorbar(bvals, IEItau(:,j), IEIdta(:,j), '--o');
    xlabel('\beta')
    ylabel('\alpha')
    yyaxis right;
    semilogy(bvals, meanIEI(:,j), 'o-');
    ylabel('<IEI>')
    title('Inter-event interval')
    print(gcf,strcat(saveFolder, '/IEIComp.png'), '-dpng', '-r300', '-painters')


    %% Size
    figure('visible', 'off');
    errorbar(bvals, Stau(:,j), Sdta(:,j));
    xlabel('\beta')
    ylabel('\tau')
    title('Avalanche size')
    yyaxis right;
    plot(bvals, Slct(:,j), ':');
    hold on;
    plot(bvals, Suct(:,j), 'k--');
    plot(bvals, kingAv(:,j), 'r^', 'MarkerSize', 10)
    ylabel('cut-off')
    legend('\alpha', 'lc', 'uc', 'king', 'location', 'best')
    print(gcf,strcat(saveFolder, '/SizeComp.png'), '-dpng', '-r300', '-painters')
    

    %% Lifetime
    figure('visible', 'off');
    errorbar(bvals, Talp(:,j), Tdal(:,j));
    xlabel('\beta')
    ylabel('\alpha')
    title('Avalanche life-time')
    yyaxis right;
    plot(bvals, Tlct(:,j), ':');
    hold on;
    plot(bvals, Tuct(:,j), 'k--');
    ylabel('cut-off')
    legend('\alpha', 'lc', 'uc', 'location', 'best')
    print(gcf,strcat(saveFolder, '/LifeAv.png'), '-dpng', '-r300', '-painters')


    %% Gamma
    figure('visible', 'off');
    errorbar(bvals,x1(:,j), dx1(:,j));
    hold on;
    errorbar(bvals,x2(:,j), dx2(:,j));
    errorbar(bvals,x3(:,j), dx3(:,j));
    xlabel('\beta')
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
    leg = legend(num2str(bvals), 'location', 'best');
    title(leg,'\beta')
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
    leg = legend(num2str(bvals), 'location', 'best');
    title(leg,'\beta')
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
    leg = legend(num2str(bvals), 'location', 'best');
    title(leg,'\beta')
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
    leg = legend(num2str(bvals), 'location', 'best');
    title(leg,'\beta')
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
    leg = legend(num2str(bvals), 'location', 'best');
    title(leg,'\beta')
    print(gcf,strcat(saveFolder, '/AvSzPlot.png'), '-dpng', '-r300', '-painters')
    
    %%
    close all;
end






%%
%% Compare by bin-sizes
for j = 1:N
    saveFolder = strcat(baseFolder, '/AvCompare/beta', num2str(bvals(j)),'/');
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