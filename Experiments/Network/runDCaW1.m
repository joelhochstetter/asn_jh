%%
params = struct();

% Set Simulation Options
params.SimOpt.useWorkspace    = false;
params.SimOpt.saveSim         = true;
params.SimOpt.takingSnapshots = false;
params.SimOpt.onlyGraphics    = true; %does not plot anything
%params.SimOpt.saveFolder      = '.';
params.SimOpt.T               = 200.0;
params.SimOpt.dt              = 1e-3;
params.SimOpt.onlyGraphics    = false; %does not plot anything
params.SimOpt.useParallel     = true;
params.SimOpt.useLong         = true;
%params.SimOpt.nameComment     = '_dt5e-6';

delete(gcp('nocreate'));
parpool(6);

%Set Stimulus
params.Stim.BiasType     = 'DCandWait'; % 'DC' \ 'AC' \ 'DCandWait' \ 'Ramp' \ 'ACsaw'
params.Stim.AmplitudeOn    = 1.0;  
params.Stim.AmplitudeOff    = 1e-5;  
params.Stim.OffTime = 5.0;


%Set Components
params.Comp.ComponentType  = 'atomicSwitch';
params.Comp.offResistance  = 1e-8;
params.Comp.setVoltage     = 1e-2;
params.Comp.resetVoltage   = 1e-3;
params.Comp.criticalFlux   =  0.1;
params.Comp.maxFlux        = 0.15;
params.Comp.penalty        =    1;
params.Comp.boost          =   10;


cd '/import/silo2/joelh/VaryParams/Thesis/DCandWait/'
addpath(genpath('/import/silo2/joelh/VaryParams/Thesis/'));


mkdir V
mkdir setV
mkdir resetV
mkdir critF
mkdir maxF
mkdir boost
mkdir toff
mkdir offV

%Set Components
params.Comp.ComponentType  = 'atomicSwitch';
params.Comp.offResistance  = 1e-8;
params.Comp.setVoltage     = 1e-2;
params.Comp.resetVoltage   = 1e-3;
params.Comp.criticalFlux   =  0.1;
params.Comp.maxFlux        = 0.15;
params.Comp.penalty        =    1;
params.Comp.boost          =   10;

addpath(genpath('/import/silo2/joelh/VaryParams/Thesis/'));

%Set Connectivity 
%Using defaults

%%

params.SimOpt.saveFolder = '/import/silo2/joelh/VaryParams/Thesis/DCandWait/V';
params.Stim.AmplitudeOn = 0.1:0.05:2.0;
params.Stim.AmplitudeOn = sort(params.Stim.AmplitudeOn);
params.Comp.ComponentType  = 'atomicSwitch';
old               = analyseSimGoodMemory(params, 'Stim', 'AmplitudeOn');
params.Comp.ComponentType  = 'tunnelSwitch2';
[tun, tvec, cList] = analyseSimGoodMemory(params, 'Stim', 'AmplitudeOn');
params.importSwitch = false;
t = multiImport(params);
a = multiImport(params);
mkdir(strcat(params.SimOpt.saveFolder, '/images')); cd(strcat(params.SimOpt.saveFolder, '/images')); 
DCaW_Plots2(params, old, tun, cList, t, a, 'Stim', 'AmplitudeOn');
save('VaryOnV.mat', 'old', 'tun', 'cList');

%%
cd '/import/silo2/joelh/VaryParams/Thesis/DCandWait/V/images';
load('VaryOnV.mat', 'old', 'tun');

%%
cd '/import/silo2/joelh/VaryParams/Thesis/DCandWait/toff';
load('VaryOffTime.mat', 'old', 'tun');

%% 
cd '/import/silo2/joelh/VaryParams/Thesis/DCandWait/offV';
load('VaryOffV.mat', 'old', 'tun');


