%% 
params = struct();

% Set Simulation Options
params.SimOpt.useWorkspace    = false;
params.SimOpt.saveSim         = true;
params.SimOpt.takingSnapshots = false;
params.SimOpt.onlyGraphics    = true; %does not plot anything
params.SimOpt.compilingMovie  = false;
params.SimOpt.useParallel     = false;
params.SimOpt.hdfSave         = true;

params.SimOpt.saveFolder      = '/import/silo2/joelh/Criticality/collective/';

params.SimOpt.T                =  1e3;
params.SimOpt.dt               = 1e-3;
%Set Stimulus
params.Stim.BiasType     = 'DC'; % 'DC' \ 'AC' \ 'DCandWait' \ 'Ramp' \ 'ACsaw'
params.Stim.Amplitude    =  0.1;
%Depending on how many switches are on

%params.Conn.filename = '2016-09-08-155044_asn_nw_00700_nj_14533_seed_042_avl_100.00_disp_10.00.mat';

%Set Components
params.Comp.ComponentType  = 'tunnelSwitch2';
params.Comp.offResistance  = 1e-8;
params.Comp.setVoltage     = 1e-2;
params.Comp.resetVoltage   = 1e-3;
params.Comp.criticalFlux   = 0.10;
params.Comp.maxFlux        = 0.15;
params.Comp.penalty        =    1;
params.Comp.boost          =   10;

%%
multiRun(params);

%%

sim = multiImport(params);
sim = sim{1};

%% 
contacts = sim.ContactNodes;
Connectivity          = struct('filename', sim.ConnectFile);
Connectivity          = getConnectivity(Connectivity);
%%
adjMat       = Connectivity.weights;
sp  = kShortestPath(adjMat, contacts(1), contacts(2), 10);
spE = getPathEdges(sp{1}, Connectivity.EdgeList);
%%
dt        = sim.dt;
timeVec   = dt:dt:sim.T;


%% Time series shortest path from the source to drain

spLam = zeros(numel(sim.netC),numel(spE));
spRes = zeros(numel(sim.netC),numel(spE));
spVol = zeros(numel(sim.netC),numel(spE));

for i = 1:numel(timeVec)
    spLam(i,:) = sim.swLam(i,spE);
    spRes(i,:) = sim.swC(i,spE); %sim.swC(i,spE);
    spVol(i,:) = sim.swV(i,spE);   
end


%% 
%% Sexy phase space
figure;semilogy(abs(spVol(:,1:5)), abs(spRes(:,1:5)));legend(string(1:5), 'location', 'northeast');xlabel('V (V)'); ylabel('G (S)')

figure;plot(abs(spVol(:,1:5)), abs(spLam(:,1:5)));legend(string(1:5), 'location', 'southeast');

%figure; semilogy(abs(Output.storevoltage(:,spE)),Output.storeCon(:,spE));xlabel('Voltage (V)'); ylabel('Conductance (S)');legend(string(1:9))

%% Plot time series analysis
tend = 100;%timeVec(idx(j));

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
plot(timeVec, critLam);
ylim([0,0.15])
xlabel 't (s)'
ylabel '\lambda (Vs)'
title(strcat('DC Activation (tunnelling model) - switch \lambda values along main current path, V = ', num2str(sim.Stim.Amplitude),'V'))
yyaxis right
semilogy(timeVec,sim.netC,'--');
ylabel 'Network Conductance (S)'
legend(cellstr(num2str(spE)), '\lambda_c')
xlim([0,tend])

Vset   = ones(size(timeVec))*sim.Comp.setV;
Vreset = ones(size(timeVec))*sim.Comp.resetV;

subplot(3,1,3)
semilogy(timeVec,abs(spVol),'-')
hold on 
plot(timeVec, Vset);
plot(timeVec, Vreset);
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



%% Colour-plot matlab

