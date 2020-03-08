%aV=a;
%tV=t;
close all
old = analyseSim(aV, 'stimulus', 'Amplitude');
[tun,tvec, VList] = analyseSim(tV, 'Stim', 'Amplitude');

ts = 50;
te = 60;

n = 10; %10 is interesting, 15
Amp = aV{n}.stimulus.Amplitude;
V1 = aV{n}.stimulus.Signal;
I1 = aV{n}.netI;
C1 = aV{n}.netC;
V2 = tV{n}.Stim.Signal;
I2 = tV{n}.netI;
C2 = tV{n}.netC;
avLam1 = old.avLam(:,n);
avLam2 = tun.avLam(:,n);

period = floor(1/aV{1}.stimulus.Frequency/aV{1}.dt);
j = 30;
x = (j-1)*2000;

figure
plot(V1((x+1+period/2):(x+period/4*3)),I1((x+1+period/2):(x+period/4*3))) %(40000:41000)
%plot(V1,I1) %(40000:41000)
hold on;
%plot(V2,I2)
plot(V2((x+1):(x+period)),I2((x+1):(x+period))) %(40000:41000)

xlabel 'V (V)'
ylabel 'I (A)'
%xlim([-5.1,5.1])
%ylim([-1.5e-4,1.5e-4])
%title(sprintf('5.01V IV for cycle %d', n))
title('AC Comparison')
legend 'Old model' 'Tunnelling'

figure
plot(tvec,C1)
hold on;
plot(tvec,C2)
xlabel('t (s)')
ylabel('Conductance (S)')
yyaxis right
plot(tvec,V2)
ylabel('Voltage (V)')
legend 'Old model' 'Tunnelling'
xlim([ts,te])

figure
plot(tvec,I1)
hold on;
plot(tvec,I2)
ylabel('Current (A)')
yyaxis right
plot(tvec,V2)
xlabel('t (s)')
ylabel('Voltage (V)')
legend 'Old model' 'Tunnelling'
xlim([ts,te])

figure 
plot(tvec, avLam1)
hold on
plot(tvec, avLam2)
plot(tvec, ones(1,numel(tvec))*aV{1}.params.critFlux)
ylabel '\lambda (Vs)'
xlabel 't (s)'
yyaxis right
plot(tvec, V2)
plot(tvec, ones(1,numel(tvec))*aV{1}.params.setV(1))
plot(tvec, ones(1,numel(tvec))*aV{1}.params.resetV(1))
ylabel 'Voltage (V)'
legend '\lambda Old model' '\lambda Tunnelling' '\lambda_{crit}' 'Stim' 'V_{set}' 'V_{reset}'
xlim([ts,te])


