%addpath(genpath('/import/silo2/joelh/Criticality/perturbation'));
%% import unperturbed
params = struct();
params.SimOpt.saveFolder   = 'switch0';
params.importAll    = true; 
s0                  = multiImport(params);


%% compare with perturbing a state
params = struct();
params.SimOpt.saveFolder   = 'switch228';
params.importAll    = true; 
sc                = multiImport(params);

%%

for j = 1:6
    s0{j}.init = s0{j}.netC(1);
    sc{j}.init = sc{j}.netC(1);
    multiPlotConductance(s0{j}.Stim.TimeAxis, {s0{j}, sc{j}}, 'init', 'Initial conductance')
end
xlim([0,20])

%% Absolute difference in conductance
sd = s0;
for j = 1:6
    sd{j}.netC = s0{j}.netC ./ sc{j}.netC;
    sd{j}.init = s0{j}.netC(1);
    sd{j}.swC  = s0{j}.swC ./ sc{j}.swC;
    sd{j}.swLam  = s0{j}.swLam - sc{j}.swLam;
    sd{j}.swV  = s0{j}.swV - sc{j}.swV;    
end

multiPlotConductance(s0{1}.Stim.TimeAxis, sd(1), 'init', 'Initial conductance')
xlim([0,20])

%% Get shortest path
Connectivity          = struct('filename', sc{1}.ConnectFile);
Connectivity          = getConnectivity(Connectivity);
adjMat       = Connectivity.weights;
contacts = sc{1}.ContactNodes;

sp  = kShortestPath(adjMat, contacts(1), 27,1);%contacts(2), 1);
spE = getPathEdges(sp{1}, Connectivity.EdgeList);


%% Compute difference
sd = s0;
sd{1}.netC = sc{2}.netC ./ s0{6}.netC;
sd{1}.init = sc{2}.netC(1);
sd{1}.swC  = sc{2}.swC ./ s0{6}.swC;
sd{1}.swLam  = sc{2}.swLam - s0{6}.swLam;
sd{1}.swV  = sc{2}.swV - s0{6}.swV;    



%% Timeseries


sim = sc{2};
dt        = sim.dt;
timeVec   = dt:dt:sim.T;


spLam = zeros(numel(sim.netC),numel(spE));
spRes = zeros(numel(sim.netC),numel(spE));
spVol = zeros(numel(sim.netC),numel(spE));

for i = 1:numel(timeVec)
    spLam(i,:) = sim.swLam(i,spE);
    spRes(i,:) = sim.swC(i,spE);
    spVol(i,:) = sim.swV(i,spE);   
end



%%% Plot time series analysis
tend = 5;%timeVec(idx(j));

figure('units','normalized','outerposition',[0 0 1 1]);
subplot(3,1,1)
semilogy(timeVec,abs(spRes),'-')
xlabel 't (s)'
ylabel 'Switch Conductance (S)'
title(strcat('DC Activation (tunnelling model) - switch conductance values along main current path, V = ', num2str(sim.Stim.Amplitude),'V'))
yyaxis right
semilogy(timeVec,sim.netC,'--');
ylabel 'Network Conductance (S)'
legend(cellstr(num2str(spE)),'net')
xlim([0,tend])

critLam = ones(size(timeVec))*sim.Comp.critFlux;

subplot(3,1,2)
plot(timeVec,abs(spLam),'-')
hold on 
%semilogy(timeVec, critLam);
%ylim([1.0,1.1])
xlabel 't (s)'
ylabel '\lambda (Vs)'
title(strcat('DC Activation (tunnelling model) - switch \lambda values along main current path, V = ', num2str(sim.Stim.Amplitude),'V'))
yyaxis right
semilogy(timeVec,sim.netC,'--');
ylabel 'Network Conductance (S)'
legend(cellstr(num2str(spE)), '\lambda_c')
xlim([0,tend])
ylim([0.09,0.1])

Vset   = ones(size(timeVec))*sim.Comp.setV;
Vreset = ones(size(timeVec))*sim.Comp.resetV;

subplot(3,1,3)
plot(timeVec,(spVol),'-')
hold on 
%plot(timeVec, Vset);
%plot(timeVec, Vreset);
xlabel 't (s)'
ylabel '\Delta V (V)'
title(strcat('DC Activation (tunnelling model) - switch V values along main current path, V = ', num2str(sim.Stim.Amplitude),'V'))
yyaxis right
semilogy(timeVec,sim.netC,'--');
ylabel 'Network Conductance (S)'
leg = cellstr(num2str(spE));
leg = {leg{:}, 'V_{set}','V_{reset}','net'};
legend(leg)
xlim([0,tend])








%% Creates snapshot from data - enter snapshots
j = 1;

edgs = [];
nds  = [];

% sc{2} 


while i > 0 
    %edgs = find(abs(sim.swV(1,1:end-1)) > 1e-2);
    %edgs   = 248;

    whatToPlot            = struct('Dissipation',  false, 'VDrop',  false, 'GraphRep', true, 'Voltages', false, 'Nanowires', true, 'Lambda', true, 'Labels',false, 'Currents', false);
    axesLimits            = struct('LambdaCbar',[min(min(abs(sim.swLam))); max(max(abs(sim.swLam)))], 'CurrentArrowScaling',10);
    snapshot = generateSnapshotFromData(sim.swV(i,:)', sim.swLam(i,:)', sim.swC(i,:)',  sim.Comp.critFlux, sim.Stim.Signal(i), sim.netC(i), i*sim.dt);
    snapshotToFigure(snapshot, sim.ContactNodes, Connectivity, whatToPlot, axesLimits, nds, edgs);
    set(gcf, 'visible','on')
    
    i = str2num(input('Enter i:   ', 's'));
end

% Generates figures of snapshots
%multiSnapshotSave(t, idx, Connectivity, sim.Comp, sim.ContactNodes, params.SimOpt.saveFolder)




%% Compare individual switch details
