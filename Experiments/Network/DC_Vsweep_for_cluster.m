function DC_Vsweep_for_cluster(idx, saveFolder, minAmp, maxAmp, stepAmp, connFile, initStateFile , initStateFolder, contactDistance, T, saveFilState)
%{
    e.g. usuage
    attractorForCluster(1, 'simulations/InitStateLyapunov/Attractors/', 'simulations/InitStateLyapunov/Lyapunov/', 'ACsaw', 0.2:0.05:0.4,  [0.1, 0.25, 0.5, 0.75, 1.0], 't2_T0.75_DC0.2V_s0.01_r0.01_c0.01_m0.015_b10_p0.mat')
    attractorForCluster(1, 'simulations/DCTriLyapunov/Attractors/', 'simulations/DCTriLyapunov/Lyapunov/', 'DCsaw', 0.2:0.05:0.4,  [0.05, 0.1, 0.25, 0.5, 0.75], 0)
    

%}

if nargin < 6
    connFile = '2016-09-08-155153_asn_nw_00100_nj_00261_seed_042_avl_100.00_disp_10.00.mat';
end

if nargin < 7 || (isnumeric(initStateFile) && initStateFile == 0)
    initLamda = 0;
else
    if nargin == 7
        initStateFolder = saveFolder;
    end
    sim = multiImport(struct('SimOpt', struct('saveFolder', initStateFolder), 'importByName', initStateFile, 'importStateOnly', true));
    if isfield(sim{1}, 'swLam')
        initLamda                  = sim{1}.swLam(end,:)';
    elseif isfield(sim{1}, 'finalStates')
        initLamda                  = sim{1}.finalStates';
    else
        disp('FAILED');
        return;
    end
end

if nargin < 9 || contactDistance < 0
    contactMode =  'farthest';
    contactDistance = -1;
else
    contactMode = 'fixedTopoDistance';
end

if nargin < 10
    T = 50;
end

if nargin < 11
    saveFilState = true;
else
    saveFilState = boolean(saveFilState);
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
params.SimOpt.hdfSave         = true;
params.SimOpt.saveSwitches = false;
params.SimOpt.saveFilStateOnly = saveFilState;
params.SimOpt.stopIfDupName = true; %this parameter only runs simulation if the savename is not used.
params.SimOpt.saveFolder      = saveFolder;
mkdir(params.SimOpt.saveFolder);

params.SimOpt.T                = T;
params.SimOpt.dt               = 1e-3;
params.SimOpt.nameComment      = '';
params.SimOpt.ContactMode = contactMode;
params.SimOpt.ContactGraphDist = contactDistance;

%Set Stimulus
params.Stim.BiasType     = 'DC'; % 'ACsaw'; % 'DC' \ 'AC' \ 'DCandWait' \ 'Ramp' \ 'ACsaw'
params.Stim.Amplitude    = minAmp:stepAmp:maxAmp; %0.2:0.05:0.4; 

%Set Components
params.Comp.ComponentType  = 'tunnelSwitchL'; %tunnelSwitch2
params.Comp.onResistance   = 7.77e-5;
params.Comp.offResistance  = 1e-8;
params.Comp.setVoltage     = 1e-2;
params.Comp.resetVoltage   = 5e-3;
params.Comp.criticalFlux   =  0.01;
params.Comp.maxFlux        = 0.015;
params.Comp.penalty        =    1;
params.Comp.boost          =   2;
params.Comp.filamentState = initLamda;

%Set connect file
params.Conn.filename = connFile;

%%%
multiRun(params);
 

end


