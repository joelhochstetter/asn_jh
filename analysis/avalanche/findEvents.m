function events =  findEvents(G, eventDetect)
    defEvDet.method = 'hybrid';
    defEvDet.window = 1;
    defEvDet.thresh = 5.0e-8; %threshold of form dG >= thr or dG./G >= thr
    defEvDet.k_std  = 0.0; %threshold of form dG >= k*std(dG) or dG./G = k*std(dG./G)
    defEvDet.k_mean = 0.0; %threshold of form dG >= k*mean(dG) or dG./G = k*mean(dG./G)
    defEvDet.relThresh = 0.01;
    defEvDet.noiseFloor = 5e-10;     
    
    fields = fieldnames(defEvDet);
    for i = 1:numel(fields)
        if isfield(eventDetect, fields{i}) == 0
            eventDetect.(fields{i}) = defEvDet.(fields{i});
        end
    end
    dG = abs(gradient(G));
    dG(isnan(dG)) = 0;
    events = zeros(size(dG));
    dG(dG < eventDetect.noiseFloor) = 0.0;
    
    switch eventDetect.method 
        case 'threshold'
            dG = abs(dG);
            events = (dG >= eventDetect.thresh) & (dG >= eventDetect.k_std*std(dG)) & (dG >= eventDetect.k_mean*mean(dG));
        case 'ratioThreshold'
            dGG = abs(dG./G);
            events = (dGG >= eventDetect.relThresh) & (dGG >= eventDetect.k_std*std(dGG)) & (dGG >= eventDetect.k_mean*mean(dGG));
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

    


end