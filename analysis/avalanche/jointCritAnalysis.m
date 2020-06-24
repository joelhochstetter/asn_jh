function jointCritAnalysis(importFolder, saveFolder, importMode, eventDetect, fitML, binSize)
%{
    Looks through data and performs a criticality analysis on all files in
    the folder. This works for experimental data and simulated data
    
    Inputs:
        importFolder (string) or cell: folder to extract data from. If
            enter a cell then loops over all folders
        saveFolder (string): name of where to save.  e.g. 'avalancheAnalysis'
        importMode (int): 0 = simulation file, 1 = TDMS file, 2 = text file   
        eventDetect (how to do the event detection): struct:
            bareThreshold, dG./G threshold, peaks of dG/dt with appropriate
            smoothing, peaks with a 'refractory period'
            'method' = 'threshold', 'ratioThreshold', 'stationaryPt'
            'window' = running a running window mean


%}         

    %% Set-up
    mkdir(saveFolder)
    
    if ~iscell(importFolder)
        importFolder = {importFolder};
    end
    
    %% Process files and extract G, V, t
    Gjoin = [];
    tjoin = [0];
    Vjoin = [];
    fname = 'joint folders:';
    
    
    numFolders = numel(importFolder);
    for j = 1:numFolders
        numFiles = howManyFiles(importMode, importFolder{j});
        fname = strcat(fname, importFolder{j}, ',');
        for i = 1:numFiles
            %import file
            [G, V, t, ~] = importByType(importMode, importFolder{j}, i);
            t = t + tjoin(end);
            tjoin = [tjoin, t];
            Gjoin = [Gjoin, G];
            Vjoin = [Vjoin, V];         
        end
    end
    
    %cut off initial zero
    tjoin = tjoin(2:end);
    
    % detect events
    events =  findEvents(Gjoin, eventDetect);
    if numel(tjoin) == 0
       disp('a') 
    end
    dt = (tjoin(end) - tjoin(1))/(numel(tjoin) - 1);
    
    %perform criticality analysis
    critAnalysis(events, dt, Gjoin, tjoin, Vjoin, fname, strcat(saveFolder, '/'), fitML, binSize);

    
end