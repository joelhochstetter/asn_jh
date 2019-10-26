%{
Here we test the numerical accuracy of the code by varying the timestep dt

Do this for DC. DC and wait and AC pulsed stimuli 


Run for atomic switch and tunnel switch


%}



params = struct();
delete(gcp('nocreate'));
parpool(5)

params.SimOpt.saveSim         = true;
params.SimOpt.onlyGraphics    = true; %does not plot anything
params.SimOpt.takingSnapshots = false;
params.SimOpt.useWorkspace    = true; %returns all variables in workspace
params.SimOpt.useParallel     = true;
params.SimOpt.hdfSave         = true;
params.importAll              = false;
params.SimOpt.useRK4          = true;

baseFolder      = '/import/silo2/joelh/Numerics/rk4/';
params.SimOpt.dt = [1e-1, 1e-2,1e-3,1e-4];
params.SimOpt.T  = 60;


%params.Stim.Amplitude    = 0.05;

%Set Components
params.Comp.ComponentType  = 'tunnelSwitch'; %'tunnelSwitch'
params.Comp.offResistance  = 1e-9;
params.Comp.setVoltage     = 1e-2;
params.Comp.resetVoltage   = 1e-3;
params.Comp.criticalFlux   =  0.1;
params.Comp.maxFlux        = 0.15;
params.Comp.penalty        =    1;
params.Comp.boost          =   10;


%% Run DC
params.Stim.BiasType  = 'DC';
params.Stim.Amplitude  = 1.5;                   % (Volt)

params.Comp.ComponentType = 'atomicSwitch';
params.SimOpt.saveFolder = strcat(baseFolder, '/', params.Stim.BiasType, '/', params.Comp.ComponentType);
mkdir(params.SimOpt.saveFolder);
multiRun(params);
sims = multiImport(params);
analyse_vary_dt(sims, params)



params.Comp.ComponentType = 'tunnelSwitch';
params.SimOpt.saveFolder = strcat(baseFolder, '/', params.Stim.BiasType, '/', params.Comp.ComponentType);
mkdir(params.SimOpt.saveFolder);
multiRun(params);
clear('sims');
sims = multiImport(params);
analyse_vary_dt(sims, params)



%% Run DC and wait
params.Stim.BiasType  = 'DCandWait';
params.Stim.OffTime      = 2; % SimulationOptions.T/3; % (sec)
params.Stim.AmplitudeOn  = 1.5;                   % (Volt)
params.Stim.AmplitudeOff = 0.005;                 % (Volt)

params.Comp.ComponentType = 'atomicSwitch';
params.SimOpt.saveFolder = strcat(baseFolder, '/', params.Stim.BiasType, '/', params.Comp.ComponentType);
mkdir(params.SimOpt.saveFolder);
multiRun(params);
sims = multiImport(params);
analyse_vary_dt(sims, params)

params.Comp.ComponentType = 'tunnelSwitch';
params.SimOpt.saveFolder = strcat(baseFolder, '/', params.Stim.BiasType, '/', params.Comp.ComponentType);
mkdir(params.SimOpt.saveFolder);
multiRun(params);
sims = multiImport(params);
analyse_vary_dt(sims, params)




%% Run AC
params.Stim.BiasType  = 'ACsaw';
params.Stim.Amplitude    = 2; 
params.Stim.Frequency  = 0.5;                   % (Volt)

params.Comp.ComponentType = 'atomicSwitch';
params.SimOpt.saveFolder = strcat(baseFolder, '/', params.Stim.BiasType, '/', params.Comp.ComponentType);
mkdir(params.SimOpt.saveFolder);
%multiRun(params);
sims = multiImport(params);
analyse_vary_dt(sims, params)

params.Comp.ComponentType = 'tunnelSwitch';
params.SimOpt.saveFolder = strcat(baseFolder, '/', params.Stim.BiasType, '/', params.Comp.ComponentType);
mkdir(params.SimOpt.saveFolder);
multiRun(params);
sims = multiImport(params);
analyse_vary_dt(sims, params)
