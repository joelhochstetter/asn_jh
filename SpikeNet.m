%% Key paramaters
T  = 100;
dt = 1e-3;
tV = 10; %pulse width in units of dt
hV = 0.05; %pulse height in Volts
wV = 40;  %average inter-event-interval: from triggering of event to triggering of next event
nSc = 5; %number of sources
nDn = 5; %number of drains
N    = 100;
cSd = 1; %contact seed
sSd = 2; %stimulus seed


%% Convert to signals
rng(sSd)
nTsteps = round(T/dt);
Signals = zeros(nTsteps, nSc + nDn);

for i = 1:nSc
    s0 = round(cumsum(exprnd(wV, nTsteps,1))); %spike
    s1 = s0 + [1:tV]; %full spike
    Signals(s1(:), i) = hV;
end

%% Plot input spike trains
timeVector = dt*[1:nTsteps];
figure;
imagesc(timeVector, 1:nSc, Signals(:, 1:nSc)');
xlabel('t (s)')
ylabel('sources')


%% Select contacts
rng(cSd)
ContactNodes = randperm(N, nSc + nDn);
src = ContactNodes(1:nSc);
drn = ContactNodes(nSc + 1:end);

%% Plot sources and drains
figure;
h = plot(graph(adj_matrix), 'XData', xc, 'YData', yc, 'NodeLabel', {}); 
highlight(h, src,'NodeColor','g', 'Marker', 'p', 'MarkerSize', 12)
highlight(h, drn,'NodeColor','r', 'Marker', 'p', 'MarkerSize', 12)
axis equal; 
axis off;


%% Source-drain distances:
sdD = distances(graph(adj_matrix), src, drn);
figure;
histogram(sdD)
xlabel('source-drain distance')
ylabel('count')
mean(sdD(:))


%% Set-up simulations
params = struct();

% Set Simulation Options
params.SimOpt.useWorkspace    = true;
params.SimOpt.saveSim         = true;
params.SimOpt.takingSnapshots = true;
params.SimOpt.onlyGraphics    = false; %does not plot anything
params.SimOpt.compilingMovie  = false;
params.SimOpt.useParallel     = false;
params.SimOpt.hdfSave         = false;

params.SimOpt.T                =  T;
params.SimOpt.dt               = dt;

%Set Stimulus
params.Stim.BiasType = 'Custom'; 
params.Stim.Signal      =  Signals;

%Set Components
params.Comp.ComponentType  = 'tunnelSwitchL';
params.Comp.offResistance       = 7.77e-8;
params.Comp.setVoltage            = 1e-2;
params.Comp.resetVoltage         = 5e-3;
params.Comp.criticalFlux             = 0.01;
params.Comp.maxFlux                 = 0.015;
params.Comp.penalty                  = 1;
params.Comp.boost                    = 10;
params.Comp.nonpolar               = true;
params.Comp.filamentState        = 0;

%Set contacts
params.SimOpt.ContactMode = 'preSet';
params.SimOpt.ContactNodes = [src, drn];

%Set connectivity
params.Conn.filename = '2016-09-08-155153_asn_nw_00100_nj_00261_seed_042_avl_100.00_disp_10.00.mat';


%%
sims = multiRun(params);