function compAvalanche(baseFolder, vals, varName, subtype, binSize, fmt)
%{
    Plots comparison between avalanche simulations when changing a
    parameter, for different binSizes

    Inputs:
        baseFolder: folder where simulations are found
                    vals: possible values of the independ

    compAvalanche('/home/joelh/Documents/NeuroNanoAI/Avalanche/RectChangeV', 0.7:0.1:1.8, 'V^*', 'Vstar', [-2,-1,-0.5])
%}

    %% defaults
    if nargin < 6
        fmt = '%g';
    end
    
    
    %% reshape data
    vals = reshape(vals, [numel(vals),1]);
    binSize = reshape(binSize, [numel(binSize),1]);
    
    %%
    close all;
    
    cd(baseFolder)
    saveFolder = strcat(baseFolder, '/AvCompare/');
    mkdir(saveFolder)

    N = numel(vals);
    Nbs = numel(binSize);


    %%
    meanG = zeros(N,Nbs);
    V = zeros(N,Nbs);
    numEvents = zeros(N,Nbs);
    meanIEI = zeros(N,Nbs);
    IEItau = zeros(N,Nbs);
    IEIdta = zeros(N,Nbs);
    branch = zeros(N,Nbs);
    Stau = zeros(N,Nbs);
    Sdta = zeros(N,Nbs);
    Slct = zeros(N,Nbs);
    Suct = zeros(N,Nbs);
    Sksd = zeros(N,Nbs);
    Spvl = zeros(N,Nbs);
    Talp = zeros(N,Nbs);
    Tdal = zeros(N,Nbs);
    Tlct = zeros(N,Nbs);
    Tuct = zeros(N,Nbs);
    Tksd = zeros(N,Nbs);
    Tpvl = zeros(N,Nbs);    
    x1  = zeros(N,Nbs);
    dx1 = zeros(N,Nbs);
    x2  = zeros(N,Nbs);
    dx2 = zeros(N,Nbs);
    x3  = zeros(N,Nbs);
    dx3 = zeros(N,Nbs);
    kingAvS = zeros(N,Nbs);
    kingAvT = zeros(N,Nbs);
    IEIbins = cell(N,Nbs);
    IEIprob = cell(N,Nbs);
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
        
        saveFolder = strcat(baseFolder, '/AvCompare/bs', num2str(bs),'/');
        mkdir(saveFolder);


        for i = 1:numel(vals)
            critResults{i,j} = load(strcat2({baseFolder, '/', subtype, num2str(vals(i), fmt), '/bs', bs, '/critResults.mat'}));
            critResults{i,j} = critResults{i,j}.critResults;
        end



        for i = 1:N
            meanG(i,j) = critResults{i,j}.net.meanG;
            V(i,j) = mean(critResults{i,j}.net.V);
            numEvents(i,j) = critResults{i,j}.events.numEvents;
            meanIEI(i,j) = critResults{i,j}.IEI.meanIEI;
            IEItau(i,j) = critResults{i,j}.IEI.tau;
            IEIdta(i,j) = critResults{i,j}.IEI.sigmaTau;
            IEIbins{i,j} = critResults{i,j}.IEI.bins;
            IEIprob{i,j} = critResults{i,j}.IEI.prob;
            if isfield(critResults{i,j}.avalanche, 'branchRatio')
                branch(i,j) = critResults{i,j}.avalanche.branchRatio;            
            end
            if ~isfield(critResults{i,j}.avalanche, 'sizeFit')
                continue
            end            
            Stau(i,j) = critResults{i,j}.avalanche.sizeFit.tau;
            Sdta(i,j) = critResults{i,j}.avalanche.sizeFit.dTau;
            Slct(i,j) = critResults{i,j}.avalanche.sizeFit.lc;
            Suct(i,j) = critResults{i,j}.avalanche.sizeFit.uc;
            Sksd(i,j) = critResults{i,j}.avalanche.sizeFit.ksd;
            Spvl(i,j) = critResults{i,j}.avalanche.sizeFit.pvl;
            Szbins{i,j} = critResults{i,j}.avalanche.sizeFit.bins;
            Szprob{i,j} = critResults{i,j}.avalanche.sizeFit.prob;
            if ~isfield(critResults{i,j}.avalanche, 'timeFit')
                continue
            end
            Talp(i,j) = critResults{i,j}.avalanche.timeFit.alpha;
            Tdal(i,j) = critResults{i,j}.avalanche.timeFit.dAlpha;
            Tlct(i,j) = critResults{i,j}.avalanche.timeFit.lc;
            Tuct(i,j) = critResults{i,j}.avalanche.timeFit.uc;
            Tksd(i,j) = critResults{i,j}.avalanche.timeFit.ksd;
            Tpvl(i,j) = critResults{i,j}.avalanche.timeFit.pvl;            
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
            kingAvS(i,j) = kingAvLoc(bins, prob, Suct(i,j));
            bins = critResults{i,j}.avalanche.timeFit.bins;
            prob = critResults{i,j}.avalanche.timeFit.prob;            
            kingAvT(i,j) = kingAvLoc(bins, prob, Tuct(i,j));
        end


        %% Comparison by parameter
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
        plot(vals, kingAvS(:,j), 'r^', 'MarkerSize', 10)
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

        %% Goodness of fit
        figure('visible', 'off');
        plot(vals,Sksd(:,j), 'o--');
        hold on;
        plot(vals,Tksd(:,j), '^--');
        xlabel(varName)
        ylabel('KSD')
        yyaxis right;
        plot(vals,Spvl(:,j), '.--');
        hold on;
        plot(vals,Tpvl(:,j), 'h--');
        ylabel('p-value')        
        legend('KSD_S', 'KSD_T', 'p_S',  'p_T', 'location', 'best')
        title('Goodness of fit')
        print(gcf,strcat(saveFolder, '/KSD.png'), '-dpng', '-r300', '-painters')


        %% Gamma + branch
        figure('visible', 'off');
        errorbar(vals,x1(:,j), dx1(:,j));
        hold on;
        errorbar(vals,x2(:,j), dx2(:,j));
        errorbar(vals,x3(:,j), dx3(:,j));
        xlabel(varName)
        ylabel('1/\sigma\tau\nu')
        yyaxis right;
        plot(vals, branch(:,j))
        ylabel('\sigma_r = s_2/s_1')
        legend('S,T', '<S>(T)', 'Shape', '\sigma_r', 'location', 'best')
        title('Crackling relationship')
        print(gcf,strcat(saveFolder, '/CrackComp.png'), '-dpng', '-r300', '-painters')


        %% Distributions

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

    %% bin free plots (variables with no bin dependence)
    saveFolder = strcat(baseFolder, '/AvCompare/binFree');
    mkdir(saveFolder)
    
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




    %%
    %% Compare by bin-sizes
    for j = 1:N
        saveFolder = strcat(baseFolder, '/AvCompare/', subtype, num2str(vals(j)),'/');
        mkdir(saveFolder);

        %% Comparison by parameter
        binSize(binSize < 0) = -binSize(binSize < 0)*meanIEI(j,1);

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
        plot(binSize, kingAvS(j,:), 'r*', 'MarkerSize', 10)    
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


        %% Goodness of fit
        figure('visible', 'off');
        plot(binSize,Sksd(j,:), 'o--');
        hold on;
        plot(binSize,Tksd(j,:), '^--');
        xlabel('\Delta t')
        ylabel('KSD')
        yyaxis right;
        plot(binSize,Spvl(j,:), '.--');
        hold on;
        plot(binSize,Tpvl(j,:), 'h--');
        ylabel('p-value')        
        legend('KSD_S', 'KSD_T', 'p_S',  'p_T', 'location', 'best')
        title('Goodness of fit')
        print(gcf,strcat(saveFolder, '/KSD.png'), '-dpng', '-r300', '-painters')
        
        %% Gamma
        figure('visible', 'off');
        errorbar(binSize,x1(j,:), dx1(j,:), 'o');
        hold on;
        errorbar(binSize,x2(j,:), dx2(j,:), '^');
        errorbar(binSize,x3(j,:), dx3(j,:), 'h');
        xlabel('\Delta t')
        ylabel('1/\sigma\tau\nu')
        yyaxis right;
        plot(binSize, branch(j,:))
        ylabel('\sigma_r = s_2/s_1')        
        legend('S,T', '<S>(T)', 'Shape',  '\sigma_r', 'location', 'best')
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
    clear('critResults');
    save(strcat(baseFolder, '/AvCompare/AvComp.mat'))
    
end