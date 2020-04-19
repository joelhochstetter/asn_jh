function [dur, size_t, time_t] = avalancheShape(events)
%{
    Input:
        events (Nx1 array) - number of events at given time bin

    Avalanche defined such that events happen in subsequent time bins and
    no events happen in preceding and after time-bin

    A avalanches are recorded

    Output:
        dur (Nx1 array) - each unique avalanche duration
        size_t (Nx1 cell) - average avalanche size as a function of time
                              for each unique duration. Each element is a
                              time-series vector
        time_t (Nx1 cell) - stores the time vectors for the duration of
                              each event in the analysis
       
%}

    avEdg  = find(events == 0); %edges for avalanches   
    A = numel(avEdg) - 1;
    lifeAv = zeros(A,1);
    
    for avId = 1:A
        lifeAv(avId) = avEdg(avId+1) - avEdg(avId) - 1;
    end   
    
    dur = unique(lifeAv(lifeAv > 0), 'sorted');
    N   = numel(dur); 
    
    size_t = cell(N,1);
    time_t = cell(N,1);
    
    %make time vectors
    for i = 1:N
        time_t{i} = 0:(dur(i) + 1); %duration + timesteps before and after
    end
    
    
    %make average event at each time point
    for i = 1:N %loop over event durations
        size_t{i} = zeros(dur(i) + 2,1);
        avIDs = find(lifeAv == dur(i)); %get the avalanche IDs
        nRelv = numel(avIDs); %Number of relevant avalanches
        
        for j = 1:(dur(i) + 2) %loop over size of avalanche            
            for k = 1:nRelv %loop over the relevant avalanches
                if avEdg(avIDs(k)) + j - 1 > numel(events)
                    break;
                end
                size_t{i}(j) = size_t{i}(j) + events(avEdg(avIDs(k)) + j - 1);
            end
        end
        size_t{i} = size_t{i}/nRelv; %convert sum to average
    end
    
    
   


end