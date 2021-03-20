function [G, V, t, I] = applyConditions(G, V, t, conditions)
%{
    Applies conditions as specified by the conditions struct to the
    conductance (G), voltage (V) and time (t) time-series
    
    e.g. 
    conditions = struct('type','crossing','after',true,'thresh'1e-6)
    conditions = struct('type','tInterval','lc', 1, 'uc', 5)
    
%}

    G = reshape(G, [numel(G),1]);
    t  = reshape(t, [numel(t),1]);
    V = reshape(V, [numel(V),1]);    

    dG = gradient(G);
    
    if ~isfield(conditions, 'type')
        conditions.type = 'none';
    end
    
    I = 1:numel(G);
    
    switch conditions.type
        case 'crossing'
            I = subTimeseries(G, conditions.after, conditions.thresh);
        case 'tInterval'
            I = extractInterval(t, conditions.lc, conditions.uc, false);
        case 'GInterval'
            I = extractInterval(G, conditions.lc, conditions.uc, false);  
        case 'Gchange'
            I =  changeInterval(G, conditions.thresh);
        case 'dGGchange'
            I =  extractInterval(abs(dG./G), conditions.thresh, inf, true);            
    end

    G = G(I);
    if numel(V) > 1
        V = V(I);
    end
    t = t(I);

end