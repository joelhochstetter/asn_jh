%% Initialise simulation paramaters
params = struct();

% Set Simulation Options: SimOpt is like SimulationOptions in old code
params.SimOpt.saveSim         = true;
params.SimOpt.takingSnapshots = false; % true \ false. snapshots as in snapshotToFigure.m. Theres a chance this will be broken. If so let me know and I'll fix it
params.SimOpt.compilingMovie  = false; % true \ false 
params.SimOpt.onlyGraphics    = false; % true: (no analysis is done and shown, only graphics (snapshots, movie) are generated) \ false: plots G time series as in plot results
params.SimOpt.saveSim         = true;  %true \ false. Saves important simulation paramaters with the details specified in saveSim.m
params.SimOpt.saveFolder      = '.';    %by default saves in current folder 
params.SimOpt.useWorkspace    = true; %returns all variables in workspace. This is like the output in MonolithicDemo.m
params.SimOpt.saveSwitches    = true;    %whether or not to save filament state / false => saves no switch data except final filament states

%time of simulation
params.SimOpt.T                = 1.0; %length of the simulation
params.SimOpt.dt               = 1e-3; %time step

%adding contacts
%for full set of options see selectContacts.m
params.SimOpt.ContactMode  = 'farthest';    % 'farthest' \ 'specifiedDistance' \ 'preSet' \ 'topoFarthest'
% params.SimOpt.ContactNodes = [73, 30]; %If you specify preSet you must specify contactnodes

%Set Stimulus
%This is like Stimulus struct in old code
%For full options see 
params.Stim.BiasType     = 'DC'; % 'DC' \ 'AC' \ 'DCandWait' \ 'Ramp' \ 'ACsaw'
params.Stim.Amplitude    = 2; 
% params.Stim.Frequency    = 0.5; 

%Set Components paramaters
% I have used the default joel parameters that I used to produce the heatmap
params.Comp.ComponentType  = 'tunnelSwitchL'; %Set switch model. I recommend tunnelSwitchL, as others might break in higher voltage regime
params.Comp.onConductance   = 7.77e-5;
params.Comp.offConductance  = 1e-8;
params.Comp.setVoltage     = 1e-2;
params.Comp.resetVoltage   = 1e-2;
params.Comp.criticalFlux   =  0.01;
params.Comp.maxFlux        =  0.015; 
params.Comp.penalty        =    1;
params.Comp.boost          =  10;


%Set Connectivity parameters
params.Conn.filename = '2016-09-08-155153_asn_nw_00100_nj_00261_seed_042_avl_100.00_disp_10.00.mat'; %defaults to 100nw/261 junctions


%% Run simulation. This runs the simulation with parameters specified above
multiRun(params);

%% Import simulation based on parameter file
sim = multiImport(params); %gives you a cell
sim = sim{1}; %Only one simulation