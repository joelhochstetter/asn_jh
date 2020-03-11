function [ieiData, ieiTimes] = IEI(events, dt, t)
%{
    Calculates inter-event interval given  binarised
    time-series data and time-step
    Other option is to give the IEI times. Then the IEI is calculated in
    seconds

    runMode = 1: use time-step
    runMode = 2: use time-vector to calculate IEI

%}

    if nargin == 2
        runMode = 1; %
    elseif nargin == 3
        runMode = 2;
    end

    ieiData   = [];
    ieiTimes  = [];
    ieiIdx    = 1;
    prevEvent = find(events, 1);
    
    if runMode == 1
        for i = (prevEvent + 1):numel(events)
            if events(i)
                ieiData(ieiIdx) = i - prevEvent;
                prevEvent = i;
                ieiIdx = ieiIdx + 1;
            end
        end

        ieiData = ieiData*dt;
    elseif runMode == 2
        for i = (prevEvent + 1):numel(events)
            if events(i)
                ieiData(ieiIdx)  = i - prevEvent;
                ieiTimes(ieiIdx) = t(i) - t(prevEvent); 
                prevEvent = i;
                ieiIdx = ieiIdx + 1;
            end
        end        
        ieiData  = ieiData(ieiTimes > 0);
        ieiTimes = ieiTimes(ieiTimes > 0);
        
    end

end