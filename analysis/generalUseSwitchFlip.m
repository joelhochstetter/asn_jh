% Switch flipping gives us some general results
% Now if we consider the source and drain connected then we can analyse
% distributions in distance
% In a fully series/parallel we get collective switching
%
%
%
%
%

%% Set up the problem

%specify source
src = 1;

%specify drain 
drn = 30;

%Specify switch flipping
flip = 73;

%specify connectivity file
Connectivity.filename = '2016-09-08-153543_asn_nw_02048_nj_11469_seed_042_avl_28.00_disp_10.00.mat'; 


%% Find the shortest path between any given wires and junctions
%Connectivity.filename ='2016-09-08-155153_asn_nw_00100_nj_00261_seed_042_avl_numW.00_disp_10.00.mat';%100nw

Connectivity.WhichMatrix       = 'nanoWires';    % 'nanoWires' \ 'randAdjMat'
Connectivity = getConnectivity(Connectivity);

numW = Connectivity.NumberOfNodes;
numJ = Connectivity.NumberOfEdges;

%Add source drain connection to adjacency matrix
%As this gives a path for charge transfer
adjMat = Connectivity.weights;
adjMat(src,drn) = 1;
adjMat(drn,src) = 1;

Connectivity.wireShortPaths = graphallshortestpaths(sparse(double(adjMat)));

spW = Connectivity.wireShortPaths;
x = zeros(numW,1); %distance from first wire
for i = 1:numW
    x(i) = spW(src,i);
end

%Choose some edge connected to the source
spJ = zeros(numJ);
for i = 1:numJ 
    for j = 1:numJ 
        spJ(i,j) = junctionDistance(i, j, Connectivity);
    end
end

fromJ =  Connectivity.EdgeList(2, find(Connectivity.EdgeList(1,:) == src,1));
y = zeros(numJ,1); %distance from the first node
for i = 1:(numJ)
    y(i) = spJ(fromJ,i);
end



%% dV distribution
fromJ =  Connectivity.EdgeList(2, find(Connectivity.EdgeList(1,:) == src,1));
y = zeros(numJ,1); %distance from the first node
for i = 1:(numJ)
    y(i) = spJ(fromJ,i);
end

[~, ~, dV] = switchFlip(flip, 1, drn); %17

figure
plot(y,dV,'x')
xlabel 'Junction distance (wires of separation)'
ylabel 'dV across junction (V)'
title 'Flipping the 229 junction - close to source'

%{
fromJ = 131;
y = zeros(numJ,1); %distance from the first node
for i = 1:numJ
    y(i) = spJ(fromJ,i);
end

[~, ~, dV] = switchFlip(fromJ, 1, 17);

figure
plot(y,dV,'x')
xlabel 'Junction distance (wires of separation)'
ylabel 'dV across junction (V)'
title 'Flipping the 131 junction - close to drain'
%}


%% Altering the drain for a given source and switch flipped

FnetC = zeros(numW,1);
dV    = zeros(numW,numJ);
Con1  = zeros(numJ,1);
Con2  = zeros(numW,numJ);
V1    = zeros(numJ,1);
V2    = zeros(numW,numJ);

drain = 1:numW;

for i = drain
    [FnetC(i)] = switchFlip(229,0,i);
end

FnetC(73) = NaN;
figure;
max(abs(dV),[],1); %For a given switch finds the maximum value out of any flipped switch
max(abs(dV),[],2); %For a given flipped switch finds the maximum of the switches
semilogy(x,FnetC,'x')
xlabel 'Distance from source of drain'
ylabel 'Conductance'



%% Altering the switch flipped for a given source and drain

FnetC = zeros(numJ,1);
dV    = zeros(numJ);
Con1  = zeros(numJ,1);
Con2  = zeros(numJ);
V1    = zeros(numJ,1);
V2    = zeros(numJ);

flips = 1:numJ;
for i = flips
    [FnetC(i), netC1, dV(i,:), Con1, Con2(i,:), V1, V2(i,:)] = switchFlip(i,0,drn);
end


figure;
max(abs(dV),[],1); %For a given switch finds the maximum value out of any flipped switch
max(abs(dV),[],2); %For a given flipped switch finds the maximum of the switches
semilogy(y,FnetC,'x')
xlabel 'Distance from source of swit'
ylabel 'Conductance'



%% Number of times a given switch is flipped  
%{

E = numJ; %number of edges
%works if a snapshot is taken at every time step
t = SimulationOptions.TimeVector;
onSwitches = zeros(E, numel(t));

for i = 1:numel(t)
    onSwitches(:, i) = snapshots{i}.OnOrOff(1:E);
end

%Number of switch flips for a given switch
switchFlips = zeros(E,1);

for i = 1:numel(t)-1
   switchFlips((onSwitches(:,i+1) - onSwitches(:,i)) ~= 0) = switchFlips((onSwitches(:,i+1) - onSwitches(:,i)) ~= 0) + 1;
end

imagesc([SimulationOptions.dt,SimulationOptions.T], [1,E], onSwitches)
xlabel 't (s)'
ylabel 'Junction number'
title  '1.5V DC - switches on'
%} 
%{
figure
semilogy(x,FnetC,'x')
%}