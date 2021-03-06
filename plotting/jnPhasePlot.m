function jnPhasePlot(sim, jn, trange, type)
%sim - struct containing lambda and V
%jn  - junction between switches 
%trange - [tmin, tmax] 
    

    timeVec = sim.dt:sim.dt:sim.T;
    %find starting and ending times
    
    if nargin >= 3 && ~isempty(trange)
        tl = find(trange(1) <= timeVec, 1);
        tu = find(trange(2) <= timeVec, 1);
        if numel(tu) == 0
            tu = numel(timeVec);
        end
    else
        tl = 1;
        tu = numel(timeVec); 
    end
    
    if nargin < 4
        type = 1;
    end
    
    figure;
    hold on;
    for i = 1:numel(jn)
        cb = phasePlot((sim.swV(tl:tu, jn(i))) , (sim.swLam(tl:tu, jn(i))) , [tl, tu], type);
        if ~isempty(cb)
            set(get(cb,'Title'),'String','timestep')
        end
        
        xlabel(strcat(' Voltage (V)'))
        ylabel(strcat(' \lambda (Vs)'))
        leg{i} = strcat('jn - ', num2str(jn(i)));
    end
    legend(leg);
    
    
    
    
end