%{
figure
plot(cList,old.beta)
hold on
plot(cList,tun.beta)
plot(cList,old.beta_0_10)
plot(cList,tun.beta_0_10)
plot(cList,old.beta_100_500)
plot(cList,tun.beta_100_500)
xlabel 'On bias (V)'
ylabel '\beta'
legend 'Old \beta' 'Tun \beta' 'Old \beta [0,10]' 'Tun \beta [0,10]' 'Old \beta [100,500]' 'Tun \beta [100,500]'
title 'DC and Wait - Beta'



t = SimulationOptions.TimeVector;
c= 1./Output.networkResistance;
lam_av = mean(abs(Output.lambda.'));
lam_std = std(abs(Output.lambda.'));
t1 = t(10000:end);
la1 = lam_av(10000:end);
ls1 = lam_std(10000:end);
figure
yyaxis left
plot(t, c)
ylabel '\sigma'
yyaxis right
plot(t, lam_std)
ylabel '\lambda_{std}'
xlabel 'Time'

%}


%Fourier Plotting

figure
% Fourier analysis of conductance:
C1(isnan(C1))=0;
C2(isnan(C2))=0;
fl = 0.0; %0,100
fu = 500.0; %500
[t_freq1, conductance_freq1] = fourier_analysis(tvec, C1);
[t_freq2, conductance_freq2] = fourier_analysis(tvec, C2);
%            [t_freq, conductance_freq] = fourier_analysis(Stim.TimeAxis(Stim.TimeAxis>=1), conductance(Stim.TimeAxis>=1));
% using built-in function:
%            [pwr,f] = pspectrum(conductance,Stim.TimeAxis,'leakage',0.5);    

% Linear fit for log-log plot of PSD:
fitCoef1 = polyfit(log10(t_freq1(t_freq1>fl & t_freq1<fu)), log10(conductance_freq1(t_freq1>fl & t_freq1<fu)), 1);
%fitCoef1 = polyfit(log10(t_freq1(t_freq1~=0 & t_freq1<5e2)), log10(conductance_freq1(t_freq1~=0 & t_freq1<5e2)), 1);
%            fitCoef = polyfit(log10(t_freq(t_freq>=0.2 & t_freq<=20)), log10(conductance_freq(t_freq>=0.2 & t_freq<=20)), 1);
fitCoef1(2) = 10^fitCoef1(2); 
PSDfit1 = fitCoef1(2)*t_freq1.^fitCoef1(1);

fitCoef2 = polyfit(log10(t_freq2(t_freq2>fl & t_freq2<fu)), log10(conductance_freq2(t_freq2>fl & t_freq2<fu)), 1);
%fitCoef2 = polyfit(log10(t_freq2(t_freq2~=0 & t_freq2<5e2)), log10(conductance_freq2(t_freq2~=0 & t_freq2<5e2)), 1);
fitCoef2(2) = 10^fitCoef2(2); 
PSDfit2 = fitCoef2(2)*t_freq2.^fitCoef2(1);


%            semilogy(t_freq,conductance_freq);
loglog(t_freq1,conductance_freq1,'b');
%xlim([min(t_freq1), max(t_freq1)]);
xlim([fl, fu]);
hold on;
%            loglog(f,pwr,'g');
%            semilogy(t_freq,PSDfit,'r');
loglog(t_freq2,conductance_freq2,'r');
loglog(t_freq1,PSDfit1,'g-');
loglog(t_freq2,PSDfit2,'y-');
%            loglog(t_freq(t_freq>=0.2 & t_freq<=20),PSDfit(t_freq>=0.2 & t_freq<=20),'r');
title('Conductance PSD');
xlabel('Frequency (Hz)');
ylabel('PSD');
ylim([min(conductance_freq1)/10,max(conductance_freq1)*10]);
set(gca,'Ytick',10.^(-20:1:20));
%set(gca,'Xtick',10.^(-20:1:20));
grid on;
legend('Old', 'Tunnel', strcat('Old fit: ', sprintf('\\beta=%.1f', -fitCoef1(1))), strcat('Tun fit: ', sprintf('\\beta=%.1f', -fitCoef2(1))));
fitCoef1(1)
fitCoef2(1)
hold off;

figure
subplot(2,1,1);
loglog(t_freq1,conductance_freq1,'b');
hold on;
loglog(t_freq1,PSDfit1,'g-');
ylim([min(conductance_freq1)/10,max(conductance_freq1)*10]);
xlim([fl, fu]);
legend('Old', sprintf('\\beta=%.1f', -fitCoef1(1)));
title 'AC Triangular: 4V, 0.5Hz Conductance PSD'
xlabel('Frequency (Hz)');
ylabel('PSD');

grid on;
subplot(2,1,2);
loglog(t_freq2,conductance_freq2,'r');
hold on;
loglog(t_freq2,PSDfit2,'y-');
ylim([min(conductance_freq1)/10,max(conductance_freq1)*10]);
xlim([fl, fu]);
legend('Tunnel', strcat('Tun fit: ', sprintf('\\beta=%.1f', -fitCoef2(1))));
grid on;
xlabel('Frequency (Hz)');
ylabel('PSD');