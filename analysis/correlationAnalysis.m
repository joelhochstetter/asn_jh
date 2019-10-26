%{
    2.16pm 22/8 - We are running correlation analysis for pre-activation
    phase


    Next:
    Plot shortest path passing through a given node vs lambda value
    
%}


%% Correlation analysis
swLam = Output.lambda(:,1:Connectivity.NumberOfEdges);
swV   = Output.storevoltage(:,1:Connectivity.NumberOfEdges);
con   = Output.networkResistance;
lam   = abs(swLam(1:floor(end/2),:));
vol   = abs(swV(1:floor(end/2),:));
adjMat = Connectivity.weights;
contacts = SimulationOptions.ContactNodes;
critL = Components.criticalFlux(1);
onOff = (abs(swLam) > critL);%*2 - 1; %1 if on -1 if off

lamCorr = corrcoef(abs(lam));
volCorr = corrcoef(abs(vol));
%Nan means that std is 0

%g = graph(adjMat);
%plot(distances(g),lamCorr,'x')
jd = ones(Connectivity.NumberOfEdges);
sijd = ones(Connectivity.NumberOfEdges);


%adjMat = getOnSubGraph(adjMat, Connectivity.EdgeList, onOff(end,:)');
src = contacts(1);
drn = contacts(2);
adjMat(src,drn) = 1;
adjMat(drn,src) = 1;
%Consider the subset of switches which get involved in switching in the


Connectivity.wireShortPaths = graphallshortestpaths(sparse(double(adjMat)));

for i = 1:Connectivity.NumberOfEdges
    for j = 1:Connectivity.NumberOfEdges
        jd(i,j) = junctionDistance(i, j, Connectivity);
    end
end

% An edge adjacent to source or drain
edgeSrc = find(Connectivity.EdgeList(1,:) == contacts(1));
edgeDrn = find(Connectivity.EdgeList(1,:) == contacts(2));
edgeSrc = edgeSrc(1);
edgeDrn = edgeDrn(1);


% For sijd we need to remove the src drn path from the adjacency matrix
sid = ones(Connectivity.NumberOfEdges,1);
%shortest distance from 
for i = 1:Connectivity.NumberOfEdges
    sid(i) = jd(i,edgeSrc) +  jd(i,edgeDrn);
    for j = 1:Connectivity.NumberOfEdges
        sijd(i,j) = min((jd(edgeSrc,i)+jd(edgeDrn,j)+jd(i,j)), (jd(edgeSrc,j)+jd(edgeDrn,i)+jd(i,j)));
    end
end


figure;plot(jd,lamCorr,'.');xlabel 'Shortest source drain path through both nodes'; ylabel 'Lambda Correlation';title '2048nw network - DC activation Tunn - correlation analysis - pre-activation'
figure;plot(jd,volCorr,'.');xlabel 'Shortest source drain path through both nodes'; ylabel 'V drop Correlation';title '2048nw network - DC activation Tunn - correlation analysis - pre-activation'
%{
figure;
plot(sijd,lamCorr,'.')
figure;
plot(sijd,lamCorr,'.')
%}


%% Differences in lambda trajectories
%How do lambda trajectories differ from initial trajectory
%Does switch flipping actually affect dynamics or are trajectories fixed
V0 = swV(1,:);
dt = SimulationOptions.dt;
T  = SimulationOptions.T;
tVec = dt:dt:T;
tVec = tVec';
bst  = Components.boost(1);
setV = Components.setVoltage(1);
resV = Components.resetVoltage(1);
maxL = Components.maxFlux(1);

Vdiff = (abs(V0) > setV).*(abs(V0) - setV).*sign(V0); %+ (abs(V0) < resV).*(abs(V0) - setV).*sign(swLam(2,:))*bst;


lamTraj = (tVec-dt).*Vdiff;
lamTraj(abs(lamTraj) > maxL) = maxL.*sign(lamTraj(abs(lamTraj) > maxL));
lamTraj = (swLam - lamTraj);


figure;
imagesc(tVec, 1:261, lamTraj')
colorbar
yyaxis right;
semilogy(tVec, con);
figure;semilogy(max(abs(lamTraj)')');
hold on;
semilogy(min(abs(lamTraj)')');
semilogy(mean(abs(lamTraj)')');
semilogy(std(abs(lamTraj)')');
legend 'max' 'min' 'mean' 'std'



%figure;plot(max((swV(2:end,:)-swV(1:end-1,:))')');


%% We calculate the statistical mechanical correlation function'
%{
    <s1(0).s2(r)> - <s1(0)><s2(r)>
    Here we use resistance

%}

Ron  = Components.onResistance(1);
Roff = Components.offResistance(1);
swR  = Output.storeCon(end,1:end-1);
swR = Ron * swR;

%Correlations away from 1

Corr = zeros(Connectivity.NumberOfEdges, max(max(jd)));
for j = 1:Connectivity.NumberOfEdges
for i = 1:max(max(jd))
    Corr(j,i) = mean(swR(find(jd(j,:) == i))*swR(j))- mean(swR(find(jd(j,:) == i)))*swR(j); %average over these
end
end




%% Obtain sijd
adjMat = Connectivity.weights;
jd1 = ones(Connectivity.NumberOfEdges);
sijd = ones(Connectivity.NumberOfEdges);

%Consider the subset of switches which get involved in switching in the
Connectivity.wireShortPaths = graphallshortestpaths(sparse(double(adjMat)));

for i = 1:Connectivity.NumberOfEdges
    for j = 1:Connectivity.NumberOfEdges
        jd1(i,j) = junctionDistance(i, j, Connectivity);
    end
end

% An edge adjacent to source or drain
edgeSrc = find(Connectivity.EdgeList(1,:) == contacts(1));
edgeDrn = find(Connectivity.EdgeList(1,:) == contacts(2));
edgeSrc = edgeSrc(1);
edgeDrn = edgeDrn(1);

% For sijd we need to remove the src drn path from the adjacency matrix
sid = ones(Connectivity.NumberOfEdges,1);
%shortest distance from 
for i = 1:Connectivity.NumberOfEdges
    sid(i) = jd1(i,edgeSrc) +  jd1(i,edgeDrn);
    for j = 1:Connectivity.NumberOfEdges
        sijd(i,j) = min((jd1(edgeSrc,i)+jd1(edgeDrn,j)+jd1(i,j)), (jd1(edgeSrc,j)+jd1(edgeDrn,i)+jd1(i,j)));
    end
end

figure;plot(jd,lamCorr,'.');xlabel 'Shortest source drain path through both nodes'; ylabel 'Lambda Correlation';title '2048nw network - DC activation Tunn - correlation analysis'
figure;plot(jd,volCorr,'.');xlabel 'Shortest source drain path through both nodes'; ylabel 'V drop Correlation';title '2048nw network - DC activation Tunn - correlation analysis'
