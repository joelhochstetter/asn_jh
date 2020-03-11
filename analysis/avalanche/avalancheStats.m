function [sizeAv, lifeAv] = avalancheStats(events, t)
%{
    Input:
        events (Nx1 array) - number of events at given time bin

    Avalanche defined such that events happen in subsequent time bins and
    no events happen in preceding and after time-bin

    A avalanches are recorded


    runMode = 1: use time-step
    runMode = 2: use time-vector to calculate IEI

    Output:
        sizeAv (Ax1 array) - number of events in given avalanche
        lifeAv (Ax1 array) - number of bins avalanche goes for 
       
%}


    if nargin == 1
        runMode = 1; %
    elseif nargin == 2
        runMode = 2;
    end
    
    
    avEdg  = find(events == 0); %edges for avalanches
    
    A      = numel(avEdg) - 1;    
    sizeAv = zeros(A,1);
    lifeAv = zeros(A,1);

    
    if runMode == 1
        for avId = 1:A
            sizeAv(avId) = sum(events(avEdg(avId):avEdg(avId+1)));
            lifeAv(avId) = avEdg(avId+1) - avEdg(avId) - 1;
        end   
    elseif runMode == 2
        for avId = 1:A
            sizeAv(avId) = sum(events(avEdg(avId):avEdg(avId+1)));
            lifeAv(avId) = t(avEdg(avId+1)) - t(avEdg(avId));
        end   
    end
    
    

    



end