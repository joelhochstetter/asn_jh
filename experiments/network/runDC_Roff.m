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

mkdir V
mkdir setV
mkdir resetV
mkdir critF
mkdir maxF
mkdir boost
mkdir freq

%%


%{
    Also want to calculate number of junctions on at equilbrium

%}

addpath(genpath('/import/silo2/joelh/VaryParams/Thesis/'));

params.SimOpt.saveFolder = '/import/silo2/joelh/VaryParams/Thesis/DCRun2/sims';
params.Stim.Amplitude = [0.010:0.005:0.080, 0.09001:0.00001:0.09004, 0.09006:0.00001:0.09009, 0.085:0.0005:0.0995];
params.Comp.ComponentType  = 'atomicSwitch';
params.Stim.Amplitude = [0.010:0.005:0.080, 0.09001:0.00001:0.09004, 0.09006:0.00001:0.09009, 0.085:0.0005:0.0995, 0.1:0.05:2.0];
a = multiImport(params);
old               = analyseSim(a, 'Stim', 'Amplitude');
old = getEquilibriumTime(a, params, 'Stim', 'Amplitude', old);
clear('a');
params.importSwitch = false;
a = multiImport(params);
params.Comp.ComponentType  = 'tunnelSwitch2';
params.Stim.Amplitude = [0.010:0.005:0.080, 0.09001:0.00001:0.09004, 0.09006:0.00001:0.09009, 0.085:0.0005:0.0995];

params.Stim.Amplitude = [0.010:0.005:0.080, 0.09001:0.00001:0.09004, 0.09006:0.00001:0.09009, 0.085:0.0005:0.0995, 0.1:0.05:2.0];
params.importSwitch = true;
t = multiImport(params);
[tun,~, ~] = analyseSim(t, 'Stim', 'Amplitude');
tun.eqTimes = eqTimes;
tun.maxG    = maxG;
clear('t');
params.importSwitch = false;
t = multiImport(params);
cList = getCList(a, 'Stim', 'Amplitude');
[~, sortIndex] = sort(cList);
a = a(sortIndex);
t = t(sortIndex);


mkdir(strcat(params.SimOpt.saveFolder, '/images')); cd(strcat(params.SimOpt.saveFolder, '/images')); 
%%
[old, tun] = DC_Plots1(params, old, tun, cList, t, a, 'Stim', 'Amplitude')


%{
params.SimOpt.saveFolder = '/import/silo2/joelh/VaryParams/Thesis/DC/setV';
params.Stim.Amplitude = 1.0;
params.Comp.setVoltage = [1e-3:2e-3:1e-1];
params.Comp.ComponentType  = 'atomicSwitch';
%multiRun(params);
a = multiImport(params);
params.Comp.ComponentType  = 'tunnelSwitch2';
%multiRun(params);
t = multiImport(params);
cList = getCList(a, 'Comp', 'setV');
[~, sortIndex] = sort(cList);
a = a(sortIndex);
t = t(sortIndex);
mkdir(strcat(params.SimOpt.saveFolder, '/images')); cd(strcat(params.SimOpt.saveFolder, '/images')); DC_Plots(params, t, a, 'Comp', 'setV');

params.SimOpt.saveFolder = '/import/silo2/joelh/VaryParams/Thesis/DC/maxF';
params.Comp.setVoltage = 1e-2;
params.Comp.maxFlux = [0.1:0.005:0.25];
params.Comp.ComponentType  = 'atomicSwitch';
%multiRun(params);
a = multiImport(params);
params.Comp.ComponentType  = 'tunnelSwitch2';
%multiRun(params);
t = multiImport(params);
cList = getCList(a, 'Comp', 'maxFlux');
[~, sortIndex] = sort(cList);
a = a(sortIndex);
t = t(sortIndex);
mkdir(strcat(params.SimOpt.saveFolder, '/images')); cd(strcat(params.SimOpt.saveFolder, '/images')); DC_Plots(params, t, a, 'Comp', 'maxFlux');

params.SimOpt.saveFolder = '/import/silo2/joelh/VaryParams/Thesis/DC/boost';
params.Comp.maxFlux = 0.15;
params.Comp.boost = [0.01, 0.02,0.05,0.2,0.5, 1, 2, 5, 10, 20, 50, 100];
params.Comp.ComponentType  = 'atomicSwitch';
%multiRun(params);
a = multiImport(params);
params.Comp.ComponentType  = 'tunnelSwitch2';
%multiRun(params);
t = multiImport(params);
cList = getCList(a, 'Comp', 'boost');
[~, sortIndex] = sort(cList);
a = a(sortIndex);
t = t(sortIndex);
mkdir(strcat(params.SimOpt.saveFolder, '/images')); cd(strcat(params.SimOpt.saveFolder, '/images')); DC_Plots(params, t, a, 'Comp', 'boost');

params.SimOpt.saveFolder = '/import/silo2/joelh/VaryParams/Thesis/DC/resetV';
params.Comp.boost = 10;
params.Comp.resetVoltage = [1e-4,5e-4:5e-4:1e-2];
params.Comp.ComponentType  = 'atomicSwitch';
%multiRun(params);
a = multiImport(params);
params.Comp.ComponentType  = 'tunnelSwitch2';
%multiRun(params);
t = multiImport(params);
cList = getCList(a, 'Comp', 'resetV');
[~, sortIndex] = sort(cList);
a = a(sortIndex);
t = t(sortIndex);
mkdir(strcat(params.SimOpt.saveFolder, '/images')); cd(strcat(params.SimOpt.saveFolder, '/images')); DC_Plots(params, t, a, 'Comp', 'resetV');

params.SimOpt.saveFolder = '/import/silo2/joelh/VaryParams/Thesis/DC/critF';
params.Comp.resetVoltage = 1e-3;
params.Comp.criticalFlux = [1e-4, 5e-4, 1e-3, 0.01:0.005:0.15];
params.Comp.ComponentType  = 'atomicSwitch';
%multiRun(params);
a = multiImport(params);
params.Comp.ComponentType  = 'tunnelSwitch2';
%multiRun(params);
t = multiImport(params);
cList = getCList(a, 'Comp', 'critFlux');
[~, sortIndex] = sort(cList);
a = a(sortIndex);
t = t(sortIndex);
mkdir(strcat(params.SimOpt.saveFolder, '/images')); cd(strcat(params.SimOpt.saveFolder, '/images')); DC_Plots(params, t, a, 'Comp', 'critFlux');

params.Comp.criticalFlux = 0.1;
%}
