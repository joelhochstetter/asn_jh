function DC_sweep_vary_netsVG(idx, netFolder, saveFolder) 
    
    nets = dir(strcat(netFolder, '/*.mat'))';
    numNets = 25;
    netIdx = mod((idx-1), numNets) + 1; 
    Vidx    = floor((idx-1)/numNets) + 1;
    saveF1 = strcat(saveFolder, '/NWN', nets(netIdx).name, '/');
    mkdir(saveF1)
%     DC_Vsweep_for_cluster(Vidx, saveF1, 45*1.25*0.01, 45*1.25*0.01, 45*0.25*0.01, nets(netIdx).name, 0 , '.', 45)
%      DC_Vsweep_for_cluster(Vidx, saveF1, 45*5*0.01, 2.5, 1.0, nets(netIdx).name, 0 , '.', 45, 10, 0)
 %    DC_Vsweep_for_cluster(Vidx, saveF1, 45*0.25*0.01, 45*2.00*0.01, 45*0.25*0.01, nets(netIdx).name, 'tl_T10_DC2.25V_s0.01_r0.005_c0.01_m0.015_b2_p1.mat', saveF1, 45, 45, 1)
    DC_Vsweep_for_cluster(Vidx, saveF1, 0.5*0.01, 2.0*0.01, 0.02*0.01, nets(netIdx).name, 0 , '.', -1, 800, false, true, 0, 1, false, 0, '', 0, false);     
     
end