function getThresholdVaryNets(idx, netFolder, saveFolder)
    %% get networks
    nets = dir(strcat(netFolder, '/*.mat'))';
    
    %% get contacts
    connFilename = nets(idx).name;
    connFile = open(connFilename);
    xc = connFile.xc';
    yc = connFile.yc';

    Lx = double(connFile.length_x);
    Ly = double(connFile.length_y);


    [~, drn] = min(sum(([xc, yc] - [0, 0]).^2,2));
    [~, srcA] = min(sum(([xc, yc] - [Lx, Ly]).^2,2));
    [~, srcB] = min(sum(([xc, yc] - [0, Ly]).^2,2));


    
    %% parameters
    params = struct();

    % Set Simulation Options
    params.SimOpt.useWorkspace    = true;
    params.SimOpt.saveSim         = true;
    params.SimOpt.saveSwitches = false;
    params.SimOpt.hdfSave  = false;
    params.SimOpt.onlyGraphics    = true; %does not plot anything
    params.SimOpt.takingSnapshots = false;
    params.SimOpt.useParallel     = false;
    params.SimOpt.T               = 150;
    params.SimOpt.dt              = 1e-2;
    params.SimOpt.saveFolder = strcat(saveFolder, '/Ramp', connFilename, '/');
    mkdir(params.SimOpt.saveFolder);
    params.SimOpt.nameComment = strcat('idx_', num2str(idx, '%03. f'));
    
    %Set Stimulus
    params.Stim.BiasType = 'Ramp';
    params.Stim.AmplitudeMin = 150;
    params.Stim.AmplitudeMax = 0;


    %Set Components
    params.Comp.ComponentType  = 'tunnelSwitchL'; % 'quantCSwitch' \ 'atomicSwitch'
    params.Comp.onResistance = 1e-6;
    params.Comp.offResistance  = 1e-10;
    params.Comp.setVoltage     = 2.1;
    params.Comp.resetVoltage  = 1.4;
    params.Comp.criticalFlux   = 0.1;
    params.Comp.maxFlux        = 1*params.Comp.criticalFlux;
    params.Comp.barrHeight  = 0.6;
    params.Comp.filArea        = 10;
    params.Comp.boost          =  1.0;
    params.Comp.nonpolar       = true;

    params.SimOpt.ContactMode     = 'preSet';
    params.SimOpt.MultiSrcOneDrn  = true;

    params.SimOpt.ContactNodes    = [srcA, srcB, drn];
    
    params.Conn.filename = connFilename;
    

	t = multiRun(params);

    
    %% threshold
%     netC = t{1}.Output.networkResistance;
%     find(netC > 100*netC(1));
    

end