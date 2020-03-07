%statistics
%first occurance of maximum
%time crossing 1e-6 for the first time - delay time
%time reaching max. This - 1e-6 - switching time
%time to drop below 1e-6  - memory time
MD1;

SimulationOptions.T  = 1;    % (sec) duration of simulation

E = Connectivity.NumberOfEdges;
Components.setVoltage    = ones(E+1,1)*1e-2; %1e-2;    % (Volt) %% sawtooth: 0.3
Components.resetVoltage  = ones(E+1,1)*1e-3; %1e-3;    % (Volt) %% sawtooth: 0.01
Components.criticalFlux  = ones(E+1,1)*1e-1; %1e-1;  % (Volt*sec)  %% sawtooth: 1e-4
Components.maxFlux       = ones(E+1,1)*0.15; %1.5e-1 % (Volt*sec) %% sawtooth: 0.1
Components.penalty       = 1; %10
Components.boost         = 10; %10

i = 1;
%1e-7, 2e-5, max, 1st occurence of max

Vlist = 0.01:0.5:2.01;

Max     = zeros(size(Vlist));
MaxLoc  = zeros(size(Vlist));
onStart = zeros(size(Vlist));
onEnd   = zeros(size(Vlist));

for V = Vlist
    Stimulus.Amplitude = V;
    Stimulus = getStimulus(Stimulus, SimulationOptions);
    [Output, SimulationOptions, snapshots] = simulateNetwork(Equations, Components, Stimulus, SimulationOptions, snapshotsIdx); % (Ohm)
    c = Output.networkResistance;
    Max(i) = max(c);
    MaxLoc(i) = SimulationOptions.TimeVector(find(c==Max(i),1));
    x = c(c >= 1e-7);
    if size(x,1) == 0
        onStart(i) = NaN;
    else
        onStart(i) = SimulationOptions.TimeVector(find(c==x(1),1));
    end
    
    x = c(c >= 2e-5);
    if size(x,1) == 0
        onEnd(i) = NaN;
    else
        onEnd(i) = SimulationOptions.TimeVector(find(c==x(1),1));
    end
    i = i + 1;
end

%{
c = Output.networkResistance;
Max = max(c)
x = find(c==max(c));
MaxLoc(i) = x(1);
%}
%{
for i = 1:size(c)
    
end
%}