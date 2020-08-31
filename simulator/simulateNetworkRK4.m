function [OutputDynamics, SimulationOptions] = simulateNetworkRK4(Connectivity, Components, Signals, SimulationOptions, varargin)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Simulate network at each time step. Mostly the same as Ido's code.
% Improved the simulation efficiency by change using nodal analysis.
% Enabled multi-electrodes at the same time.
%
% Left the API of snapshots. For later usage of visualize the network.
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
%            snapshot of the conductances and voltages in the network is
%            requested. This indices are based on the length of the simulation.
% OUTPUT:
% OutputDynamics -- is a struct with the activity of the network
%                    .networkConductance - the conductance of the network (between the two 
%                     contacts) as a function of time.
%                    .networkCurrent - the overall current from contact (1) to contact (2) as a
%                     function of time.
% Simulationoptions -- same struct as input, with updated field names
% snapshots - a cell array of structs, holding the conductance and voltage 
%             values in the network, at the requested time-stamps.
        
% REQUIRES:
% updateComponentConductance
% updateComponentState
%
%
% Authors:
% Ido Marcus
% Paula Sanz-Leon
% Ruomin Zhu
% Joel Hochstetter
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
    junctionConductance = zeros(niterations, E);
    junctionFilament   = zeros(niterations, E);

   
    
    %% Solve equation systems for every time step and update:
    for ii = 1 : niterations
        % Show progress:
        progressBar(ii,niterations);
        
        %Use the RK4 method

        %I modify notation from http://www.ohiouniversityfaculty.com/youngt/IntNumMeth/book.pdf 
        %{
            h = dt
            y is lambda
        
            Here I refer to:
            k1 = yi+h f(t_i, yi)
            k2 = yi+h f(t_i + h/2, (yi + k1)/2)
            k3 = yi+h f(t_i + h/2, (yi + k2)/2)
            k4 = yi+h f(t_i + dt, k3)
        
        %}

        
        k1Ptr = compPtr;        
        % Calculate k1      
        % Update conductance values:
        updateComponentConductance(k1Ptr); 
        
        %Update component voltage:
        sol = updateComponentVoltages(k1Ptr, edgeList, electrodes, Signals, LHSinit, RHS, 2*ii-1, V, E, numOfElectrodes);
        
        %Update component state without implementing windowing
        changeComponentState(k1Ptr, SimulationOptions.dt)
        
        k2Ptr = compPtr; 
        k2Ptr.comp.filamentState = (compPtr.comp.filamentState + k1Ptr.comp.filamentState)/2;
        %Calculate k2
        % Update conductance values:
        updateComponentConductance(k2Ptr); 
        
        %Update component voltage:
        updateComponentVoltages(k2Ptr, edgeList, electrodes, Signals, LHSinit, RHS, 2*ii, V, E, numOfElectrodes);
        
        %Update component state without implementing windowing
        changeComponentState(k2Ptr, SimulationOptions.dt)        
        
        
        k3Ptr = compPtr;        
        k3Ptr.comp.filamentState = (compPtr.comp.filamentState + k2Ptr.comp.filamentState)/2;
        
        %Calculate k3
        % Update conductance values:
        updateComponentConductance(k3Ptr); 
        
        %Update component voltage:
        updateComponentVoltages(k3Ptr, edgeList, electrodes, Signals, LHSinit, RHS, 2*ii, V, E, numOfElectrodes);
        
        %Update component state without implementing windowing
        changeComponentState(k3Ptr,  SimulationOptions.dt)  
        

        k4Ptr = k3Ptr;        
        %Filament state is just same as previous
        
        %Calculate k4
        % Update conductance values:
        updateComponentConductance(k4Ptr); 
        
        %Update component voltage:
        updateComponentVoltages(k4Ptr, edgeList, electrodes, Signals, LHSinit, RHS, 2*ii+1, V, E, numOfElectrodes);
        
        %Update component state without implementing windowing
        changeComponentState(k4Ptr,  SimulationOptions.dt)  
        
        
        
        
        
        
        % Update component state from Runge-Kutta:
        compPtr = k1Ptr;
        compPtr.comp.filamentState = 1/6*(k1Ptr.comp.filamentState + 2*k2Ptr.comp.filamentState + 2*k3Ptr.comp.filamentState + k4Ptr.comp.filamentState);
        
        %Apply window function
        compPtr.comp.filamentState (compPtr.comp.filamentState >  compPtr.comp.maxFlux) =  compPtr.comp.maxFlux(compPtr.comp.filamentState >  compPtr.comp.maxFlux);
        compPtr.comp.filamentState (compPtr.comp.filamentState < -compPtr.comp.maxFlux) = -compPtr.comp.maxFlux(compPtr.comp.filamentState < -compPtr.comp.maxFlux);
        
        %Store stuff
        wireVoltage(ii,:)        = sol(1:V);
        electrodeCurrent(ii,:)   = sol(V+1:end);
        junctionVoltage(ii,:)    = compPtr.comp.voltage;
        junctionConductance(ii,:) = compPtr.comp.conductance;
        junctionFilament(ii,:)   = compPtr.comp.filamentState;
        
        
    end
    
    % Calculate network conductance and save:
    OutputDynamics.electrodeCurrent   = electrodeCurrent;
    OutputDynamics.wireVoltage        = wireVoltage;
    
    OutputDynamics.storevoltage       = junctionVoltage;
    OutputDynamics.storeCon           = junctionConductance;
    OutputDynamics.lambda             = junctionFilament;

    % Calculate network conductance and save:
    OutputDynamics.networkCurrent    = electrodeCurrent(:, 2);
    OutputDynamics.networkConductance = abs(OutputDynamics.networkCurrent ./ Signals{1}(2:2:end));
    
end