figure;
subplot(1,3,1);
imagesc(timeVec(1:end), 1:10,abs(sim.swV(1:end,spE))');colorbar
xlabel 'time (s)'
ylabel 'Distance from source'
title 'Voltage colour plot'
xlim([0,15])

subplot(1,3,2);
imagesc(timeVec(1:end), 1:10,abs(sim.swLam(1:end,spE))');colorbar
xlabel 'time (s)'
ylabel 'Distance from source'
title 'Lambda colour plot'
xlim([0,15])

subplot(1,3,3);
imagesc(timeVec(1:end), 1:10,log(abs(sim.swC(1:end,spE)))');colorbar
xlabel 'time (s)'
ylabel 'Distance from source'
title 'Conductance colour plot'
xlim([0,15])

%% Contour
timeVector = timeVec;

figure('color','w', 'units', 'centimeters', 'OuterPosition', [5 5 25 18]);
%mesh(1:9, timeVector(1:10:60000), abs(sim.swV(1:10:60000,spE)));
contourf(1:9, timeVector(1:10:60000), abs(sim.swV(1:10:60000,spE)))
xlabel('Distance from source');
ylabel('Time (s)');
zlabel('Junction voltage (V)');
colormap(parula)
hcb = colorbar;
caxis([0,0.025])
title(hcb,'V (V)');
ylim([0,60])
grid on
saveas(gcf, '~/Documents/Honours/Project/Figures/Chapter5/contour.png')


%% 3D Plot
timeVector = timeVec;

figure('color','w', 'units', 'centimeters', 'OuterPosition', [5 5 25 18]);
mesh(1:9, timeVector(1:10:60000), abs(sim.swV(1:10:60000,spE)));
%contourf(1:9, timeVector(1:10:60000), abs(sim.swV(1:10:60000,spE)))
xlabel('Distance from source');
ylabel('Time (s)');
zlabel('Junction voltage (V)');
colormap(parula)
hcb = colorbar;
title(hcb,'V (V)');
ylim([0,50])
view([15 30])
saveas(gcf, '~/Documents/Honours/Project/Figures/Chapter5/3D.png')




%%
figure;
mesh(timeVector,1:9,abs(sim.swLam(:,spE))');ylabel('Distance from source');xlabel('Time (s)');zlabel('Filament State (Vs)');colorbar;
xlim([0,30])

figure;
mesh(timeVector,1:9,log10(sim.swC(:,spE))');ylabel('Distance from source');xlabel('Time (s)');zlabel('Log(Conductance)');colorbar;
xlim([0,30])


%% Initial voltage distribution
jd = ones(Connectivity.NumberOfEdges);
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

%%
V1 = abs(sim.swV(1,:))/0.1;
figure;
semilogy(sid, V1, 'x');
ylabel('|V_i|/V_s');
xlabel('Shortest source-drain path containing a given node');





%% Creates snapshot from data - enter snapshots
i = 1;

edgs = [];
nds  = [];

while i > 0
    %edgs = find(abs(sim.swV(1,1:end-1)) > 1e-2);
    edgs  = spE;
    whatToPlot            = struct('Dissipation',  false, 'VDrop',  false, 'GraphRep', true, 'Voltages', true, 'Nanowires', true, 'Lambda', false, 'Currents',true, 'Lyapunov', false, 'Conductance', true);
    axesLimits            = struct('dVCbar',[0; max(max(abs(sim.swV(1,:))))], 'CurrentArrowScaling',1e-2, 'LambdaCbar',[0; 0.15], 'ConCbar', [min(min(sim.swC)), max(max(sim.swC))]);
    snapshot = generateSnapshotFromData(sim.swV(i,:)', sim.swLam(i,:)', sim.swC(i,:)',  sim.Comp.critFlux, sim.Stim.Signal(i), sim.netC(i), i*sim.dt);
    %snapshot.Lyapunov = li;
    snapshotToFigureThesis(snapshot, sim.ContactNodes, Connectivity, whatToPlot, axesLimits, nds, edgs);
    set(gcf, 'visible','on')
    text(-3.2, 4.0, ['IV' newline 't = 55.0s'],'Color','w','FontSize',30);
    i = str2num(input('Enter i:   ', 's'));
end
myfig = gcf;
set(myfig,'color','w');
colorbar('hide');
myfig.InvertHardcopy = 'off'; 
%saveas(myfig, '/suphys/joelh/Documents/Honours/Project/Figures/Chapter5/networkWTA.png');
%saveas(myfig, '/suphys/joelh/Documents/Honours/Project/Figures/Chapter5/phaseI.png');
%saveas(myfig, '/suphys/joelh/Documents/Honours/Project/Figures/Chapter5/phaseII.png');
%saveas(myfig, '/suphys/joelh/Documents/Honours/Project/Figures/Chapter5/phaseIII.png');
saveas(myfig, '/suphys/joelh/Documents/Honours/Project/Figures/Chapter5/phaseIV.png');

%saveas(myfig, '/suphys/joelh/Documents/Honours/Project/Figures/Chapter5/inactiveV_dist.png');
%{
    - Fix colorbar so can see all junctions clearly
    - Fit to paper size - tick
    - Fix title size 
    PLAY AROUND WITH COLOUR BAR SO CAN SEE INACTIVE SWITCHES. SOURCE AND DRAIN BIGGER COLOR BAR AND HEADING BIGGER. FILL MORE SPACE ON THE SCREEN

%}



%% Conductance
figure;
tend = 80;
cmap = parula(10);

G0 = sim.Comp.onR;


%Ordered by activitation time

ordAct = [1,2,9,3,4,5,8,7,6];
spA = spE(ordAct);

hold on;



endI = timeVec(find((sim.swC(:,spE(1)) - sim.swC(1,spE(1)))./sim.swC(1,spE(1)) >= 0.01, 1));
CV = std(sim.swC(:,spE)')./mean(sim.swC(:,spE)');
[~, peakCV] = max(CV);
peakCV = timeVec(peakCV);
endII  = timeVec((CV < 2e-1) & timeVec > peakCV);
endII  = endII(1);
endIII = timeVec((CV == 0) & timeVec > endII);
endIII = endIII(1);

yy = 1e-4:1e-6:1.2;
semilogy(ones(size(yy))*endI   , yy, 'k-.','HandleVisibility','off');
semilogy(ones(size(yy))*endII  , yy, 'k-.','HandleVisibility','off');
semilogy(ones(size(yy))*endIII , yy, 'k-.','HandleVisibility','off');

text(endI/2.5, 0.5 , 'I','FontSize',16)
text((endI + endII)/2, 0.5 , 'II','FontSize',16)
text((endII*3 + endIII)/4, 0.5 , 'III','FontSize',16)
text((endIII + tend)/2, 0.5 , 'IV','FontSize',16)

for i = 9:-1:1
    semilogy(timeVec,sim.swC(:,spA(i))/G0, '-', 'Color', cmap(10-ordAct(i), :))
end




%{
    Layer 1 on top but first in legend
    Put regime partitioning
    https://au.mathworks.com/matlabcentral/answers/244707-how-to-change-order-of-legends

%}

xlabel 't (s)'
ylabel 'Switch Conductance (G_0)'
title('DC Activation: junctions along main current path')
set(gca, 'YScale', 'log')
ylim([1e-4,1.1])
set(gca,'XLim',[0,tend],'XTick',[0:5:80])
set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);
yyaxis right
semilogy(timeVec, 9*sim.netC/G0,'--','Linewidth',2.5, 'Color', 'r');
ylabel('Network Conductance (G_0/n)', 'Color','r')
set(gca,'YColor','red');
leg = [string(flip(ordAct)), 'net'];
myleg = legend(leg, 'location','southeast');
title(myleg, 'Junction #')
set(gca, 'YScale', 'log')
ylim([1e-4,1.1])
saveas(gcf, '~/Documents/Honours/Project/Figures/Chapter4/conductanceWithNet.png')






%% Voltage
figure;
tend = 80;
cmap = parula(10);

G0 = sim.Comp.onR;


%Ordered by activitation time

ordAct = [1,2,9,3,4,5,8,7,6];
spA = spE(ordAct);

hold on;

endI = timeVec(find((sim.swC(:,spE(1)) - sim.swC(1,spE(1)))./sim.swC(1,spE(1)) >= 0.01, 1));
CV = std(sim.swC(:,spE)')./mean(sim.swC(:,spE)');
[~, peakCV] = max(CV);
peakCV = timeVec(peakCV);
endII  = timeVec((CV < 2e-1) & timeVec > peakCV);
endII  = endII(1);
endIII = timeVec((CV == 0) & timeVec > endII);
endIII = endIII(1);

yy = 1e-4:1e-6:1;
semilogy(ones(size(yy))*endI   , yy, 'k-.','HandleVisibility','off');
semilogy(ones(size(yy))*endII  , yy, 'k-.','HandleVisibility','off');
semilogy(ones(size(yy))*endIII , yy, 'k-.','HandleVisibility','off');

text(endI/2.5, 0.5 , 'I','FontSize',16)
text((endI + endII)/2, 0.5 , 'II','FontSize',16)
text((endII*3 + endIII)/4, 0.5 , 'III','FontSize',16)
text((endIII + tend)/2, 0.5 , 'IV','FontSize',16)


for i = 9:-1:1
    semilogy(timeVec,abs(sim.swV(:,spA(i))), '-', 'Color', cmap(10-ordAct(i), :))
end




%{
    Layer 1 on top but first in legend
    Put regime partitioning
    https://au.mathworks.com/matlabcentral/answers/244707-how-to-change-order-of-legends

%}

xlabel 't (s)'
ylabel 'Switch Voltage (V)'
title('DC Activation: junctions along main current path')
set(gca, 'YScale', 'log')
set(gca,'XLim',[0,tend],'XTick',[0:5:80])
%ylim([1e-4,1.1])
set(findall(gca, 'Type', 'Line'),'LineWidth',1.5);
yyaxis right
semilogy(timeVec, 9*sim.netC/G0,'--','Linewidth',2.5, 'Color', 'r');
ylabel('Network Conductance (G_0/n)', 'Color','r')
set(gca,'YColor','red');
leg = [string(flip(ordAct)), 'net'];
myleg = legend(leg, 'location','southeast');
title(myleg, 'Junction #')
set(gca, 'YScale', 'log')
ylim([1e-4,1.1])

saveas(gcf, '~/Documents/Honours/Project/Figures/Chapter4/voltageWithNetC.png')
















%% Conductance
figure;
tend = 30;
cmap = parula(10);

hold on;
for i = 1:9
    semilogy(timeVec,sim.swC(:,spE(i)), '-', 'Color', cmap(10-i, :))
end
xlabel 't (s)'
ylabel 'Switch Conductance (S)'
title('DC Activation - junctions along main current path')
set(gca, 'YScale', 'log')
yyaxis right
semilogy(timeVec,9*sim.netC,'--','Linewidth',2, 'Color', 'r');
ylabel('Network Conductance (S)', 'Color','r')
set(gca,'YColor','red');
leg = [string(1:9), 'net'];
legend(leg, 'location','northwest');
xlim([0,tend])
set(gca, 'YScale', 'log')
% saveas(gcf, '~/Documents/Honours/Project/Talk/restOfFigures/conductanceWithNet.png')



%% 
figure;
imagesc(sim.swV >= 0);
%%
[~,I] = min(abs(sum(sim.swV >= 0 ,1) - sum(sim.swV < 0 ,1)))
