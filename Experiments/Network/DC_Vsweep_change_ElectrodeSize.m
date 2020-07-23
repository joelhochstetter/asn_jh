function DC_Vsweep_change_ElectrodeSize(idx,netFolder, saveFolder, Vidx) 
    xElect = 0.2:0.2:1.0;
    numSeeds = 500;
    seedIdx  = mod((idx-1), numSeeds) + 1;
    XEidx    = floor((idx-1)/numSeeds) + 1;
    disp(strcat('Seed idx: ', num2str(seedIdx), ', xe idx: ', num2str(XEidx)));
    saveF1 = strcat(saveFolder, '/seed', num2str(seedIdx - 1,'%03.f'), '/');
    mkdir(saveF1)
    nets = dir(strcat(netFolder, '/*_seed_', num2str(seedIdx - 1,'%03.f'), '*.mat'))';
    connFile = nets(1).name;
    
    for i = XEidx %1:numel(cds)
        xFrac = xElect(i);
        nameComment = strcat('_XE', num2str(xElect(i)));
        DC_Vsweep_for_cluster(Vidx, saveF1, 1e-2*1.05,  1e-2*1.05, 1e-2*0.05, connFile, 0 , '', -1, 30, true, 1, -1, 1, 1, 0.015, nameComment, xFrac)
    end
    
end