function [G, V, t] = applyConditions(G, V, t, conditions)
%{
    Applies conditions as specified by the conditions struct to the
    conductance (G), voltage (V) and time (t) time-series

%}

    if ~isfield(conditions, 'type')
        conditions.type = 'none';
    end
    
    I = 1:numel(G);
    
    switch conditions.type
        case 'crossing'
            I = subTimeseries(G, conditions.after, conditions.thresh);
    end

    G = G(I);
    if numel(V) > 1
        V = V(I);
    end
    t = t(I);

end