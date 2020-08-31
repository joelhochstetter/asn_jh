%{
Example how to perform non-linear transformation task within protocol
%}

%% Non-linear transform paramaters
Amp = 2.0;
Frq = 0.5;
SigType = 'ACsaw';

%targets: square, sawtooth, 2f-sine, cosine
targetPhase = 0;
targetType  = SigType;


%% Simulation parameters
params = struct();

%%% Simulation options
params.SimOpt.useWorkspace    = false;
params.SimOpt.saveSim         = true;
params.SimOpt.takingSnapshots = false;
params.SimOpt.onlyGraphics    = false; %does not plot anything
params.SimOpt.compilingMovie  = false;
params.SimOpt.useParallel     = false;
params.SimOpt.hdfSave         = false;

%%% Stimulus
params.Stim.BiasType     = SigType;
params.Stim.Amplitude    = Amp; 
params.Stim.Frequency    = Frq;%1/20; 
params.SimOpt.T                = 5.0;
params.SimOpt.dt               = 1e-3;

%%% Components
params.Comp.ComponentType  = 'tunnelSwitch2'; %tunnelSwitch2
params.Comp.onConductance   = 7.77e-5;
params.Comp.offConductance  = 1e-8;
params.Comp.setVoltage     = 1e-2;
params.Comp.resetVoltage   = 1e-3;
params.Comp.criticalFlux   =  0.01;
params.Comp.maxFlux        = 0.015;
params.Comp.penalty        =  1;
params.Comp.boost          =  0;
params.Comp.nonpolar       = false;

%%% Connectivity


%% Run simulation
multiRun(params);
sim = multiImport(params);
sim = sim{1};
contacts = sim.ContactNodes;
timeVec = sim.Stim.TimeAxis;
connectivity = struct('filename', sim.ConnectFile);
connectivity = getConnectivity(connectivity);
swV = sim.swV; %extract junction voltages
nwV = zeros(size(swV,1), connectivity.NumberOfNodes);
for i = 1:size(swV, 1)
    nwV(i, :) = getAbsoluteVoltage(swV(i,:), connectivity, contacts);
end

%% Set-up target
%% triangular wave
targetStim = struct('Amplitude', Amp, 'Frequency', Frq, 'Phase', targetPhase, 'BiasType', 'ACsaw');
targetSOpt = struct('T', sim.T, 'dt', sim.dt);
target = getStimulus(targetStim, targetSOpt);

%%%
[weights, mse, rnmse, y] = NLT(target.Signal, nwV, 0);
figure;
plot(timeVec, target.Signal);
hold on;
plot(timeVec, y);
xlabel('t (s)');
ylabel('V (V)');
legend('target', 'result');
title(strcat('Triangular wave, acc = ', num2str((1-rnmse)*100, 3), '%'));


%% 2-frequency
targetStim = struct('Amplitude', Amp, 'Frequency', 2*Frq, 'Phase', targetPhase, 'BiasType', SigType);
targetSOpt = struct('T', sim.T, 'dt', sim.dt);
target = getStimulus(targetStim, targetSOpt);

%%%
[weights, mse, rnmse, y] = NLT(target.Signal, nwV, 0);
figure;
plot(timeVec, target.Signal);
hold on;
plot(timeVec, y);
xlabel('t (s)');
ylabel('V (V)');
legend('target', 'result');
title(strcat('Double frequency, acc = ', num2str((1-rnmse)*100, 3), '%'));


%% shifted out of phase
targetStim = struct('Amplitude', Amp, 'Frequency', Frq, 'Phase', pi/2, 'BiasType', SigType);
targetSOpt = struct('T', sim.T, 'dt', sim.dt);
target = getStimulus(targetStim, targetSOpt);

%%%
[weights, mse, rnmse, y] = NLT(target.Signal, nwV, 0);
figure;
plot(timeVec, target.Signal);
hold on;
plot(timeVec, y);
xlabel('t (s)');
ylabel('V (V)');
legend('target', 'result');
title(strcat('\pi/2 Out of phase, acc = ', num2str((1-rnmse)*100, 3), '%'));



%% sine wave
targetStim = struct('Amplitude', Amp, 'Frequency', Frq, 'Phase', targetPhase, 'BiasType', 'AC');
targetSOpt = struct('T', sim.T, 'dt', sim.dt);
target = getStimulus(targetStim, targetSOpt);

%%%
[weights, mse, rnmse, y] = NLT(target.Signal, nwV, 0);
figure;
plot(timeVec, target.Signal);
hold on;
plot(timeVec, y);
xlabel('t (s)');
ylabel('V (V)');
legend('target', 'result');
title(strcat('Sine wave, acc = ', num2str((1-rnmse)*100, 3), '%'));


%% square wave
targetStim = struct('AmplitudeOn', Amp, 'AmplitudeOff', -Amp, 'OffTime', 1/(2*Frq), 'Phase', targetPhase, 'BiasType', 'Square', 'Duty', 50.0);
targetSOpt = struct('T', sim.T, 'dt', sim.dt);
target = getStimulus(targetStim, targetSOpt);

%%%
[weights, mse, rnmse, y] = NLT(target.Signal, nwV, 0);
figure;
plot(timeVec, target.Signal);
hold on;
plot(timeVec, y);
xlabel('t (s)');
ylabel('V (V)');
legend('target', 'result');
title(strcat('Square wave, acc = ', num2str((1-rnmse)*100, 3), '%'));


