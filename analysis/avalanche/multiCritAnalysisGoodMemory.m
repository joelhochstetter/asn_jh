function multiCritAnalysisGoodMemory(importFolder, saveFolder, importMode, eventDetect, fitML, binSize)
%{
    Looks through data and performs a criticality analysis on all files in
    the folder. This works for experimental data and simulated data
    
    Inputs:
        importFolder (string): folder to extract data from
        saveFolder (string): name of where to save.  e.g. 'avalancheAnalysis'
        importMode (int): 0 = simulation file, 1 = TDMS file, 2 = text file   
        eventDetect (how to do the event detection): struct:
            bareThreshold, dG./G threshold, peaks of dG/dt with appropriate
            smoothing, peaks with a 'refractory period'
            'method' = 'threshold', 'ratioThreshold', 'stationaryPt'
            'window' = running a running window mean


%}          

    %% Set-up
    cd(importFolder)
    mkdir(saveFolder)
    
    
    %% Process files and extract G, V, t
    numFiles = howManyFiles(importMode, importFolder);
    parfor i = 1:numFiles
        %import file
        [G, V, t, fname] = importByType(importMode, importFolder, idx);
         dt = (t(end) - t(1))/(numel(t) - 1);
   
        % detect events
        events =  findEvents(G, eventDetect);
        
        %perform criticality analysis
        critAnalysis(events, dt, G, t, V, fname, strcat(saveFolder, '/', fname, '/'), fitML, binSize);
    end
       
   
end