function Noisy_DC_change_PathLength(idx, saveFolder,connFile)
    cds = 5:15:65;
    N = numel(cds);
    cdidx = mod((idx-1), N) + 1; 
    Vidx    = floor((idx-1)/N) + 1;    
    for i = cdidx %1:numel(cds)
        contactDistance = cds(i);
        saveF1 = strcat(saveFolder, '/sd', num2str(contactDistance), '/');
        mkdir(saveF1)
        NoisyDC_Vsweep_for_cluster(Vidx, saveF1, 1e-2*1,  1e-2*1.05, 1e-2*0.05, connFile, 0 , '', contactDistance, 1e4, 5e-3, 1, 0, 1)
    end

end