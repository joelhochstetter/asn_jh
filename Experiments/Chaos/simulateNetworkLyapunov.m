function [OutputDynamics, SimulationOptions] = simulateNetworkLyapunov(Connectivity, Components, Signals, SimulationOptions, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Modifies simulate network to perform lyapunov exponent calculation
%
% ARGUMENTS: 
% Connectivity - The Connectivity information of the network. Most
%                importantly the edge list, which shows the connectivity
%                condition between nanowires, and number of nodes and
%                junctions.
% Components - Structure that contains the component properties. Every 
%              field is a (E+1)x1 vector. The extra component is the
%              tester resistor connected in series to the voltage and to 
%              the network.
% Stimulus - Structure that contains the details of the external stimulus
%            (time axis details, voltage signal).
% SimulationOptions - Structure that contains general simulation details that are indepedent of 
%           the other structures (eg, dt and simulation length);
% varargin - if not empty, contains an array of indidces in which a
%            snapshot of the resistances and voltages in the network is
%            requested. This indices are based on the length of the simulation.
% OUTPUT:
% OutputDynamics -- is a struct with the activity of the network
%                    .networkResistance - the resistance of the network (between the two 
%                     contacts) as a function of time.
%                    .networkCurrent - the overall current from contact (1) to contact (2) as a
%                     function of time.
% Simulationoptions -- same struct as input, with updated field names
% snapshots - a cell array of structs, holding the resistance and voltage 
%             values in the network, at the requested time-stamps.
        
% REQUIRES:
% updateComponentResistance
% updateComponentState
%
% Authors:
% Joel Hochstetter
% Ido Marcus
% Paula Sanz-Leon
% Ruomin Zhu
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
   
    %% Initialize:
    compPtr         = ComponentsPtr(Components);        % using this matlab-style pointer to pass the Components structure by reference
    niterations     = SimulationOptions.NumberOfIterations;
    electrodes      = SimulationOptions.electrodes;
    numOfElectrodes = SimulationOptions.numOfElectrodes;
    E               = Connectivity.NumberOfEdges;
    V               = Connectivity.NumberOfNodes;
    edgeList        = Connectivity.EdgeList.';
    RHS             = zeros(V+numOfElectrodes,1); % the first E entries in the RHS vector.
    LHSinit         = zeros(V+numOfElectrodes, V+numOfElectrodes);
        
    wireVoltage        = zeros(niterations, V);
    electrodeCurrent   = zeros(niterations, numOfElectrodes);
    junctionVoltage    = zeros(niterations, E);
    junctionResistance = zeros(niterations, E);
    junctionFilament   = zeros(niterations, E);
    
  
    %Calculate the unperturbed orbit
    unpertFilState        = SimulationOptions.unpertFilState';
    
    LyapunovMax        = zeros(niterations,1);
    
    %% Solve equation systems for every time step and update:
    for ii = 1 : niterations
        % Show progress:
        progressBar(ii,niterations);
        
        % Update resistance values:
        updateComponentResistance(compPtr); 
        componentConductance = compPtr.comp.resistance;
        
        % Get LHS (matrix) and RHS (vector) of equation:
        Gmat = zeros(V);

        
         for i = 1:E
             Gmat(edgeList(i,1),edgeList(i,2)) = componentConductance(i);
             Gmat(edgeList(i,2),edgeList(i,1)) = componentConductance(i);
         end
        
        Gmat = diag(sum(Gmat, 1)) - Gmat;
        
        LHS          = LHSinit;
        
        LHS(1:V,1:V) = Gmat;
        
        for i = 1:numOfElectrodes
            this_elec           = electrodes(i);
            LHS(V+i,this_elec)  = 1;
            LHS(this_elec,V+i)  = 1;
            RHS(V+i)            = Signals{i,1}(ii);
        end
        % Solve equation:
        sol = LHS\RHS;

        tempWireV = sol(1:V);
        compPtr.comp.voltage = tempWireV(edgeList(:,1)) - tempWireV(edgeList(:,2));
        
        
        % Update element fields:
        updateComponentState(compPtr, SimulationOptions.dt);    % ZK: changed to allow retrieval of local values
        
        %Calculate state difference
        deltaLam     = compPtr.comp.filamentState - unpertFilState(:,ii);
        normDeltaLam = norm(deltaLam);
        if normDeltaLam == 0
            LyapunovMax(ii) = -inf;
            break
        end
        
        %Update trajectory
        compPtr.comp.filamentState =  unpertFilState(:,ii) + SimulationOptions.LyEps/normDeltaLam*deltaLam;
        
        LyapunovMax(ii) = log(normDeltaLam/SimulationOptions.LyEps);
        
        wireVoltage(ii,:)        = sol(1:V);
        electrodeCurrent(ii,:)   = sol(V+1:end);
        junctionVoltage(ii,:)    = compPtr.comp.voltage;
        junctionResistance(ii,:) = compPtr.comp.resistance;
        junctionFilament(ii,:)   = compPtr.comp.filamentState;
        
    end
    
    % Calculate network resistance and save:
    OutputDynamics.electrodeCurrent   = electrodeCurrent;
    OutputDynamics.wireVoltage        = wireVoltage;
    
    OutputDynamics.storevoltage       = junctionVoltage;
    OutputDynamics.storeCon           = junctionResistance;
    OutputDynamics.lambda             = junctionFilament;

    % Calculate network resistance and save:
    OutputDynamics.networkCurrent    = electrodeCurrent(:, 2);
    OutputDynamics.networkResistance = abs(OutputDynamics.networkCurrent ./ Signals{1});

    OutputDynamics.LyapunovMax       = LyapunovMax;
    
end