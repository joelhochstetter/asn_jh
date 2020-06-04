function multiCritAnalysis(importFolder, saveFolder, importMode, eventDetect, fitML, binSize)
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
    Gvals = {};
    Vvals = {};
    tvals = {};
    numFiles = 0;
    fname = {};
    filStates = {};
    
    switch importMode
        case 0 %simulated data
            sims = multiImport(struct('importAll', true));
            numFiles = numel(sims);
            for i = 1:numel(sims)
                Gvals{i} = sims{i}.netC;
                Vvals{i} = sims{i}.Stim.Signal;
                tvals{i} = sims{i}.Stim.TimeAxis;       
                fname{i} = sims{i}.filename;
            end
        case 1 %TDMS file, datatype of Adrian's file from labview
            files = dir(strcat(importFolder, '/*.tdms'));
            for file = files'
                ff = strcat(file.folder,'/',file.name);
                my_tdms_struct = TDMS_getStruct(ff);
                if isfield(my_tdms_struct,'Untitled')
                    if isfield(my_tdms_struct.Untitled,'Volt')
                        t = my_tdms_struct.Untitled.Time.data;
                        t = t - t(1);
                        I = my_tdms_struct.Untitled.Input.data;
                        [~, I] = fixDupTimes(t, I);

                        V = my_tdms_struct.Untitled.Volt.data;
                        [t1, V] = fixDupTimes(t, V); 
                        t = t1;
                        G = abs(I./V);
                        G(abs(V)< 1e-6) = NaN;
                    else
                        t = my_tdms_struct.Untitled.Time.data;
                        t = t - t(1);
                        I = my_tdms_struct.Untitled.Input.data;
                        [t, I] = fixDupTimes(t, I);
                        V = str2double(my_tdms_struct.Props.Source__V_or_A_)*ones(size(I));
                        G = abs(I./V);
                        G(abs(V)< 1e-6) = NaN;
                    end
                    
                    numFiles = numFiles + 1;
                    Gvals{numFiles} = G;
                    Vvals{numFiles} = V;
                    tvals{numFiles} = t;
                    fname{numFiles} = file.name;   
                end

            end
        case 2 %text file - rintaro data format
            files = dir('*.txt');
            for file = files'
                [t, I, V] = importCVRint(file.name);
                G = I./V;
                G(abs(V)< 1e-6) = NaN;
                numFiles = numFiles + 1;
                Gvals{numFiles} = G';
                Vvals{numFiles} = V';
                tvals{numFiles} = t';
                fname{numFiles} = file.name;   
            end 
    end
    
    
    %% Run event detection algorithm
    %{
        struct('method', 
    %}
    
    defEvDet.method = 'hybrid';
    defEvDet.window = 1;
    defEvDet.thresh = 5.0e-8; %threshold of form dG >= thr or dG./G >= thr
    defEvDet.k_std  = 0.0; %threshold of form dG >= k*std(dG) or dG./G = k*std(dG./G)
    defEvDet.k_mean = 0.0; %threshold of form dG >= k*mean(dG) or dG./G = k*mean(dG./G)
    defEvDet.relThresh = 0.01;
     
    fields = fieldnames(defEvDet);
    for i = 1:numel(fields)
        if isfield(eventDetect, fields{i}) == 0
            eventDetect.(fields{i}) = defEvDet.(fields{i});
        end
    end
    
    
    eventVals = {}; %events
    parfor i = 1:numFiles
        Gvals{i} = runningMean(Gvals{i}, eventDetect.window);
        G = Gvals{i};
        dG = abs(gradient(G));
        dG(isnan(dG)) = 0;
        events = zeros(size(dG));
        
        switch eventDetect.method 
            case 'threshold'
                dG = abs(dG);
                events = (dG >= eventDetect.thresh) & (dG >= k_std*std(dG)) & (dG >= k_mean*mean(dG));
            case 'ratioThreshold'
                dGG = abs(dG./G);
                events = (dGG >= eventDetect.thresh) & (dGG >= k_std*std(dGG)) & (dGG >= k_mean*mean(dGG));
            case 'hybrid'
                dG = abs(dG);
                dGG = abs(dG./G);
                events = (dGG >= eventDetect.relThresh) | (dG >= eventDetect.thresh);
            case 'stationaryPt'
                %find peaks, check bigger than threshold ratio
                dG = abs(dG);
                [pks, locs] = findpeaks(dG);
                events(locs(pks > eventDetect.thresh)) = true; 
                
            case 'kirchoff' %use kirchoff laws to estimate an event given network conductance.
                %to do
                events = zeros(size(dG));
        end
        eventVals{i} = events;
    end  
    
    
    
    %% Run criticality analysis
    critResults = cell(numFiles , 1);
    parfor i = 1:numFiles
        dt = (tvals{i}(end) - tvals{i}(1))/(numel(tvals{i}) - 1);
        critResults{i} = critAnalysis(eventVals{i}, dt, Gvals{i}, tvals{i}, Vvals{i}, fname{i}, strcat(saveFolder, '/', fname{i}, '/'), fitML, binSize);
    end
    save(strcat(saveFolder,'/critResults.mat'), 'numFiles', 'Gvals', 'Vvals', 'tvals', 'fname', 'critResults', 'eventDetect');

    
    %% Run analysis on joint sim, all the data in folder
%     Gmerge = mergeData(Gvals);
%     tmerge = mergeData(tvals, true);
%     Vmerge = mergeData(Vvals);   
%     emerge = mergeData(eventVals);
%     dt = (tmerge(end) - tmerge(1))/(numel(tmerge) - 1);
%     res = critAnalysis(emerge, dt, Gmerge, tmerge, Vmerge, 'merged', strcat(saveFolder, '/merged/'), fitML, binSize);
%     save(strcat(saveFolder,'merged.mat'), 'res', 'eventDetect');
    
    %% Run analysis on 'active' networks
    %% Run analysis on 'inactive' networks
    %% Run analysis on 'critical networks'


end