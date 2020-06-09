function DC_sim_vary_nets(idx, netFolder, saveFolder) 
    
    nets = dir(strcat(netFolder, '/*.mat'))';
    numNets = 100;
    netIdx = mod((idx-1), numNets) + 1; 
    Vidx    = floor((idx-1)/numNets) + 1;
    saveF1 = strcat(saveFolder, '/seed', num2str(netIdx - 1,'%03.f'), '/');
    mkdir(saveF1)
    DC_Vsweep_for_cluster(Vidx, saveF1, 45*0.25*0.01, 45*2.00*0.01, 45*0.25*0.01, nets(netIdx).name, 0 , '.', 45)
    
    
end