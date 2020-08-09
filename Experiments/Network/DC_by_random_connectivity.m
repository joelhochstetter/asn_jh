function DC_by_random_connectivity(seed, saveFolder, amp, useRect, rescalePLength, Connectivity, T)
%{
    Connectivity = struct('WhichMatrix', 'WattsStrogatz', 'beta', 0.0,...
    'EdgesPerNode', 2, 'NumberOfNodes', 500)
    Connectivity = struct('WhichMatrix', 'BarabasiAlbert', 'm0', 2.0,...
    'm', 2, 'NumberOfNodes', 500)
    Connectivity = struct('WhichMatrix', 'BarabasiAlbert', 'm0', 2.0,...
    'm', 2, 'NumberOfNodes', 500)
    Connectivity = struct('WhichMatrix', 'Lattice', 'sizex', 23,...
    'BondProb', 1.0)
%}


%%
params = struct();

% Set Simulation Options
params.SimOpt.useWorkspace    = false;
params.SimOpt.saveSim         = true;
params.SimOpt.takingSnapshots = false;
params.SimOpt.onlyGraphics    = true; %does not plot anything
params.SimOpt.compilingMovie  = false;
params.SimOpt.useParallel     = false;
params.SimOpt.hdfSave         = false;
params.SimOpt.saveSwitches = false;

params.SimOpt.saveFilStateOnly = false;
params.SimOpt.saveEventsOnly  = true;

params.SimOpt.stopIfDupName = true; %this parameter only runs simulation if the savename is not used.
params.SimOpt.saveFolder      = saveFolder;
mkdir(saveFolder);

params.SimOpt.T                = T;
params.SimOpt.dt               = 1e-3;
params.SimOpt.ContactMode = 'topoFarthest';

%Set Stimulus
params.Stim.BiasType     = 'DC'; % 'ACsaw'; % 'DC' \ 'AC' \ 'DCandWait' \ 'Ramp' \ 'ACsaw'
params.Stim.Amplitude    = amp; %0.2:0.05:0.4; 

%Set connect file
params.Conn = Connectivity;
params.Conn.seed = seed;

if strcat(Connectivity.WhichMatrix, 'Lattice')
    L = params.Conn.sizex;
    if useRect
        src = 1:L;
        drn = (1:L) + L^2 - L;
        params.Conn.addNodes = {src, drn};
        params.SimOpt.ContactMode  = 'preSet';
        params.SimOpt.ContactNodes = L^2 + [1, 2];
    else
        params.SimOpt.ContactMode =  'preSet';
        params.SimOpt.ContactNodes = [1,L^2];
    end    
end

if rescalePLength
    if ~multiElectrode
        [Connectivity] = getConnectivity(params.Conn);
        SimulationOptions = selectContacts(Connectivity, params.SimOpt);
        Contacts = SimulationOptions.ContactNodes;
        SDpath = distances(graph(Connectivity.weights), Contacts(1), Contacts(2));
    end
    params.Stim.Amplitude = SDpath*params.Stim.Amplitude;
end

if strcat(Connectivity.WhichMatrix, 'WattsStrogatz')
    params.SimOpt.nameComment = strcat2({'_WS_beta', Connectivity.beta, '_k', Connectivity.EdgesPerNode, '_s', num2str(Connectivity.seed, '%03.f')});
end

if strcat(Connectivity.WhichMatrix, 'BarabasiAlbert')
    params.SimOpt.nameComment = strcat2({'_BA_m0', Connectivity.m0, '_m', Connectivity.m, '_s', num2str(Connectivity.seed, '%03.f')});
end

if strcat(Connectivity.WhichMatrix, 'Lattice')
    params.SimOpt.nameComment = nameComment;
end

%Set Components
params.Comp.ComponentType  = 'tunnelSwitchL'; %tunnelSwitch2
params.Comp.onResistance   = 7.77e-5;
params.Comp.offResistance  = 1e-8;
params.Comp.setVoltage     = 1e-2;
params.Comp.resetVoltage   = 5e-3;
params.Comp.criticalFlux   =  0.01;
params.Comp.maxFlux        = 0.015;
params.Comp.penalty        =    1.0;%1;
params.Comp.boost          =   2;
params.Comp.filamentState = 0.0;



%%%
multiRun(params);
 

end


