function [sizeAv, lifeAv] = avalancheStats(events)
%{
    Input:
        events (Nx1 array) - number of events at given time bin

    Avalanche defined such that events happen in subsequent time bins and
    no events happen in preceding and after time-bin

    A avalanches are recorded

    Output:
        sizeAv (Ax1 array) - number of events in given avalanche
        lifeAv (Ax1 array) - number of bins avalanche goes for 
       
%}

    avEdg  = find(events == 0); %edges for avalanches
    
    A      = numel(avEdg) - 1;    
    sizeAv = zeros(A,1);
    lifeAv = zeros(A,1);
    
    for avId = 1:A
        sizeAv(avId) = sum(events(avEdg(avId):avEdg(avId+1)));
        lifeAv(avId) = avEdg(avId+1) - avEdg(avId) - 1;
    end


end