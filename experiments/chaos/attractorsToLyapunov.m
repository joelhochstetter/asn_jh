function attractorsToLyapunov(idx, numAtt, attractorFolder, lyFolder, runMode)
    %{
        runMode = 0 one for every file
        runMode = 1, enter idx = 1:E where E is number of particles
    %}

    if nargin == 4
        runMode = 0;
    end
    
    addpath(genpath(attractorFolder));
    files = dir(strcat(attractorFolder, '/*.mat'));
    
    if runMode == 0
        %convert idx to attIdx and runIdx
        %1-numAtt is jn 1, numAtt+1:2*numAtt for jn 2
        attIdx  = mod(idx,numAtt);
        attIdx(attIdx ==0) = numAtt;
        runIdx = ceil(idx/numAtt);
        %calc
        calcLyapunovV5(0, runIdx, attractorFolder, files(attIdx).name, lyFolder, 0)
    elseif runMode == 1 %each index corresponds to a perturbed junction
        for attIdx = 1:numAtt
            disp(strcat('Attractor: ', files(attIdx).name, ', idx: ', num2str(idx)));
            calcLyapunovV5(0, idx, attractorFolder, files(attIdx).name, lyFolder, 0)
        end            
    elseif runMode == 2 %each index corresponds to one attractor:
        calcLyapunovV5(0, -1, attractorFolder, files(idx).name, lyFolder, 0)
    end
    
end