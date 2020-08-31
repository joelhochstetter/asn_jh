function [old, tun] = DC_Plots1(params, old, tun, cList, tV, aV, sect, field)
    
    tvec = tV{1}.Stim.TimeAxis;
    
    close all
    %Timing plot
        figure('units','normalized','outerposition',[0 0 1 1]);

    subplot(1,2,1);
    semilogy(cList,old.firstIncrease,  'r-');
    hold on
    semilogy(cList,tun.firstIncrease, 'g--');
    semilogy(cList,old.onStart(:,2),   '-', 'Color', 'y');
    semilogy(cList,tun.onStart(:,2),  '--', 'Color', [0.4940, 0.1840, 0.5560]);
%     semilogy(cList,old.onMed(:,2),     '-', 'Color', [0.75, 0.75, 0]);
%     semilogy(cList,tun.onMed(:,2),    '--', 'Color', [0, 0.5, 0]);
%     semilogy(cList,old.onEnd(:,2),     'y-');
%     semilogy(cList,old.onEnd(:,2),    '--', 'Color', 1/255*[0,104,87]);
    semilogy(cList,old.firstCPath,     'b-');
    semilogy(cList,tun.firstCPath,    'c--');
%      semilogy(cList,old.eqTimes,        'm-');
%      semilogy(cList,tun.eqTimes,       'k--');
    set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);

    yy = 0:1e-1:10000;
    plot( 0.09*ones(size(yy)), yy, 'k-', 'LineWidth',2.5,  'HandleVisibility','off')%)

    set(gca, 'YScale', 'log')

    ylabel 'Time (s)'
    xlabel('Stimulus bias (V)');


    yyaxis right
    semilogy(cList,old.Max,  '-', 'Color', [0.9290, 0.6940, 0.1250], 'LineWidth', 2);% [0.4940 0.1840 0.5560])
    semilogy(cList,tun.Max, '-.', 'Color', 'm'	, 'LineWidth', 2);%[0, 0.5, 0]);%[0.6350 0.0780 0.1840])
    set(gca, 'YScale', 'log');
    ylabel 'Network conductance (S)'

    yyaxis left; set(gca, 'YScale', 'lin'); ylim([0,5])
    yy = 0:1e-1:10000;
    plot( 0.09*ones(size(yy)), yy, 'k-', 'LineWidth',2.5,  'HandleVisibility','off')%)
    
%     legend('Bin 1st Increase', 'Tun 1st Increase', 'Bin 1st Cur Path', 'Bin Cross 1e-7', 'Tun Cross 1e-7', 'Bin Cross 1e-6', 'Tun Cross 1e-6', 'Bin Cross 1e-5', 'Tun Cross 1e-5', 'Tun 1st Cur Path', 'Bin 1st Max Time', 'Tun 1st Max Time', 'Bin Max G', 'Tun Max G', 'location', 'northeast')
    legend('Bin 1st Increase', 'Tun 1st Increase', 'Bin Cross 1e-7', 'Tun Cross 1e-7',  'Bin 1st Cur Path', 'Tun 1st Cur Path', 'Bin Max G', 'Tun Max G', 'location', 'northeast')
    title('DC Activation Timing Comparison');
    
    hold off
    saveas(gcf,strcat(field,'_DC_TimingFullRange.png'))
    
    old.firstCPath(old.firstCPath == 1e4) = nan;
    tun.firstCPath(tun.firstCPath == 1e4) = nan;
    old.firstIncrease(old.firstIncrease == 1e4) = nan;
    tun.firstIncrease(tun.firstIncrease == 1e4) = nan;
    
    
        subplot(1,2,2);
    semilogy(cList,old.firstIncrease,  'r-');
    hold on
    semilogy(cList,tun.firstIncrease, 'g--');
    semilogy(cList,old.onStart(:,2),   '-', 'Color', 'y');
    semilogy(cList,tun.onStart(:,2),  '--', 'Color', [0.4940, 0.1840, 0.5560]);
%     semilogy(cList,old.onMed(:,2),     '-', 'Color', [0.75, 0.75, 0]);
%     semilogy(cList,tun.onMed(:,2),    '--', 'Color', [0, 0.5, 0]);
%     semilogy(cList,old.onEnd(:,2),     'y-');
%     semilogy(cList,old.onEnd(:,2),    '--', 'Color', 1/255*[0,104,87]);
    semilogy(cList,old.firstCPath,     'b-');
    semilogy(cList,tun.firstCPath,    'c--');
%      semilogy(cList,old.eqTimes,        'm-');
%      semilogy(cList,tun.eqTimes,       'k--');
    set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);

    yy = 0:1e-1:10000;
    plot( 0.09*ones(size(yy)), yy, 'k-', 'LineWidth',2.5,  'HandleVisibility','off')%)
    ylim([1e-1,1000])
    set(gca, 'YScale', 'log')

    ylabel 'Time (s)'
    xlabel('Stimulus bias (V)');


    yyaxis right
    semilogy(cList,old.Max,  '-', 'Color', [0.9290, 0.6940, 0.1250], 'LineWidth', 2);% [0.4940 0.1840 0.5560])
    semilogy(cList,tun.Max, '-.', 'Color', 'm'	, 'LineWidth', 2);%[0, 0.5, 0]);%[0.6350 0.0780 0.1840])
    set(gca, 'YScale', 'log');
    ylabel 'Network conductance (S)'
    
    yyaxis left;
    xlim([0,0.12])
    yy = 0:1e-1:10000;
    plot( 0.09*ones(size(yy)), yy, 'k-', 'LineWidth',2.5,  'HandleVisibility','off')%)
    plot( cList(find(old.Max > old.Max(1),1) - 1)*ones(size(yy)), yy, 'k-', 'LineWidth',2.5,  'HandleVisibility','off')%)

        

    
