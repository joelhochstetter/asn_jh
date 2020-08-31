%% Process sims

calcLyapunov(1 , 2, false)

%eps 1e-5

%% Import stuff
lyRes  = open('Ly1.mat');
V      = open('100nwInitVoltages.mat');
lij    = lyRes.lijArr;
netC   = lyRes.netCArr;
gamma  = lyRes.gammaArr;
lambda = lyRes.lambdaArr;
V      = V.V;

%% Run


dt       = 1e-3;
T        = 1e3;
timeVec  = dt:dt:T;

SimulationOptions.dt         = dt;
SimulationOptions.T          = T;
SimulationOptions.TimeVector = timeVec;

%Set Stimulus
Stimulus.BiasType     = 'AC'; % 'DC' \ 'AC' \ 'DCandWait' \ 'Ramp' \ 'ACsaw'
Stimulus.Frequency       = 0.5; % (Hz)
Stimulus.Amplitude       = 3;   % (Volt)
Stimulus = getStimulus(Stimulus, SimulationOptions);




figure;plot(lij');title('Lyapunov vs period - for each switch');ylabel('\lambda_1');xlabel('Period');
%figure;plot(timeVec, netC); title('Network conductance vs time');ylabel('Conductance (S)'); xlabel('Time (s)');


%% Lypanov
figure;plot(lij');

%% Comparison of maximal Lyapunov exponents

figure;
plot(abs(V), lambda, 'x');
xlabel('Initial Voltage drop (V)')
ylabel('Maximal lyapunov exponent')


MLEest = mean(lambda)



%% Analysis of a single simulation 
params = struct();
params.importByName = 't_T1000_AC3V_f0.5Hz_s0.01_r0.001_c0.1_m0.15_b1_p10_eps1e-05_i248';
t = multiImport(params);
t{1}.Lyapunov.perturbID = 248;

%%
params.importByName = 't_T1000_AC3V_f0.5Hz_s0.01_r0.001_c0.1_m0.15_b1_p10_eps1e-05_i262';
init = multiImport(params);
init{1}.Lyapunov.perturbID = 0;



%% 
params = struct();
params.importByName = 't_T1000_AC3V_f0.5Hz_s0.01_r0.001_c0.1_m0.15_b1_p10_eps1e-05_i207';
a = multiImport(params);
a{1}.Lyapunov.perturbID = 207;
t{2} = a{1};


%% 
params = struct();
params.importByName = 't_T1000_AC3V_f0.5Hz_s0.01_r0.001_c0.1_m0.15_b1_p10_eps1e-05_i238';
a = multiImport(params);
a{1}.Lyapunov.perturbID = 238;
t{3} = a{1};

%% Use single simulation 
%Perturbed switch comparison
tidx = 1;

period = floor(1/t{1}.Stim.Frequency/t{1}.dt);
tNumT  = (1:numel(timeVec))/t{1}.Stim.Frequency/t{1}.dt;%time in units of number of periods

figure('units','normalized','outerposition',[0 0 1 1]);
subplot(3,2,1)
plot(tNumT, t{tidx}.swLam(:,t{tidx}.Lyapunov.perturbID))
xlabel('Number of periods')
title(strcat('Perturbed Switch ', num2str(t{tidx}.Lyapunov.perturbID)))
ylabel('switch \lambda')
yyaxis right
semilogy(tNumT,t{tidx}.swC(:,t{tidx}.Lyapunov.perturbID))
ylabel('switch conductance (S)')
xlabel('Number of periods')
legend('pert \lambda', 'pert con')

subplot(3,2,2)
plot(tNumT, init{1}.swLam(:,t{tidx}.Lyapunov.perturbID))
ylabel('switch \lambda')
yyaxis right
semilogy(tNumT, init{1}.swC(:,t{tidx}.Lyapunov.perturbID))
ylabel('switch conductance (S)')
legend('pert \lambda', 'pert con')
xlabel('Number of periods')
title(strcat('Unperturbed Switch ', num2str(t{tidx}.Lyapunov.perturbID)))


numTPlot = 10;
%Plotting switches IV curve first 10
subplot(3,2,3)
plot(t{tidx}.swV(1:numTPlot*period,t{tidx}.Lyapunov.perturbID), t{tidx}.swV(1:numTPlot*period,t{tidx}.Lyapunov.perturbID).*t{tidx}.swC(1:numTPlot*period,t{tidx}.Lyapunov.perturbID))
title(strcat('Perturbed vs underpert Switch ', num2str(t{tidx}.Lyapunov.perturbID),  '(V,I) first', num2str(numTPlot), ' periods'))
ylabel('switch V (V)')
hold on;
plot(init{1}.swV(1:numTPlot*period,t{tidx}.Lyapunov.perturbID), init{1}.swV(1:numTPlot*period,t{tidx}.Lyapunov.perturbID).*init{1}.swC(1:numTPlot*period,t{tidx}.Lyapunov.perturbID))
ylabel('switch I (A)')
legend('pert', 'unpert')


%Plotting switches IV curve last 10 
subplot(3,2,4)
semilogy((t{tidx}.swV(end-numTPlot*period+1:end,t{tidx}.Lyapunov.perturbID)), abs(t{tidx}.swV(end-numTPlot*period+1:end,t{tidx}.Lyapunov.perturbID).*t{tidx}.swC(end-numTPlot*period+1:end,t{tidx}.Lyapunov.perturbID)))
ylabel('switch V (V)')
hold on;
semilogy((init{1}.swV(end-numTPlot*period+1:end,t{tidx}.Lyapunov.perturbID)), abs(init{1}.swV(end-numTPlot*period+1:end,t{tidx}.Lyapunov.perturbID).*init{1}.swC(end-numTPlot*period+1:end,t{tidx}.Lyapunov.perturbID)))
ylabel('switch I (A)')
legend('pert', 'unpert')
title(strcat('Perturbed vs underpert Switch ', num2str(t{tidx}.Lyapunov.perturbID),  '(V,I) last', num2str(numTPlot), ' periods'))






%Plotting switches (lambda, V) phase space first 10
subplot(3,2,5)
plot(t{tidx}.swLam((1:numTPlot*period),t{tidx}.Lyapunov.perturbID), t{tidx}.swV((1:numTPlot*period),t{tidx}.Lyapunov.perturbID))
title(strcat('Perturbed vs underpert Switch ', num2str(t{tidx}.Lyapunov.perturbID),  '(\lambda,V) first', num2str(numTPlot), ' periods'))
xlabel('switch \lambda')
hold on
plot(init{1}.swLam((1:numTPlot*period),t{tidx}.Lyapunov.perturbID), init{1}.swV((1:numTPlot*period),t{tidx}.Lyapunov.perturbID))
ylabel('switch V (V)')
legend('pert', 'unpert')


%Plotting switches (lambda, V) phase space last 10 
subplot(3,2,6)
plot(t{tidx}.swLam(end-numTPlot*period+1:end,t{tidx}.Lyapunov.perturbID), t{tidx}.swV(end-numTPlot*period+1:end,t{tidx}.Lyapunov.perturbID))
title(strcat('Perturbed vs underpert Switch ', num2str(t{tidx}.Lyapunov.perturbID),  '(\lambda,V) first', num2str(numTPlot), ' periods'))
xlabel('switch \lambda')
hold on
plot(init{1}.swLam(end-numTPlot*period+1:end,t{tidx}.Lyapunov.perturbID), init{1}.swV(end-numTPlot*period+1:end,t{tidx}.Lyapunov.perturbID))
ylabel('switch V (V)')
legend('pert', 'unpert')
title(strcat('Perturbed vs underpert Switch ', num2str(t{tidx}.Lyapunov.perturbID),  '(\lambda,V) last', num2str(numTPlot), ' periods'))






%% Network comparison

tidx = 1;
tNumT  = (1:numel(timeVec))/t{1}.Stim.Frequency/t{1}.dt;%time in units of number of periods

figure('units','normalized','outerposition',[0 0 1 1]);
subplot(2,2,1)
semilogy(tNumT, t{tidx}.netC./init{1}.netC)
ylabel 'Ratio of pert/unpert G'
xlabel('Number of periods'),
title(strcat('Perturbed Switch ', num2str(t{tidx}.Lyapunov.perturbID),'Network conductance comparison'))

subplot(2,2,2)
period = floor(1/t{tidx}.Stim.Frequency/t{1}.dt);
plot(t{tidx}.Stim.Signal, t{tidx}.netI)
hold on
plot(init{1}.Stim.Signal, init{1}.netI)
legend('pert', 'unpert')
xlabel('Voltage (V)');
ylabel('Current (A)');
title 'Total IV curve'

numTPlot = 10;
subplot(2,2,3)
plot(t{tidx}.Stim.Signal(1:numTPlot*period) , t{tidx}.netI(1:numTPlot*period))
hold on
plot(init{1}.Stim.Signal(1:numTPlot*period), init{1}.netI(1:numTPlot*period))
legend('pert', 'unpert')
title 'First 10 periods IV comparison'
xlabel('Voltage (V)');
ylabel('Current (A)');

subplot(2,2,4)
plot(t{tidx}.Stim.Signal(end-numTPlot*period+1:end), t{tidx}.netI(end-numTPlot*period+1:end))
hold on
plot(init{1}.Stim.Signal(end-numTPlot*period+1:end), init{1}.netI(end-numTPlot*period+1:end))
xlabel('Voltage (V)');
ylabel('Current (A)');
title 'Last 10 periods IV comparison'



%% AC IV analysis
%aV=a;
%tV=t;

ts = 950;
te = 1000;

n = 1; %10 is interesting, 15
Amp = init{1}.Stim.Amplitude;
V1  = init{1}.Stim.Signal;
I1  = init{1}.netI;
C1  = init{n}.netC;
V2  = t{n}.Stim.Signal;
I2  = t{n}.netI;
C2  = t{n}.netC;

period = floor(1/t{1}.Stim.Frequency/t{1}.dt);
j = 72;
x = (j-1)*2000;

figure('units','normalized','outerposition',[0 0 1 1]);
subplot(3,1,1);
plot(V1(((x+1):(x+period))),I1((x+1):(x+period)))%(40000:41000)
%plot(V1,I1) %(40000:41000)
hold on;
%plot(V2,I2)
plot(V2((x+1):(x+period)),I2((x+1):(x+period))) %(40000:41000)

xlabel 'V (V)'
ylabel 'I (A)'
%xlim([-5.1,5.1])
%ylim([-1.5e-4,1.5e-4])
%title(sprintf('5.01V IV for cycle %d', n))
title(strcat('AC Comparison, ', num2str(j), 'th cycle'))
legend 'Unperturbed' 'Perturbed'

subplot(3,1,2);
plot(timeVec,C1)
hold on;
plot(timeVec,C2)
xlabel('t (s)')
ylabel('Conductance (S)')
yyaxis right
plot(timeVec,V2)
ylabel('Voltage (V)')
legend 'Unperturbed' 'Perturbed'
xlim([ts,te])

subplot(3,1,3);
plot(timeVec,I1)
hold on;
plot(timeVec,I2)
ylabel('Current (A)')
yyaxis right
plot(timeVec,V2)
xlabel('t (s)')
ylabel('Voltage (V)')
legend 'Unperturbed' 'Perturbed'
xlim([ts,te])

% we care about differences in trajectories at late time steps


%% Power spectral analysis
figure
% Fourier analysis of conductance:
C1(isnan(C1))=0;
C2(isnan(C2))=0;
fl = 0.0; %0,100
fu = 500.0; %500
%Fourier analysis of conductance
[t_freq1, conductance_freq1] = fourier_analysis(timeVec, C1);
[t_freq2, conductance_freq2] = fourier_analysis(timeVec, C2);

%Fourier analysis of input signal
[t_freqV, V_freq] = fourier_analysis(timeVec, Stimulus.Signal');

% Linear fit for log-log plot of PSD:
fitCoef1 = polyfit(log10(t_freq1(t_freq1>fl & t_freq1<fu)), log10(conductance_freq1(t_freq1>fl & t_freq1<fu)), 1);
fitCoef1(2) = 10^fitCoef1(2); 
PSDfit1 = fitCoef1(2)*t_freq1.^fitCoef1(1);

fitCoef2 = polyfit(log10(t_freq2(t_freq2>fl & t_freq2<fu)), log10(conductance_freq2(t_freq2>fl & t_freq2<fu)), 1);
fitCoef2(2) = 10^fitCoef2(2); 
PSDfit2 = fitCoef2(2)*t_freq2.^fitCoef2(1);


fitCoefV = polyfit(log10(t_freqV(t_freqV>fl & t_freqV<fu)), log10(V_freq(t_freqV>fl & t_freqV<fu)), 1);
fitCoefV(2) = 10^fitCoefV(2); 
PSDfitV = fitCoefV(2)*t_freqV.^fitCoefV(1);

loglog(t_freq1,conductance_freq1,'b');
xlim([fl, fu]);
hold on;
loglog(t_freq2,conductance_freq2,'r');
loglog(t_freq1,PSDfit1,'g-');
loglog(t_freq2,PSDfit2,'y-');
title('Conductance PSD');
xlabel('Frequency (Hz)');
ylabel('PSD');
ylim([min(conductance_freq1)/10,max(conductance_freq1)*10]);
set(gca,'Ytick',10.^(-20:1:20));
grid on;
legend('Unper', 'Pert', strcat('Old fit: ', sprintf('\\beta=%.1f', -fitCoef1(1))), strcat('Tun fit: ', sprintf('\\beta=%.1f', -fitCoef2(1))));
fitCoef1(1)
fitCoef2(1)
hold off;

figure
subplot(3,1,1);
loglog(t_freq1,conductance_freq1,'b');
hold on;
loglog(t_freq1,PSDfit1,'g-');
ylim([min(conductance_freq1)/10,max(conductance_freq1)*10]);
xlim([fl, fu]);
legend('Unper', sprintf('\\beta=%.1f', -fitCoef1(1)));
title 'AC Triangular: 4V, 0.5Hz Conductance PSD'
xlabel('Frequency (Hz)');
ylabel('PSD');

grid on;
subplot(3,1,2);
loglog(t_freq2,conductance_freq2,'r');
hold on;
loglog(t_freq2,PSDfit2,'y-');
ylim([min(conductance_freq1)/10,max(conductance_freq1)*10]);
xlim([fl, fu]);
legend('Pert', strcat('Pert fit: ', sprintf('\\beta=%.1f', -fitCoef2(1))));
grid on;
xlabel('Frequency (Hz)');
ylabel('PSD');

subplot(3,1,3);
loglog(t_freqV,V_freq,'r');
hold on;
loglog(t_freqV,PSDfitV,'y-');
ylim([min(V_freq)/10,max(V_freq)*10]);
xlim([fl, fu]);
legend('V', strcat('V fit: ', sprintf('\\beta=%.1f', -fitCoefV(1))));
grid on;
xlabel('Frequency (Hz)');
ylabel('PSD');







%% 
%https://en.wikipedia.org/wiki/Recurrence_plot - recurrence plots
%https://en.wikipedia.org/wiki/Poincar%C3%A9_map - poincare map

% analyse chaotic dynamics in lyapunov exponents

%% Coupled map lattices
%See page 398


%If I calculate all Lyapunov exponents then I can calculate the attractor
%dimension which is an estimate of complexity of the system


%Try for other periodic pulses
