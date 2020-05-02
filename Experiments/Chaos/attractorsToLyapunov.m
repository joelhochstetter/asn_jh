function attractorsToLyapunov(idx, numAtt, attractorFolder, lyFolder)
    %convert idx to attIdx and runIdx
    %1-numAtt is jn 1, numAtt+1:2*numAtt for jn 2
    attIdx  = mod(idx,numAtt);
    attIdx(attIdx ==0) = numAtt;

    runIdx = ceil(idx/numAtt);
    
    addpath(genpath(attractorFolder));    
    files = dir(strcat(attractorFolder, '/*.mat'));
    
    calcLyapunovV5(0, runIdx, attractorFolder, files(attIdx).name, lyFolder, 0)

end