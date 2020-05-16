function attractorForCluster(idx, saveFolder, lyFolder, BiasType, Amps, Freqs, initStateFile)
%{
    e.g. usuage
    attractorForCluster(1, 'simulations/InitStateLyapunov/Attractors/', 'simulations/InitStateLyapunov/Lyapunov/', 'ACsaw', 0.2:0.05:0.4,  [0.1, 0.25, 0.5, 0.75, 1.0], 't2_T0.75_DC0.2V_s0.01_r0.01_c0.01_m0.015_b10_p0.mat')
    attractorForCluster(1, 'simulations/DCTriLyapunov/Attractors/', 'simulations/DCTriLyapunov/Lyapunov/', 'DCsaw', 0.2:0.05:0.4,  [0.05, 0.1, 0.25, 0.5, 0.75], 0)
    

%}

if nargin < 7
    initLamda = 0;
else
    sim = multiImport(struct('SimOpt', struct('saveFolder', saveFolder), 'importByName', initStateFile, 'importStateOnly', true));
    if isfield(sim{1}, 'swLam')
        initLamda                  = sim{1}.swLam(end,:)';
    elseif isfield(sim{1}, 'finalStates')
        initLamda                  = sim{1}.finalStates';
    else
        disp('FAILED');
        return;
    end
end

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

params.SimOpt.T                = 1500;
params.SimOpt.dt               = 1e-3;
params.SimOpt.nameComment      = '';

%Set Stimulus
params.Stim.BiasType     = BiasType; % 'ACsaw'; % 'DC' \ 'AC' \ 'DCandWait' \ 'Ramp' \ 'ACsaw'
% params.Stim.Amplitude    = [0.2, 0.3, 0.4, 0.8, 1.5, 2.5, 0.1, 0.25, 0.35,  0.6, 1.0, 1.25, 1.75, 2.0, 3]; 
% params.Stim.Frequency    =  [0.05, 0.1, 0.25, 0.5, 0.75 1.0, 2.0, 0.025, 0.15,  0.35, 0.65, 0.85, 1.25, 1.5, 1.75] ; 
params.Stim.Amplitude    = Amps; %0.2:0.05:0.4; 
params.Stim.Frequency    = Freqs; %[0.1, 0.25, 0.5, 0.75, 1.0];%1/20; 

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
params.Comp.filamentState = initLamda;
params.Comp.nonpolar       = false;


%%%
s = multiRun(params);
 [~,saveName,ext] = fileparts(s{1}.saveName);
 saveName = strcat(saveName, ext);
 
if isstring(lyFolder) || ischar(lyFolder)
    calcLyapunovV5(0, 1, saveFolder, saveName, lyFolder, 0);
end

end


