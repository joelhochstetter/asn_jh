function autoVG_inact_vs_preact(params, saveFolder, splength)
%{
    Takes params runs a VG simulation and outputs screenshots
%}

    if nargin < 3
        splength = 9;
    end

    %% Preactivated VG
    %Set Stimulus
    params.Stim.BiasType     = 'DC'; % 'DC' \ 'AC' \ 'DCandWait' \ 'Ramp' \ 'ACsaw'
    params.Stim.Amplitude    = 1.8; 
    params.SimOpt.saveFolder      = saveFolder;
    params.SimOpt.saveSwitches = false;
    params.SimOpt.nameComment = '_preactivated'; 
    mkdir(params.SimOpt.saveFolder)
    multiRun(params);

    init = multiImport(params);
    params.Comp.filamentState = init{1}.finalStates';
    params.Stim.Amplitude =sort([0.05:0.005:0.27])/9*splength;
%     params.SimOpt.dt = 5e-3;
    params.SimOpt.T               = 1000;
    params.SimOpt.stopIfDupName = true; %this parameter only runs simulation if the savename is not used.
    params.SimOpt.useParallel     = true;
    multiRun(params);
    sims = multiImport(params);
    
    Vlist1    = zeros(size(sims)); 
    Gend1 = zeros(size(sims));
    Gstd1   = zeros(size(sims));
    timeVec = sims{1}.Stim.TimeAxis;
    for i = 1:numel(sims)
        Vlist1(i) = sims{i}.Stim.Amplitude;
        Gend1(i) = mean(sims{i}.netC(round(end*3/4):end));
        Gstd1(i)  = std(sims{i}.netC(round(end*3/4):end)); 
    end

    Vlist = Vlist1;
    idx = [];
    idx(1) = find(Vlist >= 0.0,1);
    idx(2) = find(Vlist >= 0.06/9*splength,1);
    idx(3) = find(Vlist >= 0.08/9*splength,1);
    idx(4) = find(Vlist >= 0.0899/9*splength,1);
    idx(5) = find(Vlist >= 0.10/9*splength,1);
    idx(6) = find(Vlist >= 0.12/9*splength,1);
    idx(7) = find(Vlist >= 0.15/9*splength,1);
    idx(8) = find(Vlist >= 0.20/9*splength,1);
    idx(9) = find(Vlist >= 0.25/9*splength,1);

    leg = {};
    cmap = parula(10);
    figure;
    for i =1:numel(idx) 
        semilogy(timeVec, sims{idx(i)}.netC/7.77e-5, '-', 'color', cmap(i,:))
        leg{i} = num2str(Vlist(idx(i))/0.09, '%.1f');
        hold on;
    end

    xlim([0,7.5])
    xlabel('t (s)', 'fontweight','bold','fontsize',10)
    ylabel('G_{nw} (G_0)', 'fontweight','bold','fontsize',10)
    leg = legend(leg, 'location', 'east');
    title(leg, 'V^*')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2.0);
    axis square;
    print(gcf, strcat(saveFolder, '/GTimeSeriesDeactive.png'), '-dpng', '-r300', '-painters')


    %% initally inactive VG
    params.Comp.filamentState = 0;
    params.SimOpt.nameComment = '_inactive'; 
    multiRun(params);
    sims = multiImport(params);
    
    Vlist    = zeros(size(sims)); 
    Gend = zeros(size(sims));
    Gstd   = zeros(size(sims));
    for i = 1:numel(sims)
        Vlist(i) = sims{i}.Stim.Amplitude;
        Gend(i) = mean(sims{i}.netC(round(end*3/4):end));
        Gstd(i)  = std(sims{i}.netC(round(end*3/4):end)); 
    end   
    
    
    idx = zeros(7,1);
    idx(1) = find(Vlist >= 0.08/9*splength,1);
    idx(2) = find(Vlist >= 0.0899/9*splength,1);
    idx(3) = find(Vlist >= 0.10/9*splength,1);
    idx(4) = find(Vlist >= 0.12/9*splength,1);
    idx(5) = find(Vlist >= 0.15/9*splength,1);
    idx(6) = find(Vlist >= 0.20/9*splength,1);
    idx(7) = find(Vlist >= 0.25/9*splength,1);
    % idx(10) = find(Vlist >= 1.0,1)
    leg = {};
    cmap = parula(10);
    figure;
    for i =1:numel(idx) 
        semilogy(timeVec, sims{idx(i)}.netC/7.77e-5, '-', 'color', cmap(i,:))
        leg{i} = num2str(Vlist(idx(i))/0.09, '%.1f');
        hold on;
    end

    xlim([0,7])
    xlabel('t (s)', 'fontweight','bold','fontsize',10)
    ylabel('G_{nw} (G_0)', 'fontweight','bold','fontsize',10)
    leg = legend(leg, 'location', 'east');
    pos = get(leg,'position');
    pos(1) = 0.5;
    pos(2) = 0.37;
    set(leg,'position', pos)
    title(leg, 'V^*')
    set(findall(gca, 'Type', 'Line'),'LineWidth',2.0);
    axis square;
    print(gcf, strcat(saveFolder, '/GTimeSeriesActivate.png'), '-dpng', '-r300', '-painters')

    
    
    
    %% V-G plot
    figure;
    set(gcf, 'color', 'w');
    errorbar(Vlist/0.01/9, Gend/7.77e-5*9, Gstd/7.77e-5*9,  'ko', 'MarkerSize', 6, 'LineWidth', 1.0)
    hold on;
    errorbar(Vlist1/0.01/9, Gend1/7.77e-5*9, Gstd1/7.77e-5*9,  'r^', 'MarkerSize', 6, 'LineWidth', 1.0)
    hline(1, 'k:')
    vline(1, 'k:')
    vline(0.5, 'k:')
    xlabel('V^*','fontweight','bold','fontsize',10)
    ylabel('G_{nw}^* (t = \infty)','fontweight','bold','fontsize',10)
    leg = legend('Inactive', 'Preactivated');
    axis square;
    print(gcf, strcat(saveFolder, '/VGplot.png'), '-dpng', '-r300', '-painters')

end