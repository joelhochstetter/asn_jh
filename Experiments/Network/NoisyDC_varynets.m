function NoisyDC_varynets(idx, saveFolder, netFolder)

    nets = dir(strcat(netFolder, '/*.mat'))';
    numNets = 100;
    netIdx = mod((idx-1), numNets) + 1; 
    Vidx    = floor((idx-1)/numNets) + 1;
    saveF1 = strcat(saveFolder, '/seed', num2str(netIdx - 1,'%03.f'), '/');
    mkdir(saveF1)

    %folders by network. Add a comment
    %add a resscale path length option
    NoisyDC_Vsweep_for_cluster(1, saveF1, 1.05*1e-2, 1.06*1e-2, 0.05*1e-2, connFile, 0 , '', -1, 1e5, 1e-2, 1, 0, 1)

end