%%
j = 1:1:200000;
figure;
semilogy(old.c(j,:)', '-');
hold on;
semilogy(tun.c(j,:)', '--');


%%

params.SimOpt.saveFolder = '/import/silo2/joelh/VaryParams/Thesis/DCandWait/toff';
params.Stim.AmplitudeOn = 1.0;
params.Stim.OffTime = [0.1, 0.25:0.25:10.0];
params.Stim.OffTime = sort(params.Stim.OffTime);
params.Comp.ComponentType  = 'atomicSwitch';
old               = analyseSimGoodMemory(params, 'Stim', 'OffTime');
params.Comp.ComponentType  = 'tunnelSwitch2';
[tun, tvec, cList] = analyseSimGoodMemory(params, 'Stim', 'OffTime');
params.importSwitch = false;
t = multiImport(params);
a = multiImport(params);
mkdir(strcat(params.SimOpt.saveFolder, '/images')); cd(strcat(params.SimOpt.saveFolder, '/images')); 
DCaW_Plots2(params, old, tun, cList, t, a, 'Stim', 'OffTime');
save('VaryOffTime.mat', 'old', 'tun');



%%
params.SimOpt.saveFolder = '/import/silo2/joelh/VaryParams/Thesis/DCandWait/offV';
params.Stim.OffTime      = 5.0;
params.Stim.AmplitudeOff = [1e-5, 2e-5, 5e-5, 1e-4, 2e-4, 5e-4, 1e-3, 2e-3, 5e-3, 1e-2, 2e-2, 5e-2, 1e-1, 2e-1, 0.050:0.025:1.0];
params.Stim.AmplitudeOff = sort(params.Stim.AmplitudeOff);
params.Comp.ComponentType  = 'atomicSwitch';
multiRun(params);
old               = analyseSimGoodMemory(params, 'Stim', 'AmplitudeOff');
params.Comp.ComponentType  = 'tunnelSwitch2';
multiRun(params);
[tun, tvec, cList] = analyseSimGoodMemory(params, 'Stim', 'AmplitudeOff');
params.importSwitch = false;
t = multiImport(params);
a = multiImport(params);
mkdir(strcat(params.SimOpt.saveFolder, '/images')); cd(strcat(params.SimOpt.saveFolder, '/images')); 
DCaW_Plots2(params, old, tun, cList, t, a, 'Stim', 'AmplitudeOff');
save('VaryOffV.mat', 'old', 'tun');
params.Stim.AmplitudeOff = 1e-5;




%{
params.SimOpt.saveFolder = '/import/silo2/joelh/VaryParams/Thesis/DCandWait/setV';
params.Stim.OffTime = 5.0;
params.Comp.setVoltage = [1e-3:2e-3:1e-1];
params.Comp.ComponentType  = 'atomicSwitch';  multiRun(params); 
a = multiImport(params); params.Comp.ComponentType  = 'tunnelSwitch2'; multiRun(params); 
t = multiImport(params);
cList = getCList(a, 'Comp', 'setV');
[~, sortIndex] = sort(cList);
a = a(sortIndex);
t = t(sortIndex);
mkdir(strcat(params.SimOpt.saveFolder, '/images')); cd(strcat(params.SimOpt.saveFolder, '/images')); DCaW_Plots(t, a, 'Comp', 'setV');

params.SimOpt.saveFolder = '/import/silo2/joelh/VaryParams/Thesis/DCandWait/maxF';
params.Comp.setVoltage = 1e-2;
params.Comp.maxFlux = [0.1:0.005:0.25];
params.Comp.ComponentType  = 'atomicSwitch';  multiRun(params); a = multiImport(params); params.Comp.ComponentType  = 'tunnelSwitch2'; multiRun(params); t = multiImport(params);
cList = getCList(a, 'Comp', 'maxFlux');
[~, sortIndex] = sort(cList);
a = a(sortIndex);
t = t(sortIndex);
mkdir(strcat(params.SimOpt.saveFolder, '/images')); cd(strcat(params.SimOpt.saveFolder, '/images')); DCaW_Plots(t, a, 'Comp', 'maxFlux');

params.SimOpt.saveFolder = '/import/silo2/joelh/VaryParams/Thesis/DCandWait/boost';
params.Comp.maxFlux = 0.15;
params.Comp.boost = [0.01, 0.02,0.05,0.2,0.5, 1, 2, 5, 10, 20, 50, 100];
%params.Comp.ComponentType  = 'atomicSwitch';  multiRun(params); a = multiImport(params); params.Comp.ComponentType  = 'tunnelSwitch2'; multiRun(params); t = multiImport(params);
cList = getCList(a, 'Comp', 'boost');
[~, sortIndex] = sort(cList);
a = a(sortIndex);
t = t(sortIndex);
mkdir(strcat(params.SimOpt.saveFolder, '/images')); cd(strcat(params.SimOpt.saveFolder, '/images')); DCaW_Plots(t, a, 'Comp', 'boost');

params.SimOpt.saveFolder = '/import/silo2/joelh/VaryParams/Thesis/DCandWait/resetV';
params.Comp.boost = 10;
params.Comp.resetVoltage = [1e-4,5e-4:5e-4:1e-2];
params.Comp.ComponentType  = 'atomicSwitch';  multiRun(params); a = multiImport(params); params.Comp.ComponentType  = 'tunnelSwitch2'; multiRun(params); t = multiImport(params);
cList = getCList(a, 'Comp', 'resetV');
[~, sortIndex] = sort(cList);
a = a(sortIndex);
t = t(sortIndex);
mkdir(strcat(params.SimOpt.saveFolder, '/images')); cd(strcat(params.SimOpt.saveFolder, '/images')); DCaW_Plots(t, a, 'Comp', 'resetV');

params.SimOpt.saveFolder = '/import/silo2/joelh/VaryParams/Thesis/DCandWait/critF';
params.Comp.resetVoltage = 1e-3;
params.Comp.criticalFlux = [1e-4, 5e-4, 1e-3, 0.01:0.005:0.15];
params.Comp.ComponentType  = 'atomicSwitch';  multiRun(params); a = multiImport(params); params.Comp.ComponentType  = 'tunnelSwitch2'; multiRun(params); t = multiImport(params);
cList = getCList(a, 'Comp', 'critFlux');
[~, sortIndex] = sort(cList);
a = a(sortIndex);
t = t(sortIndex);
mkdir(strcat(params.SimOpt.saveFolder, '/images')); cd(strcat(params.SimOpt.saveFolder, '/images')); DCaW_Plots(t, a, 'Comp', 'critFlux');

params.Comp.criticalFlux = 0.1;
%}
