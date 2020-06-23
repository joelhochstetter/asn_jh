function totalCritAnalysis(baseFolder, subfolders, importMode, fitML, ncpu, whatMethods, Gthresh, relthresh, noisefloor)
%{
Given a base folder and subfolders:
- Runs criticality analysis of each file from subfolder (either .mat,
    .tdms, .txt)
- Runs joint criticality analysis on each subfolder
- Runs joint criticality analysis on all data combined
- methods is a vector [1,1,1] means run all. [1,0,0] is just threshold
%}
    cd(baseFolder);
    
    if ~iscell(subfolders)
        subfolders = {subfolders};
    end

    methods = {'threshold', 'ratioThreshold', 'hybrid'};
    methods = methods(whatMethods);
    
    eventDetect = struct();
    eventDetect.thresh     = Gthresh;
    eventDetect.relThresh  = relthresh;
    eventDetect.noiseFloor = noisefloor;       
    
    for j = 1:numel(methods)
        for i = 1:numel(subfolders)
            eventDetect.method = methods{j};

            importFolder = strcat(baseFolder, '/', subfolders{i});
            saveFolder = strcat('Avalanche_', num2str(methods{j}), '_Gt', num2str(eventDetect.thresh), '_rt', num2str(eventDetect.relThresh), '_nf', num2str(eventDetect.noiseFloor));
            multiCritAnalysis(importFolder, saveFolder, importMode, eventDetect, fitML, -1, ncpu)
            cd(baseFolder)
            saveFolder = strcat('Avalanche_Joint_', num2str(methods{j}), '_Gt', num2str(eventDetect.thresh), '_rt', num2str(eventDetect.relThresh), '_nf', num2str(eventDetect.noiseFloor));        
            jointCritAnalysis(importFolder, saveFolder, importMode, eventDetect, fitML, -1);
        end
        cd(baseFolder)
        saveFolder = strcat('Avalanche_Joint_', num2str(methods{j}), '_Gt', num2str(eventDetect.thresh), '_rt', num2str(eventDetect.relThresh), '_nf', num2str(eventDetect.noiseFloor));
        jointCritAnalysis(subfolders, saveFolder, importMode, eventDetect, fitML, -1);
    end




end