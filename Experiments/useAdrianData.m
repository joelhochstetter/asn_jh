%must have Hokanson TDMS code in path
close all;
folder = '/import/silo2/joelh/modelValidation/Adrian/Network#1/Squ/';
%folder = '/import/silo2/joelh/modelValidation/Adrian/Network#2/DC/activate/';
%folder  = '/import/silo2/joelh/modelValidation/Adrian/GoodAC/';
cd(folder);


%{
mkdir 'DC'
mkdir 'Tri'
mkdir 'AC'
mkdir 'Squ'
mkdir 'Bad'
%}
%{
mkdir 'Pinch'
mkdir 'Not_pinch'
%}
%{
    movefile('good/*','.')
    rmdir bad s
    rmdir good s
    %mkdir good
    %mkdir bad
    return
%}

delete('*.tdms_index')

%file = 'TFIVKeith_2019_05_28_15_38_24__dist-0-20-0.tdms';


files = dir(strcat(folder, '*.tdms'));
for file = files'
    ff = strcat(file.folder,'/',file.name);
    my_tdms_struct = TDMS_getStruct(ff);
    %{
    if ~isfield(my_tdms_struct, 'Untitled')
        movefile(ff, 'bad');
       continue
    end
    %}
    file.name

    
    if isfield(my_tdms_struct,'Untitled')
        if isfield(my_tdms_struct.Untitled,'Volt')
            t = my_tdms_struct.Untitled.Time.data;
            t = t - t(1);
            I = my_tdms_struct.Untitled.Input.data;
            V = my_tdms_struct.Untitled.Volt.data;
            V(V==0) = 1e-8; %avoids singularities when fourier transform.
            G = I./V;
            
            figure('units','normalized','outerposition',[0 0 1 1]);
            subplot(2,2,1);
            plot(t,(I));
            xlabel 'Time (s)'
            ylabel 'Current (A)'
            yyaxis right;
            plot(t,V);
            ylabel 'Source voltage (V)'
            title(file.name)
            
            subplot(2,2,2);
            semilogy(t, G)
            xlabel('Time (s)');
            ylabel('Conductance (S)');
            yyaxis right;
            plot(t,V);
            
            subplot(2,2,3);            
            semilogy(V, abs(I));          
            xlabel 'Voltage (V)'
            ylabel 'Current (A)'
%             legend('Inner', 'Outer')
            subplot(2,2,4);
            semilogy(V, G)
