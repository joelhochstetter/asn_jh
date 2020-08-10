function AC_sim_vary_nets(idx, netFolder, saveFolder, Amps, Freqs) 
    %{
        Example usage:
            AC_sim_vary_nets($PBS_ARRAY_INDEX, 'networks/Lx150Ly150/', 'simulations/ACavalanches/', 5, 0.25:0.25:1.0) 
            AC_sim_vary_nets(1, '/import/silo2/joelh/Criticality/Avalanche/BigNetwork/Lx150Ly150/', 'test', 5, 0.25:0.25:1.0) 

    %}

    numNets = 50;
    netIdx = mod((idx-1), numNets) + 1; 
    connFile = dir(strcat(netFolder, '/*seed_', num2str(netIdx - 1,'%03.f'), '*.mat'))';
    connFile = connFile.name;
    StimIdx    = floor((idx-1)/numNets) + 1;
    saveF1 = strcat(saveFolder, '/seed', num2str(netIdx - 1,'%03.f'), '/');
    mkdir(saveF1)
    
    attractorForCluster(StimIdx, saveF1, -1, 'ACsaw', Amps, Freqs, 0 , -1, 1e-3, 100, connFile, true, 45)

end