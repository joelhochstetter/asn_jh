%% Initialise simulation paramaters
params = struct();

% Set Simulation Options
params.SimOpt.saveSim         = true;
params.SimOpt.takingSnapshots = false; % true \ false

params.SimOpt.hdfSave         = false; %saves files in hdf file format
params.SimOpt.T                = 1.0; %length of the simulation
params.SimOpt.dt               = 1e-3; %time step
params.SimOpt.onlyGraphics    = false; %does not plot anything

%adding contacts
%for full set of options see selectContacts.m
params.SimOpt.ContactMode  = 'farthest';    % 'farthest' \ 'specifiedDistance' \ 'preSet' \ 'topoFarthest'
% params.SimOpt.ContactNodes = [9, 10]; % only really required for preSet, other modes will overwrite this


%Set Stimulus
params.Stim.BiasType     = 'DC'; % 'DC' \ 'AC' \ 'DCandWait' \ 'Ramp' \ 'ACsaw'
params.Stim.Amplitude    = 2; 
% params.Stim.Frequency    = 0.5; 

%Set Components paramaters
params.Comp.ComponentType  = 'tunnelSwitchL'; %Set switch model
params.Comp.onConductance   = 7.77e-5;
params.Comp.offConductance  = 1e-8;
params.Comp.setVoltage     = 1e-2;
params.Comp.resetVoltage   = 1e-3;
params.Comp.criticalFlux   =  0.1;
params.Comp.maxFlux        = 0.15;
params.Comp.penalty        =    1;
params.Comp.boost          =  10;

multiRun(params);

%% Sets default paramaters
%% Plot and analysis output flags:
params.SimOpt.compilingMovie  = false; % true \ false 
params.SimOpt.onlyGraphics    = true; % true \ false (no analysis is done and shown, only graphics (snapshots, movie) are generated).
params.SimOpt.saveSim         = true;  %true \ false. Saves important simulation paramaters with the details specified in saveSim.m
params.SimOpt.saveFolder      = '.';    %by default saves in current folder
params.SimOpt.useWorkspace    = true; %returns all variables in workspace
params.SimOpt.nameComment     = '';
params.SimOpt.useLong         = false;
params.SimOpt.lyapunovSim     = false;
params.SimOpt.useUncorrelated = false;        
params.SimOpt.useRK4          = false;
params.SimOpt.perturb         = false;
params.SimOpt.saveSwitches    = true;    %false => saves no switch data except final filament states
params.SimOpt.saveFilStateOnly = false;
params.SimOpt.saveEventsOnly  = false; %saves events if not saving filament state        
params.SimOpt.numOfElectrodes = 2;
params.SimOpt.oneSrcMultiDrn  = false;
params.SimOpt.MultiSrcOneDrn  = false; 
params.SimOpt.stopIfDupName = false; %this parameter only runs simulation if the savename is not used.
params.SimOpt.reserveFilename = false; %this saves an empty mat file 
params.SimOpt.megaLiteSave = false; %Does not save current or time-vector to save memory in the save file
params.SimOpt.NewEdgeRS  = false; %True: If new edges added are resistive switching elemnents. False: If new edges have fixed conductance
params.SimOpt.RectElectrodes  = false;  %overwrites electrode configuration to use rectangular electrode
params.SimOpt.RectFractions     = 0.05; %fraction of nodes in each electrode          
params.SimOpt.XRectFraction     = 1.00; %fraction of nodes in each electrode  in x direction       
params.SimOpt.dt = 1e-3;   % (sec)
params.SimOpt.T  = 1;    % (sec) duration of simulation


%% Simulation general options:
rng(42); %Set the seed for PRNGs for reproducibility
params.SimOpt.seed  = rng;    % save
params.SimOpt.rSeed = 1;    % seed for running sims

%% Simulation recording options:




%% Import parameters
sim = multiImport(params);
sim = sim{1}; %Only one simulation