%Conducting Path analysis
%{
    Perform on the 4 sims particularly compare switches which turn off in
    the discussion stability analysis

%}


%% Load shit
qc1 = load('QuantumCSuperLongSim_lam=0.1.mat');
qc0 = load('QuantumCSuperLongSim_lam=0.0.mat'); 
tn1 = load('tunnelSuperLongSim_lam=0.1.mat');
tn0 = load('tunnelSuperLongSim_lam=0.0.mat'); 

%% Workspace variables
SimulationOptions = tn0.SimulationOptions;
Output            = tn0.Output;
Components        = tn0.Components;
Stimulus          = tn0.Stimulus;
Connectivity      = tn0.Connectivity;


%% Plot conductance power spectrum
figure;
semilogy(qc1.SimulationOptions.TimeVector, qc1.Output.networkResistance)
hold on 
semilogy(tn1.SimulationOptions.TimeVector, tn1.Output.networkResistance)
ylabel 'G (S)'
xlabel 't (s)'
legend 'qc' 'tun'
xlim([0,100])
title 'Recovery from \lambda = 0.1'

%% Get subgraph of on switches
Snapshot = snapshots{100};
% Find the edges which correspond to OFF switches:
badPairs = Connectivity.EdgeList(:, ~Snapshot.OnOrOff(1:end-1));
    % Reminder: EdgeList is a 2XE matrix of vertex indices, where each 
    % column represents an edge. The index of an edge is defined as the 
    % index of the corresponding column in this list.

% Get the original adjacency matrix:
onSwitchMatrix = Connectivity.weights;

% Remove the edges which correspond to OFF switches:
onSwitchMatrix(sub2ind(size(onSwitchMatrix),badPairs(1,:),badPairs(2,:))) = 0;
onSwitchMatrix(sub2ind(size(onSwitchMatrix),badPairs(2,:),badPairs(1,:))) = 0;



%% Consider connected components
g = graph(getOnSubGraph(adjMat, edgeList, onOrOff(1000,:)));
figure
plot(g)

bins = conncomp(g);
% find(bins == 1)) gives you all elements in a bin
sg = subgraph(g, find(bins == 1));

contacts = SimulationOptions.ContactNodes;

isCurrentPath = bins(contacts(1)) == bins(contacts(2));
currentBin    = bins(contacts(1));
bins == currentBin

figure
plot(sg)


%% We can classify nodes as the following

% Adds to current pathways
%   Below this we can characterise this as adding to an independent
%   currrent pathway
% Separate current pathways
% Switches that are off current pathways 
%   Connected to others, connected
% new switch
% increasing quantum conductance
% number of switches on at once


%{
    The tunnelling and regular comparison is brilliant
    None of the switches reach fulling on in the tunnelling model
    ~2nd order phase transition omg
    current path forms straight after first switch turns on

    Switches never fully turn on in tunnelling model unless they lie on a
    current path or a connected component

%}


dt        = Stimulus.dt;
timeVec   = dt:dt:Stimulus.T;
timeShift = timeVec(1:end-1) + dt/2;
timeShif2 = timeVec(2:end - 1);
contacts  = SimulationOptions.ContactNodes;
adjMat    = Connectivity.weights;
edgeList  = Connectivity.EdgeList;
switchV   = Output.storevoltage(:,1:end-1);
switchLam = Output.lambda(:,1:end-1);
critLam   = Components.criticalFlux(1);
onOrOff   = abs(switchLam) > critLam;
i = 1;
numE      = Connectivity.NumberOfEdges;
g         = graph(adjMat);

isCurrentPath = zeros(size(switchV,1),1);
lieOnCurrentP = zeros(size(switchV));

changeOnOrOff = onOrOff(2:end,:) - onOrOff(1:end - 1,:);
turnOff       = onOrOff(2:end,:) < onOrOff(1:end - 1,:);
turnOn        = onOrOff(2:end,:) > onOrOff(1:end - 1,:);


% Calculate velocities and accelerations
lambdaVel     = (switchLam(2:end,:)-switchLam(1:end-1,:))/dt;
lambdaAcc     = (lambdaVel(2:end,:)-lambdaVel(1:end-1,:))/dt;

for i = 1:size(onOrOff,1)
    sg               = getOnSubGraph(adjMat, edgeList, onOrOff(i,:));
    g                = graph(sg);
    bins             = conncomp(g);
    isCurrentPath(i) = bins(contacts(1)) == bins(contacts(2));    
    if isCurrentPath(i)
        currentBin       = bins(contacts(1));  
        lieOnCurrentP(i,:) = (bins(edgeList(1,:)) == currentBin) & (bins(edgeList(2,:)) == currentBin) & onOrOff(i,:);
    end 
end

figure;
plot(timeVec,sum(lieOnCurrentP,2));
hold on;
plot(timeVec,sum(onOrOff,2));
plot(timeShift,sum(changeOnOrOff,2));
plot(timeShift,sum(turnOff,2));
plot(timeShift,sum(turnOn,2));
plot(timeVec,isCurrentPath)
yyaxis right;
plot(timeVec,Output.networkResistance);
ylabel 'Conductance (S)'
legend 'lie on current' 'on or off' 'switch changes' 'turn off' 'turn on' 'isCurrent Path' 'conductance';
title 'Tunnelling'
xlabel 'Time (s)'


figure;imagesc(switchLam');colorbar;
figure;imagesc(log10(abs(lambdaVel))');colorbar;
figure;imagesc(log10(abs(lambdaAcc))');colorbar;


% figure;plot(sum(lieOnCurrentP,2));hold on;plot(sum(onOrOff,2)); legend 'lie on current' 'on or off';

    %{
    %Subgraph method 
    %This deletes nodes not relevant
    % need to get the nodes corresponding to the edges which are onOrOff
    onNodes = unique(edgeList(:, onOrOff(i,:)));
  
    onSubGraph       = subgraph(g,onNodes);
    bins             = conncomp(onSubGraph);
    isCurrentPath(i) = bins(contacts(1)) == bins(contacts(2));
    %}

%% 
figure
plot(timeShift, sum(turnOff & lieOnCurrentP(2:end,:),2));
hold on;
plot(timeShift, sum(turnOff & ~lieOnCurrentP(2:end,:),2));
ylabel 'Switches turning off per timestep'
xlabel 'time (s)'
legend 'On current path' 'Off current path'
title 'Tunnel - Current path are stable'
yyaxis right
plot(timeVec,Output.networkResistance)
ylabel 'Conductance (S)'

figure;
plot(timeVec,sum(lieOnCurrentP,2));
hold on;
plot(timeVec,sum(onOrOff,2));
plot(timeShift,sum(changeOnOrOff,2));
plot(timeShift,sum(turnOff,2));log10
plot(timeShift,sum(turnOn,2));
plot(timeVec,isCurrentPath)
yyaxis right;
plot(timeVec,Output.networkResistance);
ylabel 'Conductance (S)'
legend('lie on current','on or off', 'switch changes', 'turn off', 'turn on', 'isCurrent Path', 'conductance', 'location', 'NorthWest');
title 'Tunnel'
xlabel 'Time (s)'
