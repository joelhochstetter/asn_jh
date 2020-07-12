function DC_Vsweep_change_PathLength(idx, saveFolder,connFile) 
    for contactDistance = 5:15:65
        saveF1 = strcat(saveFolder, '/sd', num2str(contactDistance));
        mkdir(saveF1)
        DC_Vsweep_for_cluster(idx, saveF1, 1e-2*0.5, 1e-2*3.0, 1e-2*0.05, connFile, 0 , '', contactDistance, 800, 0, true, 0)
    end

end