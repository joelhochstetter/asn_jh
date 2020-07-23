function events = findEventsFromFilState(sim, eventDetect)
%{
                 sim: Imported simulation
    eventDetect: struct

    returns vector: events of same length as time-series
%}

    defEvDet.method = 'conductanceRatio';  % 'conductanceRatio'  /  'conductanceCrossing' / 'voltageSpike'
    defEvDet.conductanceRatio  = 1.1; %ratio for conductance ratio
    defEvDet.conductancePower = 2.0; %ratio for conductance ratio
    defEvDet.dLamdtThreshold   = 1e-2; %|dlambda/dt| >= 1e-2 threshold
    
    fields = fieldnames(defEvDet);
    for i = 1:numel(fields)
        if isfield(eventDetect, fields{i}) == 0
            eventDetect.(fields{i}) = defEvDet.(fields{i});
        end
    end

    d = (sim.Comp.critFlux - abs(sim.swLam))*5/sim.Comp.critFlux;
    d(d < 0.0) = 0.0;
    switchC = tunnelSwitchL(d, 0.81, 0.17, sim.Comp.offR, sim.Comp.onR);
    
    switch eventDetect.method 
        case 'conductanceRatio'    
            onOrOff   = switchC > eventDetect.conductanceRatio*sim.Comp.offR;
            changeOnOrOff = abs(onOrOff(2:end,:) - onOrOff(1:end - 1,:));            
            events = sum(changeOnOrOff,2);
        case 'conductanceCrossing'
            onOrOff   = floor(log(switchC/sim.Comp.offR)/log(eventDetect.conductancePower));
            changeOnOrOff = abs(onOrOff(2:end,:) - onOrOff(1:end - 1,:)) > 0;            
            events = sum(changeOnOrOff,2);            
        case 'voltageSpike'
            dlamdt = abs(sim.swLam(2:end,:) - sim.swLam(1:end - 1,:))/sim.dt;
            spike    = dlamdt > eventDetect.dLamdtThreshold;
            dlamdt(~spike) = 0.0; %remove peaks below threshold   
            events = zeros(size(sim.netC));                
            for jn = 1:size(sim.swLam, 2)
                evEdg  = find(~spike(:,jn)); %edges for avalanches
                E = numel(evEdg) - 1;
                for ev = 1:E
                    %find max of each sequence of nonzero activity
                    if (evEdg(ev+1) - evEdg(ev)) > 1
                        [~,maxE] = max(dlamdt(evEdg(ev):evEdg(ev+1),jn));
                        tm = evEdg(ev) + maxE - 1;
                        events(tm) = events(tm) + 1;
                    end
                end
            end
    end
    
    events = [events ; 0];
end