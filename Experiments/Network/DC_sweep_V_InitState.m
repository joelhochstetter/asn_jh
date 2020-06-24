function DC_sweep_V_InitState(idx, saveFolder, numInitStates, Gmin, Gmax, initStateFile, initStateFolder) 
    
    Gidx = mod((idx-1), numInitStates) + 1; 
    Vidx    = floor((idx-1)/numInitStates) + 1;
     initCon = 10.^linspace(log10(Gmin), log10(Gmax), numInitStates);
    
    netName = '2016-09-08-155153_asn_nw_00100_nj_00261_seed_042_avl_100.00_disp_10.00.mat';
    DC_Vsweep_for_cluster(Vidx, saveFolder, 0.5*0.01*9, 3.0*0.01*9, 0.025*0.01*9, netName, initStateFile , initStateFolder, -1, 800, false, false, initCon(Gidx))
     
end