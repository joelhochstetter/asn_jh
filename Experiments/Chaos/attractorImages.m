function attractorImages(attractorFolder, saveFolder, num2Show)
    params = struct();
    params.SimOpt.saveFolder = attractorFolder;
    cd(params.SimOpt.saveFolder)
    params.importAll = true;
    params.importSwitches = false;
    params.SimOpt.useParallel = true; 
    t = multiImport(params);

    mkdir(saveFolder)

    parfor i = 1:numel(t)
        dt = t{i}.dt;
        T  = t{i}.T;
        nstepT = round(1/dt/t{i}.Stim.Frequency);
        numT   = round(T*t{i}.Stim.Frequency);
        figure('units','normalized','outerposition',[0 0 1 1]);
        set(gcf, 'Visible', 'off');

        subplot(2,2,1);
        plot(t{i}.Stim.Signal(1:end), t{i}.netI(1:end), '--b')
        xlabel('V (V)')
        ylabel('I (A)')
        yyaxis right;
        semilogy(t{i}.Stim.Signal(1:end), t{i}.netC(1:end), '-.r')
        ylabel('G (S)')
        title(strcat('IV total, Amp=', num2str(t{i}.Stim.Amplitude),  'V, f =', num2str(t{i}.Stim.Frequency), 'Hz, b =', num2str(t{i}.Comp.boost)))
        legend('tun I-V', 'tun G-V')

        subplot(2,2,2);
        plot(t{i}.Stim.Signal(1:num2Show*nstepT), t{i}.netI(1:num2Show*nstepT), '--b')
        xlabel('V (V)')
        ylabel('I (A)')
        yyaxis right;
        semilogy(t{i}.Stim.Signal(1:num2Show*nstepT), t{i}.netC(1:num2Show*nstepT), '-.r')        
        ylabel('G (S)')
        title('IV 5 periods')
        legend('tun I-V', 'tun G-V')

        subplot(2,2,3);
        ttimeAveC = zeros(size(t{i}.netC));
        ttimeMinC = zeros(size(t{i}.netC));
        ttimeMaxC = zeros(size(t{i}.netC));

        t{i}.netC(find(isnan(t{i}.netC))) = t{i}.netC(find(isnan(t{i}.netC)) + 1);

        for j = 1:(numT)
            ttimeAveC((j - 1)* nstepT + 1 : j*nstepT) =  mean(t{i}.netC((j - 1)* nstepT + 1 : j*nstepT));
            ttimeMinC((j - 1)* nstepT + 1 : j*nstepT) =  min(t{i}.netC((j - 1)* nstepT + 1 : j*nstepT));
            ttimeMaxC((j - 1)* nstepT + 1 : j*nstepT) =  max(t{i}.netC((j - 1)* nstepT + 1 : j*nstepT));

        end
        semilogy(t{i}.Stim.TimeAxis, t{i}.netC, '--g');  
        hold on;
        semilogy(t{i}.Stim.TimeAxis, ttimeAveC, '-k', 'LineWidth', 3);
        semilogy(t{i}.Stim.TimeAxis, ttimeMinC, '-r', 'LineWidth',  3);
        semilogy(t{i}.Stim.TimeAxis, ttimeMaxC, '-b', 'LineWidth', 3);  

        xlabel('Time (s)');
        ylabel('Time averaged conductance (S)');
        title('Time averaged conductance')
        legend('con','ave', 'min', 'max');

        %{
        plot(t{i}.Stim.Signal((numT-1)*nstepT+1:end), t{i}.netI((numT-1)*nstepT+1:end), '-r')
        hold on;
        plot(t{i}.Stim.Signal((numT-1)*nstepT+1:end), t{i}.netI((numT-1)*nstepT+1:end), '--b')
        xlabel('V (V)')
        ylabel('I (A)')
        yyaxis right;
        semilogy(t{i}.Stim.Signal((numT-1)*nstepT+1:end), t{i}.netC((numT-1)*nstepT+1:end), ':g')
        hold on;
        semilogy(t{i}.Stim.Signal((numT-1)*nstepT+1:end), t{i}.netC((numT-1)*nstepT+1:end), '-.y')
        ylabel('G (S)')
        title('IV last period')
        legend('bin I-V', 'tun I-V', 'bin G-V', 'tun G-V')
        %}


        subplot(2,2,4);
        plot(t{i}.Stim.Signal((numT- num2Show - 1)*nstepT+1:end), t{i}.netI((numT- num2Show - 1)*nstepT+1:end), '--b')
        xlabel('V (V)')
        ylabel('I (A)')
        yyaxis right;
        semilogy(t{i}.Stim.Signal((numT- num2Show - 1)*nstepT+1:end), t{i}.netC((numT- num2Show - 1)*nstepT+1:end), '-.r')
        ylabel('G (S)')
        title('IV last 5 periods')    
        legend('tun I-V', 'tun G-V')

        saveas(gcf, strcat(saveFolder, '/IV_A', num2str(t{i}.Stim.Amplitude,  '%.1f'), '_f', num2str(t{i}.Stim.Frequency,  '%.2f'), '_b', num2str(t{i}.Comp.boost), '.png'))
        close all;

    end
    
    
    
end