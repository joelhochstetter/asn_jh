function NoisyDC_varynets(idx, saveFolder, netFolder, Vidx)

    numSeeds = 1;
    numL     = 5;
    seedIdx  = mod((idx-1), numSeeds) + 1;
    Lidx     = floor((idx-1)/numSeeds) + 1;
    L = 40:10:80;

    nets = dir(strcat(netFolder, '/asn*_seed_', num2str(seedIdx - 1,'%03.f'), '*_lx_', num2str(L(Lidx)), '*.mat'))';
    connFile = nets(1).name;
    saveF1 = strcat(saveFolder, '/seed', num2str(seedIdx - 1,'%03.f'), '/');
    mkdir(saveF1)

    nameComment = strcat('_L', num2str(L(Lidx)), '_s', num2str(seedIdx - 1,'%03.f'));
    
    %folders by network. Add a comment
    %add a resscale path length option
    NoisyDC_Vsweep_for_cluster(Vidx, saveF1, 1.00*1e-2, 1.01*1e-2, 0.01*1e-2, connFile, 0 , '', -1, 1e4, 5e-3, 1, true, true, nameComment)

end