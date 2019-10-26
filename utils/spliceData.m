function simOut = spliceData(sim, olddt, newdt)
    %Takes data and skips timesteps to set consistent with a certain length
    
    splice = newdt/olddt;
    
    els =  1:splice:numel(sim.netC);
    
    
    
    simOut = sim;
    simOut.netC = sim.netC(els);
    simOut.netI = sim.netI(els);
    simOut.Stim.Signal = sim.Stim.Signal(els);
    simOut.Stim.TimeAxis = sim.Stim.TimeAxis(els);    
 
    simOut.swV = sim.swV(els,:);
    simOut.swC = sim.swC(els,:);    
    simOut.swLam = sim.swLam(els,:);    
    
    simOut.dt = newdt;
    
end