%% Initialise simulation paramaters
params = struct();

% Set Simulation Options
params.SimOpt.saveSim         = true;
params.SimOpt.hdfSave         = true; %saves files in hdf file format
params.SimOpt.T                = 200.0; %length of the simulation
params.SimOpt.dt               = 1e-3; %time step

%Set Stimulus
params.Stim.BiasType     = 'ACsaw'; % 'DC' \ 'AC' \ 'DCandWait' \ 'Ramp' \ 'ACsaw'
params.Stim.Amplitude    = 2; 
params.Stim.Frequency    = 0.5; 

%Set Components paramaters
params.Comp.ComponentType  = 'tunnelSwitch2'; %Set switch model
params.Comp.onResistance   = 7.77e-5;
params.Comp.offResistance  = 1e-8;
params.Comp.setVoltage     = 1e-2;
params.Comp.resetVoltage   = 1e-3;
params.Comp.criticalFlux   =  0.1;
params.Comp.maxFlux        = 0.15;
params.Comp.penalty        =    1;
params.Comp.boost          =  10;

%% Run simulations with the ASN paramaters
multiRun(params);

%% Import parameters
sim = multiImport(params);
sim = sim{1}; %Only one simulation


%% Plot simulations to determine attractor
numT = params.Stim.Frequency/params.SimOpt.dt; %Number of time-steps in one period
I1 = sim{1}.netI(1:round(numT*50)); %Current for first 50 periods
V1 = sim{1}.Stim.Signal(1:round(numT*50)); %Voltage for first 50 periods
I2 = sim{1}.netI(round(numT*50) + 1:end); %Current for last 50 periods
V2 = sim{1}.Stim.Signal(round(numT*50) + 1:end); %Voltage for last 50 periods 

figure;
semilogy(V1, abs(I1), 'r');
hold on;
semilogy(V2, abs(I2), 'b');
xlabel('V (V)');
ylabel('I (A)');
legend('First 50 periods', 'Second 50 periods');

%If the red curve is fully enclosed in or overlaps the blue curve
%a tolerance of 1% is allowed
%then we say an attractor is reached
%Else repeat this process