params = struct();

% Set Simulation Options
params.SimOpt.useWorkspace    = false;
params.SimOpt.saveSim         = true;
params.SimOpt.takingSnapshots = false;
params.SimOpt.onlyGraphics    = true; %does not plot anything
%params.SimOpt.saveFolder      = '.';
params.SimOpt.T               = 200.0;
params.SimOpt.dt              = 1e-3;
params.SimOpt.useParallel     = false;
params.SimOpt.hdfSave         = true;
params.importSwitch = false;

%delete(gcp('nocreate')); parpool(2);

%Set Stimulus
params.Stim.BiasType     = 'DC'; % 'DC' \ 'AC' \ 'DCandWait' \ 'Ramp' \ 'ACsaw'
params.Stim.Amplitude    = 0.1; 


%Set Components
params.Comp.ComponentType  = 'atomicSwitch';
params.Comp.offConductance  = 1e-8;
params.Comp.setVoltage     = 1e-2;
params.Comp.resetVoltage   = 1e-3;
params.Comp.criticalFlux   =  0.1;
params.Comp.maxFlux        = 0.15;
params.Comp.penalty        =    1;
params.Comp.boost          =   10;

%Set Connectivity 
%Using defaults

cd '/import/silo2/joelh/VaryParams/Thesis/DC/'


addpath(genpath('/import/silo2/joelh/VaryParams/Thesis/'));

params.SimOpt.saveFolder = '/import/silo2/joelh/VaryParams/Thesis/DC/V';
params.Comp.ComponentType  = 'atomicSwitch';
params.Stim.Amplitude = [0.010:0.005:0.080, 0.09001:0.00001:0.09004, 0.09006:0.00001:0.09009, 0.085:0.0005:0.0995, 0.1:0.05:2.0];
a = multiImport(params);
params.Comp.ComponentType  = 'tunnelSwitch2';
params.Stim.Amplitude = [0.010:0.005:0.080, 0.09001:0.00001:0.09004, 0.09006:0.00001:0.09009, 0.085:0.0005:0.0995, 0.1:0.05:2.0];
t = multiImport(params);

old               = analyseSim(a, 'Stim', 'Amplitude');
[tun, tvec, cList] = analyseSim(t, 'Stim', 'Amplitude');



%%
%expt = load('TFOscilloKeithDaq_2019_07_29_14_30_43__act.mat');
expt = load('TFOscilloKeithDaq_2019_07_29_15_18_27__act.mat');
scale = 0.0045;
tend = 5.0;
expt.G = [expt.G,  ones(size(max(expt.t*scale):1e-3:tend))*expt.G(end)];
expt.t = [expt.t*scale,  max(expt.t*scale):1e-3:tend];

%DC tun, cmp
j = find(cList == 1.5);
figure;
semilogy(tvec,old.c(:,j))
hold on
semilogy(tvec,tun.c(:,j))
semilogy(expt.t,expt.G);
xlim([0,tend])
xlabel('t (s)')
ylabel('G (S)')
yyaxis right
plot(tvec, t{j}.Stim.Signal)
ylim([0,0.2]);
ylabel 'V (V)'
legend('Tun', 'Bin', 'Exp', 'location', 'southeast')
title('Network DC Stimulation - 0.1V');
set(findall(gca, 'Type', 'Line'),'LineWidth',2.0);
%saveas(gcf, 'lowV_DC_ConComparison.png')
hold off

%%
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
legend('Bin: 0.5 V', 'Tun: 0.5 V', 'Bin: 1.0 V', 'Tun: 1.0 V', 'Bin: 1.5 V', 'Tun: 1.5 V')
title('DC Activation - Compare Voltages');
set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);
%saveas(gcf, 'bin_tun_high_V_DC_ConComparison.png')



%% Total DC Comparison
expt = load('TFOscilloKeithDaq_2019_07_29_14_30_43__act.mat');
scale = 0.64;
j = find(cList == 0.1);
figure('visible','on', 'color','w', 'units', 'centimeters', 'OuterPosition', [5 5 50 20]);
subplot(1,2,1);
semilogy(tvec,old.c(:,j), '-')
hold on
semilogy(tvec,tun.c(:,j), '--')
semilogy(expt.t*scale,expt.G);
xlim([0,70])
xlabel('t (s)')
ylabel('G (S)')
yyaxis right
plot(tvec, t{j}.Stim.Signal)
ylim([0,0.2]);
ylabel 'V (V)'
legend('Bin', 'Tun', 'Exp', 'location', 'northwest')
title('Low voltage DC stimulation');
set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);
hold off

%High Voltage regime
expt = load('TFOscilloKeithDaq_2019_07_29_15_18_27__act.mat');
scale = 0.0045;
tend = 6.0;
expt.G = [expt.G,  ones(size(max(expt.t*scale):1e-3:tend))*expt.G(end)];
expt.t = [expt.t*scale,  max(expt.t*scale):1e-3:tend];
subplot(1,2,2);
semilogy(tvec,old.c(:,j1), '-');
hold on;
semilogy(tvec,tun.c(:,j1), '--');
semilogy(tvec,old.c(:,j2), '-');
semilogy(tvec,tun.c(:,j2), '--');
semilogy(tvec,old.c(:,j3), '-');
semilogy(tvec,tun.c(:,j3), '--');
semilogy(expt.t, expt.G, '-.');
xlabel('t (s)')
ylabel('G (S)')
xlim([0,4]);
legend('Bin: 0.5 V', 'Tun: 0.5 V', 'Bin: 1.0 V', 'Tun: 1.0 V', 'Bin: 1.5 V', 'Tun: 1.5 V', 'Exp', 'location', 'southeast')
title('High voltage DC stimulation');
set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);
saveas(gcf, '~/Documents/Honours/Project/Figures/Chapter4/DC_Comparison1.png')
