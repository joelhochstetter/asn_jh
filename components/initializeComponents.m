function Components = initializeComponents(E,Components, NodalAnal)
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
% Initializes a structure which holds the characteristics and current state
% of all the electrical elemetns in the network.
%
% ARGUMENTS: 
% E - number of components.
% Components - a structure containing all the options for the components. It
%           must contain a field 'Component Type' which must be one of the
%           following strings:
%           - 'resistor' - passive element
%           - 'memristor' - an element with a charge-dependent resistance
%                           function (memristance) 
%           - 'atomicSwitch' - an element in which switching events are 
%                              driven by voltage.
% 
%
% OUTPUT:
% Components - a struct containing all the properties of the electrical
%              components in the network. {identity, type, voltage, 
%              resistance, onResistance, offResistance} are obligatory 
%              fields, other fields depend on 'componentType'.
%
% REQUIRES:
% none
%
% USAGE:
%{
    Components.ComponentType = 'atomicSwitch'; 
    Components = initializeComponents(Connectivity.NumberOfEdges,Components);
%}
%
% Authors:
% Ido Marcus, Joel Hochstetter
%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%

    if nargin == 2
        NodalAnal = false;
    end

    %initialises to default values if none are given 
    default.onResistance  = 7.77e-5;
    default.offResistance = 1e-8;
    default.filamentState = 0.0;
    default.resistance    = 1e-7; %conductance of passive elements
    %default.OnOrOff       = 0.0;
    default.setVoltage    = 0.3;%1e-2; %0.3
    default.resetVoltage  = 1e-2;%1e-3; %0.01
    default.criticalFlux  = 1e-4;%1e-1; %1e-4
    default.maxFlux       = 0.15;%0.15;
    default.barrHeight    = 0.81; %potential barrier height for tunnelling in V
    default.filArea       = 0.17; %area of filament tip 
    default.penalty       = 1;%10;
    default.boost         = 10;%10;
    default.nonpolar      = false;
    default.unipolar      = false;
    default.noise         = 0.0;
    
    fields = fieldnames(default);
    for i = 1:numel(fields)
        if isfield(Components, fields{i}) == 0
            Components.(fields{i}) = default.(fields{i});
        end
    end
      

    
    Components.identity      = ones(E,1);          % 0 for a passive resistor, 1 for an active element
        % If one wants an element to be active with probability p,
        % Components.identity      = [rand(E,1) <= p ; 0];
    Components.type          = Components.ComponentType; % type of active elements ('atomicSwitch' \ 'memristor' \ ...)
    Components.voltage       = zeros(E,1);             % (Volt)
    Components.resistance    = ones(E,1)*1e7;             % (Ohm) (memory allocation)
    Components.onResistance  = ones(E,1)*Components.onResistance;   % (Ohm) 1/(12.9 kOhm) = conductance quantum
    Components.offResistance = ones(E,1)*Components.offResistance; %*1e7;   % (Ohm) literature values
    
    if NodalAnal
        sz = E;
    else
        Components.onResistance(end + 1)  = 100;
        Components.offResistance(end + 1) = 100;  
        Components.identity(end + 1)      = 0;
        Components.voltage(end + 1)       = 0;
        Components.resistance(end + 1)    = 0;
        sz = E + 1;
        if numel(Components.filamentState) == E
            Components.filamentState = [Components.filamentState; 0.0];
        end
    end

    switch Components.ComponentType        
        case 'memristor'
            Components.charge         = zeros(sz,1);                                   % (Coulomb)
            % parameters of (... _/-\_/-\ ...) shape:
            Components.lowThreshold   = rand(sz,1)*1e-8;                               % (Coulomb) (1V applied across an OFF-state switch will cause it to open up in about 0.1 sec)
            Components.highThreshold  = (1+rand(sz,1)*1e1) .*Components.lowThreshold;  % (Coulomb)
            Components.period         = (2+rand(sz,1))     .*Components.highThreshold; % (Coulomb) (optional, usually memristance is not a periodic function)
            Components.OnOrOff        = []; % Dummy field only required in atomic switch
        case {'atomicSwitch', 'tunnelSwitch', 'quantCSwitch', 'hybridSwitch', 'tunnelSwitch2', 'tunnelSwitchL', 'linearSwitch'}
            % parameters of filament formation\dissociation:
            Components.setVoltage    = ones(sz,1).*Components.setVoltage; %1e-2;    % (Volt) %% sawtooth: 0.3
            Components.resetVoltage  = ones(sz,1).*Components.resetVoltage; %1e-3;    % (Volt) %% sawtooth: 0.01
            Components.criticalFlux  = ones(sz,1).*Components.criticalFlux; %1e-1;  % (Volt*sec)  %% sawtooth: 1e-4
            Components.maxFlux       = ones(sz,1).*Components.maxFlux; %1.5e-1 % (Volt*sec) %% sawtooth: 0.1
            Components.penalty       = Components.penalty; %10
            Components.boost         = Components.boost; %10
            Components.filamentState = ones(sz,1) .* Components.filamentState;        % (Volt*sec)
            Components.OnOrOff       = true(sz,1); %This gets fixed upon running sim
            
            
        case 'resistor'
            Components.identity      = zeros(sz,1);        % 0 for a passive resistor, 1 for an active element
            Components.OnOrOff       = []; % Dummy field only required in atomic swithc
            
        case 'nonlinearres'
           Components.OnOrOff        = [];

    end
end