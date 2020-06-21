function [ieiData, ieiTimes] = IEI(events, dt, t, joinperiod)
%{
    Calculates inter-event interval given  binarised
    time-series data and time-step
    Other option is to give the IEI times. Then the IEI is calculated in
    seconds
    joinperiod: for time series which join an ensemble of
    different simulations stores periodicity so ignores events calculated 
    between adjacent simulations

    runMode = 1: use time-step
    runMode = 2: use time-vector to calculate IEI

%}

    if nargin == 2
        runMode = 1; %
    else
        runMode = 2;
    end
    
    if nargin < 4
        joinperiod = -1;        
    end
    
    if joinperiod == -1
        joinperiod = numel(events) + 1;
    end
        
    ieiData   = [];
    ieiTimes  = [];
    ieiIdx    = 1;
    prevEvent = find(events, 1);
    
    if runMode == 1
        for i = (prevEvent + 1):numel(events)
            if events(i)
                if mod(i-1, joinperiod) == mod(prevEvent-1, joinperiod)
                    ieiData(ieiIdx) = i - prevEvent;
                    ieiIdx = ieiIdx + 1;
                end
                prevEvent = i;
            end
        end

        ieiData = ieiData*dt;
    elseif runMode == 2
        for i = (prevEvent + 1):numel(events)
            if events(i)
                if mod(i-1, joinperiod) == mod(prevEvent-1, joinperiod)
                    ieiData(ieiIdx)  = i - prevEvent;
                    ieiTimes(ieiIdx) = t(i) - t(prevEvent); 
                    ieiIdx = ieiIdx + 1;
                end
                prevEvent = i;                
            end
        end        
        ieiData  = ieiData(ieiTimes > 0);
        ieiTimes = ieiTimes(ieiTimes > 0);
        
    end

end