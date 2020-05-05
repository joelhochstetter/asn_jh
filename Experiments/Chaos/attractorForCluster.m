function attractorForCluster(idx, saveFolder, lyFolder)

%%
params = struct();

% Set Simulation Options
params.SimOpt.useWorkspace    = false;
params.SimOpt.saveSim         = true;
params.SimOpt.takingSnapshots = false;
params.SimOpt.onlyGraphics    = true; %does not plot anything
params.SimOpt.compilingMovie  = false;
params.SimOpt.useParallel     = false;
params.SimOpt.runIndex = idx;
params.SimOpt.hdfSave         = false;
params.SimOpt.saveSwitches = false;
params.SimOpt.stopIfDupName = true; %this parameter only runs simulation if the savename is not used.
params.SimOpt.saveFolder      = saveFolder;
mkdir(params.SimOpt.saveFolder);

params.SimOpt.T                = 3000;
params.SimOpt.dt               = 1e-3;
params.SimOpt.nameComment      = '';

%Set Stimulus
params.Stim.BiasType     = 'ACsaw'; % 'DC' \ 'AC' \ 'DCandWait' \ 'Ramp' \ 'ACsaw'
params.Stim.Amplitude    =[0.2, 0.3, 0.4, 0.8, 1.5, 2.5, 0.1, 0.25, 0.35,  0.6, 1.0, 1.25, 1.75, 2.0, 3]; 
params.Stim.Frequency    = [0.05, 0.1, 0.25, 0.5, 0.75 1.0, 2.0, 0.025, 0.15,  0.35, 0.65, 0.85, 1.25, 1.5, 1.75] ; 

%Set Components
params.Comp.ComponentType  = 'tunnelSwitch2'; %tunnelSwitch2
params.Comp.onResistance   = 7.77e-5;
params.Comp.offResistance  = 1e-8;
params.Comp.setVoltage     = 1e-2;
params.Comp.resetVoltage   = 1e-2;
params.Comp.criticalFlux   =  0.01;
params.Comp.maxFlux        = 0.015;
params.Comp.penalty        =    1;
params.Comp.boost          =  [10];
params.Comp.nonpolar       = false;


%%%
s = multiRun(params);

if nargin == 3
    calcLyapunovV5(0, 1, saveFolder, s{1}.filename, lyFolder, 0);
end

end


