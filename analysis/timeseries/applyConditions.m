function [G, V, t, I] = applyConditions(G, V, t, conditions)
%{
    Applies conditions as specified by the conditions struct to the
    conductance (G), voltage (V) and time (t) time-series
    
    e.g. 
    conditions = struct('type','crossing','after',true,'thresh'1e-6)
    conditions = struct('type','tInterval','lc', 1, 'uc', 5)
    
%}

    if ~isfield(conditions, 'type')
        conditions.type = 'none';
    end
    
    I = 1:numel(G);
    
    switch conditions.type
        case 'crossing'
            I = subTimeseries(G, conditions.after, conditions.thresh);
        case 'tInterval'
            I = extractInterval(t, conditions.lc, conditions.uc);
        case 'GInterval'
            I = extractInterval(G, conditions.lc, conditions.uc);            
    end

    G = G(I);
    if numel(V) > 1
        V = V(I);
    end
    t = t(I);

end