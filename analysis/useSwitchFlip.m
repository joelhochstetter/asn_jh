%% Find the shortest path between any given wires and junctions
%%{
%Connectivity.filename = '2016-09-08-155153_asn_nw_00100_nj_00261_seed_042_avl_100.00_disp_10.00.mat'; %100nw
Connectivity = struct();
Connectivity.filename = '2016-09-08-153543_asn_nw_02048_nj_11469_seed_042_avl_28.00_disp_10.00.mat'; %100nw
Connectivity.WhichMatrix       = 'nanoWires';    % 'nanoWires' \ 'randAdjMat'
Connectivity = getConnectivity(Connectivity);

src = 73;
drn = 30;
adjMat = Connectivity.weights;
adjMat(src,drn) = 1;
adjMat(drn,src) = 1;
Connectivity.wireShortPaths = graphallshortestpaths(sparse(double(adjMat)));

spW = Connectivity.wireShortPaths;
x = zeros(100,1); %distance from first wire
for i = 1:100
    x(i) = spW(73,i);
end

E = 261;
spJ = zeros(E);
for i = 1:E
    for j = 1:E
        spJ(i,j) = junctionDistance(i, j, Connectivity);
    end
end

fromJ = 131;
y = zeros(261,1); %distance from the first node
for i = 1:261
    y(i) = spJ(fromJ,i);
end


%%
contacts = [src, drn]
sijd = ones(Connectivity.NumberOfEdges);
adjMat       = Connectivity.weights;
src = contacts(1);
drn = contacts(2);
% adjMat(src,drn) = 1;
% adjMat(drn,src) = 1;
%Consider the subset of switches which get involved in switching in the
Connectivity.wireShortPaths = graphallshortestpaths(sparse(double(adjMat)));
wsp = Connectivity.wireShortPaths;
% for i = 1:Connectivity.NumberOfEdges
%     for j = 1:Connectivity.NumberOfEdges
%         jd(i,j) = junctionDistance(i, j, Connectivity);
%     end
% end

% An edge adjacent to source or drain
edgeSrc = find(Connectivity.EdgeList(1,:) == contacts(1));
edgeDrn = find(Connectivity.EdgeList(1,:) == contacts(2));
edgeSrc = edgeSrc(1);
edgeDrn = edgeDrn(1);

eList = Connectivity.EdgeList;

jd = ones(Connectivity.NumberOfEdges);
for i = 1:Connectivity.NumberOfEdges
    for j = 1:Connectivity.NumberOfEdges
        jd(i, j) = 1 + min([wsp(eList(1,i), eList(1,j)), wsp(eList(2,i), eList(2,j)), wsp(eList(1,i), eList(2,j)), wsp(eList(2,i), eList(1,j))]);
    end 
end

%Node to junction distance
njd = ones(Connectivity.NumberOfNodes, Connectivity.NumberOfEdges);
for i = 1:Connectivity.NumberOfNodes
    for j = 1:Connectivity.NumberOfEdges
        njd(i, j) = min(wsp(i, eList(1,j)), wsp(i, eList(2,j)));
    end
end


% For sijd we need to remove the src drn path from the adjacency matrix
sid = ones(Connectivity.NumberOfEdges,1);
%shortest distance from 
for i = 1:Connectivity.NumberOfEdges
    sid(i) = min(wsp(eList(1,i), contacts(1)) + wsp(eList(2,i), contacts(2)) + 1, wsp(eList(1,i), contacts(2)) + wsp(eList(2,i), contacts(1)) + 1);
    for j = 1:Connectivity.NumberOfEdges
        sijd(i,j) = min(njd(contacts(1), i) + njd(contacts(2), j), njd(contacts(2), i) + njd(contacts(1), j)) + jd(i,j) + 1;
    end
end

sp  = kShortestPath(adjMat, contacts(1), contacts(2), 1);
spE = getPathEdges(sp{1}, Connectivity.EdgeList);


%%}

%% dV distribution
%Consider sign change

%Fractional c

fromJ = 229;
y = zeros(261,1); %distance from the first node
for i = 1:261
    y(i) = spJ(fromJ,i);
end
%%
[~, ~, dV, ~, ~, V1] = switchFlip(fromJ, 0, drn,1); %17

figure
plot(jd(229,:),(dV).*1e12,'x')
xlabel 'Junction distance (wires of separation)'
ylabel('$$\frac{\partial V}{\partial G}\qquad (V \Omega)$$', 'interpreter','latex')
title 'Flipping the 229 junction - close to source'
%ylim([-max(abs(dV)).*1e12,max(abs(dV)).*1e12]);
%{
sum(abs(dV./V1-dV2./V2) > 1e-10)
find(abs(dV./V1-dV2./V2) > 1e-10)
dV./V1-dV2./V2;
%}


%{
fromJ = 131;
y = zeros(261,1); %distance from the first node
for i = 1:261
    y(i) = spJ(fromJ,i);
end

[~, ~, dV] = switchFlip(fromJ, 1, 17);

figure
plot(y,dV,'x')
xlabel 'Junction distance (wires of separation)'
ylabel 'dV across junction (V)'
title 'Flipping the 131 junction - close to drain'
%}

%% Number of times a given switch is flipped  
%{

E = 261; %number of edges
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


%% Altering the drain for a given source and switch flipped

FnetC = zeros(100,1);
dV    = zeros(100,261);
Con1  = zeros(261,1);
Con2  = zeros(100,261);
V1    = zeros(261,1);
V2    = zeros(100,261);

drain = 1:100;
for i = drain
    [FnetC(i), netC1, dV(i,:), Con1, Con2(i,:), V1, V2(i,:)] = switchFlip(229,0,i);
end

FnetC(73) = NaN;
figure;
max(abs(dV),[],1); %For a given switch finds the maximum value out of any flipped switch
max(abs(dV),[],2); %For a given flipped switch finds the maximum of the switches
semilogy(x,FnetC,'x')
xlabel 'Distance from source of drain'
ylabel 'Conductance'

%% Altering the switch flipped for a given source and drain

FnetC = zeros(261,1);
dV    = zeros(261);
Con1  = zeros(261,1);
Con2  = zeros(261);
V1    = zeros(261,1);
V2    = zeros(261);

flips = 1:261;
for i = flips
    [FnetC(i), netC1, dV(i,:), Con1, Con2(i,:), V1, V2(i,:)] = switchFlip(i,0,-1);
end


figure;
max(abs(dV),[],1); %For a given switch finds the maximum value out of any flipped switch
max(abs(dV),[],2); %For a given flipped switch finds the maximum of the switches
semilogy(y,FnetC,'x')
xlabel 'Distance from source of swit'
ylabel 'Conductance'