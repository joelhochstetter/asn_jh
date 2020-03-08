function ieiData = IEI(events, dt)
%{
    Calculates inter-event interval given  binarised
    time-series data and time-step
%}

    ieiData = [];
    ieiIdx = 1;
    prevEvent = find(events, 1);
    
    for i = (prevEvent + 1):numel(events)
        if events(i)
            ieiData(ieiIdx) = i - prevEvent;
            prevEvent = i;
            ieiIdx = ieiIdx + 1;
        end
    end
    
    ieiData = ieiData*dt;


end