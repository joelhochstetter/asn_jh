function simOut = chopData(sim, length)
    %Chops length number of timesteps for each time series data
    simOut = sim;
    simOut.T = simOut.T * length/numel(simOut.netC);
    simOut.netC = sim.netC(1:length);
    simOut.netI = sim.netI(1:length);
    simOut.Stim.Signal = sim.Stim.Signal(1:length);
    simOut.Stim.TimeAxis = sim.Stim.TimeAxis(1:length);    
 
    simOut.swV = sim.swV(1:length,:);
    simOut.swC = sim.swC(1:length,:);    
    simOut.swLam = sim.swLam(1:length,:);    
    

end