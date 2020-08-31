function DC_sim_random_states(initSeed, connSeed, saveFolder, amp, useRect, rescalePLength, Connectivity, T, initRandType, initRandLower, initRandUpper, initBinProb)
%{
    params.Comp.initRandType   = 'binary'; % {'none', 'binary', 'uniform'}
    params.Comp.initRandLower = 0; % lower value for random initial state. For 'binary' and 'uniform'
    params.Comp.initRandUpper = 0.015; % upper value for random initial state. For 'binary' and 'uniform'
    params.Comp.initBinProb       = 0.75; %binary probability of being in initRandUpper other than initRandUpper
    params.Comp.initSeed           = 0; %random seed for initial seed


    DC_sim_random_states(0, 1, '.',  1.05, true, true, struct('WhichMatrix', 'Lattice', 'sizex', 23, 'BondProb', 1.0), 30, 'binary', 0, 0.015, 0.1)
    
    DC_sim_random_states(0, 1, '.',  1.05, true, true, struct('WhichMatrix', 'nanoWires', 'filename', 'asn_nw_00499_nj_01444_seed_000_avl_10.00_disp_01.00_lx_70.00_ly_70.00.mat'), 30, 'binary', 0, 0.015, 0.1)
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

    params.SimOpt.saveFilStateOnly = true;
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
    params.Conn.seed = connSeed;

    if strcmp(Connectivity.WhichMatrix, 'Lattice')
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

    if useRect && strcmp(Connectivity.WhichMatrix, 'nanoWires')
        %Connectivity and contacts
        Connectivity          = getConnectivity(params.Conn);
        params.SimOpt.RectElectrodes = true;
        params.SimOpt.NewEdgeRS      = false;
        params.SimOpt.RectFractions  = 0.025;
        params.SimOpt.XRectFraction  = 1.0;    
        [~, ~, SDpath] = addRectElectrode(Connectivity, params.SimOpt.RectFractions, params.SimOpt.XRectFraction);
        if SDpath == Inf
            disp('No such SD path')
            return
        end
    end    

    if rescalePLength
        Connectivity = getConnectivity(params.Conn);
        if ~useRect            
            SimulationOptions = selectContacts(Connectivity, params.SimOpt);
            Contacts = SimulationOptions.ContactNodes;
            SDpath = distances(graph(Connectivity.weights), Contacts(1), Contacts(2));
        elseif strcmp(Connectivity.WhichMatrix, 'Lattice')
            SDpath = distances(graph(Connectivity.weights), L^2+1, L^2+2) - 2;   
            if SDpath == Inf
                disp('Graph not connected')
                return
            end
%             SDpath = L-1;
        elseif strcmp(Connectivity.WhichMatrix, 'nanoWires')
            
        else
            disp('Failed');
            return;
        end
        params.Stim.Amplitude = SDpath*0.01*amp;
    end

    switch Connectivity.WhichMatrix
        case 'WattsStrogatz'
            nameCommTop = strcat2({'_WS_beta', Connectivity.beta, '_k', Connectivity.EdgesPerNode, '_s', num2str(connSeed, '%03.f')});
        case 'BarabasiAlbert'
            nameCommTop = strcat2({'_BA_m0_', Connectivity.m0, '_m', Connectivity.m, '_s', num2str(connSeed, '%03.f')}); 
        case 'Lattice'
            nameCommTop = strcat2({'_Lattice_L', L, '_p', Connectivity.BondProb, '_s', num2str(connSeed, '%03.f')});
        case 'nanoWires'
            load(Connectivity.filename, 'number_of_wires', 'number_of_junctions')
            nameCommTop = strcat2({'_nwn_N',  number_of_wires, '_E', number_of_junctions});
    end
    
    nameCommInit = '';
    switch initRandType
        case 'binary'
                nameCommInit = strcat2({'_', initRandType, '_l',  initRandLower, '_u', initRandUpper, '_p', initBinProb, '_s', num2str(initSeed, '%03.f')});
        case 'uniform'
                nameCommInit = strcat2({'_', initRandType, '_l',  initRandLower, '_u', initRandUpper, '_s', num2str(initSeed, '%03.f')});
    end
    

    params.SimOpt.nameComment = strcat(nameCommTop, nameCommInit);
    
    %Set Components
    params.Comp.ComponentType  = 'tunnelSwitchL'; %tunnelSwitch2
    params.Comp.onConductance   = 7.77e-5;
    params.Comp.offConductance  = 1e-8;
    params.Comp.setVoltage     = 1e-2;
    params.Comp.resetVoltage   = 5e-3;
    params.Comp.criticalFlux   =  0.01;
    params.Comp.maxFlux        = 0.015;
    params.Comp.penalty        =    1.0;%1;
    params.Comp.boost          =   2;
    params.Comp.filamentState = 0.0;

    params.Comp.initRandType   = initRandType; % {'none', 'binary', 'uniform'}
    params.Comp.initRandLower = initRandLower; % lower value for random initial state. For 'binary' and 'uniform'
    params.Comp.initRandUpper = initRandUpper; % upper value for random initial state. For 'binary' and 'uniform'
    params.Comp.initBinProb       = initBinProb; %binary probability of being in initRandUpper other than initRandUpper
    params.Comp.initSeed           = initSeed; %random seed for initial seed
    params.Comp.nonpolar = true;

    %%%
    multiRun(params);
 

end