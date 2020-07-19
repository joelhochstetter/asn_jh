function [ sim ] = runSim(SimulationOptions,  Stimulus, Components, Connectivity)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Runs a simulation of the network for given parameters and saves the
% output to a file. Uses default parameters if none are given
%
% Based on MonolithicDemo.m this routine also allows entry of paramaters as
% an array in which case the simulation is performed for that set of
% paramaters
% Here I denote default parameters with D in front of the paramater
%
% ARGUMENTS: 
% SimulationOptions -  a struct with additional information about the simulation
%                    Required fields:
%                      .T                           (signal duration)
%                      .dt                          (duration of time-step)
%           It is assumed that the units of all input fields are sec, Hz
%           and Volt. Thus, the output fields are in sec and Volt.
%
% Stimulus - Structure containing the details of the required stimulus. It
%           must contain a field .BiasType, whose value is a string
%           specifying the type of stimulus.:
%           - 'DC' - Constant external voltage. 
%60
%                      .Amplitude
%           - 'AC' - Sinusoidal external voltage.
%                    Required fields:
%                      .Frequency
%                      .Amplitude
%           - 'DCandWait' - A DC signal followed by a much smaller DC
%                           signal (which is meant only for probing, rather 
%                           then for stimulating).
%                           Required fields:
%                             .T 
%                             .dt
%                             .OffTime % Time at which tthe stimulus changes to AmplitudeOff
%                             .AmplitudeOn
%                             .AmplitudeOff
%           - 'Ramp' - A ramping voltage signal.
%                      Required fields:
%                        .T
%                        .dt
%                        .AmplitudeMin
%                        .AmplitudeMax
%           - 'Custom' - An arbitrary voltage signal.
%                        Required fields:
%                          .T
%                          .dt
%                          .TimeAxis
%                          .Signal
% Components - a struct containing all the properties of the electrical
%              components in the network. {identity, type, voltage, 
%              resistance, onResistance, offResistance} are obligatory 
%              fields, other fields depend on 'componentType'.
% OUTPUT:
% sim - a structure containing everything produced by the sim. Fields:
%        
%         Stimulus - Structure with the details of the time axis and with the 
%                    external voltage signal. Fields:
%                      .BiasType
%                      .T
%                      .dt
%                      .TimeAxis
%                      .Signal
%                      .Frequency [Hz] (for AC and Sawtooth)
%
%
%
% USAGE:
%{
    Options.T          = 1e+1; % (sec)
    Options.dt         = 1e-3; % (sec)
    Stimulus.BiasType  = 'DC';       
    Stimulus.Amplitude = 3;    % (Volt)

    Stimulus = getStimulus(Stimulus, Options);
%}
%
% Authors:
% Joel Hochstetter
% Ido Marcus
% Paula Sanz-Leon
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    %% Generate a runID - this is used to avoid duplicates in saving
    %% duplicates avoided if SimulationOptions.reserveFilename = true
    rng('shuffle');
    runID = randi(intmax);



    %% Sets default paramaters
        %% Plot and analysis output flags:
        DSimulationOptions.takingSnapshots = false; % true \ false
        DSimulationOptions.compilingMovie  = false; % true \ false 
        DSimulationOptions.onlyGraphics    = true; % true \ false (no analysis is done and shown, only graphics (snapshots, movie) are generated).
        DSimulationOptions.saveSim         = true;  %true \ false. Saves important simulation paramaters with the details specified in saveSim.m
        DSimulationOptions.saveFolder      = '.';    %by default saves in current folder
        DSimulationOptions.useWorkspace    = true; %returns all variables in workspace
        DSimulationOptions.nameComment     = '';
        DSimulationOptions.useLong         = false;
        DSimulationOptions.lyapunovSim     = false;
        DSimulationOptions.NodalAnal       = true;
        DSimulationOptions.useRK4          = false;
        DSimulationOptions.perturb         = false;
        DSimulationOptions.saveSwitches    = true;    %false => saves no switch data except final filament states
        DSimulationOptions.saveFilStateOnly = false;
        DSimulationOptions.numOfElectrodes = 2;
        DSimulationOptions.oneSrcMultiDrn  = false;
        DSimulationOptions.MultiSrcOneDrn  = false; 
        DSimulationOptions.stopIfDupName = false; %this parameter only runs simulation if the savename is not used.
        DSimulationOptions.reserveFilename = false; %this saves an empty mat file 
        DSimulationOptions.megaLiteSave = false; %Does not save current or time-vector to save memory in the save file
        DSimulationOptions.NewEdgeRS  = false; %True: If new edges added are resistive switching elemnents. False: If new edges have fixed resistance
        DSimulationOptions.RectElectrodes  = false;  %overwrites electrode configuration to use rectangular electrode
        DSimulationOptions.RectFractions     = 0.05; %fraction of nodes in each electrode          
        DSimulationOptions.XRectFraction     = 1.00; %fraction of nodes in each electrode  in x direction       
        
        
        %% Simulation general options:
        rng(42); %Set the seed for PRNGs for reproducibility
        DSimulationOptions.seed  = rng;    % save
        DSimulationOptions.rSeed = 1;    % seed for running sims
        DSimulationOptions.dt = 1e-3;   % (sec)
        DSimulationOptions.T  = 1;    % (sec) duration of simulation

        %% Simulation recording options:
        DSimulationOptions.ContactMode  = 'farthest';    % 'farthest' \ 'specifiedDistance' \ 'random' (the only one relevant for 'randAdjMat' (no spatial meaning)) \ 'preSet'
        DSimulationOptions.ContactNodes = [9, 10]; % only really required for preSet, other modes will overwrite this
        DSimulationOptions.ContactGraphDist = 10;

        %% Generate Connectivity: - LATER UPDATE THIS TO GIVE A CHANCE TO INPUT
        if isfield(Connectivity, 'WhichMatrix') == 1
        	DConnectivity.WhichMatrix = Connectivity.WhichMatrix;             
        else 
            DConnectivity.WhichMatrix  = 'nanoWires';    % 'nanoWires' \ 'randAdjMat'         
        end
        
        switch DConnectivity.WhichMatrix
            case 'nanoWires'
                DConnectivity.filename = '2016-09-08-155153_asn_nw_00100_nj_00261_seed_042_avl_100.00_disp_10.00.mat';
                %Connectivity.filename = '2016-09-08-155044_asn_nw_00700_nj_14533_seed_042_avl_100.00_disp_10.00.mat';
            case 'randAdjMat'
                DConnectivity.NumberOfNodes = 30;
                DConnectivity.AverageDegree = 10;
        end
  


        %% Initialize dynamic components
        DComponents.ComponentType       = 'atomicSwitch'; % 'atomicSwitch' \ 'memristor' \ 'resistor', \'tunnelSwitch'
        %other defaults for component params are specified in initializeComponents.m
        
        %% Initialize stimulus:
        %generates default DC stimulus unless a different stimulus type is
        %stated
        
        if isfield(Stimulus, 'BiasType') == 1
        	DStimulus.BiasType = Stimulus.BiasType;             
        else 
            DStimulus.BiasType = 'DC'; % 'DC' \ 'AC' \ 'DCandWait' \ 'Ramp'  \ 'ACsaw'         
        end
        
        switch DStimulus.BiasType
        case 'DC'
            DStimulus.Amplitude = 1.0;  % (Volt)
        case {'AC', 'ACsaw'}
            DStimulus.Frequency       = 0.5; % (Hz)
            DStimulus.Amplitude       = 3;   % (Volt)
            DStimulus.Phase           = 0.0;
        case 'DCandWait'
            DStimulus.OffTime      = 1; % SimulationOptions.T/3; % (sec)
            DStimulus.AmplitudeOn  = 1.5;                   % (Volt)
            DStimulus.AmplitudeOff = 0.005;                 % (Volt)
        case 'Square'
            DStimulus.OffTime      = 1; % SimulationOptions.T/3; % (sec)
            DStimulus.AmplitudeOn  = 1.5;                   % (Volt)
            DStimulus.AmplitudeOff = 0.005;    
            DStimulus.Phase        = 0.0;
            DStimulus.Duty         = 50;
            
        case 'Ramp'
            DStimulus.AmplitudeMin = 0;    % (Volt)
            DStimulus.AmplitudeMax = 5;    % (Volt)

        case 'Triangle'
            DStimulus.AmplitudeMin = 0;
            DStimulus.AmplitudeMax = 3;    % (Volt)        
        end


	%% Sets paramaters to default for SimulationOptions,  Stimulus, Components, Connectivity
    fields = fieldnames(DSimulationOptions);
    for i = 1:numel(fields)
        if isfield(SimulationOptions, fields{i}) == 0
            SimulationOptions.(fields{i}) = DSimulationOptions.(fields{i});
        end
    end

    fields = fieldnames(DStimulus);
    for i = 1:numel(fields)
        if isfield(Stimulus, fields{i}) == 0
            Stimulus.(fields{i}) = DStimulus.(fields{i});
        end
    end
    
    fields = fieldnames(DComponents);
    for i = 1:numel(fields)
        if isfield(Components,fields{i}) == 0
            Components.(fields{i}) = DComponents.(fields{i});
        end
    end
    
    fields = fieldnames(DConnectivity);
    for i = 1:numel(fields)
        if isfield(Connectivity,fields{i}) == 0
            Connectivity.(fields{i}) = DConnectivity.(fields{i});
        end
    end
     

    
    
    
    %% Set mode
    if SimulationOptions.lyapunovSim  || SimulationOptions.useLong || SimulationOptions.perturb
        SimulationOptions.NodalAnal = true;
    end
      
    %% Generates Stimulus, Components and Connectivity
    SimulationOptions.TimeVector = (SimulationOptions.dt:SimulationOptions.dt:SimulationOptions.T)';
    SimulationOptions.NumberOfIterations = length(SimulationOptions.TimeVector);  
    
    Stimulus  = getStimulus(Stimulus, SimulationOptions);
    
    %For runge Kutta we get the stimulus with half the time-step
    if SimulationOptions.useRK4 %RK4
        SOpt2 = SimulationOptions;
        SOpt2.dt = SimulationOptions.dt/2;
        
        % For RK4 implementation I use t = 0 as 1 and t=dt/2 as 2, etc.
        
        Stimulus2 = getStimulus(Stimulus, SOpt2, true);
    end
    
    %% Choose Contacts and Connectivity:    
    Connectivity = getConnectivity(Connectivity);
    if SimulationOptions.RectElectrodes
        [Connectivity, ContactNodes] = addRectElectrode(Connectivity, SimulationOptions.RectFractions, SimulationOptions.XRectFraction);
        SimulationOptions.ContactMode  = 'preSet';
        SimulationOptions.ContactNodes =ContactNodes;
    end
   
    %if treating edges to new nodes as passive resistive elements
    if ~SimulationOptions.NewEdgeRS
        Components.passiveRes = Connectivity.NewEdges;
    end
    
    if strcmp(SimulationOptions.ContactMode, 'specifiedDistance')
        SimulationOptions.BiProbeDistance = 500; % (um)
    end
    SimulationOptions = selectContacts(Connectivity, SimulationOptions);
    
    
    %% Get Equations / Components:
    
    if SimulationOptions.useRK4

        SimulationOptions.numOfElectrodes = 2;
        Signals = cell(SimulationOptions.numOfElectrodes,1);
        
        % For RK4 implementation I use t = 0 as 1 and t=dt/2 as 2, etc.
        
        Signals{1} = Stimulus2.Signal;

        Signals{2} = zeros(2*SimulationOptions.NumberOfIterations + 1,1);

        SimulationOptions.electrodes      = SimulationOptions.ContactNodes;
        Components = initializeComponents(Connectivity.NumberOfEdges,Components, true);    
        
        
    elseif SimulationOptions.NodalAnal
        if SimulationOptions.numOfElectrodes == 2
            Signals = cell(SimulationOptions.numOfElectrodes,1);

            Signals{1} = Stimulus.Signal;

            Signals{2} = zeros(SimulationOptions.NumberOfIterations,1);

            SimulationOptions.electrodes      = SimulationOptions.ContactNodes;
            Components = initializeComponents(Connectivity.NumberOfEdges,Components, true);
        
        elseif SimulationOptions.oneSrcMultiDrn %single source multiple drains
            %First electrode in contacts is source. Rest are drains
            Signals = cell(SimulationOptions.numOfElectrodes,1);

            Signals{1} = Stimulus.Signal;
            
            for i = 2:SimulationOptions.numOfElectrodes
                Signals{i} = zeros(SimulationOptions.NumberOfIterations,1);
            end

            SimulationOptions.electrodes      = SimulationOptions.ContactNodes;
            Components = initializeComponents(Connectivity.NumberOfEdges,Components, true);            
        
        elseif SimulationOptions.MultiSrcOneDrn %single source multiple drains
            %First electrode in contacts is source. Rest are drains
            Signals = cell(SimulationOptions.numOfElectrodes,1);

            Signals{SimulationOptions.numOfElectrodes} = zeros(SimulationOptions.NumberOfIterations,1);
            
            for i = 1:SimulationOptions.numOfElectrodes - 1
                Signals{i} = Stimulus.Signal;
            end

            SimulationOptions.electrodes      = SimulationOptions.ContactNodes;
            Components = initializeComponents(Connectivity.NumberOfEdges,Components, true);            

        end
        
    else
        Components = initializeComponents(Connectivity.NumberOfEdges,Components, false);
        Equations = getEquations(Connectivity,SimulationOptions.ContactNodes, strcmp(SimulationOptions.ContactMode, 'farthest'));
    end
        
    %% generate saveName
    if SimulationOptions.saveSim == 1 
        [saveName, alreadyExists] = genSaveName(SimulationOptions, Components, Stimulus);
        if SimulationOptions.stopIfDupName && alreadyExists
                disp('Save name already in use');
                disp('Terminating')
                sim.saveName = saveName;
                return; %early exit from the program
        end
        
        %reserves the filename
        if ~alreadyExists && SimulationOptions.reserveFilename
            save(strcat(saveName, '.mat'), 'runID')            
        end
    end
        
    %% Initialize snapshot time stamps:
    if SimulationOptions.takingSnapshots
        snapshotPeriod   = SimulationOptions.dt; % (sec) make it a multiple integer of dt
        snapshotStep     = ceil(snapshotPeriod / SimulationOptions.dt);
        snapshotsIdx     = 1:snapshotStep:SimulationOptions.NumberOfIterations;
    end


    %% Simulate:
    rng(SimulationOptions.rSeed);
    if SimulationOptions.takingSnapshots
        if SimulationOptions.NodalAnal
            [Output, SimulationOptions, snapshots] = simulateNetworkRuomin(Connectivity, Components, Signals, SimulationOptions, snapshotsIdx); % (Ohm)              
        else
            [Output, SimulationOptions, snapshots] = simulateNetwork(Equations, Components, Stimulus, SimulationOptions, snapshotsIdx); % (Ohm)        
        end
    else % this discards the snaphots
        if SimulationOptions.useLong 
            [Output, SimulationOptions] = longSimulateNetwork(Connectivity, Components, Signals, SimulationOptions);  % (Ohm)   
        elseif SimulationOptions.lyapunovSim
            [Output, SimulationOptions] = simulateNetworkLyapunov(Connectivity, Components, Signals, SimulationOptions); % (Ohm)
        elseif SimulationOptions.perturb
            [Output, SimulationOptions] = simulateNetworkPerturb(Connectivity, Components, Signals, SimulationOptions); % (Ohm)
        elseif SimulationOptions.useRK4
            [Output, SimulationOptions] = simulateNetworkRK4(Connectivity, Components, Signals, SimulationOptions); % (Ohm)
        elseif ~SimulationOptions.saveSwitches
            [Output, SimulationOptions] = simulateNetworkLite(Connectivity, Components, Signals, SimulationOptions); % (Ohm)            
        elseif SimulationOptions.NodalAnal
            [Output, SimulationOptions] = simulateNetworkRuomin(Connectivity, Components, Signals, SimulationOptions); % (Ohm)
        elseif SimulationOptions.useUncorrelated
            
        else
            [Output, SimulationOptions, snapshots] = simulateNetwork(Equations, Components, Stimulus, SimulationOptions); % (Ohm)
        end       
    end


    %% Analysis and plot results:
    if ~SimulationOptions.onlyGraphics
        plotResults(Output.networkResistance,Output.networkCurrent,Stimulus);

    end

    %% Save important paramaters of simulation for later use
    if SimulationOptions.saveSim == 1 
        saveName = saveSim(Stimulus,SimulationOptions,Output,Components, Connectivity, saveName, runID)
    else 
        saveName = 'None';
    end
    
    %% Graphics:
    if SimulationOptions.takingSnapshots
        % What to plot:
        whatToPlot = struct(...
                            'Nanowires',    true, ...
                            'Contacts',     true, ...
                            'Dissipation',  false, ...
                            'Lambda',       true, ... #can either plot lambda or dissipation
                            'Currents',     true, ...
                            'Voltages',     true,  ...
                            'Labels',       false,  ...
                            'VDrop',        false,  ... 
                            'GraphRep',     true  ... 
                            );


        % Uniform scales:
        axesLimits.DissipationCbar = [0,5]; % (1pW*10^0 : 1pW*10^5)
        axesLimits.CurrentArrowScaling = 0.25;
        switch Stimulus.BiasType
            case 'DC'
                if Stimulus.Signal(1) > 0
                    axesLimits.VoltageCbar = [0,Stimulus.Signal(1)]; % (V)
                else
                    axesLimits.VoltageCbar = [Stimulus.Signal(1),0]; % (V)
                end
            case {'AC' , 'DCandWait', 'Ramp', 'Triangle', 'ACsaw'}
                axesLimits.VoltageCbar = [min(Stimulus.Signal),max(Stimulus.Signal)]; % (V)
        end


        % Just for fun - extract a specific frame (from the middle):
        snapshotToFigure(snapshots{end},SimulationOptions.ContactNodes,Connectivity,whatToPlot,axesLimits);
        set(gcf, 'visible','on')

        % Compile whole movie:
        if SimulationOptions.compilingMovie 
            fprintf('\nCompiling movie...\n');

            % Only Windows and MacOS >  10.7
            %v = VideoWriter('networkMovie.mp4','MPEG-4');
            % All platforms
            
            %if we save the file, video has the same name as the savefile
            videoName = saveName;
            
            %generates unique videoname if we are not saving the file
            if strcmp(videoName, 'None')
                 videoName = 'networkMovie';
                 num = 1;
                 while exist(strcat(videoName, num2str(num), '.avi'), 'file') > 1 
                    num = num + 1;
                 end
                 videoName = strcat(videoName, num2str(num));
            end
            
            v = VideoWriter(videoName,'Motion JPEG AVI');
            v.FrameRate = floor(1/snapshotPeriod/10);

            v.Quality = 100;
            open(v);
            for i = 1 : length(snapshots)
                progressBar(i,length(snapshots));
                frameFig = snapshotToFigure(snapshots{i},SimulationOptions.ContactNodes,Connectivity,whatToPlot,axesLimits);
                writeVideo(v,getframe(frameFig));
                close(frameFig);
            end
            close(v);
            fprintf('\nDone.\n');
        end
        if SimulationOptions.useWorkspace == 1  
            sim.AxesLimits = axesLimits;  
            sim.snapshots = snapshots;
            sim.snapshotPeriod = snapshotPeriod;
            sim.snapshotsIdx = snapshotsIdx;    
            sim.whatToPlot = whatToPlot;
        end
    end

    fprintf('\n');

    if SimulationOptions.useWorkspace == 1
        sim.Components = Components;
        sim.Connectivity = Connectivity;
        %sim.Equations = Equations;
        sim.Output = Output;
        sim.SimulationOptions = SimulationOptions;
        sim.Stimulus = Stimulus;

    end
    sim.saveName = saveName;
    
end