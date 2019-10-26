function [initStates, netC, spE] = equilibriateSimsV1(numInitStates, folder, name)
%initStates =equilibriateSims(10, '/import/silo2/joelh/Criticality/perturbation/700nwn', 't_T10_DC1V_s0.01_r0.001_c0.1_m0.15_b1_p1')
    
    %pool = parpool(6);

    %% Import the simulation which we sample states from
    pImport = struct();
    pImport.SimOpt.saveFolder   = folder; %'/import/silo2/joelh/Criticality/perturbation/700nwn';
    pImport.importByName        = name; %t_T10_DC1V_s0.01_r0.001_c0.1_m0.15_b1_p1';
    t = multiImport(pImport);
    
    % Get first current path
    sim = t{1};

    contacts  = sim.ContactNodes;
    Connectivity.filename = sim.ConnectFile;
    Connectivity.WhichMatrix  = 'nanoWires';  
    Connectivity       = getConnectivity(Connectivity);
    E = Connectivity.NumberOfEdges;
    
    adjMat    = Connectivity.weights;
    
    
    %Use shortest paths function to get all paths
    sp  = kShortestPath(adjMat, contacts(1), contacts(2), 10);
    spE = getPathEdges(sp{1}, Connectivity.EdgeList);

    initStates = t{1}.swLam(end,1:E)';


    
    %% Set-up paramaters to equilibriate
    params = struct();

    % Set Simulation Options
    params.SimOpt.useWorkspace    = true;
    params.SimOpt.saveSim         = false;
    params.SimOpt.takingSnapshots = false;
    params.SimOpt.onlyGraphics    = true; %does not plot anything
    params.SimOpt.compilingMovie  = false;
    params.SimOpt.useParallel     = false;
    params.SimOpt.hdfSave         = true;
    params.SimOpt.NodalAnal       = true;
    
    
    params.SimOpt.T               = 100.0;%500.0;
    params.SimOpt.dt              = 1e-2;
    params.SimOpt.nameComment     = '';


    %Set Stimulus
    params.Stim.BiasType     = 'DC'; % 'DC' \ 'AC' \ 'DCandWait' \ 'Ramp' \ 'ACsaw'
    params.Stim.Amplitude    = 0.0899;   % (Volt)


    %Set Components
    params.Comp.ComponentType  = 'tunnelSwitch';
    params.Comp.offResistance  = 1e-7;
    params.Comp.setVoltage     = 1e-2;
    params.Comp.resetVoltage   = 1e-3;
    params.Comp.criticalFlux   =  0.1;
    params.Comp.maxFlux        = 0.15;
    params.Comp.penalty        =    1;
    params.Comp.boost          =    1;

    %Set Connectivity
    params.Conn.filename = t{1}.ConnectFile; %'2016-09-08-155044_asn_nw_00700_nj_14533_seed_042_avl_100.00_disp_10.00.mat'; %700nw

    

    %% Run sims to equilbriate
    netC = zeros(numInitStates, 1);
    
    for i = 1:numInitStates
        p = params;
        p.Comp.filamentState  = initStates(: ,i);
        
        u = multiRun(p);  
        initStates(: ,i) = u{1}.Output.lambda(end, 1:E);
        netC(i)          = u{1}.Output.networkResistance(end);
        j = 1;
        sprintf('%d %d\n', i, j);
        
        while ~checkDCEquilibrium(1e-12, u{1}.Output.networkResistance, u{1}.Output.lambda) && j < 10
            p.Comp.filamentState = initStates(: ,i);
            u = multiRun(p);  
            initStates(: ,i) = u{1}.Output.lambda(end, 1:E);
            netC(i)          = u{1}.Output.networkResistance(end); 
            j = j + 1;
            sprintf('%d %d\n', i, j);
        end
        
        %% Take final simulation and equilbriate at a lower timestep to complete eq
        p.SimOpt.T               = 5.0;%500.0;
        p.SimOpt.dt              = 1e-4;
        p.Comp.filamentState     = initStates(: ,i);
        u = multiRun(p);  
        initStates(: ,i) = u{1}.Output.lambda(end, 1:E);
        netC(i)          = u{1}.Output.networkResistance(end); 
        
        
    end

    

    %delete(pool)
    
end