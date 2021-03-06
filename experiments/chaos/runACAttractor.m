function runACAttractor(Amps, Freqs, dt, T, attractorFolder)
%   Inputs:
%       Amps (vector of doubles): Amplitudes (in volts) on AC triangular signals
%       Freqs (vector of doubles): Frequency (in Hz) on AC triangular signals
%       dt (double): time-step
%       T (double):  Length of simulation.
%               Need to ensure T*Freqs is an integer (integer number of periods
%               Need to manually check convergence of each attractor by
%               plotting G-V (or I-V curves). Otherwise increase T.
%       attractorFolder (string): name of folder to save attractors to
%
%
%  Outputs: 
%       Saves simulation files for each attractor
%
% Written by: Joel Hochstetter


    %% Initialise simulation paramaters
    params = struct();

    % Set Simulation Options
    params.SimOpt.saveSim         = true;
    params.SimOpt.useParallel     = false; %can set to true to allow parallel processing
    params.SimOpt.hdfSave         = true;  %saves junction parameters to a 'hdf5' file
    params.SimOpt.saveSwitches         = true; %to save memory set this to false and "hdfSave" to false
    params.SimOpt.stopIfDupName = true; %this parameter only runs simulation if the savename is not used.
    params.SimOpt.T                = T; %length of the simulation in seconds
    params.SimOpt.dt               = dt; %time step

    %Set Stimulus
    params.Stim.BiasType     = 'ACsaw'; % 'DC' \ 'AC' \ 'DCandWait' \ 'Ramp' \ 'ACsaw'
    params.Stim.Amplitude    = Amps; 
    params.Stim.Frequency    = Freqs; 

    params.SimOpt.saveFolder = attractorFolder;
    
    %Set Components paramaters
    params.Comp.ComponentType  = 'tunnelSwitchL'; %Set switch model
    params.Comp.onConductance   = 7.77e-5;
    params.Comp.offConductance  = 7.77e-8;
    params.Comp.setVoltage       = 1e-2;
    params.Comp.resetVoltage   = 1e-2;
    params.Comp.criticalFlux   =  0.01;
    params.Comp.maxFlux        = 0.015;
    params.Comp.penalty        =    1;
    params.Comp.boost          =  10;

    %% Run simulations
    multiRun(params);
    
end