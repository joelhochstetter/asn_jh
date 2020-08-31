function DCaW_Plots2(params, old, tun, cList, tV, aV, sect, field)
    
    tvec = tV{1}.Stim.TimeAxis;
    
    ts = 0;
    te = 10;

    close all
    %Timing plot
    figure
    semilogy(cList,old.MaxLoc,         'm-');
    hold on;
    semilogy(cList,tun.MaxLoc,        'k--');
    semilogy(cList,old.MaxEnd,         'k-');
    semilogy(cList,tun.MaxEnd,        'm--');
    semilogy(cList,old.lastCPath,     'c-');
    semilogy(cList,tun.lastCPath,    'b--');
    semilogy(cList,old.reachMin,  'g-');
    semilogy(cList,tun.reachMin, 'r--');    
    ylabel 'time (s)'
    xlabel(field);
    yyaxis right
    semilogy(cList,old.Max,  ':', 'Color', [0.4940 0.1840 0.5560])
    semilogy(cList,tun.Max, '-.', 'Color', [0.6350 0.0780 0.1840])
    semilogy(cList,old.Min,  ':', 'Color', [0.4940 0.1840 0.5560])
    semilogy(cList,tun.Min, '-.', 'Color', [0.6350 0.0780 0.1840])    
    ylabel 'G_{m} (S)'
    legend('Bin 1st Max Time', 'Tun 1st Max Time', 'Bin last Max Time', 'Tun last Max Time', 'Bin Last Cur Path', 'Tun Last Cur Path', 'Bin Last Reach Min', 'Tun Last Reach Min', 'Bin Max G', 'Tun Max G', 'Bin Min G', 'Tun Min G')
    title(strcat('DC Activation Timing Varying ', field));
    hold off
    set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);
    saveas(gcf,strcat(field,'_DC_Timing.png'))

    
    nums = 1:numel(cList/5):numel(cList);
        
    %DC tun, cmp
    for j = nums
        figure
        semilogy(tvec,old.c(:,j))
        hold on
        semilogy(tvec,tun.c(:,j))
        xlim([ts,te])
        xlabel('t (s)')
        ylabel('G (S)')
        yyaxis right
        plot(tvec, tV{j}.Stim.Signal)
        ylabel 'V (V)'
        legend('Binary', 'Tunneling')
        title(strcat('DC,  ', field,' = ', num2str(tV{j}.(sect).(field),2)));
        set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);        
        saveas(gcf, strcat(field,num2str(tV{j}.(sect).(field),3), '_DC_ConComparison.png'))
        hold off
    end
    
    %Tun plot
    figure;
    loglog(tvec,old.c(:,nums));
    xlabel('t (s)')
    ylabel('G (S)')
    xlim([ts,te]);
    legend(string(cList(nums)));
    title(strcat('Binary DC, Vary', field));
    set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);
    saveas(gcf, strcat(field, '_bin_DC_ConComparison.png'))
    
    %Bin plot
    figure;
    loglog(tvec,tun.c(:,nums));
    xlabel('t (s)')
    ylabel('G (S)')
    xlim([ts,te]);
    legend(string(cList(nums)));
    title(strcat('Tunnelling DC, Vary', field));
    set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);    
    saveas(gcf, strcat(field, '_tun_DC_ConComparison.png'))
    
    close all;
end