%     legend('Bin 1st Increase', 'Tun 1st Increase', 'Bin 1st Cur Path', 'Bin Cross 1e-7', 'Tun Cross 1e-7', 'Bin Cross 1e-6', 'Tun Cross 1e-6', 'Bin Cross 1e-5', 'Tun Cross 1e-5', 'Tun 1st Cur Path', 'Bin 1st Max Time', 'Tun 1st Max Time', 'Bin Max G', 'Tun Max G', 'location', 'northeast')
    legend('Bin 1st Increase', 'Tun 1st Increase', 'Bin Cross 1e-7', 'Tun Cross 1e-7',  'Bin 1st Cur Path', 'Tun 1st Cur Path', 'Bin Max G', 'Tun Max G', 'location', 'northwest')
    title('DC Activation Timing Comparison');
    
    hold off
    saveas(gcf,strcat(field,'_DC_TimingLowRange.png'))
    
    
    
    
    %{
    load('TFOscilloKeithDaq_2019_07_29_14_30_43__act.mat', 't', 'G')
    %DC tun, cmp
    j = find(cList == 0.1);
    figure;
    semilogy(tvec,old.c(:,j))
    hold on
    semilogy(tvec,tun.c(:,j))
    semilogy(t*0.64,G);
    xlim([0,80])
    xlabel('t (s)')
    ylabel('G (S)')
    yyaxis right
    plot(tvec, tV{j}.Stim.Signal)
    ylim([0,0.2]);
    ylabel 'V (V)'
    legend('Tun', 'Bin', 'Exp', 'location', 'northwest')
    title('Network DC Stimulation - 0.1V');
    set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);
    saveas(gcf, strcat(field,num2str(tV{j}.(sect).(field),3), '_DC_ConComparison.png'))
    hold off

    
    j1 = find(cList == 0.5);
    j2 = find(cList == 1.0);
    j3 = find(cList == 1.5);    
    %Tun plot
    figure;
    semilogy(tvec,old.c(:,j1));
    hold on;
    semilogy(tvec,tun.c(:,j1));
    semilogy(tvec,old.c(:,j2));
    semilogy(tvec,tun.c(:,j2));
    semilogy(tvec,old.c(:,j3));
    semilogy(tvec,tun.c(:,j3));    
    xlabel('t (s)')
    ylabel('G (S)')
    xlim([0,20]);
    legend(string(cList(nums)), 'location', 'southeast');
    title('DC Activation - Compare Voltages');
    set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);
    saveas(gcf, strcat(field, '_bin_tun_high_V_DC_ConComparison.png'))
    
    
    
    %Total DC Comparison
    figure('visible','on', 'color','w', 'units', 'centimeters', 'OuterPosition', [5 5 25 15]);
    subplot(1,2,1);
    semilogy(tvec,old.c(:,j))
    hold on
    semilogy(tvec,tun.c(:,j))
    semilogy(t*0.64,G);
    xlim([0,80])
    xlabel('t (s)')
    ylabel('G (S)')
    yyaxis right
    plot(tvec, tV{j}.Stim.Signal)
    ylim([0,0.2]);
    ylabel 'V (V)'
    legend('Tun', 'Bin', 'Exp', 'location', 'northwest')
    title('Network DC Stimulation - 0.1V');
    set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);
    hold off
    %Tun plot
    subplot(1,2,2);
    semilogy(tvec,old.c(:,j1));
    hold on;
    semilogy(tvec,tun.c(:,j1));
    semilogy(tvec,old.c(:,j2));
    semilogy(tvec,tun.c(:,j2));
    semilogy(tvec,old.c(:,j3));
    semilogy(tvec,tun.c(:,j3));    
    xlabel('t (s)')
    ylabel('G (S)')
    xlim([0,20]);
legend('Bin: 0.5 V', 'Tun: 0.5 V', 'Bin: 1.0 V', 'Tun: 1.0 V', 'Bin: 1.5 V', 'Tun: 1.5 V', 'location', 'southeast')
    title('DC Activation - Compare Voltages');
    set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);
    saveas(gcf, 'DC_Comparison.png')
    
    
    
%     %Bin plot
%     figure;
%     semilogy(tvec,tun.c(:,nums));
%     xlabel('t (s)')
%     ylabel('G (S)')
%     xlim([ts,te]);
%     legend(string(cList(nums)), 'location', 'southeast');
%     title(strcat('Tunnelling DC, Vary', field));
%     set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);
%     saveas(gcf, strcat(field, '_tun_DC_ConComparison.png'))
%   
    close all;
    save(strcat('old_', field, '.mat'), 'old');
    save(strcat('tun_', field, '.mat'), 'tun');
    %}
end
