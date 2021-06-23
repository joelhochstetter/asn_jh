function events =  findEvents(G, eventDetect, t)
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
    
    G = reshape(G, [numel(G), 1]);
    
    dG = abs(G(2:end) - G(1:end - 1));
    dG(isnan(dG)) = 0;
    dG = [dG; 0];
    
    events = zeros(size(dG));
    dG(dG < eventDetect.noiseFloor) = 0.0;
    
    if numel(dG) <= 5
        return
    end
    
    if nargin == 3
        dG = dG./gradient(t);
    end     
    
    switch eventDetect.method 
        case 'threshold'
            dG = abs(dG);
            events = (dG >= eventDetect.thresh) & (dG >= eventDetect.k_std*std(dG)) & (dG >= eventDetect.k_mean*mean(dG));
        case 'ratioThreshold'
            dGG = abs(calc_dx_x(G)); %method of calculating dx./x to treat forward and backward events on equal footing
            events = (dGG >= eventDetect.relThresh) & (dGG >= eventDetect.k_std*std(dGG)) & (dGG >= eventDetect.k_mean*mean(dGG));
        case 'hybrid'
            dG = abs(dG);
            dGG = abs(calc_dx_x(G)); %method of calculating dx./x to treat forward and backward events on equal footing
            events = (dGG >= eventDetect.relThresh) | (dG >= eventDetect.thresh);
        case 'stationaryPt'
            %find peaks, check bigger than threshold ratio
            %threshold ratio
            dGG =abs(calc_dx_x(G)); %method of calculating dx./x to treat forward and backward events on equal footing
            [pks, locs] = findpeaks(dGG);
            events(locs(pks > eventDetect.relThresh)) = true;             
            %threshold
            dG = abs(dG);
            [pks, locs] = findpeaks(dG);
            events(locs(pks > eventDetect.thresh)) = true;
        case 'thresholdPeak'
            dGG =calc_dx_x(G); %method of calculating dx./x to treat forward and backward events on equal footing
            
            % find crossing of threshold. Take peak from that sequence as event time.
            events = events + thresholdCrossingPeaks(dG, eventDetect.thresh);
            events = events + thresholdCrossingPeaks(-dG, eventDetect.thresh);
            events = events + thresholdCrossingPeaks(dGG, eventDetect.relThresh);
            events = events + thresholdCrossingPeaks(-dGG, eventDetect.relThresh);
            events = events > 0;
            
        case 'kirchoff' %use kirchoff laws to estimate an event given network conductance.
            %to do
            events = zeros(size(dG));
            
            
    end

    


end