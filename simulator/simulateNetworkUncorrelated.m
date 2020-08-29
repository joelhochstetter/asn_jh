function [OutputDynamics, SimulationOptions, snapshots] = simulateNetworkUncorrelated(Equations, Components, Stimulus, SimulationOptions, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulates the network and finds the resistance between the two contacts
% as a function of time.
%
% ARGUMENTS: 
% Equations - Structure that contains the (abstract) matrix of coefficients
%             (as documented in getEquations) and the number of nodes in
%             the circuit.
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
% USAGE:
%{
    Connectivity = getConnectivity(Connectivity);
    contact      = [1,2];
    Equations    = getEquations(Connectivity,contact);
    Components   = initializeComponents(Connectivity.NumberOfEdges,Components)
    Stimulus     = getStimulus(Stimulus);
    
    OutputDynamics = runSimulation(Equations, Components, Stimulus);
%}
%
% Authors:
% Ido Marcus
% Paula Sanz-Leon
% Joel Hochstetter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
    
    %% Initialize:
    %sets sources for additional sources or drains
    %{
    if ~isfield(SimulationOptions, 'isSource')
        SimulationOptions.isSource = [];
    end    
    %}

    %numDrain      = 1 + numel(SimulationOptions.isSource) - sum(SimulationOptions.isSource);
    compPtr       = ComponentsPtr(Components);        % using this matlab-style pointer to pass the Components structure by reference
    niterations   = SimulationOptions.NumberOfIterations; 
    %modified to store testerVoltage for each drain
    testerVoltage = zeros(niterations, 1);                      % memory allocation for the voltage on the tester resistor as function of time
    
    RHSZeros      = zeros(Equations.NumberOfEdges, 1); % the first E entries in the RHS vector.
    avLambda      = zeros(niterations,1);
    %lambda_vals   = zeros(niterations,Equations.NumberOfEdges - 1 + numel(SimulationOptions.ContactNodes));
    %voltage_vals  = zeros(niterations,Equations.NumberOfEdges - 1 + numel(SimulationOptions.ContactNodes));
    lambda_vals   = zeros(niterations,Equations.NumberOfEdges + 1);
    voltage_vals  = zeros(niterations,Equations.NumberOfEdges + 1);
    c_vals        = zeros(niterations,Equations.NumberOfEdges + 1);
    
    %% Use sparse matrices:
    Equations.KCLCoeff = sparse(Equations.KCLCoeff);
    Equations.KVLCoeff = sparse(Equations.KVLCoeff);
    RHSZeros           = sparse(RHSZeros);
    
    %% If snapshots are requested, allocate memory for them:
    if ~isempty(varargin)
        snapshots           = cell(size(varargin{1}));
        snapshots_idx       = sort(varargin{1}); 
    else
        nsnapshots          = 10;
        snapshots           = cell(nsnapshots,1);
        snapshots_idx       = ceil(logspace(log10(1), log10(niterations), nsnapshots));
    end
    kk = 1; % Counter
    
    
    %% Solve equation systems for every time step and update:
    for ii = 1 : niterations
        % Show progress:
        progressBar(ii,niterations);
        
        %OG Solution
        %{
        % Update resistance values:
        updateComponentResistance(compPtr); 
        LHS = [Equations.KCLCoeff .* compPtr.comp.resistance(:,ones(Equations.NumberOfNodes-1,1)).' ; ...
               Equations.KVLCoeff];
        RHS = [RHSZeros ; Stimulus.Signal(ii,:)'];

        % Solve equation:
        compPtr.comp.voltage = LHS\RHS; %temporary Voltage
        %}
        
        
        %%{
        %My solution %Valid for a single source and drain
        % Update resistance values:
        switchChange = updateComponentResistance(compPtr); 
        %switchChange = 1;
        %Only need to resolve voltage is there are switches which changes
        if switchChange 
            LHS = [Equations.KCLCoeff .* compPtr.comp.resistance(:,ones(Equations.NumberOfNodes-1,1)).' ; ...
                   Equations.KVLCoeff];
            RHS = [RHSZeros ; 1.0];

            % Solve equation:
            V = LHS\RHS; %temporary Voltage
            %ii
        end
        
        if ii == 1
            compPtr.comp.voltage = V*Stimulus.Signal(ii);
        end
        
        %%}
        
        lam = compPtr.comp.filamentState;       
        
        % Update element fields:
        %updateComponentState(compPtr, Stimulus.dt);    % ZK: changed to allow retrieval of local values
        [lambda_vals(ii,:), voltage_vals(ii,:)] = updateComponentState(compPtr, Stimulus.dt);
        
        % Record tester voltage:
        c_vals(ii,:) = compPtr.comp.resistance;
        
        testerVoltage(ii,:) = compPtr.comp.voltage(Equations.NumberOfEdges + 1: end);
        
        %Record average value of lambda 
        avLambda(ii) = mean(abs(compPtr.comp.filamentState));            
        
        % Record the activity of the whole network
        
        if find(snapshots_idx == ii) 
                frame.Timestamp  = SimulationOptions.TimeVector(ii);
                frame.Voltage    = compPtr.comp.voltage;
                frame.Resistance = compPtr.comp.resistance;
                frame.OnOrOff    = compPtr.comp.OnOrOff;
                frame.filamentState = compPtr.comp.filamentState;
                frame.netV = Stimulus.Signal(ii);
                frame.netI = testerVoltage(ii) * compPtr.comp.resistance(end);
                frame.netC = compPtr.comp.resistance(end)/((Stimulus.Signal(ii) / testerVoltage(ii) - 1));
                snapshots{kk} = frame;
                kk = kk + 1;
        end
        
    end
    
    % Store some important fields
    SimulationOptions.SnapshotsIdx = snapshots_idx; % Save these to access the right time from .TimeVector.

    % Calculate network resistance and save:
    OutputDynamics.testerVoltage     = testerVoltage;
    OutputDynamics.networkCurrent    = testerVoltage .* compPtr.comp.resistance(end);
    OutputDynamics.networkResistance = 1./(Stimulus.Signal ./ testerVoltage - 1).*compPtr.comp.resistance(end);
    OutputDynamics.AverageLambda = avLambda;

    % ZK: also for local values:
    OutputDynamics.lambda = lambda_vals;
    OutputDynamics.storevoltage = voltage_vals;
    OutputDynamics.storeCon  = c_vals;
    
    
    
end