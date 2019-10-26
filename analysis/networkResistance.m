function R = networkResistance()
%Calculates the conductance of a network for given connectivity
%and switch values
onR  =    10000;
offR = 10000000;

Equations = getEquations(Connectivity,SimulationOptions.ContactNodes);

%% Solve equation systems for every time step and update:
% Update resistance values:
updateComponentResistance(compPtr); 

% Get LHS (matrix) and RHS (vector) of equation:
LHS = [Equations.KCLCoeff ./ compPtr.comp.resistance(:,ones(Equations.NumberOfNodes-1,1)).' ; ...
       Equations.KVLCoeff];
RHS = [RHSZeros ; Stimulus.Signal(ii)];

% Solve equation:
compPtr.comp.voltage = LHS\RHS;


R =
end

