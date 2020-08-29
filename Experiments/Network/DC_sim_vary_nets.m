function DC_sim_vary_nets(idx, netFolder, saveFolder, usePoint, saveEvents) 

    if nargin < 5
        saveEvents = true;
    end

    numNets = 100;
    netIdx = mod((idx-1), numNets) + 1; 
    Vidx    = floor((idx-1)/numNets) + 1;
    seed = netIdx - 1;
    nets = dir(strcat(netFolder, '/*_seed_', num2str(seed,'%03.f'), '*.mat'))';
    netName = nets(1).name;
    saveF1 = strcat(saveFolder, '/seed', num2str(seed,'%03.f'), '/');
    mkdir(saveF1)
    
    %DC_Vsweep_for_cluster(Vidx, saveF1, 1.05*0.01, 1.08*0.01, 0.25*0.01, nets(netIdx).name, 0 , '.', -1, 30, true, true, -1, 1, true, 0.015)
%      DC_Vsweep_for_cluster(Vidx, saveF1, 45*5*0.01, 2.5, 1.0, nets(netIdx).name, 0 , '.', 45, 10, 0)
    if usePoint
        DC_Vsweep_for_cluster(Vidx, saveF1,0.50*0.01,2.00*0.01,0.25*0.01, netName,0, '.', 45,50,true,true,-1,1,false,0,'',0,true)
    else
%         DC_Vsweep_for_cluster(Vidx, saveF1, 0.7*0.01, 1.8*0.01, 0.1*0.01, nets(netIdx).name, 0 , '.', -1, 30, true, true, -1, 1, true, 0.015, '', 1, true); 
        DC_Vsweep_for_cluster(Vidx, saveF1, 1.05*0.01, 1.1*0.01, 0.1*0.01, netName, 0 , '.', -1, 30, true, true, -1, 1, true, 0.015, '', 1, saveEvents); 
    end
%     DC_Vsweep_for_cluster(Vidx, saveF1, 45*1.25*0.01, 45*1.25*0.01, 45*0.25*0.01, nets(netIdx).name, 0 , '.', 45, 1000, 0)
     
end