%             hold on;
%             semilogy(V, abs(G(9000:10000)));
%             legend('Inner', 'Outer')
            xlabel('Voltage (V)');
            ylabel('Conductance (S)');
            
            
            
            
            %{
            [tf,Vf] = fourier_analysis(t, V);
            [~,i] = max(Vf);
            T = 1/tf(i);
            dt = (t(end)-t(1))/(numel(t)-1);

            numT = round(T/dt);
            %{
            plot(t,I);
            xlabel 'Time (s)'
            ylabel 'Current (A)'
            if isfield(my_tdms_struct.Untitled, 'Volt')
                V = my_tdms_struct.Untitled.Volt.data;
                yyaxis right;
                plot(t,V);
                ylabel 'Voltage (V)'        
            end
            %}

            figure;
            subplot(2,2,1);
            plot(V,I); %IV curve
            xlabel 'Voltage (V)'
            ylabel 'Current (I)'
            title(file.name)

            
            %Conductance time series
            subplot(2,2,2);
            plot(t,I);
            xlabel 'Time (s)'
            ylabel 'Current (A)'
            yyaxis right;
            plot(t,V);
            ylabel 'Source voltage (V)'
            title('I, V time series')

             
            %IV 1

            subplot(2,2,3);

            plot(V(1:numT),I(1:numT)); %IV curve
            xlabel 'Voltage (V)'
            ylabel 'Current (I)'
            title('IV Curve for first period')
          

            subplot(2,2,4);
                        % Fourier analysis of conductance:
            [t_freq, conductance_freq] = fourier_analysis(t,G');
%            [t_freq, conductance_freq] = fourier_analysis(Stimulus.TimeAxis(Stimulus.TimeAxis>=1), conductance(Stimulus.TimeAxis>=1));
            % using built-in function:
%            [pwr,f] = pspectrum(conductance,Stimulus.TimeAxis,'leakage',0.5);    

            % Linear fit for log-log plot of PSD:
            fitCoef = polyfit(log10(t_freq(t_freq~=0 & t_freq<max(t_freq))), log10(conductance_freq(t_freq~=0 & t_freq<max(t_freq))), 1);
%            fitCoef = polyfit(log10(t_freq(t_freq>=0.2 & t_freq<=20)), log10(conductance_freq(t_freq>=0.2 & t_freq<=20)), 1);
            fitCoef(2) = 10^fitCoef(2); 
            PSDfit = fitCoef(2)*t_freq.^fitCoef(1);
            %            semilogy(t_freq,conductance_freq);
            loglog(t_freq,conductance_freq);
            xlim([min(t_freq), max(t_freq)]);
            hold on;
%            loglog(f,pwr,'g');
%            semilogy(t_freq,PSDfit,'r');
            loglog(t_freq,PSDfit,'r');
%            loglog(t_freq(t_freq>=0.2 & t_freq<=20),PSDfit(t_freq>=0.2 & t_freq<=20),'r');
            text(0.5,0.8,sprintf('\\beta=%.1f', -fitCoef(1)),'Units','normalized','Color','r','FontSize',18);
            title('Conductance PSD');
            xlabel('Frequency (Hz)');
            ylabel('PSD');
            ylim([min(conductance_freq)/10,max(conductance_freq)*10]);
            set(gca,'Ytick',10.^(-20:1:20));
            %set(gca,'Xtick',10.^(-20:1:20));
            grid on;
            %}
        else
            
            % DC 
            
            t = my_tdms_struct.Untitled.Time.data;
            t = t - t(1);
            I = my_tdms_struct.Untitled.Input.data;

    
            
            %average over adjacent elements if double datapoints obtained
            if t(1) == t(2)
                t = 0.5 * (t(1:end-1) + t(2:end));
                I = 0.5 * (I(1:end-1) + I(2:end));                
            end
            
            V = str2double(my_tdms_struct.Props.Source__V_or_A_)*ones(size(I));
            G = I./V;
            
            sp = split(file.name, '.');            
            save(strcat(char(sp(1)), '.mat'), 'V', 'G', 'I', 't');
            
            %{
            figure
            subplot(1,2,1);
            semilogy(t,G);
            title(file.name)
            xlabel 'Time (s)'
            ylabel 'Conductance (S)'
            yyaxis right
            plot(t,V)
            ylabel 'Voltage (V)'
            
            % Fourier analysis of conductance:
            [t_freq, conductance_freq] = fourier_analysis(t, G');
%            [t_freq, conductance_freq] = fourier_analysis(Stimulus.TimeAxis(Stimulus.TimeAxis>=1), conductance(Stimulus.TimeAxis>=1));
            % using built-in function:
%            [pwr,f] = pspectrum(conductance,Stimulus.TimeAxis,'leakage',0.5);    

            % Linear fit for log-log plot of PSD:
            fitCoef = polyfit(log10(t_freq(t_freq~=0 & t_freq<max(t_freq))), log10(conductance_freq(t_freq~=0 & t_freq<max(t_freq))), 1);
%            fitCoef = polyfit(log10(t_freq(t_freq>=0.2 & t_freq<=20)), log10(conductance_freq(t_freq>=0.2 & t_freq<=20)), 1);
            fitCoef(2) = 10^fitCoef(2); 
            PSDfit = fitCoef(2)*t_freq.^fitCoef(1);

            subplot(1,2,2);
            %            semilogy(t_freq,conductance_freq);
            loglog(t_freq,conductance_freq);
            xlim([min(t_freq), max(t_freq)]);
            hold on;
%            loglog(f,pwr,'g');
%            semilogy(t_freq,PSDfit,'r');
            loglog(t_freq,PSDfit,'r');
%            loglog(t_freq(t_freq>=0.2 & t_freq<=20),PSDfit(t_freq>=0.2 & t_freq<=20),'r');
            text(0.5,0.8,sprintf('\\beta=%.1f', -fitCoef(1)),'Units','normalized','Color','r','FontSize',18);
            title('Conductance PSD');
            xlabel('Frequency (Hz)');
            ylabel('PSD');
            ylim([min(conductance_freq)/10,max(conductance_freq)*10]);
            set(gca,'Ytick',10.^(-20:1:20));
            %set(gca,'Xtick',10.^(-20:1:20));
            grid on;
            %}
            
            figure;
            semilogy(t/40,G*10);
            title(file.name)
            xlabel 'Time (s)'
            ylabel 'Conductance (S)'
            yyaxis right
            plot(t/40,0.5*ones(size(t)))
            ylabel 'Voltage (V)' 
            xlim([0, max(t/40)])
        
        end


        s = input('DC: 0, Tri: 1, AC: 2, Squ: 3, Bad: 4\n', 's');
        %{


            if s == '0'
               movefile(ff, 'DC');
            elseif s == '1'
                movefile(ff, 'Tri');
            elseif s == '2'
                movefile(ff, 'AC');
            elseif s == '3'
                movefile(ff, 'Squ');
            elseif s == '4'
                movefile(ff, 'Bad');
            end
                if s == '1'
           movefile(ff, 'Pinch');
        elseif s == '2'
            movefile(ff, 'Not_pinch');
        end

        %}        

    end

end
