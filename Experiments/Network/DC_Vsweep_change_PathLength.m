function DC_Vsweep_change_PathLength(idx,netFolder, saveFolder, Vidx) 
    cds = 5:10:45;
    numSeeds = 100;
    seedIdx  = mod((idx-1), numSeeds) + 1;
    cdidx    = floor((idx-1)/numSeeds) + 1;
    disp(strcat('Seed idx: ', num2str(seedIdx), ', cd idx: ', num2str(cdidx)));
    saveF1 = strcat(saveFolder, '/seed', num2str(seedIdx - 1,'%03.f'), '/');
    mkdir(saveF1)
    nets = dir(strcat(netFolder, '/*_seed_', num2str(seedIdx - 1,'%03.f'), '*.mat'))';
    connFile = nets(1).name;
    
    for i = cdidx %1:numel(cds)
        contactDistance = cds(i);
        nameComment = strcat('_sd', num2str(contactDistance));
        DC_Vsweep_for_cluster(Vidx, saveF1, 1e-2*1.05,  1e-2*1.05, 1e-2*0.05, connFile, 0 , '', contactDistance, 0.01, true, 1, -1, 1, 0, 0, nameComment)
    end
    
end